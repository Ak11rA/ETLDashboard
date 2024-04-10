/*-----------------------------------------------------------------------------
|| Skript der View V_TST_RUN
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DWH_DM"."V_TST_RUN" ("RUNID", "CONFID", "TSTID", "TEST", "SCHEMA", "TYP", "BESCHREIBUNG", "ERGEBNIS", "STARTZEIT", "LAUFZEIT", "BEMERKUNG", "FEHLER") AS
  SELECT
		"RUNID","CONFID","TSTID","TEST","SCHEMA","TYP","BESCHREIBUNG","ERGEBNIS","STARTZEIT","LAUFZEIT","BEMERKUNG","FEHLER"
	FROM
		dwh_mtd.v_tst_run;

-------------------
-- Zugehörige Kommentare
-------------------

   COMMENT ON TABLE "DWH_DM"."V_TST_RUN"  IS 'Zeigt alle gültigen Testläufe.';


-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_DM"."V_TST_RUN" TO "HISI";
  GRANT SELECT ON "DWH_DM"."V_TST_RUN" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."V_TST_RUN" TO "OBIEE_BEDIAN";

