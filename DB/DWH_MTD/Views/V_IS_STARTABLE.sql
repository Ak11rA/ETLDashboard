/*-----------------------------------------------------------------------------
|| Skript der View V_IS_STARTABLE
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DWH_MTD"."V_IS_STARTABLE" ("JOB_ID", "JOB_NAME", "IS_PERIODIC", "CHANGED_ON", "LAST_EXECUTED_ON", "LAST_FINISHED_ON", "FIX_RUN_DATE", "MONTHS_LIST", "WEEK_OF_MONTHS_LIST", "WEEK_OF_YEAR_LIST", "DAY_OF_MONTHS_LIST", "DAY_OF_WEEK_LIST", "HOUR_LIST", "MINUTE_LIST", "COMMAND", "ARG_LIST", "IST_AKTIV", "ASAP", "LAST_ERROR", "CMD_TYPE", "SCENARIO", "INVALID_HOURS", "RESTART_AFTER_ERROR", "SYNC_MODE", "ERROR_COUNTER", "SUCCESS_COUNTER", "IS_STARTABLE_NOW", "IS_SESSION_RUNNING_NOW") AS
  select j."JOB_ID",j."JOB_NAME",j."IS_PERIODIC",j."CHANGED_ON",j."LAST_EXECUTED_ON",j."LAST_FINISHED_ON",j."FIX_RUN_DATE",j."MONTHS_LIST",j."WEEK_OF_MONTHS_LIST",j."WEEK_OF_YEAR_LIST",j."DAY_OF_MONTHS_LIST",j."DAY_OF_WEEK_LIST",j."HOUR_LIST",j."MINUTE_LIST",j."COMMAND",j."ARG_LIST",j."IST_AKTIV",j."ASAP",j."LAST_ERROR",j."CMD_TYPE",j."SCENARIO",j."INVALID_HOURS",j."RESTART_AFTER_ERROR",j."SYNC_MODE",j."ERROR_COUNTER",j."SUCCESS_COUNTER", dwh_mtd.dwh_tools.get_job_startable(job_id, sysdate) is_startable_now,
     dwh_mtd.dwh_tools.check_session_running(command, cmd_type, invalid_hours ) is_session_running_now
from dwh_dm.c_dwh_joblist j order by job_id;

-------------------
-- Zugehörige Kommentare
-------------------
-- keine Kommentare vorhanden


-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_MTD"."V_IS_STARTABLE" TO "DWH_WORK";
  GRANT SELECT ON "DWH_MTD"."V_IS_STARTABLE" TO "HISI";

