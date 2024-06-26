/*-----------------------------------------------------------------------------
|| Tabellen-Skript der Tabelle TST_CNF
*/-----------------------------------------------------------------------------


  CREATE TABLE "DWH_MTD"."TST_CNF"
   (	"SYSTEM" VARCHAR2(100 CHAR) NOT NULL ENABLE,
	"RUN_SCHEMA" VARCHAR2(255 CHAR) NOT NULL ENABLE,
	"THRESHOLD" NUMBER NOT NULL ENABLE,
	"REMARK" VARCHAR2(25 CHAR),
	"TEST" NUMBER NOT NULL ENABLE,
	"ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE,
	"ACTIVE" NUMBER DEFAULT 1 NOT NULL ENABLE,
	 CONSTRAINT "TST_CNF_PK" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "DWH_MTD"  ENABLE
   ) SEGMENT CREATION IMMEDIATE
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  TABLESPACE "DWH_MTD" ;

-------------------
-- Zugehörige Kommentare
-------------------

   COMMENT ON COLUMN "DWH_MTD"."TST_CNF"."SYSTEM" IS 'System where the test shall be executed';
   COMMENT ON COLUMN "DWH_MTD"."TST_CNF"."RUN_SCHEMA" IS 'Database schema the test is to run in';
   COMMENT ON COLUMN "DWH_MTD"."TST_CNF"."THRESHOLD" IS 'Result number indicating a test failure';
   COMMENT ON COLUMN "DWH_MTD"."TST_CNF"."REMARK" IS 'Name of this configuration';
   COMMENT ON COLUMN "DWH_MTD"."TST_CNF"."TEST" IS 'Test definition to be used. Foreign key to TST_DEF';
   COMMENT ON COLUMN "DWH_MTD"."TST_CNF"."ID" IS 'Number of this configuration (PK)';
   COMMENT ON COLUMN "DWH_MTD"."TST_CNF"."ACTIVE" IS 'Flag indicating the test shall run';
   COMMENT ON TABLE "DWH_MTD"."TST_CNF"  IS 'Test configuration';

-------------------
-- Zugehörige Indizes
-------------------

-- PK- und UK-Indizes werden nicht separat ausgewiesen

-------------------
-- Zugehörige Grants
-------------------

  GRANT DELETE ON "DWH_MTD"."TST_CNF" TO "DWH_WORK";
  GRANT INSERT ON "DWH_MTD"."TST_CNF" TO "DWH_WORK";
  GRANT SELECT ON "DWH_MTD"."TST_CNF" TO "DWH_WORK";
  GRANT UPDATE ON "DWH_MTD"."TST_CNF" TO "DWH_WORK";
  GRANT SELECT ON "DWH_MTD"."TST_CNF" TO "HISI";
  GRANT SELECT ON "DWH_MTD"."TST_CNF" TO "DWH_DM";

