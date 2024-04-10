/*-----------------------------------------------------------------------------
|| Skript der View V_IS_XS_BLOCKED
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DWH_MTD"."V_IS_XS_BLOCKED" ("LOAD_IS_XS_BLOCKED") AS
  select dwh_mtd.dwh_tools.load_is_xs_blocked from dual;

-------------------
-- Zugehörige Kommentare
-------------------
-- keine Kommentare vorhanden


-------------------
-- Zugehörige Grants
-------------------
-- keine Grants vorhanden

