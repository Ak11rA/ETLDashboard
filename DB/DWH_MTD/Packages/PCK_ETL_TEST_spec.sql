/*-----------------------------------------------------------------------------
|| DDL for Package PCK_ETL_TEST
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE PACKAGE "DWH_MTD"."PCK_ETL_TEST"
authid current_user
IS

  /*  PCK_ETL_TEST
      Package to run ETL unit / set tests periodically.

      v0.1  2017-08-22  Jan Schreiber
      v0.2  2018-02-19  Jan Schreiber
      v1.0  2021-03-03  Jan Schreiber

      Usage:

      pck_etl_test.run_test(<NR>);  Run specific test with ID <NR>
      pck_etl_test.run_all();       Run all active tests
      pck_etl_test.add_new_test(
        p_name in varchar,              -- Name of test, e.g. "test"
        p_testcode_nr in varchar,       -- SQL Code (mandatory, shall return a numeric value greater then 0 in case of error, e.g. "select 0 from dual")
      );

      Deployment:

      1.  create tables in schema DWH_MTD (in given order)
      1.1 TST_DEF (test definitions):                         TST_DEF.sql
      1.2 TST_CNF (test configurations, relates to TST_DEF):  TST_CNF.sql
      1.3 TST_RUN (test runs, relates to TST_CNF):            TST_RUN.sql

      2.  create view, also in schema DWH_MTD
      2.1 V_TST_RUN (view also all test runs, denormalized and readable)

      3.  compile package in schema DWH_WORK (this is necessary to use the insert privileges only available for DWH_WORK)
      3.1 compile package header:                             PCK_ETL_TST_spec.sql
      3.2 compile package body:                               PCK_ETL_TEST_body.sql

      4.  add some tests via pck_etl_test.add_new_test or by importing
      5.  schedule periodic execution of "pck_etl_test.run_all();" via DBMS scheduler or ODI */

  procedure run_test(
        p_config        in number,      -- ID of test to run
        p_result        out varchar     -- Result of the operation
        );

  procedure run_all;

  procedure add_new_test
      (
        p_name in varchar,              -- Name of test (mandatory)
        p_system in varchar,            -- Database system the test shall run (optional, defaults to "ALL")
        p_testcode_nr in varchar,       -- SQL Code (mandatory, shall return a numeric value greater then 0 in case of error)
        p_testcode_txt in varchar,      -- SQL Code (optional, may return an additional text message)
        p_description in varchar,       -- Test definition description (optional)
        p_threshold in number,          -- Threshold (optional, shall be greater then the expected result of p_testcode_nr for a positive test, defaults to 0). Negative numbers are meant as result minimum
        p_remark in varchar,            -- Test configuration remark (optional)
        p_active number,                -- Active flag (optional, 0=inactive, 1=active, defaults to 1)
        p_schema in varchar,            -- Schema to be run against (optional, may be empty)
        p_runschema in varchar,         -- Schema to be run at (optional, defaults to DWH_WORK)
        p_type in varchar,              -- Test type (optional, defaults to SQL and has to be SQL for the test to be executed currently)
        p_result out varchar            -- Result of the operation
      );

END PCK_ETL_TEST;
/


-------------------
-- Zugehörige Grants
-------------------

  GRANT EXECUTE ON "DWH_MTD"."PCK_ETL_TEST" TO "DWH_WORK";

