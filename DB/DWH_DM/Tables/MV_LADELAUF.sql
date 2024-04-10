/*-----------------------------------------------------------------------------
|| Tabellen-Skript der Tabelle MV_LADELAUF
*/-----------------------------------------------------------------------------


  CREATE TABLE "DWH_DM"."MV_LADELAUF"
   (	"QUELLE" VARCHAR2(255 CHAR),
	"BELADUNG_DATAMART" DATE,
	"BELADUNG_STAGE" DATE,
	"DATENSTAND_QUELLE" DATE
   ) SEGMENT CREATION IMMEDIATE
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  TABLESPACE "DWH_DM" ;

-------------------
-- Zugehörige Kommentare
-------------------

   COMMENT ON MATERIALIZED VIEW "DWH_DM"."MV_LADELAUF"  IS 'snapshot table for snapshot DWH_DM.MV_LADELAUF';

-------------------
-- Zugehörige Indizes
-------------------

-- PK- und UK-Indizes werden nicht separat ausgewiesen

-------------------
-- Zugehörige Grants
-------------------

  GRANT DELETE ON "DWH_DM"."MV_LADELAUF" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."MV_LADELAUF" TO "HISI";
  GRANT INSERT ON "DWH_DM"."MV_LADELAUF" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."MV_LADELAUF" TO "DWH_WORK";
  GRANT UPDATE ON "DWH_DM"."MV_LADELAUF" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."MV_LADELAUF" TO "OBIEE_BEDIAN";
  GRANT ALTER ON "DWH_DM"."MV_LADELAUF" TO "DWH_WORK";

