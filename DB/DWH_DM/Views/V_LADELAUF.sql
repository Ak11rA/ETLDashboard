/*-----------------------------------------------------------------------------
|| Skript der View V_LADELAUF
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DWH_DM"."V_LADELAUF" ("QUELLE", "BELADUNG_DATAMART", "BELADUNG_STAGE", "DATENSTAND_QUELLE") AS
  select
    cq.quelle as QUELLE,
    --fetl_dm.ladeplan,
    max(fetl_dm.ende_zeit) as BELADUNG_DATAMART,
    --edl.schema_name,
    MAX(edl.dwh_delta_date) as BELADUNG_STAGE,
    CAST(MAX(TO_TIMESTAMP(edl.high_watermark_src_delta, 'DD.MM.YYYY HH24:MI:SS,FF')) AS DATE) as DATENSTAND_QUELLE
from --dwh_mtd.gen_source_systems gss -- TODO Gibt es nicht nach der EW
    dwh_dm.c_quellsystem cq -- on cq.quelle = gss.source_system_name
join (
                SELECT
                    f.start_zeit,
                    f.ende_zeit,
                    lp.ladeplan,
                    ls.status
                FROM
                    dwh_dm.v_f_etl_monitoring_akt f
                    join dwh_dm.s_d_etl_ladeplan lp on lp.detllp_id = f.detllp_id
                    join dwh_dm.s_d_etl_status ls on ls.detlst_id = f.detlst_id
                UNION
                SELECT
                    f.start_zeit,
                    f.ende_zeit,
                    lp.ladeplan,
                    ls.status
                FROM
                    dwh_dm.s_f_etl_monitoring_hist f
                    join dwh_dm.s_d_etl_ladeplan lp on lp.detllp_id = f.detllp_id
                    join dwh_dm.s_d_etl_status ls on ls.detlst_id = f.detlst_id
            ) fetl_stg on fetl_stg.ladeplan = cq.ladeplan_stg
join (
                SELECT
                    f.start_zeit,
                    f.ende_zeit,
                    f.detlst_id,
                    lp.ladeplan,
                    ls.status
                FROM
                    dwh_dm.v_f_etl_monitoring_akt f
                    join dwh_dm.s_d_etl_ladeplan lp on lp.detllp_id = f.detllp_id
                    join dwh_dm.s_d_etl_status ls on ls.detlst_id = f.detlst_id
                UNION
                SELECT
                    f.start_zeit,
                    f.ende_zeit,
                    f.detlst_id,
                    lp.ladeplan,
                    ls.status
                FROM
                    dwh_dm.s_f_etl_monitoring_hist f
                    join dwh_dm.s_d_etl_ladeplan lp on lp.detllp_id = f.detllp_id
                    join dwh_dm.s_d_etl_status ls on ls.detlst_id = f.detlst_id
            ) fetl_dm on fetl_dm.ladeplan = cq.ladeplan_dm
left join dwh_mtd.etl_delta_log edl on edl.schema_name = cq.schema_stg
where fetl_stg.status = 'Erfolgreich'
    and fetl_dm.status = 'Erfolgreich'
group by cq.quelle --, fetl_dm.ladeplan, edl.schema_name
order by beladung_datamart desc, quelle;

-------------------
-- Zugehörige Kommentare
-------------------

   COMMENT ON TABLE "DWH_DM"."V_LADELAUF"  IS 'View für Zeitpunkte der Datenbewegungen aus den Quellsystemen in das DWH';


-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_DM"."V_LADELAUF" TO "HISI";
  GRANT DELETE ON "DWH_DM"."V_LADELAUF" TO "DWH_WORK";
  GRANT INSERT ON "DWH_DM"."V_LADELAUF" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."V_LADELAUF" TO "DWH_WORK";
  GRANT UPDATE ON "DWH_DM"."V_LADELAUF" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."V_LADELAUF" TO "OBIEE_BEDIAN";

