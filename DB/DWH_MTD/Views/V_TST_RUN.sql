/*-----------------------------------------------------------------------------
|| Skript der View V_TST_RUN
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DWH_MTD"."V_TST_RUN" ("RUNID", "CONFID", "TSTID", "TEST", "SCHEMA", "TYP", "BESCHREIBUNG", "ERGEBNIS", "STARTZEIT", "LAUFZEIT", "BEMERKUNG", "FEHLER") AS
  select
  r.id as RunID,
  c.id as ConfID,
  d.id as TstID,
  d.name as Test,
  d.schema as Schema,
  d.type as Typ,
  substr(d.description,1,60) as Beschreibung,
  r.grade as Ergebnis,
  r.RUN_BEGIN as Startzeit,
  r.RUN_END - r.RUN_BEGIN as Laufzeit,
  r.remark as Bemerkung,
  r.error as Fehler
from dwh_mtd.tst_run r
  join dwh_mtd.tst_cnf c on r.config = c.id
  join dwh_mtd.tst_def d on c.TEST = d.id
where
  c.active = 1
order by r.id asc;

-------------------
-- Zugehörige Kommentare
-------------------

   COMMENT ON TABLE "DWH_MTD"."V_TST_RUN"  IS 'Zeigt alle g�ltigen Testl�ufe.';


-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_MTD"."V_TST_RUN" TO "OBIEE_BEDIAN";
  GRANT SELECT ON "DWH_MTD"."V_TST_RUN" TO "HISI";
  GRANT SELECT ON "DWH_MTD"."V_TST_RUN" TO "DWH_DM" WITH GRANT OPTION;
  GRANT SELECT ON "DWH_MTD"."V_TST_RUN" TO "DWH_WORK";

