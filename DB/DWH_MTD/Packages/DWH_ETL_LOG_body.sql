/*-----------------------------------------------------------------------------
|| DDL for Package Body DWH_ETL_LOG
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE PACKAGE BODY "DWH_MTD"."DWH_ETL_LOG"
AS


  PROCEDURE SET_RUNNING (
      I_ODI_ID                IN NUMBER,
      I_DWH_DELTA_DATE            IN DATE,
      I_SCHEMA_NAME           IN VARCHAR2,
      I_TABLE_NAME            IN VARCHAR2,
      I_MAPPING_NAME          IN VARCHAR2,
      I_SRC_DELTA_TYPE        IN VARCHAR2 DEFAULT NULL,
      I_LOW_WM_SRC_DELTA      IN VARCHAR2 DEFAULT NULL,
      I_HIGH_WM_SRC_DELTA     IN VARCHAR2 DEFAULT NULL,
      I_ODI_ID_PARENT         IN NUMBER  DEFAULT NULL
      )  IS
      PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

    INSERT INTO DWH_MTD.ETL_DELTA_LOG (odi_id, dwh_delta_date, usage, schema_name,
                                       table_name, mapping_name, status, low_watermark_src_delta, high_watermark_src_delta,
                                       src_delta_type, exec_owner, created_at, odi_id_parent)
    VALUES
    (
      I_ODI_ID,
      I_DWH_DELTA_DATE,
      1,
      I_SCHEMA_NAME,
      I_TABLE_NAME,
      I_MAPPING_NAME,
      'running',
      I_LOW_WM_SRC_DELTA,
      I_HIGH_WM_SRC_DELTA,
      I_SRC_DELTA_TYPE,
	  SYS_CONTEXT ('USERENV', 'SESSION_USER'),
      sysdate,
      I_ODI_ID_PARENT
    );

    COMMIT;

  EXCEPTION
  WHEN OTHERS THEN

    ROLLBACK;
    RAISE;

  END SET_RUNNING;


  PROCEDURE SET_SUCCESS (
      I_ODI_ID                IN NUMBER,
      I_ROWS                  IN NUMBER DEFAULT NULL
      )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

    UPDATE DWH_MTD.ETL_DELTA_LOG
    SET STATUS    = 'success', PROCESSED_ROWS = I_ROWS, updated_at = sysdate
    WHERE ODI_ID  = I_ODI_ID;
    COMMIT;

  EXCEPTION
  WHEN OTHERS THEN

    ROLLBACK;
    RAISE;

  END SET_SUCCESS;


  PROCEDURE SET_ERROR (
      I_ODI_ID                IN NUMBER,
      I_ROWS                  IN NUMBER DEFAULT NULL
      )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

    UPDATE DWH_MTD.ETL_DELTA_LOG
    SET STATUS    = 'error', PROCESSED_ROWS = I_ROWS, updated_at = sysdate
    WHERE ODI_ID  = I_ODI_ID
      AND STATUS = 'running';
    COMMIT;

  EXCEPTION
  WHEN OTHERS THEN

    ROLLBACK;
    RAISE;

  END SET_ERROR;

  PROCEDURE SET_ERROR_FROM_LOADPLAN (
      I_ODI_LOADPLAN_GUID                IN VARCHAR2,
      I_RUN_NUMBER                       IN NUMBER DEFAULT 1
      )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;
  BEGIN

    UPDATE DWH_MTD.ETL_DELTA_LOG
    SET STATUS    = 'error', UPDATED_AT = sysdate
    WHERE ODI_ID  in (

        SELECT sess_no
          FROM ODIEBIV_ODI_REPO.SNP_LP_INST li
          JOIN ODIEBIV_ODI_REPO.SNP_LPI_STEP_LOG lr on li.i_lp_inst = lr.i_lp_inst
           WHERE li.global_id = I_ODI_LOADPLAN_GUID
            AND lr.nb_run = I_RUN_NUMBER
            AND lr.status = 'E'
            AND lr.sess_no is not null

        UNION ALL

        SELECT se.sess_no
          FROM ODIEBIV_ODI_REPO.SNP_LP_INST li
          JOIN ODIEBIV_ODI_REPO.SNP_LPI_STEP_LOG lr on li.i_lp_inst = lr.i_lp_inst
          JOIN ODIEBIV_ODI_REPO.SNP_SESSION se on lr.sess_no = se.parent_sess_no
          WHERE li.global_id = I_ODI_LOADPLAN_GUID
            AND lr.nb_run = I_RUN_NUMBER
            AND se.sess_status = 'E'
            )
        AND STATUS = 'running';

    COMMIT;

  EXCEPTION
  WHEN OTHERS THEN

    ROLLBACK;
    RAISE;

  END SET_ERROR_FROM_LOADPLAN;


  PROCEDURE CLEAR_STAGE (
      I_STAGE_SCHEMA                    IN VARCHAR2,
      I_PSA_SCHEMA                      IN VARCHAR2
      )
  IS
    PRAGMA AUTONOMOUS_TRANSACTION;

    l_sql   VARCHAR2(4000);
    l_days_to_keep NUMBER;

  BEGIN

    SELECT NUMBER_VALUE
      INTO l_days_to_keep
      FROM DWH_MTD.ETL_CONFIGURATION
     WHERE PROCESS_NAME = 'BEDIAN' AND CONFIGURATION = 'Tage_Stage_behalten';

      FOR curs IN (
                  Select table_name, day_delta from (
                   select table_name, trunc(dwh_delta_date) day_delta, max(status) day_status from (

                       select stg.table_name, stg.dwh_delta_date, decode(psa.status,'success', '1_success', '2_no_success') status
                        from DWH_MTD.etl_delta_log stg
                   left join DWH_MTD.etl_delta_log psa
                          on (stg.dwh_delta_date = psa.dwh_delta_date
                              AND psa.schema_name = I_PSA_SCHEMA
                              AND stg.table_name = psa.table_name
                              AND psa.status = 'success'
                              AND psa.usage = 1
                             )
                      where stg.schema_name = I_STAGE_SCHEMA
                        and stg.status = 'success'
                        and stg.processed_rows > 0
						AND stg.usage = 1
                         and stg.dwh_delta_date < trunc(sysdate+1) - l_days_to_keep
                       ) group by table_name, trunc(dwh_delta_date)
                  ) where day_status = '1_success' order by table_name, day_delta)
      LOOP

        l_sql := 'BEGIN ' || I_STAGE_SCHEMA || '.dwh_schema_tools.drop_partition_by_value(''' || curs.table_name || ''', ''' || curs.day_delta || '''); END;';
        EXECUTE IMMEDIATE l_sql;


        UPDATE DWH_MTD.ETL_DELTA_LOG
        SET STATUS    = 'cleared', UPDATED_AT = sysdate
        WHERE SCHEMA_NAME = I_STAGE_SCHEMA
          and TABLE_NAME = curs.table_name
          and TRUNC(DWH_DELTA_DATE) = curs.day_delta
          and STATUS = 'success'
          and PROCESSED_ROWS > 0;

        COMMIT;

      END LOOP;

  EXCEPTION
  WHEN OTHERS THEN

    ROLLBACK;
    RAISE;

  END CLEAR_STAGE;

  FUNCTION GET_LAST_HIGH_WM_SRC_DELTA (
      I_SCHEMA_NAME           IN VARCHAR2,
      I_TABLE_NAME            IN VARCHAR2)
    RETURN VARCHAR2
  is
    v_high_watermark VARCHAR2(30);

  BEGIN

    SELECT max(HIGH_WATERMARK_SRC_DELTA) KEEP (DENSE_RANK FIRST ORDER BY CREATED_AT desc)
    INTO v_high_watermark
    FROM DWH_MTD.ETL_DELTA_LOG
    WHERE 1=1
      AND SCHEMA_NAME   = I_SCHEMA_NAME
      AND TABLE_NAME    = I_TABLE_NAME
      AND STATUS        in ('success','cleared')
      AND USAGE         = 1;

    RETURN v_high_watermark;

  END GET_LAST_HIGH_WM_SRC_DELTA;

  FUNCTION GET_LAST_DELTA_DATE (
      I_SCHEMA_NAME           IN VARCHAR2,
      I_TABLE_NAME            IN VARCHAR2,
      I_MAPPING_NAME          IN VARCHAR2)
    RETURN DATE
  IS
    v_delta_date DATE;

  BEGIN

    SELECT MAX(edl.DWH_DELTA_DATE)
      INTO v_delta_date
      FROM DWH_MTD.ETL_DELTA_LOG edl
     WHERE 1=1
       AND edl.SCHEMA_NAME  = I_SCHEMA_NAME
       AND edl.TABLE_NAME   = I_TABLE_NAME
       AND edl.MAPPING_NAME = I_MAPPING_NAME
       AND edl.STATUS        = 'success'
       AND edl.USAGE       = 1
       and not exists ( select 1 from DWH_MTD.ETL_DELTA_LOG edl_child where edl_child.odi_id_parent = edl.odi_id and edl_child.status <> 'success');

    v_delta_date := NVL(v_delta_date,to_date('01.01.1111','DD.MM.YYYY'));

    RETURN v_delta_date;

  END GET_LAST_DELTA_DATE;

  FUNCTION GET_NEXT_DELTA_DATE (
      I_SOURCE_TAB_LIST       IN VARCHAR2,
      I_SCHEMA_NAME           IN VARCHAR2 DEFAULT NULL,
      I_TABLE_NAME            IN VARCHAR2 DEFAULT NULL,
      I_MAPPING_NAME          IN VARCHAR2 DEFAULT NULL
      )
    RETURN DATE
  IS
    v_delta_date DATE;

  BEGIN

    SELECT min(DWH_DELTA_DATE)
      INTO v_delta_date
      FROM DWH_MTD.ETL_DELTA_LOG
     WHERE 1=1
       AND instr(';' || I_SOURCE_TAB_LIST || ';', ';' || SCHEMA_NAME || '.' || TABLE_NAME || ';') > 0
       AND STATUS = 'success'
       AND PROCESSED_ROWS > 0
	   AND USAGE = 1
       AND DWH_DELTA_DATE >
           get_last_delta_date(I_SCHEMA_NAME, I_TABLE_NAME, I_MAPPING_NAME);

    RETURN v_delta_date;

  END GET_NEXT_DELTA_DATE;

  FUNCTION GET_MAX_SRC_DELTA_DATE (
      I_SOURCE_TAB_LIST       IN VARCHAR2,
      I_SCHEMA_NAME           IN VARCHAR2 DEFAULT NULL,
      I_TABLE_NAME            IN VARCHAR2 DEFAULT NULL,
      I_MAPPING_NAME          IN VARCHAR2 DEFAULT NULL
      )
    RETURN DATE
  IS
    v_delta_date DATE;
    v_max_date DATE;
    v_par_max_date varchar2(100 char);

  BEGIN
    v_par_max_date := dwh_tools.get_param('MAX_HIGH_WATERMARK');


    SELECT max(DWH_DELTA_DATE)
    INTO v_delta_date
      FROM DWH_MTD.ETL_DELTA_LOG
     WHERE 1=1
       AND instr(';' || I_SOURCE_TAB_LIST || ';', ';' || SCHEMA_NAME || '.' || TABLE_NAME || ';') > 0
       AND STATUS = 'success'
       AND PROCESSED_ROWS > 0
	   AND USAGE = 1
       AND DWH_DELTA_DATE >
           get_last_delta_date(I_SCHEMA_NAME, I_TABLE_NAME, I_MAPPING_NAME);

    --Wert auf MAX_HIGH_WATERMARK beschränken, ermöglicht z.B. Initial-Beladung nicht bis sysdate
    if v_par_max_date <> '-' and v_par_max_date is not null then
       v_max_date := to_date(v_par_max_date, 'DD.MM.YYYY HH24:MI_SS');
    else
       v_max_date := to_date('99991231','YYYYMMDD');
    end if;
    v_delta_date := least(v_delta_date, v_max_date);

    RETURN v_delta_date;

  END GET_MAX_SRC_DELTA_DATE;


  FUNCTION GET_DELTA_DATE_FROM_LOG (
      I_ODI_ID                IN NUMBER
      )
    RETURN DATE
  IS
    v_delta_date DATE;

  BEGIN

    SELECT DWH_DELTA_DATE
      INTO v_delta_date
      FROM DWH_MTD.ETL_DELTA_LOG
     WHERE 1=1
       AND ODI_ID = I_ODI_ID;

    RETURN v_delta_date;

  END GET_DELTA_DATE_FROM_LOG;


  FUNCTION GET_ODI_SESS_INS_UPD (
      I_ODI_ID                IN NUMBER
      )
    RETURN NUMBER
  IS
    v_rows  NUMBER;

  BEGIN

    SELECT sum(NB_INS + NB_UPD)
      INTO v_rows
      FROM ODIEBIV_ODI_REPO.SNP_SESS_TASK_LOG
     WHERE 1=1
       AND SESS_NO = I_ODI_ID
       AND TASK_NAME3 IS NOT NULL;

    RETURN v_rows;

  END GET_ODI_SESS_INS_UPD;



  PROCEDURE SET_PARAMETER (
      I_PARAMETER_NAME        IN VARCHAR2,
      I_CHAR_VALUE_1          IN VARCHAR2 DEFAULT NULL,
      I_CHAR_VALUE_2          IN VARCHAR2 DEFAULT NULL,
      I_DATE_VALUE_1          IN DATE DEFAULT NULL,
      I_DATE_VALUE_2          IN DATE DEFAULT NULL,
      I_NUMBER_VALUE_1        IN NUMBER DEFAULT NULL,
      I_NUMBER_VALUE_2        IN NUMBER DEFAULT NULL,
      I_PARAMETER_DESCRIPTION IN VARCHAR2 DEFAULT NULL
  )
      IS
    PRAGMA AUTONOMOUS_TRANSACTION;

  BEGIN

    MERGE INTO DWH_MTD.ETL_PARAMETER tgt
    USING (SELECT I_PARAMETER_NAME          PARAMETER_NAME,
                  I_CHAR_VALUE_1            CHAR_VALUE_1,
                  I_CHAR_VALUE_2            CHAR_VALUE_2,
                  I_DATE_VALUE_1            DATE_VALUE_1,
                  I_DATE_VALUE_2            DATE_VALUE_2,
                  I_NUMBER_VALUE_1          NUMBER_VALUE_1,
                  I_NUMBER_VALUE_2          NUMBER_VALUE_2,
                  I_PARAMETER_DESCRIPTION   PARAMETER_DESCRIPTION
            FROM DUAL) src
    ON (tgt.PARAMETER_NAME = src.PARAMETER_NAME)
    WHEN MATCHED THEN UPDATE
      SET tgt.CHAR_VALUE_1 = src.CHAR_VALUE_1,
          tgt.CHAR_VALUE_2 = src.CHAR_VALUE_2,
          tgt.DATE_VALUE_1 = src.DATE_VALUE_1,
          tgt.DATE_VALUE_2 = src.DATE_VALUE_2,
          tgt.NUMBER_VALUE_1 = src.NUMBER_VALUE_1,
          tgt.NUMBER_VALUE_2 = src.NUMBER_VALUE_2,
          tgt.UPDATED_AT = sysdate,
          tgt.UPDATED_BY = SYS_CONTEXT ('USERENV', 'SESSION_USER')
    WHEN NOT MATCHED THEN INSERT
      (PARAMETER_NAME,
       CHAR_VALUE_1,
       CHAR_VALUE_2,
       DATE_VALUE_1,
       DATE_VALUE_2,
       NUMBER_VALUE_1,
       NUMBER_VALUE_2,
       PARAMETER_DESCRIPTION,
       CREATED_AT,
       CREATED_BY)
    VALUES (
       src.PARAMETER_NAME,
       src.CHAR_VALUE_1,
       src.CHAR_VALUE_2,
       src.DATE_VALUE_1,
       src.DATE_VALUE_2,
       src.NUMBER_VALUE_1,
       src.NUMBER_VALUE_2,
       src.PARAMETER_DESCRIPTION,
       sysdate,
       SYS_CONTEXT ('USERENV', 'SESSION_USER'))
    ;
    COMMIT;

  EXCEPTION
  WHEN OTHERS THEN

    ROLLBACK;
    RAISE;

  END SET_PARAMETER;


  PROCEDURE SET_PARAMETER_SCEN_VERSION (
      I_MAPPING_NAME        IN VARCHAR2
  )
    IS
      v_scen_version      varchar2(35);
      v_scen_snapshot_no  number;
  BEGIN

    SELECT scen_version, scen_snapshot_no
      INTO v_scen_version, v_scen_snapshot_no
      FROM (
        SELECT scen_name, scen_version, scen_snapshot_no, row_number() over (partition by scen_name order by scen_version desc) ord from ODIEBIV_ODI_REPO.SNP_SCEN
         WHERE scen_name = I_MAPPING_NAME
      ) WHERE ord = 1;


    SET_PARAMETER (
        I_PARAMETER_NAME  => I_MAPPING_NAME || '_current_version',
        I_CHAR_VALUE_1    => v_scen_version,
        I_NUMBER_VALUE_1    => v_scen_snapshot_no
      );


  EXCEPTION
  WHEN OTHERS THEN

    ROLLBACK;
    RAISE;

  END SET_PARAMETER_SCEN_VERSION;


  FUNCTION IS_SCEN_VERSION_PARAM_ACTUAL (
      I_MAPPING_NAME        IN VARCHAR2
  )
  RETURN CHAR
  IS
    v_count number;
  BEGIN


      SELECT count(*)
       INTO v_count
      FROM (
        SELECT scen_name, scen_version, scen_snapshot_no, row_number() over (partition by scen_name order by scen_version desc) ord from ODIEBIV_ODI_REPO.SNP_SCEN
         WHERE scen_name = I_MAPPING_NAME
      ) WHERE ord = 1
          AND (scen_version, scen_snapshot_no) IN (SELECT CHAR_VALUE_1, NUMBER_VALUE_1 FROM DWH_MTD.ETL_PARAMETER WHERE PARAMETER_NAME = I_MAPPING_NAME || '_current_version' );

    IF v_count = 1 THEN
      return 'Y';
    ELSE
      return 'N';
    END IF;

  EXCEPTION
  WHEN OTHERS THEN

    ROLLBACK;
    RAISE;

  END IS_SCEN_VERSION_PARAM_ACTUAL;


END DWH_ETL_LOG;
/

