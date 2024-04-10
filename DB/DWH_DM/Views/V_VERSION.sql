/*-----------------------------------------------------------------------------
|| Skript der View V_VERSION
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DWH_DM"."V_VERSION" ("CONFIGURATION", "CHAR_VALUE") AS
  SELECT
		configuration,
		char_value
	FROM
		dwh_mtd.v_val_version;

-------------------
-- Zugehörige Kommentare
-------------------
-- keine Kommentare vorhanden


-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_DM"."V_VERSION" TO "HISI";
  GRANT SELECT ON "DWH_DM"."V_VERSION" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."V_VERSION" TO "OBIEE_BEDIAN";

