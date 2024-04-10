/*-----------------------------------------------------------------------------
|| DDL for Package Body PCK_ETL_TEST
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE PACKAGE BODY "DWH_MTD"."PCK_ETL_TEST" IS

  /*  PCK_ETL_TEST
      Package to run ETL unit / set tests periodically.
      See package header for README.
      See git for version information   */

  PROCEDURE ins_run(
      p_CONFIG     IN dwh_mtd.TST_RUN.CONFIG%type ,
      p_RUN_BEGIN  IN dwh_mtd.TST_RUN.RUN_BEGIN%type DEFAULT NULL ,
      p_RUN_END    IN dwh_mtd.TST_RUN.RUN_END%type DEFAULT NULL ,
      p_GRADE      IN dwh_mtd.TST_RUN.GRADE%type DEFAULT NULL ,
      p_DELTA_DATE IN dwh_mtd.TST_RUN.DELTA_DATE%type DEFAULT NULL ,
      p_RESULT     IN dwh_mtd.TST_RUN.RESULT%type DEFAULT NULL,
      p_error      IN  dwh_mtd.TST_RUN.ERROR%type DEFAULT NULL,
      p_remark     IN  dwh_mtd.TST_RUN.REMARK%type DEFAULT NULL,
      p_sql_id     IN dwh_mtd.tst_run.sql_id%type default null,
      p_sql_plan   IN dwh_mtd.tst_run.sql_plan%type default null)
  IS
  BEGIN
    INSERT
    INTO dwh_mtd.TST_RUN
      (
        CONFIG ,
        RUN_BEGIN ,
        RUN_END ,
        GRADE ,
        DELTA_DATE ,
        RESULT,
        error,
        remark,
        sql_id,
        sql_plan
      )
      VALUES
      (
        p_CONFIG ,
        p_RUN_BEGIN ,
        p_RUN_END ,
        p_GRADE ,
        p_DELTA_DATE ,
        p_RESULT,
        p_error,
        p_remark,
        p_sql_id,
        p_sql_plan
      );
      commit;
  END;

  PROCEDURE upd_run
    (
      p_CONFIG     IN dwh_mtd.TST_RUN.CONFIG%type ,
      p_RUN_BEGIN  IN dwh_mtd.TST_RUN.RUN_BEGIN%type DEFAULT NULL ,
      p_RUN_END    IN dwh_mtd.TST_RUN.RUN_END%type DEFAULT NULL ,
      p_GRADE      IN dwh_mtd.TST_RUN.GRADE%type DEFAULT NULL ,
      p_ID         IN dwh_mtd.TST_RUN.ID%type ,
      p_DELTA_DATE IN dwh_mtd.TST_RUN.DELTA_DATE%type DEFAULT NULL ,
      p_error       IN  dwh_mtd.TST_RUN.ERROR%type DEFAULT NULL,
      p_RESULT     IN dwh_mtd.TST_RUN.RESULT%type DEFAULT NULL,
      p_remark    IN  dwh_mtd.TST_RUN.REMARK%type DEFAULT NULL
    )
  IS
  BEGIN
    UPDATE dwh_mtd.TST_RUN
    SET CONFIG   = p_CONFIG ,
      RUN_BEGIN  = p_RUN_BEGIN ,
      RUN_END    = p_RUN_END ,
      GRADE      = p_GRADE ,
      DELTA_DATE = p_DELTA_DATE ,
      RESULT     = p_RESULT,
      ERROR      = p_error,
      REMARK     = p_remark
    WHERE ID     = p_ID;
    commit;
  END;

  PROCEDURE del_run(
      p_ID IN dwh_mtd.TST_RUN.ID%type )
  IS
  BEGIN
    DELETE FROM dwh_mtd.TST_RUN WHERE ID = p_ID;
  END;

  function timestamp_diff(a timestamp, b timestamp) return number as
  begin
  return extract (day    from (a-b))*24*60*60 +
         extract (hour   from (a-b))*60*60+
         extract (minute from (a-b))*60+
         extract (second from (a-b));
  end;

  procedure run_test (
      p_config      in number,
      p_result      out varchar
                      )
  is

      run_begin   timestamp;
      run_end     timestamp;
      grade       varchar(255);
      id          number;
      v_result    number;
      v_system    varchar(100);
      t_system    varchar(100);
      sql_text    clob;
      v_threshold number;
      v_error_nr  varchar2(1024);
      v_error_txt varchar2(1024);
      v_error_msg varchar2(256);
      v_def_id    number;
      v_testtype  varchar(20);
      v_remark    varchar(1024);
      v_restext   clob;
      v_sql_id    varchar2(13);
      v_sql_plan  clob;

  PRAGMA AUTONOMOUS_TRANSACTION;

  begin

    select global_name into v_system from global_name;
    select system into t_system from dwh_mtd.tst_cnf where id = p_config;
    select threshold into v_threshold from dwh_mtd.tst_cnf where id = p_config;
    select test into v_def_id from dwh_mtd.tst_cnf where id = p_config;
    select type into v_testtype from dwh_mtd.tst_def where id = v_def_id;

    if

      (v_system = t_system or t_system = 'ALL') and (v_testtype = 'SQL')

    then

      run_begin := systimestamp;

      select testcode_nr into sql_text from dwh_mtd.tst_def
        where id = v_def_id;

      begin
        execute immediate sql_text into v_result;
      exception
        when others then v_error_nr := SQLERRM;
      end;

      run_end := systimestamp;

      -- write execution plan for NR statement in log table variable
      FOR source_r IN ( select plan_table_output from table(DBMS_XPLAN.DISPLAY_CURSOR()) )
      LOOP
        v_sql_plan := v_sql_plan || chr(10) || source_r.plan_table_output;
      END LOOP;

      -- snip chars from displaycursor output into sql_id
      v_sql_id := substr(v_sql_plan,10,13);

      if v_result is null then
        grade := 'NOVAL: Got: NULL Max: '||v_threshold||'.';
      end if;

      if v_threshold >= 0 then   -- positive threshold

          if
            v_result <= v_threshold
          then
            grade := 'PASSED: Got: '||round(v_result,2)||' Max: '||v_threshold||'.';
          else
            grade := 'FAILED: Got: '||round(v_result,3)||' Max: '||v_threshold||'.';
          end if;

      else                      -- negative threshold (minimum value meant)

          if
            v_result >= abs(v_threshold)
          then
            grade := 'PASSED: Got: '||round(v_result,2)||' Min: '||abs(v_threshold)||'.';
          else
            grade := 'FAILED: Got: '||round(v_result,3)||' Min: '||abs(v_threshold)||'.';
          end if;

      end if;

      select testcode_txt into sql_text from dwh_mtd.tst_def
        where id = v_def_id;

      if sql_text is not null then

          begin
            execute immediate sql_text into v_restext;
          exception
            when others then v_error_txt := SQLERRM;
          end;

      end if;

      v_remark := substr(v_restext,1,1024);

      if v_error_nr is not null or v_error_txt is not null then
        v_error_msg := 'NR: ' || nvl(v_error_nr,'no error') ||', TXT: ' || nvl(v_error_txt,'no error');
        v_error_msg := substr(v_error_msg,1,255);
      end if;

      ins_run(
        p_CONFIG    => p_config,
        p_RUN_BEGIN => run_begin,
        p_RUN_END   => run_end,
        p_GRADE     => grade,
        p_RESULT    => v_result,
        p_error     => v_error_msg,
        p_remark    => v_remark,
        p_sql_id    => v_sql_id,
        p_sql_plan  => v_sql_plan
        );

    end if;

    p_result := 'Ran config '||p_config||'. Result: '||v_result||'.';

  end;

  procedure run_all
  is
    cursor cnf_id_cur
        is
           select id
            from dwh_mtd.tst_cnf
            where active = 1;
    l_cnf_id    cnf_id_cur%ROWTYPE;
    x_result    varchar2(2000);
  begin
    open cnf_id_cur;
    loop
      fetch cnf_id_cur into l_cnf_id;
      exit when cnf_id_cur%NOTFOUND;
      run_test(l_cnf_id.id, x_result);
    end loop;
    close cnf_id_cur;
  end;

  procedure add_new_test

      (
        p_name in varchar,
        p_system in varchar,
        p_testcode_nr in varchar,
        p_testcode_txt in varchar,
        p_description in varchar,
        p_threshold in number,
        p_remark in varchar,
        p_active number,
        p_schema in varchar,
        p_runschema in varchar,
        p_type in varchar,
        p_result out varchar
      )

  is

        v_type varchar2(20);
        v_runschema varchar2(255);
        v_schema varchar2(255);
        v_threshold number;
        e_sql exception;
        e_param exception;
        v_result varchar2(1000);
        v_err_reason varchar2(1000);
        v_testdef_id number;
        v_active  number;
        v_system varchar2(100);
        e_testexists exception;
        e_internal exception;
        v_cnf_rem varchar2(25);
        v_def_desc varchar2(1000);

    begin

      v_type := nvl(p_type, 'SQL');
      v_runschema := nvl(p_runschema, 'DWH_WORK');
      v_threshold := nvl(p_threshold, 0);
      v_active := nvl(p_active, 1);
      v_system := nvl(p_system,'ALL');
      v_cnf_rem := nvl(p_remark,'Autocreated');
      v_def_desc := nvl(p_description,'Autocreated by add_new_test');

      if p_name is null then
        v_err_reason := 'Parameter p_name cannot be empty.';
        raise e_param;
      end if;
      if p_testcode_nr is null then
        v_err_reason := 'Parameter p_testcode_nr cannot be empty.';
        raise e_param;
      end if;

      begin
            INSERT
            INTO DWH_MTD.TST_DEF
              (
                SCHEMA ,
                DESCRIPTION ,
                TESTCODE_NR ,
                TYPE ,
                TESTCODE_TXT ,
                NAME
              )
              VALUES
              (
                p_schema ,
                v_def_desc ,
                p_testcode_nr ,
                v_type ,
                p_testcode_txt ,
                p_name
              );
              commit;
      exception
        when DUP_VAL_ON_INDEX then raise e_testexists;
        when others then raise e_sql;
      end;

      begin
            select id into v_testdef_id from DWH_MTD.TST_DEF
              where (name = p_name and type = v_type and (nvl(schema,'-') = nvl(p_schema,'-')));
      exception
        when NO_DATA_FOUND then raise e_internal;
        when others then raise e_sql;
      end;

      begin
        INSERT
        INTO dwh_mtd.TST_CNF
          (
            SYSTEM ,
            THRESHOLD ,
            ACTIVE ,
            TEST ,
            RUN_SCHEMA ,
            remark
          )
          VALUES
          (
            v_SYSTEM ,
            v_threshold ,
            v_active ,
            v_testdef_id ,
            v_runschema ,
            v_cnf_rem
          );
          commit;
      exception
        when others then raise e_sql;
      end;

      if v_active = 1 then
        p_result := 'Sucessfully inserted test '||p_name||' as ID '||v_testdef_id||' (active).';
      else
        p_result := 'Sucessfully inserted test '||p_name||' as ID '||v_testdef_id||' (test is still INactive).';
      end if;

    exception
      when e_sql then p_result := 'ERROR: SQL error: '||SQLERRM;
      when e_param then p_result := 'ERROR: Parameter error: '||v_err_reason;
      when e_testexists then p_result := 'ERROR: Test already exists.';
      when e_internal then p_result := 'ERROR: Internal error with test definition for '||p_name||'.';
    end;

END PCK_ETL_TEST;
/

