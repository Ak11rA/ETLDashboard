/*-----------------------------------------------------------------------------
|| Skript der View V_VAL_LAST_TABLE_GEN_LOG
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DWH_MTD"."V_VAL_LAST_TABLE_GEN_LOG" ("GEN_EXEC_LOG_ID", "TEXT", "TIME_STAMP", "SCOPE", "USER_NAME", "CONTENT") AS
  select "GEN_EXEC_LOG_ID","TEXT","TIME_STAMP","SCOPE","USER_NAME","CONTENT" from gen_exec_log
WHERE 1=1
AND time_stamp >= (select max(time_stamp) from gen_exec_log where text = 'Table generation started')
AND lower(scope) like 'dwh_generator.%'
order by time_stamp desc;

-------------------
-- Zugehörige Kommentare
-------------------
-- keine Kommentare vorhanden


-------------------
-- Zugehörige Grants
-------------------
-- keine Grants vorhanden

