/*-----------------------------------------------------------------------------
|| DDL for Package DWH_TOOLS
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE PACKAGE "DWH_MTD"."DWH_TOOLS" AUTHID current_user AS

  -- Commonly used ETL functions for Data Warehouse applications and Data Vault
  -- Based on the work of Stefan Raabe and Jan Schreiber
  no_watermark  exception;
  PRAGMA EXCEPTION_INIT(no_watermark, -20001);
  -- default hash value for pseudo null entry in hub business keys
  -- result resembles "select STANDARD_HASH('~^') from dual;"
    FUNCTION gc_default_hash RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE;

  -- default value for a pseudo null entry in hubs

    FUNCTION gc_default_bk RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE;

  -- concatenation for hash values, to avoid collisions and real world values

    FUNCTION gc_concat_delimiter RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE;

  -- standard end date value for historization

    FUNCTION gc_end_date RETURN DATE
        DETERMINISTIC
        PARALLEL_ENABLE;

  -- standard start date value

    FUNCTION gc_initial_date RETURN DATE
        DETERMINISTIC
        PARALLEL_ENABLE;

  -- unsorted string in default format

    FUNCTION get_sorted_concat_string (
        i_concatenated_string   IN                      VARCHAR2,
        i_used_seperator        IN                      VARCHAR2 DEFAULT ';'
    ) RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE;

    FUNCTION get_standard_char_format (
        p_value NUMBER
    ) RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE;

    FUNCTION get_standard_char_format (
        p_value DATE
    ) RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE;

    FUNCTION get_standard_char_format (
        p_value TIMESTAMP
    ) RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE;

    FUNCTION is_holiday (
        p_datum DATE,
        p_bundesland VARCHAR2
    ) RETURN NUMBER
        DETERMINISTIC;

    FUNCTION workdays_between (
        p_datum1       DATE,
        p_datum2       DATE,
        p_bundesland   VARCHAR2
    ) RETURN NUMBER
        DETERMINISTIC;

    FUNCTION seconds_between (
        p_ts1 TIMESTAMP,
        p_ts2 TIMESTAMP
    ) RETURN NUMBER
        DETERMINISTIC;

  --Function to calculate the valid_from, valid_to date of groups of rows with identical values in preconfigured columns

    FUNCTION get_interval_borders (
        p_target_table   IN               VARCHAR2,      -- Table name to use the required columns
        p_load_date      IN               DATE           -- DWH_VALID_FROM from source table
    ) RETURN CLOB;

  -- truncate and reload data mart

    procedure reset_data_mart;

  -- process DWH jobs, code for ETL load control

    procedure exec_dwh_jobqueue;                            -- scan dwh_dm.c_dwh_jobqueue for pending jobs and execute them
    -- This is called from ODI when a Load Plan starts
    procedure dwhjq_start_mart (i_cmd in varchar2,
        i_odi_id in number
        );                                                  -- mark start of Loadplan
    -- This is called from ODI when a Load Plan end regularly
    procedure dwhjq_end_mart (i_cmd in varchar2,
        i_odi_id in number
        );                                                  -- mark end of Loadplan
   -- This is called from ODI when a load plan falls into exception
    procedure dwhjq_error_mart (i_cmd in varchar2,
        i_odi_id in number
        );          -- mark error of LOAD_DATA_MART
    function load_is_blocked return number deterministic;   -- returns a number greater then zero if data mart loaded is set to be blocked
    function load_is_xs_blocked return number deterministic;   -- returns a number greater then zero if xs table loading is set to be blocked

    -- This is called by ODI at the beginning of Data Mart load plan to determine whether there is a previous load still running or blocked
    function is_running(i_lp_name in varchar2) return number;

    procedure drop_stale_worktables;                        -- cleanup i- and c-tables in work schema

 -- code needed for reduced data mart (XS tables)

    function get_xs_lower_limit return date;                -- returns the lower date limit for the XS tabel data

    -- This is called from ODI when Data Mart starts loading the xs-tables
    --v_env kann sein ORIG, A1, A2, SEC
    procedure truncate_xs_tables(i_env in varchar2 default 'XS');

    -- This is called from ODI when Data Mart starts loading the a2_agg-tables
    procedure truncate_a2_agg_tables ;

    -- This is called from ODI when Data Mart starts loading the sec-tables
    procedure truncate_sec_tables ;

    procedure set_param(i_param_name in varchar2, i_param_value in varchar2);
    procedure set_sec_param;
    function get_param(i_param_name in varchar2) return varchar2;
    function get_date_param(i_param_name in varchar2) return date;

    function expand_intervall(i_intervall in varchar2, i_min in number, i_max in number) return varchar2;
    FUNCTION get_expanded_intervall (
        i_concatenated_string   IN VARCHAR2,
        i_min                   IN number,
        i_max                   IN number
    ) RETURN VARCHAR2
        DETERMINISTIC
        PARALLEL_ENABLE;

    FUNCTION get_week_of_months (
        i_date   IN date
        )  return varchar2;

    FUNCTION get_last_value (
        i_concatenated_string   IN VARCHAR2,
        i_current               IN number
        )  return number;

    FUNCTION get_job_startable (
        i_job_id   IN number,
        i_ref_date IN date
        )  return number;

    function check_session_running(i_sess_name in varchar2, i_type in varchar2, i_time_limit in number) return number;

    procedure set_job_running(i_job_id in number);
    procedure set_job_ending(i_job_id in number);
    procedure set_job_error(i_job_id in number, i_last_error in varchar2, i_keywords in varchar2);

    function get_start_list return varchar2;
    procedure end_dispatcher_run;

       --Format arg-List: Liste von Parameter-Namen mit Werten, separiert durch Semikolon ( A|1;B|2;C|3)
       --oder einfache Werte-Listen mit Semikolon ( 1;2;3 ).
       --In diesem Fall muss die Reihenfolge und Anzahl den Parametern im ODI-Repository entsprechen
       --i_type ist Name ('N') oder Value ('V')
    function get_job_parameter(i_job_id in number, i_pos in number, i_type in varchar2) return varchar2;

    --funktion, um zu testen, ob in den XS-Tabellen auch wirklich etwas drin steht
    --Dazu muss die Anzahl der Sätze über dem Limit ( Parameter XS_NOT_EMPTY_LIMIT (default 1000 ) liegen
    function check_xs_filled return integer;

    --etl Helpers
    --Procedure called once a day by odi Job to look for new tables. There are entered into dwh_mtd.etl_tables
    procedure check_etl_tables;

    --procedure to enter a new table into dwh_mtd.etl_tables if it doesnt exist. Called from installation script. Put into table properties in modeler, post inst scripts
    procedure add_etl_table(i_table_name in varchar2, i_owner in varchar2, i_source in varchar2);

    --Zurücksetzen des Delta Log nach truncates
    procedure reset_delta_log(i_schema in varchar2, i_table_name in varchar2);

    --convertiert einen Timestam in einen Integerwert als Millisekunden seid dem 1.1.1970
    function conv_ts_2_int(i_ts in timestamp) return number;

    --convertiert einen Millisekunden-Integer zurück nach timestamp
    function conv_int_2_ts(i_num in number) return timestamp;

    --checht, ob es die Dummy_Einträge in c_dwh_joblist gibt, wenn nicht, werden sie angelegt
    procedure rebuild_dummies;

    --schaltet die Synonyme von den Switch-Tabellen um
    --Die Möglichkeit für Force=1 brauchen wir für die truncate_dm Prozedur nach Fehlern
    procedure switch_fact_syns(i_force in integer default 0);

    --schaltet die externen Lease-Synonyme von den Switch-Tabellen um
    --Die Möglichkeit für Force=1 brauchen wir für die truncate_dm Prozedur nach Fehlern
    --S_F... Synonyme umschalten
    procedure switch_read_syns_on_success;


    --schaltet die Synonyme von den Switch-Tabellen in CORE um
    --Die Möglichkeit für Force=1 brauchen wir für die trunc_core_table Prozedur nach Fehlern
    procedure switch_core_syns(i_force in integer default 0);

    --schaltet die externen Lease-Synonyme von den Switch-Tabellen um
    --Die Möglichkeit für Force=1 brauchen wir für die truncate_dm Prozedur nach Fehlern
    --S_... Synonyme umzuschalten
    procedure switch_core_read_syns_on_success;

END dwh_tools;
/


-------------------
-- Zugehörige Grants
-------------------

  GRANT EXECUTE ON "DWH_MTD"."DWH_TOOLS" TO "DWH_WORK";
  GRANT EXECUTE ON "DWH_MTD"."DWH_TOOLS" TO "DWH_CORE";
  GRANT EXECUTE ON "DWH_MTD"."DWH_TOOLS" TO "DWH_DM";

