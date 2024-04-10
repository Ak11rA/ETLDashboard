/*-----------------------------------------------------------------------------
|| DDL for Package Body DWH_GENERATOR
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE PACKAGE BODY "DWH_MTD"."DWH_GENERATOR"

  AS

  gc_scope_prefix   CONSTANT VARCHAR2(31) 	:= lower($$plsql_unit) || '.';
  gc_newline        CONSTANT VARCHAR2(1) 	:= chr(10);

  procedure dmesg (
    p_text      in varchar2,
    p_scope		in varchar2 default 'GroovyGenerator',
    p_severity  in number default 0,
    p_content   in clob default null
    ) is
    -- Source: https://stash.loopback.org/projects/LDEV/repos/dbatools/browse/DBATOOLS.sql
    pragma autonomous_transaction;
    begin
        /* dbms_output.put_line(
              sysdate       || '|' ||
              p_severity    || '|' ||
              p_scope       || '|' ||
              substr(p_text,0,10)
          ); */
          -- no more console logging due to ORU-10027: buffer overflow, limit of 20000 bytes,
          -- see https://asktom.oracle.com/pls/apex/f?p=100:11:0::::P11_QUESTION_ID:30820403261885
    -- logging to generator log
    insert into DWH_MTD.gen_exec_log (
        scope,
        time_stamp,
        user_name,
        text,
        content
    ) VALUES (
        p_scope,
        systimestamp,
        user,
        p_text,
        p_content
    );
    -- logging to general log
    insert into DWH_MTD.dwh_messages(
                SCOPE
                ,SEVERITY
                ,TEXTOFMESSAGE
            ) values (
                p_SCOPE
                ,p_SEVERITY
                ,to_clob(p_text)
    );
    commit;
  end;

  PROCEDURE get_objects (
      i_src_system_alias    IN VARCHAR2
      )
  IS
    l_scope             gen_exec_log.scope%type   :=  gc_scope_prefix || 'get_objects';
    v_sql               varchar2(32000);
    v_processed_rows    NUMBER;

  BEGIN

      dmesg('  Reverse engineering of source data on object level', l_scope);

      FOR
		c_sources in
			(SELECT * FROM DWH_MTD.gen_source_systems where SOURCE_SYSTEM_ALIAS = i_src_system_alias)
	  LOOP

        v_sql := q'[
MERGE INTO DWH_MTD.GEN_SOURCE_OBJECTS tgt
USING (
    SELECT CASE
             WHEN ins_close.cdc_method = 'CLOSE' THEN GEN_SOURCE_OBJECTS_ID
             ELSE NULL
           END GEN_SOURCE_OBJECTS_ID,
           object_name,
           object_type,
           object_description,
           object_refresh_type,
           sysdate load_date
      FROM (
        SELECT dwh.gen_source_objects_id,
               NVL(src_mtd.object_name, dwh.object_name) object_name,
               CASE WHEN dwh.gen_source_objects_id IS NULL THEN 'I'
                    WHEN src_mtd.object_name IS NULL THEN 'D'
                    ELSE 'U'
               END CDC_IDENTIFIER,
               src_mtd.object_type,
               src_mtd.object_description,
               dwh.object_refresh_type
          FROM
            -- new data source set
              (SELECT object_name, object_type,
                         (SELECT comments FROM all_tab_comments@]' || c_sources.SOURCE_DATABASE_LINK || q'[ co WHERE co.owner = ao.owner and co.table_name = ao.object_name) object_description
                    FROM all_objects@]' || c_sources.SOURCE_DATABASE_LINK || q'[ ao
                   WHERE owner = ']' || c_sources.SOURCE_SCHEMA || q'[' AND object_type IN ('TABLE', 'VIEW') AND ]' || NVL(c_sources.SOURCE_OBJECT_FILTER, '1=1') || q'[
              ) src_mtd
            -- metadata already used are joined to recognize new data and ignore existing
            FULL OUTER JOIN
              (SELECT * FROM DWH_MTD.GEN_SOURCE_OBJECTS
                WHERE SOURCE_SYSTEMS_ID = ]' || c_sources.GEN_SOURCE_SYSTEMS_ID || q'[ AND VALID_TO = DWH_TOOLS.GC_END_DATE
              ) dwh
            ON src_mtd.object_name = dwh.object_name

        -- filter already existing data
        WHERE DECODE( src_mtd.object_type,        dwh.object_type,        0, 1 ) +
              DECODE( src_mtd.object_description, dwh.object_description, 0, 1 ) > 0
    ) new_data
    INNER JOIN
      (SELECT 'I' cdc_identifier, 'INSERT' cdc_method FROM DUAL UNION
       SELECT 'U' cdc_identifier, 'INSERT' cdc_method FROM DUAL UNION
       SELECT 'U' cdc_identifier, 'CLOSE' cdc_method FROM DUAL UNION
       SELECT 'D' cdc_identifier, 'CLOSE' cdc_method FROM DUAL) ins_close
       ON new_data.cdc_identifier = ins_close.cdc_identifier
) src
ON (tgt.gen_source_objects_id = src.gen_source_objects_id)
WHEN MATCHED THEN
-- close existing set
  UPDATE SET tgt.VALID_TO = load_date
WHEN NOT MATCHED THEN
-- insert new row
INSERT
  (tgt.OBJECT_NAME,
   tgt.OBJECT_TYPE,
   tgt.OBJECT_DESCRIPTION,
   tgt.OBJECT_REFRESH_TYPE,
   tgt.SOURCE_SYSTEMS_ID,
   tgt.VALID_FROM,
   tgt.VALID_TO)
VALUES
  (src.object_name,
   src.object_type,
   src.object_description,
   src.object_refresh_type,
   ]' || c_sources.GEN_SOURCE_SYSTEMS_ID || q'[,
   src.load_date,
   DWH_TOOLS.GC_END_DATE
  )]'
;

      EXECUTE IMMEDIATE v_sql;
      v_processed_rows := sql%ROWCOUNT;

      COMMIT;

    END LOOP;

      dmesg('  Number of new or closed objects: ' || v_processed_rows, l_scope);

  END get_objects;

  PROCEDURE get_columns (
      i_src_system_alias    IN VARCHAR2
      )
  IS
    l_scope             gen_exec_log.scope%type   :=  gc_scope_prefix || 'prc_get_columns';
    v_source_dbl        gen_source_systems.source_database_link%TYPE;
    v_sql               varchar2(32000);
    v_processed_rows    NUMBER;

  BEGIN

      dmesg('  Source data reverse engineering on row level', l_scope);

    SELECT source_database_link
      INTO v_source_dbl
      FROM DWH_MTD.gen_source_systems
     WHERE source_system_alias = i_src_system_alias;

        v_sql := q'[
MERGE INTO DWH_MTD.GEN_SOURCE_COLUMNS tgt
USING (
    SELECT gen_source_objects_id,
           CASE
             WHEN ins_close.cdc_method = 'CLOSE' THEN gen_source_columns_id
             ELSE NULL
           END gen_source_columns_id,
           column_name,
           column_data_type,
           column_nullable,
           column_description,
           column_function,
           -- cannot get CLOB and BLOB via database link
           NVL(synch_to_dwh, CASE WHEN column_data_type in ('BLOB','CLOB') THEN 'N' ELSE 'Y' END) synch_to_dwh,
           NVL(historize_in_psa, 'Y') historize_in_psa,
           sysdate load_date
      FROM
      (
        SELECT src_mtd.gen_source_objects_id,
               dwh.gen_source_columns_id,
               NVL(src_mtd.column_name, dwh.column_name) column_name,
               CASE WHEN dwh.gen_source_columns_id IS NULL THEN 'I'
                    WHEN src_mtd.column_name IS NULL THEN 'D'
                    ELSE 'U'
               END CDC_IDENTIFIER,
               src_mtd.column_data_type,
               src_mtd.column_nullable,
               src_mtd.column_description,
               CASE WHEN src_mtd.column_function like 'PK%' OR dwh.column_function like 'PK%'
                 THEN src_mtd.column_function
               ELSE dwh.column_function END column_function,
               dwh.synch_to_dwh,
               dwh.historize_in_psa

        FROM
        -- new source data set
            (
                SELECT gso.gen_source_objects_id
                       ,atc.column_name
                       ,atc.data_type || CASE WHEN atc.data_type = 'NUMBER' AND atc.data_precision is not NULL THEN '(' || atc.data_precision || ',' || atc.data_scale || ')'
                                              -- WHEN atc.data_type IN ('VARCHAR2', 'CHAR') THEN '(' || atc.char_length || ' ' || DECODE(atc.char_used, 'C', 'CHAR', 'B', 'BYTE') || ')'
                                              -- BEDIAN-154: Von ABBA keine BYTE Typen annehmen wegen Nicht-Unicode
                                              WHEN atc.data_type IN ('VARCHAR2', 'CHAR') THEN '(' || atc.char_length || ' ' || 'CHAR' || ')'
                                         END column_data_type
                       ,atc.nullable column_nullable
                       ,acc.comments column_description
                       ,CASE WHEN pke.position IS NOT NULL THEN 'PK_' || lpad(pke.position, 2, '0') END column_function
                FROM DWH_MTD.v_gen_dwh_tables gso
                JOIN all_tab_columns@]' || v_source_dbl || q'[ atc
                     ON atc.owner = gso.source_schema and atc.table_name = gso.object_name
                LEFT JOIN
                -- detect source systems primary key
                      ( SELECT aco.owner, aco.table_name, acc.column_name, acc.position
                          FROM all_constraints@]' || v_source_dbl || q'[ aco
                          JOIN all_cons_columns@]' || v_source_dbl || q'[ acc ON aco.constraint_name = acc.constraint_name and aco.owner = acc.owner
                         WHERE aco.constraint_type ='P'
                      ) pke ON pke.owner = gso.source_schema AND pke.table_name = gso.object_name AND pke.column_name = atc.column_name
                LEFT JOIN all_col_comments@]' || v_source_dbl || q'[ acc on acc.owner = atc.owner and acc.table_name = atc.table_name and acc.column_name = atc.column_name
                WHERE gso.source_system_alias = ']' || i_src_system_alias || q'['
                -- BEDIAN-157, Beladung über Views, hier kommen Spalten mit Länge 0 vor
                and (atc.char_length > 0 or atc.data_type not in ('VARCHAR2', 'CHAR'))
            ) src_mtd
            FULL OUTER JOIN
              (
               SELECT * FROM DWH_MTD.v_gen_dwh_columns
                WHERE source_system_alias = ']' || i_src_system_alias || q'['
              ) dwh
            ON src_mtd.gen_source_objects_id = dwh.gen_source_objects_id AND src_mtd.column_name = dwh.column_name
         WHERE CASE WHEN src_mtd.column_function like 'PK%' OR dwh.column_function like 'PK%'
                 THEN DECODE( src_mtd.column_function,   dwh.column_function,  0, 1 )
               ELSE 0 END +
               DECODE( src_mtd.column_data_type,        dwh.column_data_type, 0, 1 ) +
               DECODE( src_mtd.column_nullable,         dwh.column_nullable,  0, 1 ) +
               DECODE( src_mtd.column_description,      dwh.column_description,  0, 1 ) > 0
      ) new_data
        INNER JOIN
          (SELECT 'I' cdc_identifier, 'INSERT' cdc_method FROM DUAL UNION
           SELECT 'U' cdc_identifier, 'INSERT' cdc_method FROM DUAL UNION
           SELECT 'U' cdc_identifier, 'CLOSE' cdc_method FROM DUAL UNION
           SELECT 'D' cdc_identifier, 'CLOSE' cdc_method FROM DUAL) ins_close
           ON new_data.cdc_identifier = ins_close.cdc_identifier
) src
ON (tgt.gen_source_columns_id = src.gen_source_columns_id)
WHEN MATCHED THEN
  UPDATE SET tgt.VALID_TO = load_date
WHEN NOT MATCHED THEN
INSERT
  (tgt.SOURCE_OBJECTS_ID,
   tgt.COLUMN_NAME,
   tgt.COLUMN_DATA_TYPE,
   tgt.COLUMN_NULLABLE,
   tgt.COLUMN_DESCRIPTION,
   tgt.COLUMN_FUNCTION,
   tgt.SYNCH_TO_DWH,
   tgt.HISTORIZE_IN_PSA,
   tgt.VALID_FROM,
   tgt.VALID_TO)
VALUES
  (src.gen_source_objects_id,
   src.column_name,
   src.column_data_type,
   src.column_nullable,
   src.column_description,
   src.column_function,
   src.synch_to_dwh,
   src.historize_in_psa,
   src.load_date,
   dwh_TOOLS.GC_END_DATE
  )]'
;

      EXECUTE IMMEDIATE v_sql;
      v_processed_rows := sql%ROWCOUNT;
      COMMIT;

      dmesg('  Number of inserted or closed attributes: ' || v_processed_rows, l_scope);

  END get_columns;

  PROCEDURE get_src_metadata (
      i_src_system_alias    IN VARCHAR2
      )
  IS
    l_scope             gen_exec_log.scope%type   :=  gc_scope_prefix || 'get_src_metadata';
    v_sql               varchar2(32000);
    v_processed_rows    NUMBER;

  BEGIN
      dmesg('Begin analyzing source data ' || i_src_system_alias, l_scope);

      get_objects(i_src_system_alias);
      get_columns(i_src_system_alias);

      dmesg('Analyzing metadata from source ' || i_src_system_alias || ' finished.', l_scope);

  END get_src_metadata;

  FUNCTION ddl_for_table (
      i_dwh_layer           VARCHAR2,
      i_source_system_alias VARCHAR2,
      i_table_name          VARCHAR2,
      i_execute             VARCHAR2,
      i_include_drop_stmt   VARCHAR2
      )
  RETURN clob
  IS
    l_scope         gen_exec_log.scope%type   :=  gc_scope_prefix || 'ddl_for_table';
    l_drop_ddl      clob;
    l_table_ddl     clob;
    l_grant1_ddl    CLOB;
    --l_grant2_ddl    clob;
    l_comment_ddl   clob;
    l_comments_ddl  clob;
    l_complete_ddl  clob;
    l_delimiter     VARCHAR2(1);
    l_pk_columns    VARCHAR2(4000);
    l_table_schema  VARCHAR2(30);
    l_tec_validfrom VARCHAR2(30);
    l_tec_validto   VARCHAR2(30);
    l_work_schema   VARCHAR2(30);

  BEGIN

    l_delimiter := ' ';
    l_work_schema := 'DWH_WORK';

    SELECT column_name INTO l_tec_validfrom FROM DWH_MTD.gen_tec_columns WHERE column_behavior = 'VF';
    SELECT column_name INTO l_tec_validto FROM DWH_MTD.gen_tec_columns WHERE column_behavior = 'VT';


    SELECT DECODE(i_dwh_layer, 'STG', dwh_stg_schema, 'PSA', dwh_psa_schema, '<tbd>')
      INTO l_table_schema
      FROM DWH_MTD.gen_source_systems WHERE source_system_alias = i_source_system_alias;

    IF l_table_schema = '<tbd>' THEN
      dmesg('  Couldnt get database schema, generation not possible.', l_scope);
      RETURN NULL;
    END IF;

      dmesg('  DROP syntax for ' || l_table_schema || '.' || i_table_name || ' generated', l_scope);

    IF i_include_drop_stmt IN ('Y', 'J') THEN
      l_drop_ddl := 'DECLARE' || gc_newline ||
                    '  l_count number;' || gc_newline ||
                    'BEGIN' || gc_newline ||
                    '  select count(*) into l_count from user_tables where table_name = ''' || i_table_name || ''';' || gc_newline ||
                    '  IF l_count > 0 THEN' || gc_newline ||
                    '      EXECUTE IMMEDIATE ''DROP TABLE ' || l_table_schema || '.' || i_table_name || ''';' || gc_newline ||
                    '  END IF;' || gc_newline ||
                    'END;';
    ELSE
      l_drop_ddl := '/* no drop command for table ' || l_table_schema || '.' || i_table_name || ' generated */';
    END IF;


    dmesg('  Table header for ' || l_table_schema || '.' || i_table_name, l_scope);
    l_table_ddl := 'CREATE TABLE ' || l_table_schema || '.' || i_table_name || gc_newline || '(';
    dmesg('  technical attributes for ' || l_table_schema || '.' || i_table_name || ' generated', l_scope);
    l_table_ddl := l_table_ddl || gc_newline || '  -- technical attributes for DWH control';

    FOR c_tec_columns IN (SELECT column_name, column_data_type, DECODE(column_nullable, 'N', 'NOT NULL') column_nullable
                          FROM DWH_MTD.gen_tec_columns WHERE used_in_layer LIKE '%' || i_dwh_layer || '%' ORDER BY column_order) LOOP
      l_table_ddl := l_table_ddl || gc_newline || '  ' || l_delimiter || RPAD(c_tec_columns.column_name, 40,' ') ||
                     c_tec_columns.column_data_type || ' ' || c_tec_columns.column_nullable;
      l_delimiter := ',';
    END LOOP;

    dmesg('  Generating attributes for ' || l_table_schema || '.' || i_table_name, l_scope);
    l_table_ddl := l_table_ddl || gc_newline || '  -- source attributes';

    FOR c_source_columns IN ( SELECT
								column_name,
								case column_data_type
                                    when 'RAW' then 'RAW(16)'
                                    else column_data_type
                                end column_data_type,
								DECODE(column_nullable, 'N', 'NOT NULL') column_nullable
                              FROM DWH_MTD.v_gen_dwh_columns
                              WHERE source_system_alias = i_source_system_alias AND object_name = i_table_name AND synch_to_dwh = 'Y'
                              ORDER BY CASE WHEN column_function LIKE '%PK%' THEN 0 ELSE 1 END, column_function, column_name
                              ) LOOP

      l_table_ddl := l_table_ddl || gc_newline || '  ' || l_delimiter || c_source_columns.column_name ||
                     LPAD(' ', 40 - LENGTH(c_source_columns.column_name)) || c_source_columns.column_data_type || ' ' || c_source_columns.column_nullable;
      l_delimiter := ',';
    END LOOP;

    IF  i_dwh_layer = 'PSA' THEN
      dmesg('  Generating primary keys for ' || l_table_schema || '.' || i_table_name, l_scope);

      SELECT LISTAGG(column_name, ', ') WITHIN GROUP (ORDER BY column_function)
        INTO l_pk_columns
        FROM DWH_MTD.v_gen_dwh_columns WHERE source_system_alias = i_source_system_alias AND object_name = i_table_name AND column_function LIKE '%PK_%';

      IF l_pk_columns IS NOT NULL THEN
        l_table_ddl := l_table_ddl || gc_newline || '  ' || l_delimiter || 'CONSTRAINT ' || SUBSTR(i_table_name, 1, 27) || '_PK ' ||
                      'PRIMARY KEY (' || l_pk_columns || ', ' || l_tec_validfrom || ') USING INDEX';
      ELSE
        dmesg('  no primary key for ' || l_table_schema || '.' || i_table_name || ' found!', l_scope);
      END IF;
    END IF;

      dmesg('  Appending partitioning clause for ' || l_table_schema || '.' || i_table_name, l_scope);

    IF i_dwh_layer in ('STG','PSA') THEN
      l_table_ddl := l_table_ddl || gc_newline || ')' || gc_newline || 'PARTITION BY RANGE (' || l_tec_validfrom || ') INTERVAL(NUMTODSINTERVAL(1, ''DAY''))' || gc_newline ||
                     q'{( PARTITION p_initial VALUES LESS THAN (TO_DATE('01.01.1111', 'DD.MM.YYYY')))}';
    ELSE
      l_table_ddl := l_table_ddl || gc_newline || ')';
    END IF;


      dmesg('  Generating grants for ' || l_table_schema || '.' || i_table_name, l_scope);

      l_grant1_ddl := 'GRANT DELETE, INSERT, UPDATE, SELECT ON ' || l_table_schema || '.' || i_table_name || ' TO ' || l_work_schema;

    IF i_execute IN ('Y', 'J') THEN
      dmesg('  Table scripts for ' || l_table_schema || '.' || i_table_name || ' are executed.', l_scope);
      IF i_include_drop_stmt IN ('Y', 'J') THEN
        execute immediate l_drop_ddl;
      END IF;
      execute immediate l_table_ddl;
      execute immediate l_grant1_ddl;

    ELSE
      dmesg('  Generated table script for ' || l_table_schema || '.' || i_table_name || ', but didnt execute.', l_scope);
    END IF;

    l_comments_ddl := '-- comments';

    SELECT object_description
      INTO l_comment_ddl
      FROM DWH_MTD.v_gen_dwh_tables WHERE source_system_alias = i_source_system_alias AND object_name = i_table_name;

      IF l_comment_ddl is not null THEN
        l_comment_ddl := 'COMMENT ON TABLE ' || l_table_schema || '.' || i_table_name || ' IS ''' || REPLACE( l_comment_ddl,'''','''''') || '''';
        IF i_execute IN ('Y', 'J') THEN execute immediate l_comment_ddl; END IF;

        l_comments_ddl := l_comments_ddl || gc_newline || l_comment_ddl || ';';
        dmesg('  added table comment');
      END IF;

    FOR c_comments IN (SELECT column_name, column_description FROM DWH_MTD.v_gen_dwh_columns
                       WHERE source_system_alias = i_source_system_alias AND object_name = i_table_name AND synch_to_dwh = 'Y' AND column_description is not null
                       ORDER BY CASE WHEN column_function LIKE '%PK%' THEN 0 ELSE 1 END, column_function, column_name) LOOP
        l_comment_ddl := 'COMMENT ON COLUMN ' || l_table_schema || '.' || i_table_name || '.' || c_comments.column_name || ' IS ''' || REPLACE( c_comments.column_description,'''','''''') || '''';
        IF i_execute IN ('Y', 'J') THEN execute immediate l_comment_ddl; END IF;

        l_comments_ddl := l_comments_ddl || gc_newline || l_comment_ddl || ';';
    END LOOP;

        dmesg('  added column comment');


    l_complete_ddl := '-- table ' || l_table_schema || '.' || i_table_name || gc_newline ||
                      l_drop_ddl || gc_newline || '/' || gc_newline || gc_newline ||
                      l_table_ddl || ';' || gc_newline || gc_newline ||
                      l_grant1_ddl || ';' || gc_newline ||
                      --l_grant2_ddl || ';' || gc_newline || gc_newline ||
                      l_comments_ddl;

    return l_complete_ddl;

  EXCEPTION WHEN OTHERS THEN

    dmesg('Error while generating table: ' ||SQLERRM, l_scope);
    raise_application_error(-20001,'An error was encountered - ERROR: '||SQLERRM);

  END ddl_for_table;


  PROCEDURE create_dwh_tables (
      i_source_system_alias   VARCHAR2 DEFAULT '%',
      i_table_name_mask       VARCHAR2 DEFAULT '%',
      i_dwh_layer             VARCHAR2 DEFAULT 'STG',
      i_execute               VARCHAR2 DEFAULT 'N',
      i_include_drop_stmt     VARCHAR2 DEFAULT 'N'
      )
  IS

    l_scope           gen_exec_log.scope%type   :=  gc_scope_prefix || 'create_dwh_tables';
    l_ddl             clob;
    l_ddl_complete    clob;
    l_parameter_list  varchar2(4000);

  BEGIN

    l_parameter_list := 'Execution parameters: ' || gc_newline ||
                        'Source system: ' || i_source_system_alias || gc_newline ||
                        'Tables: ' || i_table_name_mask || gc_newline ||
                        'DWH-Layer: ' || i_dwh_layer || gc_newline ||
                        'Script Execution?: ' || i_execute || gc_newline ||
                        'Drop-Statement?:' || i_include_drop_stmt;

    dmesg('Start generating DWH-tables: ' || l_parameter_list, l_scope);

    FOR c_tables in (SELECT source_system_alias, object_name FROM DWH_MTD.v_gen_dwh_tables
                      WHERE source_system_alias LIKE i_source_system_alias and object_name like i_table_name_mask) LOOP

      dmesg('Generating table "' || c_tables.object_name || '" for layer ' || i_dwh_layer, l_scope);
      l_ddl := ddl_for_table(i_dwh_layer, c_tables.source_system_alias, c_tables.object_name, i_execute, i_include_drop_stmt);

      dmesg('Table "' || c_tables.object_name || '" generated for layer ' || i_dwh_layer || '.', l_scope, 0, l_ddl);
      l_ddl_complete := l_ddl_complete || l_ddl || gc_newline || gc_newline;

    END LOOP;

    dmesg('Generation of DWH-tables finished', l_scope, 0, l_ddl_complete);

  END create_dwh_tables;

  PROCEDURE create_stg_tables(
      i_source_system_alias   VARCHAR2 DEFAULT '%',
      i_table_name_mask       VARCHAR2 DEFAULT '%',
      i_execute               VARCHAR2 DEFAULT 'N',
      i_include_drop_stmt     VARCHAR2 DEFAULT 'N'
      )
  IS
  BEGIN

      create_dwh_tables(i_source_system_alias, i_table_name_mask, 'STG', i_execute, i_include_drop_stmt);

  END create_stg_tables;

  PROCEDURE create_psa_tables(
      i_source_system_alias   VARCHAR2 DEFAULT '%',
      i_table_name_mask       VARCHAR2 DEFAULT '%',
      i_execute               VARCHAR2 DEFAULT 'N',
      i_include_drop_stmt     VARCHAR2 DEFAULT 'N'
      )
  IS
  BEGIN

      create_dwh_tables(i_source_system_alias, i_table_name_mask, 'PSA', i_execute, i_include_drop_stmt);

  END create_psa_tables;

END DWH_GENERATOR;
/

