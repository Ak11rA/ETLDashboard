/*-----------------------------------------------------------------------------
|| Skript der View V_IS_RUNNING
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DWH_MTD"."V_IS_RUNNING" ("LOAD_PLAN_NAME", "IS_RUNNING") AS
  select load_plan_name, dwh_mtd.dwh_tools.is_running(load_plan_name) is_running from (
SELECT distinct load_plan_name FROM ODIEBIV_ODI_REPO.SNP_LP_INST LPI
) order by 1;

-------------------
-- Zugehörige Kommentare
-------------------
-- keine Kommentare vorhanden


-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_MTD"."V_IS_RUNNING" TO "DWH_WORK";
  GRANT SELECT ON "DWH_MTD"."V_IS_RUNNING" TO "HISI";

