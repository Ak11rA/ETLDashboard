/*-----------------------------------------------------------------------------
|| DDL for Package Body DWH_TOOLS
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE PACKAGE BODY "DWH_MTD"."DWH_TOOLS" AS

    FUNCTION gc_default_hash RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE
    AS
    BEGIN
        RETURN '86FFA4C133BBEDA87B12F21C018570392018A381';
    END;

    FUNCTION gc_default_bk RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE
    AS
    BEGIN
        RETURN '~^';
    END;

    FUNCTION gc_concat_delimiter RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE
    AS
    BEGIN
        RETURN '~^';
    END;

    FUNCTION gc_end_date RETURN DATE
        DETERMINISTIC
        PARALLEL_ENABLE
    AS
    BEGIN
        RETURN TO_DATE('04044444', 'DDMMYYYY');
    END;

    FUNCTION gc_initial_date RETURN DATE
        DETERMINISTIC
        PARALLEL_ENABLE
    AS
    BEGIN
        RETURN TO_DATE('01011111', 'DDMMYYYY');
    END;

    FUNCTION get_sorted_concat_string (
        i_concatenated_string   IN                      VARCHAR2,
        i_used_seperator        IN                      VARCHAR2 DEFAULT ';'
    ) RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE
    AS
        v_distinct_list   VARCHAR2(4000);
    BEGIN
        SELECT
            LISTAGG(dist_src, i_used_seperator || ' ') WITHIN GROUP(
                ORDER BY
                    dist_src
            )
        INTO v_distinct_list
        FROM
            (
                SELECT DISTINCT
                    TRIM(regexp_substr(i_concatenated_string, '[^'
                                                              || i_used_seperator
                                                              || ']+', 1, level)) dist_src
                FROM
                    dual
                CONNECT BY
                    instr(i_concatenated_string, i_used_seperator, 1, level - 1) > 0
            );

        RETURN v_distinct_list;
    END get_sorted_concat_string;

    FUNCTION get_standard_char_format (
        p_value NUMBER
    ) RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE
    AS
    BEGIN
        RETURN TO_CHAR(p_value, 'TM', 'NLS_NUMERIC_CHARACTERS = '',.''');
    END get_standard_char_format;

    FUNCTION get_standard_char_format (
        p_value DATE
    ) RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE
    AS
    BEGIN
        RETURN TO_CHAR(p_value, 'DD.MM.YYYY HH24:MI:SS');
    END get_standard_char_format;

    FUNCTION get_standard_char_format (
        p_value TIMESTAMP
    ) RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE
    AS
    BEGIN
        RETURN TO_CHAR(p_value, 'DD.MM.YYYY HH24:MI:SS,FF9');
    END get_standard_char_format;

    FUNCTION is_holiday (
        p_datum DATE,
        p_bundesland VARCHAR2
    ) RETURN NUMBER
        DETERMINISTIC
    AS
        v_isholy   NUMBER;
    BEGIN
        BEGIN
            SELECT
                COUNT(*)
            INTO v_isholy
            FROM
                dwh_dm.d_feiertag
            WHERE
                ddatum_id = to_number(TO_CHAR(p_datum, 'YYYYMMDD'))
                AND bundesland = p_bundesland;
        EXCEPTION
            WHEN OTHERS THEN
                v_isholy := -1;
        END;

        RETURN v_isholy;
    END is_holiday;

    function get_dbname return varchar2
    as
        v_dbname varchar2(1024 char);
    begin
        select sys.database_name into v_dbname from dual;
        return v_dbname;
    end get_dbname;

    FUNCTION workdays_between (
        p_datum1       DATE,
        p_datum2       DATE,
        p_bundesland   VARCHAR2
    ) RETURN NUMBER
        DETERMINISTIC
    AS

        v_cnt   NUMBER;
        CURSOR c_tage IS
        SELECT
            h0l1_datum
        FROM
            dwh_dm.d_datum
        WHERE
            h0l1_datum BETWEEN nvl(p_datum1, SYSDATE) AND nvl(p_datum2, SYSDATE)
            AND h0l1_arbeitstag_bw = 1;

    BEGIN
        v_cnt := 0;
        FOR r_tag IN c_tage LOOP
            IF ( is_holiday(r_tag.h0l1_datum, p_bundesland) = 1 ) THEN
                NULL;
            ELSE
                v_cnt := v_cnt + 1;
            END IF;
        END LOOP;

        IF ( v_cnt > 0 ) THEN
            v_cnt := v_cnt - 1; -- BEDIAN-83: Es werden Nächte, und keine Tage gezählt, vrgl. §§ 187,188 BGB
        END IF;
        IF ( p_datum1 IS NULL OR p_datum2 IS NULL ) THEN
        -- Berechnung der Arbeitstage ist nicht möglich, wenn einer der Datumswerte nicht angegeben wurde
            v_cnt := -1;
        END IF;

        RETURN v_cnt;
    END workdays_between;

    FUNCTION seconds_between (
        p_ts1 TIMESTAMP,
        p_ts2 TIMESTAMP
    ) RETURN NUMBER
        DETERMINISTIC
    AS
        v_cnt   NUMBER;
    BEGIN
        v_cnt := extract(DAY FROM ( p_ts2 - p_ts1 )) * 24 * 60 * 60 + extract(HOUR FROM ( p_ts2 - p_ts1 )) * 60 * 60 + extract(MINUTE
        FROM ( p_ts2 - p_ts1 )) * 60 + extract(SECOND FROM ( p_ts2 - p_ts1 ));

        RETURN v_cnt;
    END seconds_between;

    FUNCTION get_interval_borders (
        p_target_table   IN               VARCHAR2,      -- Table name to use the required columns
        p_load_date      IN               DATE           -- DWH_VALID_FROM from source table
    ) RETURN CLOB AS

        PRAGMA autonomous_transaction;
        v_sql            VARCHAR2(32000);
        v_source_table   VARCHAR2(100);
        v_column_list    VARCHAR2(1000);
        v_key_list       VARCHAR2(1000);
        v_result         CLOB;
    BEGIN
        IF p_target_table = 'D_FESTSETZUNG_STELLE' THEN
            v_source_table := 'dwh_psa_abba.v_log130efestsetzste';
            v_column_list := 'l_festst_nr,l_festst_betriebsn,l_festst_namekurz,l_festst_name1,l_festst_name2';
            v_key_list := 'l_festst_nr';
        ELSIF p_target_table = 'B_FEST_HIST' THEN
            v_source_table := 'dwh_psa_abba.v_log131efeststzusta';
            v_column_list := 'l_festst_nr,l_man_nr';
            v_key_list := 'l_man_nr';
        END IF;

        v_column_list := 'vl.'
                         || replace(v_column_list, ',', '|| ''/'' || vl.');
        v_sql := 'SELECT
    rtrim(dbms_xmlgen.convert(extract(xmltype(''<?xml version="1.0"?><document>'' || XMLAGG(xmltype(''<V>'' || dbms_xmlgen.convert(lsql.cline) || ''</V>'')
        ORDER BY
            lsql.lhash
            , lsql.l_satz_nr
    ).getclobval() || ''</document>''), ''/document/V/text()'').getclobval(), 1), '';'') AS c_lob
    FROM
    (
        SELECT
            fsql.lhash || '':'' || to_char(fsql.l_von_min, ''YYYYMMDDHH24MISS'') || '':'' || to_char(fsql.next_v, ''YYYYMMDDHH24MISS'') || '';'' AS cline
            , fsql.lhash
            , fsql.l_satz_nr
        FROM
            (
              SELECT maxsql.*,
                     least(maxsql.l_bis_max, nvl(lead(l_von_min, anz_grp_mem) over (partition by '
                 || v_key_list
                 || ' order by l_von_min, l_bis_max), to_date(''31.12.9999'', ''DD.MM.YYYY''))) next_v
              FROM (
                SELECT
                    mmsql.*
                    , MIN(mmsql.l_gueltigvon4) OVER(PARTITION BY mmsql.lhash, mmsql.grp_nr) AS l_von_min
                    , count(*) over (PARTITION BY mmsql.lhash, mmsql.grp_nr) AS anz_grp_mem
                    , nvl(MAX(mmsql.l_gueltigbis) OVER( PARTITION BY mmsql.lhash, mmsql.grp_nr), TO_DATE(''31.12.9999'', ''DD.MM.YYYY'')) AS l_bis_max
                    , FIRST_VALUE(mmsql.l_satz_nr) OVER( PARTITION BY mmsql.lhash, mmsql.grp_nr ORDER BY mmsql.l_satz_nr ) AS satz_min
                FROM
                    (
                        SELECT
                            ssql.*
                            , SUM(ssql.has_changed_id) OVER( PARTITION BY '
                 || v_key_list
                 || ' ORDER BY ssql.l_satz_nr ) AS grp_nr
                        FROM
                            (
                                SELECT
                                    lsql.*
                                    , CASE
                                        WHEN lsql.lhash = lsql.prev_lhash THEN 0
                                        ELSE 1
                                    END AS has_changed_id
                                    , case when l_status = ''I'' then l_gueltigvon3 else l_gueltigvon end as l_gueltigvon4
                                FROM
                                    (
                                        SELECT
                                            hsql.*
                                            , LAG(hsql.lhash) OVER( PARTITION BY '
                 || v_key_list
                 || ' ORDER BY hsql.l_satz_nr ) prev_lhash
                 , min(l_gueltigvon2) over (partition by hsql.lhash) as l_gueltigvon3
                                        FROM
                                            (
                                                SELECT
                                                    vl.*
                                                    , standard_hash('
                 || v_column_list
                 || ') AS lhash
                 , nvl(vl.l_festst_von, vl.l_gueltigvon) as l_gueltigvon2
                                                FROM '
                 || v_source_table
                 || ' vl
                                                where vl.dwh_valid_from = to_date('''
                 || TO_CHAR(p_load_date, 'DD.MM.YYYY HH24:MI:SS')
                 || ''',''DD.MM.YYYY HH24:MI:SS'')
                                            ) hsql
                                    ) lsql
                            ) ssql
                    ) mmsql
                ) maxsql
            ) fsql
        WHERE
            fsql.l_satz_nr = fsql.satz_min
            AND fsql.l_von_min < fsql.l_bis_max
    ) lsql'
                 ;

        EXECUTE IMMEDIATE v_sql
        INTO v_result;
        RETURN v_result;
    --return v_sql;
    END get_interval_borders;

    procedure reset_data_mart
    AS
    BEGIN
        dwh_dm.trunc_data_mart;
        UPDATE dwh_mtd.etl_delta_log
        SET
            usage = 0
        WHERE
            schema_name = 'DWH_DM'
            and table_name NOT IN (
                'D_DATUM',
                'D_ETL_LADEPLAN',
                'D_ETL_STATUS',
                'F_ETL_MONITORING_HIST',
                'F_TESTLAUF',
                'D_TESTDEFINITION',
                'C_DWH_JOBQUEUE',
				'C_DWH_JOBLIST',
                'C_DWH_PARAMETER',
                'C_QUELLSYSTEM')
            AND usage = 1;
        COMMIT;
        dbatools.debug('DWH_TOOLS.reset_data_mart', 'DATA Mart zurückgesetzt');
    END reset_data_mart;

    procedure drop_stale_worktables
    as
        v_cnt_tab number;
        v_cnt_dbl number;
        v_anz_days   integer;
        v_tablist clob;
        v_dbllist clob;
        v_startdate timestamp;
        v_random number;
        cursor c_objects (vc_anz_days in number) is
            select object_name
            from all_objects
            where object_type = 'TABLE'
                and owner = 'DWH_WORK'
                and (object_name like 'C$_%' or object_name like 'I$_%' or object_name like 'E$_%')
                and last_ddl_time < sysdate - vc_anz_days;
        cursor c_dbl (vc_anz_days in number) is
            SELECT db_link FROM  all_db_links
            where owner = 'DWH_WORK'
              and db_link like 'DWH%'
              and length(db_link) > 20
              and created < sysdate - vc_anz_days;
    begin
        v_cnt_tab := 0;
        v_cnt_dbl := 0;
        v_tablist := 'Dropped tables: ';
        v_dbllist := 'Dropped links: ';
        select sysdate into v_startdate from dual;
        SELECT round(dbms_random.value(1,999)) into v_random FROM dual;

        v_anz_days := nvl(get_param('DROP_TEMP_LIMIT_DAYS'), 3);

        insert into dwh_dm.c_dwh_jobqueue (
            COMMAND,
            SUBMITTED,
            ERRORCODE,
            ARG1)
        values (
            'DROP_STALE_TABS',
            v_startdate,
            -2,
            to_char(v_random)
        );
        commit;
        for r_object in c_objects (v_anz_days) loop
            begin
                execute immediate ('drop table '||r_object.object_name);
             exception
                when others then
                IF SQLCODE != -942 THEN
                    RAISE;
                END IF;
            end;
            v_cnt_tab := v_cnt_tab+1;
            v_tablist := v_tablist || r_object.object_name || ' ';
        end loop;
        for r_dbl in c_dbl(v_anz_days) loop
            begin
                execute immediate ('drop database link '||r_dbl.db_link);
            end;
            v_cnt_dbl := v_cnt_dbl + 1;
            v_dbllist := v_dbllist || r_dbl.db_link || ' ';
        end loop;
        if (v_cnt_tab = 0) then
            v_tablist := 'No stale temporary tables to drop found.';
        end if;
        if (v_cnt_dbl = 0) then
            v_dbllist := 'No stale temporary DB links to drop found.';
        end if;
        update dwh_dm.c_dwh_jobqueue
        set
            RESULT = to_char(v_cnt_tab)||' Tables and '||to_char(v_cnt_dbl)||' DBlinks dropped.',
            OUTPUT = v_tablist||' '||v_dbllist,
            ERRORCODE = 1,
            EXECUTED = sysdate
        where
            COMMAND = 'DROP_STALE_TABS' and
            SUBMITTED = v_startdate and
            ERRORCODE = -2 and
            ARG1 = to_char(v_random)
        ;
        commit;
    end drop_stale_worktables;

    procedure reset_stale_job_loading
    as
       v_is_running   integer;
       cursor c is select case when min(sess_end) = to_date('11110101','YYYYMMDD') then 1 else 0 end is_running from (
                        SELECT s.sess_name, nvl(s.sess_end, to_date('11110101','YYYYMMDD')) sess_end,
                               row_number() over ( partition by s.sess_name  order by s.sess_no desc) rn
                        FROM dwh_dm.c_dwh_joblist jl
                        join ODIEBIV_ODI_REPO.snp_session s on s.sess_name = jl.command
                        where jl.ist_aktiv = 1
                        )
                 where rn = 1;
    begin
       v_is_running := get_param('IS_LOADING');
       if v_is_running = '1' then
          for rc in c loop
             if rc.is_running = 0 then
                --es läuft nix mehr, das Parameter-Flag ist also falsch
                set_param('IS_LOADING','0');
                dbatools.debug('DWH_TOOLS.reset_stale_job_loading', 'Parameter IS_LOADING zurückgesetzt');
             end if;
          end loop;
       end if;
    end reset_stale_job_loading;

    procedure clean_inmemory
    AS
            v_command  varchar2(200);
            cursor c_im_tables is
                SELECT
                    table_name
                FROM
                    all_tables
                WHERE
                    owner = 'DWH_DM'
                    AND
                        (table_name LIKE 'F_%_XS'
                            or
                        table_name LIKE 'D_%'
                            or
                        table_name LIKE 'C_%')
                    AND table_name not like '%ETL%'
                    AND table_name not like '%DWH%'
                    AND table_name not in ('D_ZEIT')
                    and inmemory = 'DISABLED'
                ORDER BY
                    blocks;
    BEGIN
        v_command := '';
        for r_table in c_im_tables loop
                if (r_table.table_name in (
                    'D_BEREINIGUNG',
                    'D_ARBEITSTAG',
                    'D_KOSTENART',
                    'D_MANDANT',
                    'D_ANSTELLERGRUPPE',
                    'D_FEIERTAG'
                    ) or
                    r_table.table_name like 'C_%')
                then
                    v_command := 'alter table '||r_table.table_name||' inmemory priority low';
                else
                    v_command := 'alter table '||r_table.table_name||' inmemory';
                end if;
                begin
                    execute IMMEDIATE (v_command);
                exception
                    when others then null;
                end;
       end loop;
    END clean_inmemory;

    -- This is to be run periodically from corresponding ODI user function
    -- scans DWH jobqueue for waiting jobs and executes them
    -- cleans up datamart loading entries in jobqueue after one day
    procedure exec_dwh_jobqueue
    AS
		v_errors number;
        v_last_drop date;
        v_return  clob;
        CURSOR c_commands IS
                SELECT
                    JOB_ID,
                    COMMAND,
                    SUBMITTED,
                    EXECUTED,
                    RESULT,
                    OUTPUT,
                    ERRORCODE,
                    ARG1
                FROM
                    dwh_dm.c_dwh_jobqueue
                WHERE
                    (executed is null or
                    job_id = -1)
                    --and nvl(errorcode,0) >= 0
                order by submitted asc, job_id asc;
    BEGIN
        FOR r_command IN c_commands LOOP
            IF ( r_command.command = 'TEST' and nvl(r_command.errorcode,0) >= 0) THEN
                -- process test command
                update dwh_dm.c_dwh_jobqueue
                set
                    executed = sysdate,
                    result = 'Test okay.',
                    errorcode = 0
                where
                    job_id = r_command.job_id;
                commit;
            ELSIF ( r_command.command = 'TRUNC_BACKUP' and nvl(r_command.errorcode,0) >= 0 ) THEN
                -- process truncate backup command
                -- mark start
                update dwh_dm.c_dwh_jobqueue
                set
                        executed = sysdate,
                        result = 'Truncating backup environment... (running)',
                        errorcode = -2
                where
                        job_id = r_command.job_id;
                commit;
                v_return := dwh_dm.trunc_syn_tables('A1');
                if substr(v_return,1,1) = '0' then
                   v_errors := 0;
                else
                   v_errors := to_number(rtrim(substr(v_return,1,6)));
                end if;
                -- mark successful end
                if v_errors = 0 then
                    update dwh_dm.c_dwh_jobqueue
                    set
                            executed = sysdate,
                            output = substr(v_return,3),
                            result = 'Truncate Backup executed.',
                            errorcode = 1
                    where
                            job_id = r_command.job_id;
                else
                    update dwh_dm.c_dwh_jobqueue
                    set
                            executed = sysdate,
                            output = substr(v_return,7),
                            result = 'Error in Truncate Backup.',
                            errorcode = v_errors
                    where
                            job_id = r_command.job_id;

                end if;
                commit;
            ELSIF ( r_command.command = 'CREATE_BACKUP' and nvl(r_command.errorcode,0) >= 0 ) THEN
                -- process create backup command
                -- frische A1-Synonymumgebung einrichten
                -- mark start
                update dwh_dm.c_dwh_jobqueue
                set
                        executed = sysdate,
                        result = 'Creating backup environment... (running)',
                        errorcode = -2
                where
                        job_id = r_command.job_id;
                commit;
                --dwh_dm.manage_dm_backups(action => 'CREATE');
                v_return := dwh_dm.fill_syn_tables('A1');
                if substr(v_return,1,1) = '0' then
                   v_errors := 0;
                else
                   v_errors := to_number(rtrim(substr(v_return,1,6)));
                end if;
                -- mark successful end
                if v_errors = 0 then
                    update dwh_dm.c_dwh_jobqueue
                    set
                            executed = sysdate,
                            output = substr(v_return,7),
                            result = 'Create Backup executed.',
                            errorcode = 1
                    where
                            job_id = r_command.job_id;
                else
                    update dwh_dm.c_dwh_jobqueue
                    set
                            executed = sysdate,
                            output = substr(v_return,7),
                            result = 'Error in Backup.',
                            errorcode = v_errors
                    where
                            job_id = r_command.job_id;

                end if;
                commit;
            ELSIF ( r_command.command = 'ACTICATE_BACKUP' and nvl(r_command.errorcode,0) >= 0 ) THEN
                -- Auf A2-Synonymumgebung wechseln
                --dwh_dm.manage_dm_backups(action => 'ACTIVATE');
                dwh_dm.switch_syns('A1');
                -- mark execution
                update dwh_dm.c_dwh_jobqueue
                set
                        executed = sysdate,
                        result = 'Switched to backup.',
                        errorcode = 1
                where
                        job_id = r_command.job_id;
                commit;
            ELSIF ( r_command.command = 'DEACTIVATE_BACKUP' and nvl(r_command.errorcode,0) >= 0 ) THEN
                -- Auf Originalumgebung wechseln
                --dwh_dm.manage_dm_backups(action => 'DEACTIVATE');
                dwh_dm.switch_syns('ORIG');
                -- mark execution
                update dwh_dm.c_dwh_jobqueue
                set
                        executed = sysdate,
                        result = 'Switched to original environment.',
                        errorcode = 1
                where
                        job_id = r_command.job_id;
                commit;
            ELSIF ( r_command.command = 'RESET_DATA_MART' and nvl(r_command.errorcode,0) >= 0 ) THEN
                -- process Reset Datamart command
                if (r_command.arg1 = get_dbname) then   -- only really execute if target database name is provided as argument
                                                        -- this is meant as precuation against accidential use
                    -- mark start
                    update dwh_dm.c_dwh_jobqueue
                    set
                        executed = sysdate,
                        result = 'Resetting Data Mart... (running)',
                        errorcode = -2
                    where
                        job_id = r_command.job_id;
                    commit;
                    reset_data_mart;
                    -- mark successful end
                    update dwh_dm.c_dwh_jobqueue
                    set
                        executed = sysdate,
                        result = 'Reset Data Mart executed.',
                        errorcode = 1
                    where
                        job_id = r_command.job_id;
                    commit;
                else
                    -- mark missing database name in arg1
                    update dwh_dm.c_dwh_jobqueue
                    set
                        executed = sysdate,
                        result = 'Command not validated: '||r_command.command||'.',
                        errorcode = -1
                    where
                        job_id = r_command.job_id;
                    commit;
                end if;
            ELSIF (r_command.command = 'LOAD_DATA_MART') THEN
                -- process Data Mart loading list cleanup of old entries which might not have been closed properly
                -- Data Mart load is blocked if there is already a job running, so we have to get rid of stale entries
                if
                    (r_command.errorcode = -2) and      -- -2 means running
                    (r_command.executed is null) and    -- executed date is maintained by ODI loadplan and is only filled after runtime
                    --(r_command.submitted < sysdate-1)   -- clear job entries older then a day
                    (r_command.submitted < sysdate - interval '23' hour)   -- clear job entries older then 23 hours
                then
                    -- so we have an old entry
                    -- lets see whether we can find an error in ODI session logs
                    begin
                        select
                            count(*)
                        into
                            v_errors
                        from odiebiv_odi_repo.snp_lpi_step_log
                        where i_lp_inst = nvl(r_command.arg1,-999)
                        and status = 'E';
                    exception
                        when others then
                            v_errors := -1; -- do not break this check if something is wrong in ODI repo
                    end;
                    if (v_errors = 0) then
                        -- job seems to be still legit and running, lets mark that we checked it
                        update dwh_dm.c_dwh_jobqueue
                        set
                            result = 'Still running at: '||sysdate
                         where
                            command = 'LOAD_DATA_MART' and
                            executed is null and
                            errorcode = -2 and
                            to_number(arg1) = nvl(r_command.arg1,-999)
                            and job_id = r_command.job_id;
                    elsif (v_errors < 0) then
                        null;   -- there was an error in our query, look in the other direction
                    else
                        --job seems to not be running any more
                        update dwh_dm.c_dwh_jobqueue
                        set
                            executed = sysdate,
                            result = 'Stale error cleared by exec_dwh_jobqueue',
                            errorcode = (-1 * abs(v_errors) -1000 )
                        where
                            command = 'LOAD_DATA_MART' and
                            executed is null and
                            errorcode = -2 and
                            to_number(arg1) = nvl(r_command.arg1,-999)
                            and job_id = r_command.job_id;
                    end if;
                    commit;
                end if;
            ELSIF (r_command.job_id = -1) THEN
                -- Check dummy entry, set submitted date to current date to indicate we are still running and to have this entry on the top in WriteBack
                update dwh_dm.c_dwh_jobqueue
                set submitted = sysdate,
                    command = 'DUMMY',
                    result = 'Leereintrag, um neue Befehle einzugeben.',
                    executed = null
                    -- overhauled to recreate dummy entry if command has been overwritten
                where job_id = r_command.job_id;
                commit;
            END IF;
        END LOOP;
        -- recreate dummy entry if missing
        v_errors := 0;
        begin
            select
                count(*)
            into
                v_errors
            from dwh_dm.c_dwh_jobqueue
            where job_id = -1
             ;
        exception
            when others then
                v_errors := -1; -- do not break this check if something is wrong
        end;
        if (v_errors < 1) then
            insert into dwh_dm.c_dwh_jobqueue
                (job_id, command, submitted, result)
            values
                (-1,'DUMMY',sysdate,'Leereintrag, um neue Befehle einzugeben.');
            commit;
        end if;
        -- run cleanup of stale temp tables left by ODI
        select sysdate into v_last_drop from dual;
        begin
            select trunc(max(submitted))
                into v_last_drop
                from dwh_dm.c_dwh_jobqueue
                where COMMAND = 'DROP_STALE_TABS'
            ;
        exception
            when others then null;
        end;
        if (nvl(v_last_drop,to_date('1111 01 01','YYYY MM DD')) < trunc(sysdate)) -- run only once a day
        then
            drop_stale_worktables;
        end if;
     END exec_dwh_jobqueue;

    -- This is called from ODI when a Load Plan starts
    procedure dwhjq_start_mart (i_cmd in varchar2,
        i_odi_id in number
        )
    AS
    BEGIN
        insert into dwh_dm.c_dwh_jobqueue (
            COMMAND,
            RESULT,
            ERRORCODE,
            ARG1 )
        values (
            i_cmd,
            i_cmd||' running',
            -2,                         -- -2 means still running
            to_char(nvl(i_odi_id,-999))   -- fill odi_id of load plan execution in arg1, -999 when empty
        );
		set_param('IS_LOADING', '1');
        commit;
        drop_stale_worktables;
    END dwhjq_start_mart;

    -- This is called from ODI when a Load Plan end regularly
    procedure dwhjq_end_mart (i_cmd in varchar2,
        i_odi_id in number
        )
    AS
    BEGIN
        update dwh_dm.c_dwh_jobqueue
        set
            executed = sysdate,
            result = i_cmd||' finished.',
            errorcode = 1
        where
            command = i_cmd and
            executed is null and
            errorcode = -2 and
            to_number(arg1) = nvl(i_odi_id,-999);
		set_param('IS_LOADING', '0');
        commit;
    END dwhjq_end_mart;

    -- This is called from ODI when a load plan falls into exception
    procedure dwhjq_error_mart (i_cmd in varchar2,
        i_odi_id in number
        )
    AS
        v_errormessage clob;
        v_errorcode varchar2(200);
    BEGIN
        begin
            select
                lsl.return_code,
                lsl.error_message
            into
                v_errorcode,
                v_errormessage
            from
                 odiebiv_odi_repo.snp_lpi_step_log lsl
            join odiebiv_odi_repo.snp_session ss on ss.sess_no = lsl.sess_no
            where
                1=1
                and ss.sess_status = 'E'
                and lsl.i_lp_inst = nvl(i_odi_id,-999)
            order by ss.sess_end desc;
        exception
            when others then
                null;
        end;
        update dwh_dm.c_dwh_jobqueue
        set
            executed = sysdate,
            result = i_cmd||' threw error ('||v_errorcode||').',
            errorcode = -3,                 -- -3 means ODI error in load plan
            output = v_errormessage
        where
            command = i_cmd and
            executed is null and
            errorcode = -2 and
            to_number(arg1) = nvl(i_odi_id,-999);
		set_param('IS_LOADING', '-1');
        commit;
    END dwhjq_error_mart;

    -- This is called by ODI at the beginning of Data Mart load plan to determine whether there is a previous load still running or blocked
    function load_is_blocked return number
        deterministic
    as
    v_block_cnt number;
    cursor c_commands is
            select
                JOB_ID,
                COMMAND,
                SUBMITTED,
                EXECUTED,
                RESULT,
                OUTPUT,
                ERRORCODE,
                ARG1
            from
                dwh_dm.c_dwh_jobqueue
            where
                command in ('LOAD_DATA_MART', 'LOAD_DATA_MART_NEU', 'LOAD_CORE_2_DM', 'LOAD_XS_TABLES')       -- LOAD_DATA_MART has been set by dwhjq_start_mart aka was triggered by a regular ODI load plan
                                                                    -- BLOCK_LOADING is a command for this framework, has been inserted manually via OBIEE WriteBack
                and executed is null
                and (submitted > sysdate - interval '1' hour)      --verhindert die Blockade nach 1 Stunde, damit der nächste reguläre Job wieder startet

            order by submitted asc, job_id asc;
    begin
        v_block_cnt := 0;
        if get_param('LOAD_DM_BLOCKED') = '1' then
           v_block_cnt :=v_block_cnt + 1;
           dbatools.debug('DWH_TOOLS.load_is_blocked', 'Parameter LOAD_DM_BLOCKED ist gesetzt');
        end if;
        if get_param('IS_LOADING') = '1' then
           v_block_cnt :=v_block_cnt + 1;
           dbatools.debug('DWH_TOOLS.load_is_blocked', 'Parameter IS_LOADING ist gesetzt');
        end if;


        for r_command in c_commands loop
           if (nvl(r_command.errorcode,0) = -2) then -- -2 means still running

              v_block_cnt :=v_block_cnt + 1;
              dbatools.debug('DWH_TOOLS.load_is_blocked', 'Offener Eintrag in Jobqueue ist vorhanden');
           end if;
        end loop;
        return v_block_cnt;
    end load_is_blocked;

    -- This is called by ODI at the beginning of Data Mart load plan to determine whether there is a previous load still running or blocked
    function is_running(i_lp_name in varchar2) return number
    as
    v_sess_cnt number;
    v_sql      varchar2(2000 char);
--    cursor c_sess(vc_lp_name in varchar2) is
--            select count(distinct ses.sid) anz
--            from ODIEBIV_ODI_REPO.snp_session ss
--            join (
--                SELECT substr(se.action, 1, instr(se.action,'/') -1) odi_session_id, substr(se.action, instr(se.action,'/') +1, instr(se.action,'/', 1, 2) - instr(se.action,'/') -1) odi_step_nb,
--                   substr(se.action, instr(se.action,'/', 1, 2) +1, instr(se.action,'/', 1, 3) - instr(se.action,'/',1,2) -1) odi_task_order_number,
--                   substr(se.action,  instr(se.action,'/', 1, 3)  +1) odi_step_run_number,
--                   se.sid
--            FROM  SYS.v_$session se
--            where se.username = 'DWH_WORK'
--            ) ses on ses.odi_session_id = ss.sess_no
--            join (
--                SELECT lpi.load_plan_name, lps.lp_step_name
--                FROM ODIEBIV_ODI_REPO.SNP_LP_INST LPI
--                join ODIEBIV_ODI_REPO.SNP_LPI_STEP LPS on LPS.I_LP_INST = LPI.I_LP_INST
--                join (
--                    SELECT max(i_lp_inst) max_lp_inst, load_plan_name
--                    FROM ODIEBIV_ODI_REPO.SNP_LP_INST LPI
--                    where sess_keywords like 'Release%'
--                    group by load_plan_name
--                ) ver on ver.max_lp_inst = lpi.i_lp_inst and ver.load_plan_name = lpi.load_plan_name
--                where lps.scen_name is not null
--                  and lps.ind_enabled = 1
--            ) lps on lps.load_plan_name = vc_lp_name and ss.sess_name = lp_step_name
--              and sess_status in ('R', 'E');
    begin
        --DBATOOLS.debug('is_running', i_lp_name);
        v_sess_cnt := 0;
        v_sql := 'select count(distinct ses.sid) anz
            from ODIEBIV_ODI_REPO.snp_session ss
            join (
                SELECT substr(se.action, 1, instr(se.action,''/'') -1) odi_session_id, substr(se.action, instr(se.action,''/'') +1, instr(se.action,''/'', 1, 2) - instr(se.action,''/'') -1) odi_step_nb,
                   substr(se.action, instr(se.action,''/'', 1, 2) +1, instr(se.action,''/'', 1, 3) - instr(se.action,''/'',1,2) -1) odi_task_order_number,
                   substr(se.action,  instr(se.action,''/'', 1, 3)  +1) odi_step_run_number,
                   se.sid
            FROM  SYS.v_$session se
            where se.username = ''DWH_WORK''
              and se.status = ''ACTIVE''
            ) ses on ses.odi_session_id = ss.sess_no
            join (
                SELECT lpi.load_plan_name, lps.lp_step_name
                FROM ODIEBIV_ODI_REPO.SNP_LP_INST LPI
                join ODIEBIV_ODI_REPO.SNP_LPI_STEP LPS on LPS.I_LP_INST = LPI.I_LP_INST
                join (
                    SELECT max(i_lp_inst) max_lp_inst, load_plan_name
                    FROM ODIEBIV_ODI_REPO.SNP_LP_INST LPI
                    where sess_keywords like ''Release%''
                    group by load_plan_name
                ) ver on ver.max_lp_inst = lpi.i_lp_inst and ver.load_plan_name = lpi.load_plan_name
                where lps.scen_name is not null
                  and lps.ind_enabled = 1
            ) lps on lps.load_plan_name = '''||i_lp_name||''' and ss.sess_name = lp_step_name
              and ss.sess_name not like ''REFRESH%'' and sess_status in (''R'', ''E'')';
        --count sessions
        execute immediate v_sql into v_sess_cnt;
        if v_sess_cnt > 0 then
           dbatools.debug('DWH_TOOLS.is_running', v_sess_cnt||' alte Session(s) vorhanden');
        end if;
        --for r_sess in c_sess(i_lp_name) loop
        --   v_sess_cnt := r_sess.anz;
        --end loop;
        --check blocking parameter
        if get_param('LOAD_ALL_BLOCKED') = '1' then
           v_sess_cnt := v_sess_cnt + 1;
           dbatools.debug('DWH_TOOLS.is_running', 'LOAD_ALL_BLOCKED is gesetzt');
        end if;
        if i_lp_name = 'LOAD_CORE_2_DM' and get_param('LOAD_DM_BLOCKED') = '1' then
           v_sess_cnt := v_sess_cnt + 1;
           dbatools.debug('DWH_TOOLS.is_running', 'LOAD_DM_BLOCKED is gesetzt');
        end if;
        if i_lp_name = 'LOAD_XS_TABLES' and get_param('LOAD_XS_BLOCKED') = '1' then
           v_sess_cnt := v_sess_cnt + 1;
           dbatools.debug('DWH_TOOLS.is_running', 'LOAD_XS_BLOCKED is gesetzt');
        end if;
		if i_lp_name = 'LOAD_XS_SEC' and get_param('LOAD_SEC_XS_BLOCKED') = '1' then
           v_sess_cnt := v_sess_cnt + 1;
           dbatools.debug('DWH_TOOLS.is_running', 'LOAD_SEC_XS_BLOCKED is gesetzt');
        end if;
        --DBATOOLS.debug('is_running', i_lp_name ||v_sess_cnt);
		return v_sess_cnt;
    end is_running;

    -- This is called by ODI at the beginning of Data Mart load plan XS tables to determine whether there is a previous load still running or blocked or DM is currently loading
    function load_is_xs_blocked return number
        deterministic
    as
    v_block_cnt number;
    cursor c_commands is
            select
                JOB_ID,
                COMMAND,
                SUBMITTED,
                EXECUTED,
                RESULT,
                OUTPUT,
                ERRORCODE,
                ARG1
            from
                dwh_dm.c_dwh_jobqueue
            where
                command in ('LOAD_XS_TABLES')       -- LOAD_XS_TABLES has been set by dwhjq_start_mart aka was triggered by a regular ODI load plan
                                                                    -- BLOCK_LOADING is a command for this framework, has been inserted manually via OBIEE WriteBack
                and executed is null
                and (submitted > sysdate - interval '1' hour)      --verhindert die Blockade nach 1 Stunde, damit der nächste reguläre Job wieder startet

            order by submitted asc, job_id asc;
    begin
        v_block_cnt := 0;
        if get_param('LOAD_XS_BLOCKED') = '1' then
           v_block_cnt :=v_block_cnt + 1;
        end if;
        if get_param('IS_LOADING') = '1' then
           v_block_cnt :=v_block_cnt + 1;
        end if;


        for r_command in c_commands loop
           if (nvl(r_command.errorcode,0) = -2) then -- -2 means still running

              v_block_cnt :=v_block_cnt + 1;
           end if;
        end loop;
        return v_block_cnt;
    end load_is_xs_blocked;

    function get_xs_lower_limit return date
    as
    v_wert          VARCHAR2(250 CHAR);
    v_format        VARCHAR2(30 CHAR);
    v_default       VARCHAR2(255 CHAR);
    v_limit         date;
    cursor c_limit is
            select
                par_wert, par_format, par_default
            from
                dwh_dm.c_dwh_parameter
            where
                par_name = 'XS_LOWER_LIMIT';
    begin
        v_limit := null;
        FOR r_limit IN c_limit LOOP
            v_wert := r_limit.par_wert;
            v_format := r_limit.par_format;
            v_default := r_limit.par_default;
        END LOOP;
        if v_wert is not null then
            v_limit := to_date(v_wert,v_format);
        else
            if v_default is null then
                v_default := 'to_date(to_char(to_number(to_char(sysdate,''YYYY''))-1)||''0101'', ''YYYYMMDD'')';
            end if;
            execute immediate ('select '||v_default||' from dual') into v_limit;
        end if;
        v_limit := v_limit - 8;  --es müssen immer komplette Wochen geladen werden, auch wenn nur ein Tag größer als das Limit ist
        return v_limit;
    end get_xs_lower_limit;

    -- This is called from ODI when Data Mart starts loading the xs-tables
    procedure truncate_xs_tables (i_env in varchar2 default 'XS')
    AS
       cursor c_prefix is SELECT case when table_name like 'A2%' then 'A2_' when table_name like 'A1%' then 'A1_' else null end prefix FROM sys.all_synonyms where owner = 'DWH_DM' and synonym_name = 'SW_C_F_ANTRAG';
       v_prefix    varchar2(10 char);
       v_tab_set   varchar2(10 char);
       v_env       varchar2(100 char);
    BEGIN
        v_tab_set := nvl(get_param('TABELLEN_SET'),'ORIG');
        v_env := v_tab_set||'_'||i_env;
        if v_env = 'ORIG_XS' then
            dwh_dm.trunc_xs_table('F_WIDERSPRUCH_XS');
            dwh_dm.trunc_xs_table('F_BEARBEITUNGSDAUER_XS');
            dwh_dm.trunc_xs_table('F_BELEG_XS');
            dwh_dm.trunc_xs_table('F_BESCHEID_XS');
            dwh_dm.trunc_xs_table('F_FESTSETZUNG_XS');
            dwh_dm.trunc_xs_table('F_ANTRAG_XS');
            dwh_dm.trunc_xs_table('F_BELEG_AGG_XS');
            --parameter table updaten, Sicherungsdatum zurücksetzen
            execute immediate('update dwh_dm.c_dwh_parameter set par_wert = ''-'' WHERE par_name = ''CURRENT_XS_DATE''');
            commit;
        elsif v_env = 'ORIG_AGG' then
            dwh_dm.trunc_xs_table('F_BELEG_AGG');
            dwh_dm.trunc_xs_table('F_BESCHEID_AGG');
            dwh_dm.trunc_xs_table('F_FESTSETZUNG_AGG');
            dwh_dm.trunc_xs_table('D_FESTST_ARBEITSTAG');
        elsif v_env = 'A1_XS' then
            dwh_dm.trunc_xs_table('A1_F_WIDERSPRUCH_XS');
            dwh_dm.trunc_xs_table('A1_F_BEARBEITUNGSDAUER_XS');
            dwh_dm.trunc_xs_table('A1_F_BELEG_XS');
            dwh_dm.trunc_xs_table('A1_F_BESCHEID_XS');
            dwh_dm.trunc_xs_table('A1_F_FESTSETZUNG_XS');
            dwh_dm.trunc_xs_table('A1_F_ANTRAG_XS');
            dwh_dm.trunc_xs_table('A1_F_BELEG_AGG_XS');
            --parameter table updaten, Sicherungsdatum zurücksetzen
            execute immediate('update dwh_dm.c_dwh_parameter set par_wert = ''-'' WHERE par_name = ''CURRENT_XS_DATE''');
            commit;
        elsif v_env = 'A1_AGG' then
            dwh_dm.trunc_xs_table('A1_F_BELEG_AGG');
            dwh_dm.trunc_xs_table('A1_F_BESCHEID_AGG');
            dwh_dm.trunc_xs_table('A1_F_FESTSETZUNG_AGG');
            dwh_dm.trunc_xs_table('A1_D_FESTST_ARBEITSTAG');
        elsif v_env = 'A2_XS' then
            dwh_dm.trunc_xs_table('A2_F_WIDERSPRUCH_XS');
            dwh_dm.trunc_xs_table('A2_F_BEARBEITUNGSDAUER_XS');
            dwh_dm.trunc_xs_table('A2_F_BELEG_XS');
            dwh_dm.trunc_xs_table('A2_F_BESCHEID_XS');
            dwh_dm.trunc_xs_table('A2_F_FESTSETZUNG_XS');
            dwh_dm.trunc_xs_table('A2_F_ANTRAG_XS');
            dwh_dm.trunc_xs_table('A2_F_BELEG_AGG_XS');
            --parameter table updaten, Sicherungsdatum zurücksetzen
            execute immediate('update dwh_dm.c_dwh_parameter set par_wert = ''-'' WHERE par_name = ''CURRENT_XS_DATE''');
            commit;
        elsif v_env = 'A2_AGG' then
            dwh_dm.trunc_xs_table('A2_F_BELEG_AGG');
            dwh_dm.trunc_xs_table('A2_F_BESCHEID_AGG');
            dwh_dm.trunc_xs_table('A2_F_FESTSETZUNG_AGG');
            dwh_dm.trunc_xs_table('A2_D_FESTST_ARBEITSTAG');
        elsif v_env = 'SEC' then
            v_prefix := '';

            --Tabellen leeren
            dwh_dm.trunc_xs_table('F_WIDERSPRUCH_XS_SEC');
            dwh_dm.trunc_xs_table('F_BEARBEITUNGSDAUER_XS_SEC');
            dwh_dm.trunc_xs_table('F_BELEG_XS_SEC');
            dwh_dm.trunc_xs_table('F_BESCHEID_XS_SEC');
            dwh_dm.trunc_xs_table('F_FESTSETZUNG_XS_SEC');
            dwh_dm.trunc_xs_table('F_ANTRAG_XS_SEC');
            dwh_dm.trunc_xs_table('F_BELEG_AGG_SEC');
            dwh_dm.trunc_xs_table('F_BELEG_AGG_XS_SEC');
            dwh_dm.trunc_xs_table('F_BESCHEID_AGG_SEC');
            dwh_dm.trunc_xs_table('F_FESTSETZUNG_AGG_SEC');
            dwh_dm.trunc_xs_table('D_FESTST_ARBEITSTAG_SEC');
            --parameter table updaten, Sicherungsdatum zurücksetzen
            execute immediate('update dwh_dm.c_dwh_parameter set par_wert = ''-'' WHERE par_name = ''SEC_DM_DATE''');
            commit;
            --get prefix : ermittelt, auf welche Umgebung die Lese-Synonyme vom OBIEE zeigen, die soll gesichert werden
            for r_prefix in c_prefix loop
               v_prefix := r_prefix.prefix;
            end loop;
            --und FKs neu anlegen, damit die Sicherungen auf die jeweils richtigen Dimensionen zeigen, sonst gibt es Fehler beim Einfügen der Daten
            dwh_dm.cre_sec_fks(v_prefix);
        end if;
    END truncate_xs_tables;

    -- This is called from ODI when Data Mart starts loading the a2_agg-tables
    procedure truncate_a2_agg_tables
    AS
    BEGIN
        dwh_dm.trunc_xs_table('A2_F_BELEG_AGG');
        dwh_dm.trunc_xs_table('A2_F_BESCHEID_AGG');
        dwh_dm.trunc_xs_table('A2_F_FESTSETZUNG_AGG');
        dwh_dm.trunc_xs_table('A2_F_WIDERSPRUCH_XS');
        dwh_dm.trunc_xs_table('A2_F_BEARBEITUNGSDAUER_XS');
        dwh_dm.trunc_xs_table('A2_F_BELEG_XS');
        dwh_dm.trunc_xs_table('A2_F_BESCHEID_XS');
        dwh_dm.trunc_xs_table('A2_F_FESTSETZUNG_XS');
        dwh_dm.trunc_xs_table('A2_F_ANTRAG_XS');
        dwh_dm.trunc_xs_table('A2_F_BELEG_AGG_XS');
    END truncate_a2_agg_tables;

    -- This is called from ODI when Data Mart starts loading the sec-tables
    procedure truncate_sec_tables
    AS
       cursor c_prefix is SELECT case when table_name like 'A2%' then 'A2_' when table_name like 'A1%' then 'A1_' else null end prefix FROM sys.all_synonyms where owner = 'DWH_DM' and synonym_name = 'SW_C_F_ANTRAG';
       v_prefix  varchar2(10 char);
    BEGIN
        v_prefix := '';

        --Tabellen leeren
        dwh_dm.trunc_xs_table('F_WIDERSPRUCH_XS_SEC');
        dwh_dm.trunc_xs_table('F_BEARBEITUNGSDAUER_XS_SEC');
        dwh_dm.trunc_xs_table('F_BELEG_XS_SEC');
        dwh_dm.trunc_xs_table('F_BESCHEID_XS_SEC');
        dwh_dm.trunc_xs_table('F_FESTSETZUNG_XS_SEC');
        dwh_dm.trunc_xs_table('F_ANTRAG_XS_SEC');
        dwh_dm.trunc_xs_table('F_BELEG_AGG_SEC');
        dwh_dm.trunc_xs_table('F_BELEG_AGG_XS_SEC');
        dwh_dm.trunc_xs_table('F_BESCHEID_AGG_SEC');
        dwh_dm.trunc_xs_table('F_FESTSETZUNG_AGG_SEC');
        dwh_dm.trunc_xs_table('D_FESTST_ARBEITSTAG_SEC');
        --parameter table updaten, Sicherungsdatum zurücksetzen
        execute immediate('update dwh_dm.c_dwh_parameter set par_wert = ''-'' WHERE par_name = ''SEC_DM_DATE''');
        commit;
        --get prefix : ermittelt, auf welche Umgebung die Lese-Synonyme vom OBIEE zeigen, die soll gesichert werden
        for r_prefix in c_prefix loop
           v_prefix := r_prefix.prefix;
        end loop;
        --und FKs neu anlegen, damit die Sicherungen auf die jeweils richtigen Dimensionen zeigen, sonst gibt es Fehler beim Einfügen der Daten
        dwh_dm.cre_sec_fks(v_prefix);
    END truncate_sec_tables;

    procedure set_param(i_param_name in varchar2, i_param_value in varchar2)
    is
       PRAGMA autonomous_transaction;
    BEGIN
        execute immediate('update dwh_dm.c_dwh_parameter set par_wert = '''||i_param_value||''' WHERE par_name = '''||i_param_name||'''');
        commit;
    END set_param;

    function get_param(i_param_name in varchar2) return varchar2
    is
       v_ret varchar2(250 char);
       cursor c (vc_par in varchar2) is select par_wert from dwh_dm.c_dwh_parameter where par_name = vc_par;
    BEGIN
        for rc in c(i_param_name) loop
           v_ret := rc.par_wert;
        end loop;
        return(v_ret);
    END get_param;

    function get_date_param(i_param_name in varchar2) return date
    is
       v_ret     date;
       v_default date;
       cursor c (vc_par in varchar2) is select par_wert, par_format, par_default from dwh_dm.c_dwh_parameter where par_typ = 'DATE' and par_name = vc_par;
    BEGIN
        for rc in c(i_param_name) loop
           --default
           begin
              if rc.par_default = '-'
                 then v_default := to_date('11110101','YYYYMMDD');
              elsif substr(rc.par_default,1,4) = 'EXP:' then
                 execute immediate('select '||substr(rc.par_default,5)||' from dual') into v_default;
              elsif substr(rc.par_default,1,4) = 'SQL:' then
                 execute immediate(substr(rc.par_default,5)) into v_default;
              else
                 v_default := rc.par_default;
              end if;
           exception
              when others then
                 v_default := to_date('11110101','YYYYMMDD');
           end;
           --wert
           begin
              if nvl(rc.par_wert, '-') = '-' then
                 v_ret := v_default;
              else
                 v_ret := to_date(rc.par_wert, rc.par_format);
              end if;
           exception
              when others then
                 v_ret := v_default;
           end;
        end loop;
        return(v_ret);
    END get_date_param;

    procedure set_sec_param
    is
    BEGIN
        execute immediate('update dwh_dm.c_dwh_parameter p set p.par_wert = (SELECT p1.par_wert from dwh_dm.c_dwh_parameter p1  WHERE p1.par_name = ''CURRENT_DM_DATE'') WHERE p.par_name = ''SEC_DM_DATE''');
        commit;
    END set_sec_param;

    function expand_intervall(i_intervall in varchar2, i_min in number, i_max in number) return varchar2
    IS
       v_low_value  number;
       v_high_value number;
       v_return varchar2(2000 char) := '';
       cursor c (vc_low_value in number, vc_high_value in number) is select r from (select 0 r from dual where vc_low_value = 0 union all Select Rownum r From dual Connect By Rownum <= vc_high_value) where r >= vc_low_value;
    BEGIN
        IF instr(i_intervall,'-') = 0 then
           v_return := i_intervall;
        ELSE
           v_low_value := to_number(substr(i_intervall, 1, instr(i_intervall,'-')-1));
           v_high_value := to_number(substr(i_intervall, instr(i_intervall,'-')+1));
           for rc in c(greatest(i_min, v_low_value), least(i_max, v_high_value)) loop
              v_return := v_return || rc.r  ||',';
           end loop;
           v_return := substr(v_return, 1, length(v_return)-1);
        END IF;
        return(v_return);
    END;

    FUNCTION get_expanded_intervall (
        i_concatenated_string   IN VARCHAR2,
        i_min                   IN number,
        i_max                   IN number
    ) RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE
    AS
        v_distinct_list   VARCHAR2(4000);
    BEGIN
        SELECT
            LISTAGG(dwh_mtd.dwh_tools.expand_intervall(dist_src, i_min, i_max), ',' ) WITHIN GROUP(
                ORDER BY
                    dist_src
            )
        INTO v_distinct_list
        FROM
            (
                SELECT DISTINCT
                    TRIM(regexp_substr(i_concatenated_string, '[^'
                                                              || ','
                                                              || ']+', 1, level)) dist_src
                FROM
                    dual
                CONNECT BY
                    instr(i_concatenated_string, ',', 1, level - 1) > 0
            );

        RETURN v_distinct_list;
    END get_expanded_intervall;

    FUNCTION get_last_value (
        i_concatenated_string   IN VARCHAR2,
        i_current               IN number
        )  return number
    IS
       v_return number;
    BEGIN
       SELECT
            dist_src  INTO v_return
        FROM
            (
            SELECT
            dist_src
        FROM
            (
                SELECT DISTINCT
                    TRIM(regexp_substr(i_concatenated_string, '[^'
                                                              || ','
                                                              || ']+', 1, level)) dist_src
                FROM
                    dual
                CONNECT BY
                    instr(i_concatenated_string, ',', 1, level - 1) > 0
            )
            where dist_src <= i_current
            order by dist_src desc
            )
            where rownum < 2;
            return v_return;
    END get_last_value;

    FUNCTION get_week_of_months (
        i_date   IN date
        )  return varchar2
    IS
      --Vorsicht: die letzten beiden Tage des Monats können zur ersten Woche des Folgemonats gehören
      --Es gibt zwei Modelle: F First ( erste Woche des Monats ist die mit dem ersten Mittwoch), A Arbeitswoche ( erste Woche ist die mit dem ersten Montag )
      --return : Stelle Inhalt  Beispiel    Beschreibung MMW ( Monat und Woche ) z.B. 052 für 2. Woche Mai. Vorsicht: die letzten beiden Tage des Monats können zur ersten Woche des Folgemonats gehören
      --         1-2    Monat   02          Nummer des Monats im Modell F, zu dem die Woche gerechnet wird
      --         3-4    Monat   02          Nummer des Monats im Modell A, zu dem die Woche gerechnet wird, die kann sich von den ersten beiden Zeichen unterscheiden
      --         5      Woche   1           Zahl der Woche im Modell F, dh. die erste Woche ist die mit einem Mittwoch. Die Tage davor gehören zur letzten Woche des Vormonats (Stelle 3-4)
      --         6      Woche   1           Zahl der Woche im Modell A, dh. die erste Woche ist die mit einem Montag, dh. die erste volle Arbeitswoche des Monats. Die Tage davor gehören zur letzten Woche des Vormonats (Stelle 3-4)
      --         7      Test    F           Ist dies die erste Woche des Monats im Modell F
      --         7ff    Test    A           Ist dies die erste Woche des Monats im Modell A
      --         7ff    Test    L           Ist dies die letzte Woche des Monats


      v_return             varchar2(8 char);
      v_first              varchar2(1 char);
      v_arbeitswoche       varchar2(1 char);

      v_first_day_of_month date;
      v_last_day_of_month  date;
      v_months             varchar2(2 char);

    BEGIN
       v_first_day_of_month := to_date(to_char(i_date, 'YYYYMM')||'01', 'YYYYMMDD');
       v_last_day_of_month  := add_months(v_first_day_of_month,1)-1;
       v_months := to_char(i_date, 'MM');


       --if i_type = 'F' then
          if to_char(i_date,'WW') = to_char(i_date + 2,'WW') and v_months <> to_char(i_date + 2, 'MM') then  --die selbe Woche, aber im nächsten Monat : Der Tag gehört zur 1. Woche des Folgemonats
             v_return := to_char(i_date + 3, 'MM');
             v_first := '1';
          elsif to_number(to_char(v_first_day_of_month,'D')) <= 3 then
             v_return := v_months;
             v_first := to_char(ceil((to_number(to_char(i_date,'DD')) + to_number(to_char(v_first_day_of_month,'D'))-1 ) / 7));
          else
             v_return := v_months;
             v_first := to_char(ceil((to_number(to_char(i_date,'DD')) - (8 - to_number(to_char(v_first_day_of_month,'D')))) / 7));
          end if;
       --elsif i_type = 'A' then
          if to_char(i_date,'WW') = to_char(v_first_day_of_month - 1,'WW') and v_months <> to_char(v_first_day_of_month - 1, 'MM') then  --die selbe Woche, aber im vorheriger Monat : Der Tag gehört zur 1. Woche des Folgemonats
             v_return := v_return || to_char(v_first_day_of_month - 1, 'MM');
             v_arbeitswoche := to_char(ceil((to_number(to_char(v_first_day_of_month - 1,'DD')) - (8 - to_number(to_char(add_months(v_first_day_of_month, -1),'D')))) / 7));
          else
             v_return := v_return || v_months;
             v_arbeitswoche := to_char(ceil((to_number(to_char(i_date,'DD')) - (8 - to_number(to_char(v_first_day_of_month,'D')))) / 7));
          end if;
          v_return := v_return || v_first||v_arbeitswoche;
          if v_first  = 1 then
             v_return := v_return || 'F';
          end if;
          if v_arbeitswoche  = 1 then
             v_return := v_return || 'A';
          end if;
          if v_arbeitswoche = to_char(ceil((to_number(to_char(v_last_day_of_month,'DD')) - (8 - to_number(to_char(v_first_day_of_month,'D')))) / 7)) then
             v_return := v_return || 'L';
          end if;
       --end if;
       return (v_return);
    END get_week_of_months;

     FUNCTION get_week_of_year (
        i_date   IN date
        )  return number
    IS
       v_return number := 0;
    begin
       for rc in (select h2l2_kw_nr from dwh_dm.d_datum where ddatu_id = to_number(to_char(i_date,'YYYYMMDD'))) loop
          v_return := rc.h2l2_kw_nr;
       end loop;
       return v_return;
    end get_week_of_year;

    FUNCTION check_day (
        i_job_id   IN number,
        i_ref_date IN date
        )  return number
    IS
       v_ok number(1);

       v_day_of_months  number(2);
       v_day_of_week    number(1);
       v_months         number(12);
       v_week_of_months number(1);
       v_week_of_year   number(2);
       v_week_of_months_combi     varchar2(9 char);

       cursor c_job(vc_job_id in number) is select * from dwh_dm.c_dwh_joblist jq where jq.job_id = vc_job_id;

    BEGIN
       v_months := to_number(to_char(i_ref_date,'MM'));
       v_day_of_months := to_number(to_char(i_ref_date,'DD'));
       v_day_of_week := to_number(to_char(i_ref_date,'D'));
       --v_week_of_months := to_number(to_char(i_ref_date,'D'));
       v_week_of_year := get_week_of_year(i_ref_date);
       v_week_of_months_combi := get_week_of_months(i_ref_date);
       v_ok := 0;
       dbms_output.put_line('check_day i_ref_date:'||i_ref_date||' v_months:'||v_months||' v_day_of_months:'||v_day_of_months||' v_day_of_week:'||v_day_of_week||' v_week_of_year:'||v_week_of_year||' v_week_of_months_combi:'||v_week_of_months_combi);
       for r_job in c_job(i_job_id) loop
          dbms_output.put_line('r_job.day_of_months_list:'||get_expanded_intervall(r_job.day_of_months_list,1,31));
          dbms_output.put_line('r_job.day_of_week_list:'||get_expanded_intervall(r_job.day_of_week_list,1,7));
          dbms_output.put_line('r_job.week_of_months_list:'||r_job.week_of_months_list);
          --Tag checken
          if ((nvl(r_job.day_of_months_list,'0') = '0' or instr(',0,'||get_expanded_intervall(r_job.day_of_months_list,1,31)||',', ','||v_day_of_months||',') > 0)
             and
             (nvl(r_job.day_of_week_list,'0') = '0' or instr(',0,'||get_expanded_intervall(r_job.day_of_week_list,1,7)||',', ','||v_day_of_week||',') > 0)
             and
             ((nvl(r_job.week_of_months_list,'0') = '0')
             or (instr(','||r_job.week_of_months_list||',', ','||substr(v_week_of_months_combi,5,1)||',') > 0)
             or (instr(','||r_job.week_of_months_list||',', ',F,') > 0 and instr(v_week_of_months_combi,'F') > 0)
             or (instr(','||r_job.week_of_months_list||',', ',A,') > 0 and instr(v_week_of_months_combi,'A') > 0)
             or (instr(','||r_job.week_of_months_list||',', ',L,') > 0 and instr(v_week_of_months_combi,'L') > 0)
             ))
             and
             (((nvl(r_job.week_of_year_list,'0') = '0')  or instr(',0,'||get_expanded_intervall(r_job.week_of_year_list,1,53)||',', ','||v_week_of_year||',') > 0)
             or (instr(','||r_job.week_of_year_list||',', ',F,') > 0 and v_week_of_year = 1)
             or (instr(','||r_job.week_of_year_list||',', ',L,') > 0 and v_week_of_year = get_week_of_year(to_date(to_char(i_ref_date,'YYYY')||'1231','YYYYMMDD')))
             )
             and
             (nvl(r_job.months_list,'0') = '0' or (instr(',0,'||r_job.months_list||',', ','||v_months||',') > 0)) then
            v_ok := 1;
         end if;
       end loop;
       return v_ok;
    end check_day;

    FUNCTION get_job_startable (
        i_job_id   IN number,
        i_ref_date IN date
        )  return number
    IS
       --v_return number;
       v_day_ok number(1);
       v_hour_ok number(2);
       v_minute_ok number(1);
       v_last_startdate date;
       v_par_last_startdate varchar2(100 char);
       v_last_enddate date;
       v_condition  varchar2(2000 char);
       v_sql  varchar2(2000 char);
       v_cond_result integer;

       cursor c_job(vc_job_id in number) is select * from dwh_dm.c_dwh_joblist jq where jq.job_id = vc_job_id;

       cursor c_day_list(vc_end_date in date, vc_start_date in date) is select least(trunc(vc_start_date) - r +1 - 1/(24*60*60), vc_start_date) as start_dt, greatest(trunc(vc_start_date - r ), vc_end_date) as end_dt from (
                                                                            Select 0 r From dual
                                                                            union all
                                                                            select r from (Select Rownum r From dual Connect By Rownum <= (trunc(vc_start_date) - trunc(vc_end_date)  )) where r <= (trunc(vc_start_date) - trunc(vc_end_date)  )
                                                                         );
       cursor c_hour_list(vc_start_date in date, vc_end_date in date) is select r  from (
                                                                            Select 0 r From dual
                                                                            union all
                                                                            select r from (Select Rownum r From dual Connect By Rownum <= to_number(to_char(vc_start_date,'HH24')))
                                                                            where r <= (to_number(to_char(vc_start_date,'HH24')) + 1)
                                                                            and ((r >= to_number(to_char(to_date(vc_end_date, 'DD.MM.YYYY HH24:MI:SS'),'HH24'))) or (trunc(vc_end_date) <> trunc(vc_start_date)))
                                                                         )
                                                                         where (r >= to_number(to_char(vc_end_date,'HH24')) and to_char(vc_end_date,'DD') = to_char(vc_start_date,'DD'))
                                                                            or (r >= 0 and to_char(vc_end_date,'DD') <> to_char(vc_start_date,'DD'));

       cursor c_minute_list(vc_end_min in number, vc_start_min in number) is select r from (
                                                                            Select 0 r From dual
                                                                            union all
                                                                            select r from (Select Rownum r From dual Connect By Rownum <= vc_start_min) where r <= vc_start_min
                                                                         )
                                                                         where (r <= vc_start_min and r > vc_end_min)
                                                                            ;
    BEGIN
       v_par_last_startdate := get_param('LAST_DISPATCHER_START_DATE');
       reset_stale_job_loading;
       if v_par_last_startdate = '-' or v_par_last_startdate is null then
          v_last_startdate := null;
       else
          v_last_startdate := to_date(v_par_last_startdate,'DD.MM.YYYY HH24:MI:SS');
       end if;
       --v_last_enddate   := to_date(get_param('LAST_DISPATCHER_END_DATE'),'DD.MM.YYYY HH24:MI:SS');
       --Auch bei einer Aufruf-Frequenz von 5 Minuten kann die Differenz zum letzten Lauf groß sein, wenn die Laufzeit lang war
       --Ich teste aber nur den Vortag, da ist ein Sprung über Mitternacht möglich
       --Wenn der Lauf mehr als einen Tag dauert, ist etwas schief gelaufen
       if v_last_startdate is null then --allererster Lauf checkt nur die letzten 5 Minuten
          v_last_startdate := i_ref_date - (5 / (24*60));
       --else
           --v_last_startdate :=  greatest(v_last_startdate,  v_last_enddate);
       end if;
       dbms_output.put_line('i_ref_date:'||to_char(i_ref_date,'DD.MM.YYYY HH24:MI:SS')||' v_last_startdate:'||to_char(v_last_startdate,'DD.MM.YYYY HH24:MI:SS'));
       for r_job in c_job(i_job_id) loop
          dbms_output.put_line('r_job.job_id:'||r_job.job_id);
          v_last_startdate := greatest(greatest(greatest(v_last_startdate, nvl(r_job.last_executed_on, to_date('11110101','YYYYMMDD'))), nvl(r_job.last_finished_on, to_date('11110101','YYYYMMDD'))),(i_ref_date - (55/(60*24))));
          dbms_output.put_line('i_ref_date:'||to_char(i_ref_date,'DD.MM.YYYY HH24:MI:SS')||' v_last_startdate:'||to_char(v_last_startdate,'DD.MM.YYYY HH24:MI:SS'));
          --Tag checken
          dbms_output.put_line('r_job.hour_list:'||r_job.hour_list);
          for r_day in c_day_list(v_last_startdate, i_ref_date) loop
             dbms_output.put_line('Tag r_day.start_dt:'||r_day.start_dt||' r_day.end_dt:'||r_day.end_dt);
             if check_day( r_job.job_id, r_day.start_dt) = 1 then
                dbms_output.put_line('check_day ok r_day.end_dt:'||r_day.end_dt||' r_day.start_dt:'||r_day.start_dt);
                --now check hour and minute


                for r_hl in c_hour_list(r_day.start_dt, r_day.end_dt) loop
                    dbms_output.put_line('Stunde:'||r_hl.r);
                    v_hour_ok := -1;
                    if((nvl(r_job.hour_list,'-1') = '-1' or instr(','||get_expanded_intervall(r_job.hour_list, 0, 23)||',', ','||to_char(r_hl.r)||',') > 0)) then
                       v_hour_ok := r_hl.r;
                    end if;
                    --exit when v_hour_ok >= 0;


                    if v_hour_ok >= 0 then
                       dbms_output.put_line('Stunde ok end_min:'||to_number(to_char(r_day.end_dt,'DDHH24MI'))||' start_min:'|| to_number(to_char(r_day.start_dt,'DDHH24MI'))||' r_hl.r:'||r_hl.r);
                       --check minutes
                       --es gibt 4 Fälle: Teil einer Stunde mit oberer Grenze i_ref_date und unterer Grenze v_last_startdate, Teil einer Stunde mit oberer Grenze i_ref_date, ganze Stunde ( sind alle gleich ), Teil einer Stunde mit unterer Grenze v_last_startdate
                       v_minute_ok := 0;
                       if to_char(r_day.start_dt,'DDHH24') = to_char(r_day.end_dt,'DDHH24') then  --gleiche Stunde am selben Tag
                          dbms_output.put_line('Minute 1');
                          for r_min in c_minute_list(greatest(0, to_number(to_char(r_day.end_dt,'MI'))), least(59, to_number(to_char(r_day.start_dt,'MI')))) loop
                             if (instr(','||r_job.minute_list||',', ','||to_char(r_min.r)||',') > 0) then
                                   v_minute_ok := 1;
                             end if;
                             exit when v_minute_ok = 1;
                          end loop;
                       end if;
                       if v_minute_ok = 0 and to_char(r_day.end_dt,'DD') = to_char(r_day.start_dt,'DD') and  to_number(to_char(r_day.end_dt,'HH24')) < to_number(to_char(r_day.start_dt,'HH24')) and to_number(to_char(r_day.start_dt,'HH24')) = r_hl.r then  --verschieden Stunde am selben Tag, laufende Stunde ist die selbe wie die vom Start_dt
                          dbms_output.put_line('Minute 2');
                          for r_min in c_minute_list(0,  to_number(to_char(r_day.start_dt,'MI'))) loop
                             if (instr(','||r_job.minute_list||',', ','||to_char(r_min.r)||',') > 0) then
                                   v_minute_ok := 1;
                             end if;
                             exit when v_minute_ok = 1;
                          end loop;
                       end if;
                       dbms_output.put_line('vor Minute 3 to_char(r_day.end_dt,''DD''):'||to_char(r_day.end_dt,'DD')||' = to_char(r_day.start_dt,''DD''):'||to_char(r_day.start_dt,'DD')||' to_number(to_char(r_day.end_dt,''HH24'')):'||to_number(to_char(r_day.end_dt,'HH24'))||' < to_number(to_char(r_day.start_dt,''HH24'')) :'||to_number(to_char(r_day.start_dt,'HH24')) ||' <> r_hl.r:'||r_hl.r);
                       if v_minute_ok = 0 and to_char(r_day.end_dt,'DD') = to_char(r_day.start_dt,'DD') and  to_number(to_char(r_day.end_dt,'HH24')) < to_number(to_char(r_day.start_dt,'HH24'))
                          and to_number(to_char(r_day.start_dt,'HH24')) > r_hl.r and to_number(to_char(r_day.end_dt,'HH24')) < r_hl.r then  --verschieden Stunde am selben Tag, laufende Stunde ist nicht die selbe wie die vom Start_dt oder end_dt
                          dbms_output.put_line('Minute 3');
                          for r_min in c_minute_list(0, 59) loop
                             dbms_output.put_line('Minute 3 r_min.r:'||r_min.r);
                             if (instr(','||r_job.minute_list||',', ','||to_char(r_min.r)||',') > 0) then
                                   v_minute_ok := 1;
                             end if;
                             exit when v_minute_ok = 1;
                          end loop;
                       end if;
                       if v_minute_ok = 0 and to_char(r_day.end_dt,'DD') = to_char(r_day.start_dt,'DD') and  to_number(to_char(r_day.end_dt,'HH24')) < to_number(to_char(r_day.start_dt,'HH24')) and to_number(to_char(r_day.end_dt,'HH24')) = r_hl.r then  --verschieden Stunde am selben Tag, laufende Stunde ist die selbe wie die vom End_dt
                          dbms_output.put_line('Minute 4');
                          for r_min in c_minute_list( to_number(to_char(r_day.end_dt,'MI')), 59) loop
                             if (instr(','||r_job.minute_list||',', ','||to_char(r_min.r)||',') > 0) then
                                   v_minute_ok := 1;
                             end if;
                             exit when v_minute_ok = 1;
                          end loop;
                       end if;
                    end if;
                    exit when v_minute_ok = 1;
                end loop;  --c_hour_list
             end if;
             exit when v_minute_ok = 1;  --wenn noch die Minuten stimmen, habe ich ein Startfenster gefunden, d.h. im Suchintervall liegt ein Soll-Startzeitpunkt
          end loop;
          --Bedingung checken, aus Ermanglung liegt sie inder ARG-List, gekennzeichnet durch "COND:" am Anfang
          if v_minute_ok = 1 and r_job.arg_list like 'COND:%' then
             v_condition := substr(r_job.arg_list,6);
             dbms_output.put_line('Cond:'||v_condition);
             if v_condition is not null then
                 --v_sql := 'SELECT '||v_condition||' from dual';
                 execute immediate v_condition into v_cond_result;
                 if nvl(v_cond_result, 0) = 0 then
                    v_minute_ok := 0;
                 end if;
             end if;
          end if;
       end loop;


       return nvl(v_minute_ok, 0);
    end get_job_startable;

    function check_session_running(i_sess_name in varchar2, i_type in varchar2, i_time_limit in number) return number
    is
       v_number_of_sessions  number;
       cursor c_pck(vc_sess_name in varchar2, vc_time_limit in number) is SELECT count(sess_no) anz FROM ODIEBIV_ODI_REPO.snp_session where sess_name = vc_sess_name and nvl(sess_beg, first_date) > sysdate - vc_time_limit/24 and sess_end is null;
       cursor c_scen(vc_sess_name in varchar2, vc_time_limit in number) is SELECT count(distinct sess_no) anz FROM dwh_mtd.v_odi_scen_log where step_name = vc_sess_name and nvl(session_begin, step_begin) > sysdate - vc_time_limit/24 and session_end is null;
    begin
       v_number_of_sessions := 0;
       if i_type = 'PCK' THEN
           for r_pck in c_pck(i_sess_name, i_time_limit) loop
              v_number_of_sessions := r_pck.anz;
           end loop;
       else
          for r_scen in c_scen(i_sess_name, i_time_limit) loop
              v_number_of_sessions := r_scen.anz;
           end loop;
       end if;
       return v_number_of_sessions;
    end check_session_running;

    procedure set_job_running(i_job_id in number)
    --setzt die Werte im C_DWH_JOBQUEUE-Eintrag, das der Job ( gleich ) anläuft
    IS
       PRAGMA autonomous_transaction;
    BEGIN
       update dwh_dm.c_dwh_joblist
          set last_executed_on = sysdate,
              asap = case when asap = 1 and is_periodic = 1 then 0 else asap end   --bei periodischen Jobs läuft es einmal sofort, danach wieder normal
        where job_id = i_job_id;
      commit;
    END set_job_running;

    procedure set_job_ending(i_job_id in number)
    --setzt die Werte im C_DWH_JOBQUEUE-Eintrag, das der Job beendet ist
    IS
       PRAGMA autonomous_transaction;
    BEGIN
       update dwh_dm.c_dwh_joblist
          set last_finished_on = sysdate,
              last_error = '-',
              success_counter = success_counter +1
        where job_id = i_job_id;
      commit;
    END set_job_ending;

    procedure set_job_error(i_job_id in number, i_last_error in varchar2, i_keywords in varchar2)
    --setzt die Werte im C_DWH_JOBQUEUE-Eintrag, das der Job auf Fehler gelaufen ist
    --Es kann entweder ein Fehlercode geliefert werden oder die Keywords, damit kann man den Fehler selber raussuchen
    IS
       PRAGMA autonomous_transaction;
       v_last_error clob;
       cursor c_job(vc_job_id in number) is select * from dwh_dm.c_dwh_joblist where job_id = vc_job_id;
       cursor c_lp(vc_lp_name in varchar2, vc_keywords in varchar2, vc_start_date in date) is
                   SELECT slr.status, slr.error_message
                    FROM ODIEBIV_ODI_REPO.snp_lp_inst sli
                    join ODIEBIV_ODI_REPO.snp_lpi_run slr on slr.i_lp_inst = sli.i_lp_inst
                    where sli.load_plan_name = vc_lp_name
                      and nvl(sli.sess_keywords,'~') like vc_keywords||'%'
                      and slr.start_date >= vc_start_date;
       cursor c_sess(vc_sess_name in varchar2, vc_keywords in varchar2, vc_start_date in date) is
                  SELECT sess_status, error_message
                  FROM ODIEBIV_ODI_REPO.snp_session
                    where sess_name = vc_sess_name
                      and nvl(sess_keywords,'~') like vc_keywords||'%'
                      and sess_beg >= vc_start_date;
    BEGIN
       v_last_error := '-';
       if i_last_error is not null then
          v_last_error := i_last_error;
       else
          for r_job in c_job(i_job_id) loop
             if r_job.cmd_type = 'LP' then
                for r_lp in c_lp(r_job.command, i_keywords, r_job.last_executed_on) loop
                   v_last_error := r_lp.error_message;
                end loop;
             else
                for r_sess in c_sess(r_job.command, i_keywords, r_job.last_executed_on) loop
                   v_last_error := r_sess.error_message;
                end loop;
             end if;
          end loop;
       end if;

       update dwh_dm.c_dwh_joblist
          set last_finished_on = sysdate,
              last_error = v_last_error,
              error_counter = error_counter + 1
        where job_id = i_job_id;
      commit;
    END set_job_error;

    --test Thomas
    function get_start_list return varchar2
    is
       v_ret_job_list varchar2(2000 char);
       v_start_date  date;
       v_is_running  number(1);
       v_is_job_running  number(1);
       v_last_dispatcher_start_date date;
       v_last_dispatcher_end_date date;
       v_current_dispatcher_start_date date;
       v_par_current_dispatcher_start_date varchar2(100 char);
       v_check_dispatcher_run number(1);
       v_is_dispatcher_active number(1);
       v_session_running number(1);
       v_is_job_startable  number;
       cursor c_job(vc_start_date in date) is select * from dwh_dm.c_dwh_joblist  jq
                        where jq.ist_aktiv = 1
                          and ((jq.is_periodic = 0 and jq.fix_run_date < vc_start_date and jq.last_executed_on = to_date('11110101','YYYYMMDD'))
                              OR
                              (jq.asap = 1 and (jq.last_executed_on = to_date('11110101','YYYYMMDD') or jq.is_periodic = 1))
                              OR
                              (jq.is_periodic =1))
						order by decode(jq.asap,1,1,0),
                        case when instr(jq.hour_list,',') > 0 then to_number(substr(jq.hour_list,1,instr(jq.hour_list,',') -1)||jq.minute_list)
                            when instr(jq.hour_list,'-') > 0 then to_number(substr(jq.hour_list,1,instr(jq.hour_list,'-') -1)||jq.minute_list)
                            else to_number(jq.hour_list||jq.minute_list)
                        end;
    begin
       dbms_output.put_line('get_start_list');
       v_start_date := sysdate;
       v_ret_job_list := '';

       v_is_dispatcher_active := to_number(get_param('DISPATCHER_ACTIVE'));
       v_check_dispatcher_run := to_number(get_param('CHECK_DISPATCHER_RUN'));
       v_par_current_dispatcher_start_date := get_param('CURRENT_DISPATCHER_START_DATE');
       if v_par_current_dispatcher_start_date = '-' then
          v_par_current_dispatcher_start_date := null;
       end if;
       v_current_dispatcher_start_date := to_date(v_par_current_dispatcher_start_date,'DD.MM.YYYY HH24:MI:SS');
       v_is_running := 1;
       dbms_output.put_line('Start');
       if v_current_dispatcher_start_date is not null then
          dbms_output.put_line('Dispatcher Session');
          v_session_running := check_session_running('PCK_DISPATCHER','PCK', 23);
          if v_session_running <= 1 then  --die eine Session ist der aktuelle Prozess
             v_is_running := 0;
             dbms_output.put_line('Dispatcher Session OK');
          end if;
       else
          v_is_running := 0;
       end if;
       --Wenn v_is_running = 0 kann es weitergehen oder wenn CHECK_DISPATCHER_RUN = 0
       dbms_output.put_line('Start ? v_check_dispatcher_run:'||v_check_dispatcher_run|| ' v_is_running:'||v_is_running);
       if (v_check_dispatcher_run = 0 or v_is_running = 0) and v_is_dispatcher_active = 1 then
          --es geht wirklich los
          dbms_output.put_line('Es geht los');
          --ggf Parameter nach Absturz zurücksetzen
          v_is_job_running := 0;
          for rc in (select distinct 1 as is_running from ODIEBIV_ODI_REPO.snp_session s where sess_status = 'R')
          loop
             v_is_job_running := 1;
          end loop;
          if v_is_job_running = 0 then
             --es läuft nix
             set_param('IS_LOADING', '0');
             set_param('LOAD_ALL_RUNNING','0');

          end if;

          set_param('CURRENT_DISPATCHER_START_DATE', to_date(v_start_date,'DD.MM.YYYY HH24:MI:SS'));
          --loop über die Jobs
          for r_job in c_job(v_start_date) loop
              dbms_output.put_line('Job:'||r_job.job_id);
              --check timing
              if r_job.asap = 1 and (r_job.last_executed_on = to_date('11110101','YYYYMMDD') or r_job.is_periodic = 1) then
                 --Ausführung sofort und läuft noch nicht
                 v_ret_job_list := v_ret_job_list ||r_job.job_id||',';
                 dbms_output.put_line('ret:'||v_ret_job_list);
              elsif r_job.is_periodic = 0 and r_job.fix_run_date < v_start_date and r_job.last_executed_on = to_date('11110101','YYYYMMDD') then
                 --Einmal-Ausführung, Termin verstrichen und läuft noch nicht
                 v_ret_job_list := v_ret_job_list ||r_job.job_id||',';
                 dbms_output.put_line('ret:'||v_ret_job_list);
              elsif r_job.is_periodic =1 then
                 --periodisch, Zeiten checken, ob gestartet werden muss
                 v_is_job_startable := get_job_startable(r_job.job_id, v_start_date);
                 if v_is_job_startable = 1 and check_session_running(r_job.command, r_job.cmd_type, r_job.invalid_hours ) = 0 then
                    v_ret_job_list := v_ret_job_list ||r_job.job_id||',';
                    dbms_output.put_line('ret:'||v_ret_job_list);
                 end if;
              end if;
          end loop;
       end if;
       if length(v_ret_job_list) > 0 then
          v_ret_job_list := substr(v_ret_job_list,1,length(v_ret_job_list) -1);
       end if;
       return(v_ret_job_list);
    end;

    procedure end_dispatcher_run
      --Das Ende des Dispatcher-Runs ist bei asynchronen Jobs nicht unbedingt das Ende aller gestarteten Aktionen
    is
       v_current_start_date  date;
       v_par_current_start_date  varchar2(100 char);
    begin
       v_par_current_start_date := get_date_param('CURRENT_DISPATCHER_START_DATE');

       set_param('LAST_DISPATCHER_START_DATE', to_char(v_current_start_date,'DD.MM.YYYY HH24:MI:SS'));
       set_param('LAST_DISPATCHER_END_DATE', to_char(sysdate,'DD.MM.YYYY HH24:MI:SS'));
       set_param('CURRENT_DISPATCHER_START_DATE', '-');
    end end_dispatcher_run;

    function get_job_parameter(i_job_id in number, i_pos in number, i_type in varchar2) return varchar2
    is
       --Format arg-List: Liste von Parameter-Namen mit Werten, separiert durch Semikolon ( A|1;B|2;C|3)
       --oder einfache Werte-Listen mit Semikolon ( 1;2;3 ).
       --In diesem Fall muss die Reihenfolge und Anzahl den Parametern im ODI-Repository entsprechen
       --i_type ist Name ('N') oder Value ('V')
       v_ret_val   varchar2(2000 char);
       v_par       varchar2(2000 char);
       cursor c_arg_list is select arg_list, scen_name, obj.scen_no, obj.odi_type from dwh_dm.c_dwh_joblist  cdj
                            join (
                            SELECT ssc.scen_name, nvl(nvl( sp.pack_name, map.name), trt.trt_name) obj_name, ssc.scen_no, 'SC' as odi_type
                            FROM ODIEBIV_ODI_REPO.snp_scen ssc
                            left outer join ODIEBIV_ODI_REPO.snp_package sp on sp.i_package = ssc.i_package
                            left outer join ODIEBIV_ODI_REPO.snp_mapping map on map.i_mapping = ssc.i_mapping
                            left outer join ODIEBIV_ODI_REPO.snp_trt trt on trt.i_trt = ssc.i_trt
                            --where scen_name = 'LOAD_STAGE'
                            union
                            select load_plan_name as scen_name, load_plan_name as obj_name, i_load_plan as scen_no, 'LP' as odi_type from  ODIEBIV_ODI_REPO.snp_load_plan
                            ) obj on obj.obj_name = cdj.command
                            where job_id = i_job_id;
       cursor c_par_list(vc_scen_no in number, vc_pos_no in number) is select case when instr(svs.var_name,'.') = 0 then svs.var_name else substr(svs.var_name,instr(svs.var_name,'.')+1) end var_name, svs.var_param_order
                            from  ODIEBIV_ODI_REPO.snp_var_scen svs
                            where svs.scen_no = vc_scen_no
                              and svs.var_param_order = vc_pos_no;

    begin
       v_ret_val := null;
       for r_par in c_arg_list loop
          if instr(r_par.arg_list,'|') > 0 then
             --es wurden Parameter-Namen mit Werten übergeben
             v_par := substr(r_par.arg_list||';', case when i_pos = 1 then 1 else instr(r_par.arg_list||';',';',1,i_pos-1) + 1 end, instr(r_par.arg_list||';',';',1,i_pos) - case when i_pos = 1 then 1 else instr(r_par.arg_list||';',';',1,i_pos-1) +1 end );
             if i_type = 'N' then
                v_ret_val := substr(v_par,1,instr(v_par,'|')-1);
             elsif i_type = 'V' then
                v_ret_val := substr(v_par,instr(v_par,'|')+1);
             end if;
          else
             --es wurden nur Werte übergeben, in diesem Fall muss die Liste auch vollständig sein
             v_par := substr(r_par.arg_list||';', case when i_pos = 1 then 1 else instr(r_par.arg_list||';',';',1,i_pos-1) + 1 end, instr(r_par.arg_list||';',';',1,i_pos) - case when i_pos = 1 then 1 else instr(r_par.arg_list||';',';',1,i_pos-1) +1 end );
             if i_type = 'N' then
                for r_name in c_par_list(r_par.scen_no, i_pos) loop
                   v_ret_val := r_name.var_name;
                end loop;
             elsif i_type = 'V' then
                v_ret_val := v_par;
             end if;
          end if;
       end loop;
       return v_ret_val;
    end get_job_parameter;

    --funktion, um zu testen, ob in den XS-Tabellen auch wirklich etwas drin steht
    --Dazu muss die Anzahl der Sätze über dem Limit ( Parameter XS_NOT_EMPTY_LIMIT (default 1000 ) liegen
    function check_xs_filled return integer
    is
       cursor c(vc_limit in integer) is select case when is_ok >= vc_limit then 1 else 0 end is_ok from (
                                                select sum(has_data) is_ok from (
                                                select case when anz > 1000 then 1 else 0 end has_data from (
                                                select 'F_ANTRAG_XS' tab, count(*) anz from dwh_dm.f_antrag_xs
                                                union
                                                select 'F_FESTSETZUNG_XS' tab, count(*) anz from dwh_dm.f_festsetzung_xs
                                                union
                                                select 'F_BESCHEID_XS' tab, count(*) anz from dwh_dm.f_bescheid_xs
                                                union
                                                select 'F_BELEG_XS' tab, count(*) anz from dwh_dm.f_beleg_xs
                                                union
                                                select 'F_WIDERSPRUCH_XS' tab, count(*) anz from dwh_dm.f_widerspruch_xs
                                                union
                                                select 'F_BEARBEITUNGSDAUER_XS' tab, count(*) anz from dwh_dm.f_bearbeitungsdauer_xs
                                                union
                                                select 'F_BELEG_AGG' tab, count(*) anz from dwh_dm.f_beleg_agg
                                                union
                                                select 'F_BELEG_AGG_XS' tab, count(*) anz from dwh_dm.f_beleg_agg_xs
                                                union
                                                select 'F_BESCHEID_AGG' tab, count(*) anz from dwh_dm.f_bescheid_agg
                                                union
                                                select 'F_FESTSETZUNG_AGG' tab, count(*) anz from dwh_dm.f_festsetzung_agg
                                                union
                                                select 'D_FESTST_ARBEITSTAG' tab, count(*) anz from dwh_dm.d_festst_arbeitstag
                                            )));

       v_tab_set varchar2(10 char);
       v_limit   integer;
       v_ret     integer := 0;
    begin
        v_tab_set := get_param('TABELLEN_SET');
        v_limit := get_param('XS_NOT_EMPTY_LIMIT');
        if v_tab_set = 'ORIG' then
           for rc in c(v_limit) loop
              v_ret := rc.is_ok;
           end loop;
        else
           --vorerst keine Tests
           v_ret := 1;
        end if;
        return(v_ret);
    end check_xs_filled;

    --Procedure called once a day by odi Job to look for new tables. There are entered into dwh_mtd.etl_tables
    procedure check_etl_tables
    is
       cursor c_new is select u.owner, u.table_name, o.created,
                          conf.char_value as version,
                          case when u.owner = 'DWH_DM' and u.table_name like 'DW%' then 'DW' else null end class_type,
                          case when u.owner = 'DWH_DM' and u.table_name like 'DW%' then 'HF' else 'ABBA' end source
                          from sys.all_tables u
                          join sys.all_objects o on o.object_name = u.table_name and o.owner = u.owner and o.object_type = 'TABLE'
                          left join dwh_mtd.etl_tables tab on tab.owner = u.owner and tab.tab_name = u.table_name
                          join dwh_mtd.etl_configuration conf on 'DWH_'||substr(conf.configuration,13 ) = upper(u.OWNER)
                          where table_name not like 'MDRT%' and table_name not like '%EXPORT' and table_name not like 'A0%' and table_name not like 'DE_%' and table_name not like 'TEST%'
                             and u.owner in ('DWH_CORE', 'DWH_DM')
                             and tab.tab_name is null     --only new entries
                          order by 1;
       cursor c_del is select tab.owner, tab.tab_name
                        from dwh_mtd.etl_tables tab
                        left join sys.all_tables u on tab.owner = u.owner and tab.tab_name = u.table_name
                        where u.table_name is null;
    begin
       for r_new in c_new loop
          insert into dwh_mtd.etl_tables (tab_name, owner, source, inst_date, inst_version, class_type) values ( r_new.table_name,r_new.owner, r_new.source, r_new.created, r_new.version, r_new.class_type);
       end loop;
       for r_del in c_del loop
          update dwh_mtd.etl_tables t
             set status = 'DELETED'
             where t.tab_name = r_del.tab_name and t.owner = r_del.owner;
       end loop;
       commit;
    end check_etl_tables;

    --procedure to enter a new table into dwh_mtd.etl_tables if it doesnt exist. Called from installation script. Put into table properties in modeler, post inst scripts
    procedure add_etl_table(i_table_name in varchar2, i_owner in varchar2, i_source in varchar2)
    is
       cursor c_tab is select 1 from dual
                       where not exists (select 1 from dwh_mtd.etl_tables t where t.tab_name = i_table_name and t.owner = i_owner);
    begin
       for r_tab in c_tab loop
          execute immediate('insert into dwh_mtd.etl_tables (tab_name, owner, source) values ( '''||i_table_name||''','''||i_owner||''', '''||i_source||''')');
          commit;
       end loop;
    end add_etl_table;

    --Zurücksetzen des Delta Log nach truncates
    procedure reset_delta_log(i_schema in varchar2, i_table_name in varchar2)
    is
    begin
       if i_table_name is null and i_schema is not null then
          execute immediate('update DWH_MTD.ETL_DELTA_LOG set usage = 0 where schema_name = '''||i_schema||''' and usage = 1');
          commit;
       elsif i_table_name is not null and i_schema is not null then
          execute immediate('update DWH_MTD.ETL_DELTA_LOG set usage = 0 where schema_name = '''||i_schema||''' and  table_name = '''||i_table_name||''' and usage = 1');
          commit;
       end if;
       dbatools.debug('DWH_TOOLS.reset_delta_log', i_schema||' zurückgesetzt');
    end reset_delta_log;

    --convertiert einen Timestam in einen Integerwert als Millisekunden seid dem 1.1.1970
    function conv_ts_2_int(i_ts in timestamp) return number
    is
       v_int        number;
       v_difference INTERVAL DAY(8) TO SECOND(6);
    begin
       v_difference := i_ts - TIMESTAMP '1970-01-01 00:00:00 UTC';
       v_int :=  EXTRACT( DAY    FROM v_difference ) * 24 * 60 * 60 * 1000
               + EXTRACT( HOUR   FROM v_difference ) *      60 * 60 * 1000
               + EXTRACT( MINUTE FROM v_difference ) *           60 * 1000
               + EXTRACT( SECOND FROM v_difference ) *                1000;
       return v_int;
    end conv_ts_2_int;

    --convertiert einen Millisekunden-Integer zurück nach timestamp
    function conv_int_2_ts(i_num in number) return timestamp
    is
       v_ts timestamp;
    begin
       v_ts := TIMESTAMP '1970-01-01 00:00:00' + numtodsinterval( i_num/ 1000, 'SECOND');
       return v_ts;
    end conv_int_2_ts;

    --checht, ob es die Dummy_Einträge in c_dwh_joblist gibt, wenn nicht, werden sie angelegt
    procedure rebuild_dummies is
       i       integer;
       v_sql   varchar2(4000);
       v_ok    integer;
       cursor c(vc_jobname in varchar2) is select 1 from dwh_dm.c_dwh_joblist where job_name = vc_jobname;
    begin
       for i in 1 .. 10 loop
           v_sql := 'INSERT INTO dwh_dm.c_dwh_joblist (job_name, is_periodic, last_executed_on, last_finished_on, fix_run_date, months_list, week_of_months_list, week_of_year_list, day_of_months_list, day_of_week_list, hour_list, minute_list, command, arg_list, ist_aktiv, asap, last_error, cmd_type, invalid_hours) VALUES (''DUMMY'||i||''', 1, to_date(''11110101'',''YYYYMMDD''), to_date(''11110101'',''YYYYMMDD''), to_date(''99991231'',''YYYYMMDD''), 0, 0, 0, 0, 0, ''00'', ''00'', ''DUMMY'||i||''', ''-'', 0, 0, ''-'', ''PCK'', 1)';
           v_ok := 0;
           for rc in c('DUMMY'||i) loop
              v_ok := 1;
           end loop;
           if v_ok = 0 then
              execute immediate(v_sql);
           end if;
       end loop;
       commit;
    end rebuild_dummies;

    --schaltet die Synonyme von den Switch-Tabellen um
    --Die Möglichkeit für Force=1 brauchen wir für die truncate_dm Prozedur nach Fehlern
    procedure switch_fact_syns(i_force in integer default 0) is
       v_current_sync_dir   varchar2(10);
       v_write_sync_dir     varchar2(10);
       v_read_sync_dir      varchar2(10);
       v_table_list         varchar2(1000 char);
       v_switch_state       varchar2(100 char);
       cursor c(vc_table_list in varchar2, vc_write_sync_dir in varchar2, vc_read_sync_dir in varchar2) is with rws as (
                  select vc_table_list str from dual
                ), vlist as (
                  select regexp_substr (
                           str,
                           '[^,]+',
                           1,
                           level
                         )||'_A' s_table
                  from   rws
                  connect by level <=
                    length ( str ) - length ( replace ( str, ',' ) ) + 1
                    union
                    select regexp_substr (
                           str,
                           '[^,]+',
                           1,
                           level
                         )||'_B' s_table
                  from   rws
                  connect by level <=
                    length ( str ) - length ( replace ( str, ',' ) ) + 1
                )
                SELECT s.synonym_name,
                   case when s.synonym_name like 'SR_F%' or s.synonym_name like 'SL_F%' or s.synonym_name like 'S_F%' then substr(s.table_name, 1,length(s.table_name)-1)||vc_read_sync_dir when s.synonym_name like 'SW_C_F%' then substr(s.table_name, 1,length(s.table_name)-1)||vc_write_sync_dir end neu_name
                FROM all_synonyms s
                join vlist vl on owner = 'DWH_DM' and table_owner = 'DWH_DM' and vl.s_table = s.table_name
                where s.synonym_name not like 'S_F%';

    begin
       v_table_list := get_param('DM_TABLE_LIST_FOR_SWITCHING');
       v_current_sync_dir := get_param('SYN_ON_DM_SWITCH_DIRECTION');
       v_switch_state := get_param('DM_SWITCH_STATE');
       if v_table_list <> '-'  then
          if v_table_list <> '-' and (v_switch_state = 'success' or i_force = 1 ) then
              v_write_sync_dir := v_current_sync_dir;
              v_read_sync_dir := case when v_current_sync_dir = 'A' then 'B' else 'A' end;
          else
              v_read_sync_dir := v_current_sync_dir;
              v_write_sync_dir := case when v_current_sync_dir = 'A' then 'B' else 'A' end;
          end if;
          for rc in c(v_table_list, v_write_sync_dir, v_read_sync_dir) loop
             --dbms_output.put_line('switch_fact_syns syn: ' ||rc.synonym_name||' tab: '|| rc.neu_name);
             if v_table_list <> '-' and (v_switch_state = 'success' or i_force = 1 ) then
               dwh_dm.switch_fact_syn(rc.neu_name, rc.synonym_name);
             end if;

             if  rc.synonym_name like 'SW_C_F_%' then
               --truncate write Target Table
               dwh_dm.TRUNC_DM_FACT_TABLE(rc.neu_name);
             end if;

          end loop;
       end if;
       if v_table_list <> '-' and (v_switch_state = 'success' or i_force = 1 ) then
          set_param('SYN_ON_DM_SWITCH_DIRECTION',v_read_sync_dir);
       end if;
       set_param('DM_SWITCH_STATE','running');
    end switch_fact_syns;

    --schaltet die externen Lease-Synonyme von den Switch-Tabellen um
    --Die Möglichkeit für Force=1 brauchen wir für die truncate_dm Prozedur nach Fehlern
    --S_F... Synonyme umzuschalten
    procedure switch_read_syns_on_success is
       v_current_sync_dir   varchar2(10);
       v_write_sync_dir     varchar2(10);
       v_read_sync_dir      varchar2(10);
       v_table_list         varchar2(1000 char);
       v_switch_state       varchar2(100 char);
       cursor c(vc_table_list in varchar2, vc_write_sync_dir in varchar2, vc_read_sync_dir in varchar2) is with rws as (
                  select vc_table_list str from dual
                ), vlist as (
                  select regexp_substr (
                           str,
                           '[^,]+',
                           1,
                           level
                         )||'_A' s_table
                  from   rws
                  connect by level <=
                    length ( str ) - length ( replace ( str, ',' ) ) + 1
                    union
                    select regexp_substr (
                           str,
                           '[^,]+',
                           1,
                           level
                         )||'_B' s_table
                  from   rws
                  connect by level <=
                    length ( str ) - length ( replace ( str, ',' ) ) + 1
                )
                SELECT s.synonym_name,
                   case when s.synonym_name like 'SR_F%' or s.synonym_name like 'SL_F%' or s.synonym_name like 'S_F%' then substr(s.table_name, 1,length(s.table_name)-1)||vc_read_sync_dir when s.synonym_name like 'SW_C_F%' then substr(s.table_name, 1,length(s.table_name)-1)||vc_write_sync_dir end neu_name
                FROM all_synonyms s
                join vlist vl on owner = 'DWH_DM' and table_owner = 'DWH_DM' and vl.s_table = s.table_name
                where s.synonym_name like 'S_F%';
    begin
       v_table_list := get_param('DM_TABLE_LIST_FOR_SWITCHING');
       v_current_sync_dir := get_param('SYN_ON_DM_SWITCH_DIRECTION');
       v_switch_state := get_param('DM_SWITCH_STATE');
       if v_table_list <> '-' and v_switch_state <> 'success' then
          v_write_sync_dir := v_current_sync_dir;
          v_read_sync_dir := case when v_current_sync_dir = 'A' then 'B' else 'A' end;
          for rc in c(v_table_list, v_write_sync_dir, v_read_sync_dir) loop
             --dbms_output.put_line('switch_fact_syns syn: ' ||rc.synonym_name||' tab: '|| rc.neu_name);
             dwh_dm.switch_fact_syn(rc.neu_name, rc.synonym_name);
          end loop;
          set_param('DM_READ_SYN_DIRECTION',v_write_sync_dir);
          set_param('DM_SWITCH_STATE','success');
       end if;
    end switch_read_syns_on_success;


    --schaltet die Synonyme von den Switch-Tabellen in CORE um
    --Die Möglichkeit für Force=1 brauchen wir für die trunc_core_table Prozedur nach Fehlern
    procedure switch_core_syns(i_force in integer default 0) is
       v_current_sync_dir   varchar2(10);
       v_write_sync_dir     varchar2(10);
       v_read_sync_dir      varchar2(10);
       v_table_list         varchar2(1000 char);
       v_switch_state       varchar2(100 char);
       cursor c(vc_table_list in varchar2, vc_write_sync_dir in varchar2, vc_read_sync_dir in varchar2) is with rws as (
                  select vc_table_list str from dual
                ), vlist as (
                  select regexp_substr (
                           str,
                           '[^,]+',
                           1,
                           level
                         )||'_A' s_table
                  from   rws
                  connect by level <=
                    length ( str ) - length ( replace ( str, ',' ) ) + 1
                    union
                    select regexp_substr (
                           str,
                           '[^,]+',
                           1,
                           level
                         )||'_B' s_table
                  from   rws
                  connect by level <=
                    length ( str ) - length ( replace ( str, ',' ) ) + 1
                )
                SELECT s.synonym_name,
                   case when s.synonym_name like 'SL_%' or s.synonym_name like 'SR_%' or s.synonym_name like 'S_BV%'  or s.synonym_name like 'S_S%'  or s.synonym_name like 'S_L%'then substr(s.table_name, 1,length(s.table_name)-1)||vc_read_sync_dir when s.synonym_name like 'SW_C_%' then substr(s.table_name, 1,length(s.table_name)-1)||vc_write_sync_dir end neu_name
                FROM all_synonyms s
                join vlist vl on owner = 'DWH_CORE' and table_owner = 'DWH_CORE' and vl.s_table = s.table_name
                where substr(s.synonym_name,1,2) <> 'S_';

    begin
       v_table_list := get_param('CORE_TABLE_LIST_FOR_SWITCHING');
       v_current_sync_dir := get_param('SYN_ON_CORE_SWITCH_DIRECTION');
       v_switch_state := get_param('CORE_SWITCH_STATE');
       if v_table_list <> '-'  then
          if v_table_list <> '-' and (v_switch_state = 'success' or i_force = 1 ) then
              v_write_sync_dir := v_current_sync_dir;
              v_read_sync_dir := case when v_current_sync_dir = 'A' then 'B' else 'A' end;
          else
              v_read_sync_dir := v_current_sync_dir;
              v_write_sync_dir := case when v_current_sync_dir = 'A' then 'B' else 'A' end;
          end if;
          for rc in c(v_table_list, v_write_sync_dir, v_read_sync_dir) loop
             --dbms_output.put_line('switch_fact_syns syn: ' ||rc.synonym_name||' tab: '|| rc.neu_name);
             if v_table_list <> '-' and (v_switch_state = 'success' or i_force = 1 ) then
               dwh_core.switch_core_syn(rc.neu_name, rc.synonym_name);
             end if;

             if  rc.synonym_name like 'SW_C_%' then
               --truncate write Target Table
               dwh_core.TRUNC_CORE_TABLE(rc.neu_name);
             end if;

          end loop;
       end if;
       if v_table_list <> '-' and (v_switch_state = 'success' or i_force = 1 ) then
          set_param('SYN_ON_CORE_SWITCH_DIRECTION',v_read_sync_dir);
       end if;
       set_param('CORE_SWITCH_STATE','running');
    end switch_core_syns;

    --schaltet die externen Lease-Synonyme von den Switch-Tabellen um
    --Die Möglichkeit für Force=1 brauchen wir für die truncate_dm Prozedur nach Fehlern
    --S_... Synonyme umzuschalten
    procedure switch_core_read_syns_on_success is
       v_current_sync_dir   varchar2(10);
       v_write_sync_dir     varchar2(10);
       v_read_sync_dir      varchar2(10);
       v_table_list         varchar2(1000 char);
       v_switch_state       varchar2(100 char);
       cursor c(vc_table_list in varchar2, vc_write_sync_dir in varchar2, vc_read_sync_dir in varchar2) is with rws as (
                  select vc_table_list str from dual
                ), vlist as (
                  select regexp_substr (
                           str,
                           '[^,]+',
                           1,
                           level
                         )||'_A' s_table
                  from   rws
                  connect by level <=
                    length ( str ) - length ( replace ( str, ',' ) ) + 1
                    union
                    select regexp_substr (
                           str,
                           '[^,]+',
                           1,
                           level
                         )||'_B' s_table
                  from   rws
                  connect by level <=
                    length ( str ) - length ( replace ( str, ',' ) ) + 1
                )
                SELECT s.synonym_name,
                   case when s.synonym_name like 'SL_%' or s.synonym_name like 'SR_%' or s.synonym_name like 'S_BV%'  or s.synonym_name like 'S_S%'  or s.synonym_name like 'S_L%'then substr(s.table_name, 1,length(s.table_name)-1)||vc_read_sync_dir when s.synonym_name like 'SW_C_%' then substr(s.table_name, 1,length(s.table_name)-1)||vc_write_sync_dir end neu_name
                FROM all_synonyms s
                join vlist vl on owner = 'DWH_CORE' and table_owner = 'DWH_CORE' and vl.s_table = s.table_name
                where substr(s.synonym_name,1,2) = 'S_';
    begin
       v_table_list := get_param('CORE_TABLE_LIST_FOR_SWITCHING');
       v_current_sync_dir := get_param('SYN_ON_CORE_SWITCH_DIRECTION');
       v_switch_state := get_param('CORE_SWITCH_STATE');
       if v_table_list <> '-' and v_switch_state <> 'success' then
          v_write_sync_dir := v_current_sync_dir;
          v_read_sync_dir := case when v_current_sync_dir = 'A' then 'B' else 'A' end;
          for rc in c(v_table_list, v_write_sync_dir, v_read_sync_dir) loop
             --dbms_output.put_line('switch_fact_syns syn: ' ||rc.synonym_name||' tab: '|| rc.neu_name);
             dwh_core.switch_core_syn(rc.neu_name, rc.synonym_name);
          end loop;
          set_param('CORE_READ_SYN_DIRECTION',v_write_sync_dir);
          set_param('CORE_SWITCH_STATE','success');
       end if;
    end switch_core_read_syns_on_success;

END dwh_tools;
/

