/*-----------------------------------------------------------------------------
|| Skript der View V_VAL_VERSION
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DWH_MTD"."V_VAL_VERSION" ("CONFIGURATION", "CHAR_VALUE") AS
  SELECT
    configuration,
    char_value
FROM
    dwh_mtd.etl_configuration
WHERE
    configuration LIKE '%_version_%'
    AND   process_name = 'BEDIAN';

-------------------
-- Zugehörige Kommentare
-------------------

   COMMENT ON TABLE "DWH_MTD"."V_VAL_VERSION"  IS 'Zeigt aktuelle Versionen.';


-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_MTD"."V_VAL_VERSION" TO "DWH_WORK";
  GRANT SELECT ON "DWH_MTD"."V_VAL_VERSION" TO "HISI";
  GRANT SELECT ON "DWH_MTD"."V_VAL_VERSION" TO "DWH_DM" WITH GRANT OPTION;

