/*-----------------------------------------------------------------------------
|| DDL for Package DWH_GENERATOR
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE PACKAGE "DWH_MTD"."DWH_GENERATOR" AUTHID current_user AS

    PROCEDURE get_src_metadata (
        i_src_system_alias IN VARCHAR2
    );

    PROCEDURE create_stg_tables (
        i_source_system_alias   VARCHAR2 DEFAULT '%',
        i_table_name_mask       VARCHAR2 DEFAULT '%',
        i_execute               VARCHAR2 DEFAULT 'N',
        i_include_drop_stmt     VARCHAR2 DEFAULT 'N'
    );

    PROCEDURE create_psa_tables (
        i_source_system_alias   VARCHAR2 DEFAULT '%',
        i_table_name_mask       VARCHAR2 DEFAULT '%',
        i_execute               VARCHAR2 DEFAULT 'N',
        i_include_drop_stmt     VARCHAR2 DEFAULT 'N'
    );

    procedure dmesg (
    p_text      in varchar2,
    p_scope		in varchar2 default 'GroovyGenerator',
    p_severity  in number default 0,
    p_content   in clob default null
    );

END dwh_generator;
/


-------------------
-- Zugehörige Grants
-------------------

  GRANT EXECUTE ON "DWH_MTD"."DWH_GENERATOR" TO "DWH_WORK";

