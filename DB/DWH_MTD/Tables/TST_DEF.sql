/*-----------------------------------------------------------------------------
|| Tabellen-Skript der Tabelle TST_DEF
*/-----------------------------------------------------------------------------


  CREATE TABLE "DWH_MTD"."TST_DEF"
   (	"TYPE" VARCHAR2(20 CHAR),
	"TESTCODE_NR" CLOB NOT NULL ENABLE,
	"NAME" VARCHAR2(255 CHAR),
	"ID" NUMBER GENERATED BY DEFAULT ON NULL AS IDENTITY MINVALUE 1 MAXVALUE 9999999999999999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE  NOKEEP  NOSCALE  NOT NULL ENABLE,
	"DESCRIPTION" VARCHAR2(1000 CHAR),
	"SCHEMA" VARCHAR2(255 CHAR),
	"TESTCODE_TXT" CLOB,
	 CONSTRAINT "TST_DEF_PK" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "DWH_MTD"  ENABLE,
	 CONSTRAINT "TST_DEF_UK" UNIQUE ("TYPE", "NAME", "SCHEMA")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "DWH_MTD"  ENABLE
   ) SEGMENT CREATION IMMEDIATE
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  TABLESPACE "DWH_MTD"
 LOB ("TESTCODE_NR") STORE AS SECUREFILE (
  TABLESPACE "DWH_MTD" ENABLE STORAGE IN ROW CHUNK 16384
  NOCACHE LOGGING  NOCOMPRESS  KEEP_DUPLICATES )
 LOB ("TESTCODE_TXT") STORE AS SECUREFILE (
  TABLESPACE "DWH_MTD" ENABLE STORAGE IN ROW CHUNK 16384
  NOCACHE LOGGING  NOCOMPRESS  KEEP_DUPLICATES ) ;

-------------------
-- Zugehörige Kommentare
-------------------

   COMMENT ON COLUMN "DWH_MTD"."TST_DEF"."TYPE" IS 'Type of test';
   COMMENT ON COLUMN "DWH_MTD"."TST_DEF"."TESTCODE_NR" IS 'Code to run - returns error code number';
   COMMENT ON COLUMN "DWH_MTD"."TST_DEF"."NAME" IS 'Name of this test';
   COMMENT ON COLUMN "DWH_MTD"."TST_DEF"."ID" IS 'Number of this test (PK)';
   COMMENT ON COLUMN "DWH_MTD"."TST_DEF"."DESCRIPTION" IS 'Decription of this test';
   COMMENT ON COLUMN "DWH_MTD"."TST_DEF"."SCHEMA" IS 'Target schema which is tested';
   COMMENT ON COLUMN "DWH_MTD"."TST_DEF"."TESTCODE_TXT" IS 'Code to run - Text output';
   COMMENT ON TABLE "DWH_MTD"."TST_DEF"  IS 'Test definitions';

-------------------
-- Zugehörige Indizes
-------------------

-- PK- und UK-Indizes werden nicht separat ausgewiesen

-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_MTD"."TST_DEF" TO "HISI";
  GRANT SELECT ON "DWH_MTD"."TST_DEF" TO "DWH_DM";
  GRANT DELETE ON "DWH_MTD"."TST_DEF" TO "DWH_WORK";
  GRANT INSERT ON "DWH_MTD"."TST_DEF" TO "DWH_WORK";
  GRANT SELECT ON "DWH_MTD"."TST_DEF" TO "DWH_WORK";
  GRANT UPDATE ON "DWH_MTD"."TST_DEF" TO "DWH_WORK";

