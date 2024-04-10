/*-----------------------------------------------------------------------------
|| Tabellen-Skript der Tabelle C_QUELLSYSTEM
*/-----------------------------------------------------------------------------


  CREATE TABLE "DWH_DM"."C_QUELLSYSTEM"
   (	"QUELLE" VARCHAR2(255 CHAR) NOT NULL ENABLE,
	"LADEPLAN_STG" VARCHAR2(255 CHAR),
	"LADEPLAN_DM" VARCHAR2(255 CHAR),
	"SCHEMA_STG" VARCHAR2(255 CHAR),
	 CONSTRAINT "C_QUELLSYSTEM_PK" PRIMARY KEY ("QUELLE")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "DWH_DM"  ENABLE
   ) SEGMENT CREATION IMMEDIATE
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  TABLESPACE "DWH_DM" ;

-------------------
-- Zugehörige Kommentare
-------------------
-- keine Kommentare vorhanden

-------------------
-- Zugehörige Indizes
-------------------

-- PK- und UK-Indizes werden nicht separat ausgewiesen

-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_DM"."C_QUELLSYSTEM" TO "DWH_WORK";
  GRANT UPDATE ON "DWH_DM"."C_QUELLSYSTEM" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."C_QUELLSYSTEM" TO "OBIEE_BEDIAN";
  GRANT DELETE ON "DWH_DM"."C_QUELLSYSTEM" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."C_QUELLSYSTEM" TO "HISI";
  GRANT INSERT ON "DWH_DM"."C_QUELLSYSTEM" TO "DWH_WORK";

