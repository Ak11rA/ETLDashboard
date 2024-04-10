/*-----------------------------------------------------------------------------
|| Skript der View V_ODI_SCEN_LOG
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DWH_MTD"."V_ODI_SCEN_LOG" ("TABLE_NAME", "SESS_NO", "STEP_NAME", "SCEN_NAME", "SCEN_VERSION", "PACK_NAME", "STEP", "NNO", "NB_RUN", "SCEN_TASK_NO", "NB_ROW", "NB_INS", "NB_UPD", "NB_DEL", "NB_ERR", "STEP_DUR", "STEP_BEGIN", "STEP_END", "RETURN_CODE", "SESSION_DUR", "SESSION_BEGIN", "SESSION_END", "SESSION_STATUS", "TASK_DEFINITION", "LOG_SCHEMA", "ERROR_MESSAGE", "TASK_ERROR_MESSAGE") AS
  SELECT
    scs.table_name
  , sess_no
  , scs.step_name
  , sce.scen_name
  , sce.scen_version
  , pck.pack_name
  , to_char(sct.scen_task_no, '099') || ' - ' || sct.task_name1 AS step
  , sct.nno
  , stl.nb_run
  , stl.scen_task_no
  , stl.nb_row
  , stl.nb_ins
  , stl.nb_upd
  , stl.nb_del
  , stl.nb_err
  , stl.task_dur                                                AS step_dur
  , stl.task_beg                                                AS step_begin
  , stl.task_end                                                AS step_end
  , stl.task_rc                                                 AS return_code
  , scr.sess_dur                                                AS session_dur
  , scr.sess_beg                                                AS session_begin
  , scr.sess_end                                                AS session_end
  , scr.sess_status                                             AS session_status
  , stl.def_txt                                                 AS task_definition
  , sct.def_lschema_name                                        AS log_schema
  , scr.error_message                                           AS error_message
  , stl.error_message                                           AS task_error_message
FROM
    ODIEBIV_ODI_REPO.snp_sess_task_log stl
  , ODIEBIV_ODI_REPO.snp_scen_report   scr
  , ODIEBIV_ODI_REPO.snp_scen_task     sct
  , ODIEBIV_ODI_REPO.snp_scen_step     scs
  , ODIEBIV_ODI_REPO.snp_scen          sce
  , ODIEBIV_ODI_REPO.snp_package       pck
WHERE
        scr.scen_run_no = stl.sess_no
    AND sct.scen_no = scr.scen_no
    AND sct.scen_task_no = stl.scen_task_no
    AND scs.scen_no = sct.scen_no
    AND scs.nno = sct.nno
    AND sct.scen_no = sce.scen_no
    and sce.i_package = pck.i_package(+)
ORDER BY
    stl.task_beg desc
  , stl.task_beg desc
  , stl.scen_task_no desc
  , sess_no desc;

-------------------
-- Zugehörige Kommentare
-------------------
-- keine Kommentare vorhanden


-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_MTD"."V_ODI_SCEN_LOG" TO "DWH_WORK";
  GRANT SELECT ON "DWH_MTD"."V_ODI_SCEN_LOG" TO "HISI";

