/*-----------------------------------------------------------------------------
|| Skript der View V_F_ETL_MONITORING_AKT
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DWH_DM"."V_F_ETL_MONITORING_AKT" ("FETLMONA_ID", "FETLMONA2_ID", "DETLLP_ID", "DDATU_ID_START", "START_ZEIT", "DDATU_ID_ENDE", "ENDE_ZEIT", "DETLST_ID", "DAUER_IN_SEK", "DATENSAETZE_EINGEFUEGT", "DATENSAETZE_AKTUALISIERT", "DATENSAETZE_GELOESCHT") AS
  SELECT
        lpi.i_lp_inst     fetlmona_id,
        lpir.nb_run       fetlmona2_id,
        --lpi.i_load_plan
        nvl((
            SELECT
                detllp_id
            FROM
                d_etl_ladeplan
            WHERE
                d_etl_ladeplan.ladeplan = lpi.load_plan_name
                and d_etl_ladeplan.dwh_aktiv = 1
        ), - 1)           detllp_id,
        nvl((
            SELECT
                ddatu_id
            FROM
                d_datum
            WHERE
                h0l1_datum = trunc(lpir.start_date)
        ), - 1) ddatu_id_start,
        lpir.start_date   start_zeit,
        nvl((
            SELECT
                ddatu_id
            FROM
                d_datum
            WHERE
                h0l1_datum = trunc(lpir.end_date)
        ), - 1) ddatu_id_ende,
        lpir.end_date     ende_zeit,
        nvl((
            SELECT
                detlst_id
            FROM
                d_etl_status
            WHERE
                status_code = lpir.status
        ), - 1) detlst_id,
        nvl(lpir.duration, round((SYSDATE - lpir.start_date) * 24 * 60 * 60, 2)) dauer_in_sek,
        lpisl.ins         datensaetze_eingefuegt,
        lpisl.upd         datensaetze_aktualisiert,
        lpisl.del         datensaetze_geloescht
    FROM
        odiebiv_odi_repo.snp_lp_inst lpi
        INNER JOIN odiebiv_odi_repo.snp_lpi_run lpir ON lpir.i_lp_inst = lpi.i_lp_inst
        LEFT JOIN (
            SELECT
                i_lp_inst,
                nb_run,
                SUM(nb_ins) ins,
                SUM(nb_upd) upd,
                SUM(nb_del) del
            FROM
                odiebiv_odi_repo.snp_lpi_step_log
            GROUP BY
                i_lp_inst,
                nb_run
        ) lpisl ON lpisl.i_lp_inst = lpi.i_lp_inst
                   AND lpisl.nb_run = lpir.nb_run
    WHERE
        NOT EXISTS (
            SELECT
                1
            FROM
                f_etl_monitoring_hist h
            WHERE
                h.fetlmonh_id = lpi.i_lp_inst
                AND h.fetlmonh2_id = lpir.nb_run
        );

-------------------
-- Zugehörige Kommentare
-------------------
-- keine Kommentare vorhanden


-------------------
-- Zugehörige Grants
-------------------

  GRANT INSERT ON "DWH_DM"."V_F_ETL_MONITORING_AKT" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."V_F_ETL_MONITORING_AKT" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."V_F_ETL_MONITORING_AKT" TO "HISI";
  GRANT DELETE ON "DWH_DM"."V_F_ETL_MONITORING_AKT" TO "DWH_WORK";
  GRANT UPDATE ON "DWH_DM"."V_F_ETL_MONITORING_AKT" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."V_F_ETL_MONITORING_AKT" TO "OBIEE_BEDIAN";

