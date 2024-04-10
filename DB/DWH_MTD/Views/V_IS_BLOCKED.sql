/*-----------------------------------------------------------------------------
|| Skript der View V_IS_BLOCKED
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DWH_MTD"."V_IS_BLOCKED" ("LOAD_IS_BLOCKED") AS
  select dwh_mtd.dwh_tools.load_is_blocked from dual;

-------------------
-- Zugehörige Kommentare
-------------------
-- keine Kommentare vorhanden


-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_MTD"."V_IS_BLOCKED" TO "HISI";
  GRANT SELECT ON "DWH_MTD"."V_IS_BLOCKED" TO "DWH_WORK";

