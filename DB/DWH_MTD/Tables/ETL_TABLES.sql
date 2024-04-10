/*-----------------------------------------------------------------------------
|| Tabellen-Skript der Tabelle ETL_TABLES
*/-----------------------------------------------------------------------------


  CREATE TABLE "DWH_MTD"."ETL_TABLES"
   (	"TAB_ID" NUMBER NOT NULL ENABLE,
	"TAB_NAME" VARCHAR2(100 CHAR) NOT NULL ENABLE,
	"OWNER" VARCHAR2(20 CHAR) NOT NULL ENABLE,
	"INST_DATE" DATE NOT NULL ENABLE,
	"INST_VERSION" VARCHAR2(30 CHAR),
	"SOURCE" VARCHAR2(30 CHAR),
	"CLASS_TYPE" VARCHAR2(30 CHAR),
	"CLASS_STYLE" VARCHAR2(30 CHAR),
	"COPY_TYPE" VARCHAR2(30 CHAR),
	"STATUS" VARCHAR2(30 CHAR) DEFAULT 'ACTIVE',
	 CONSTRAINT "TAB_PK" PRIMARY KEY ("TAB_ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "DWH_MTD"  ENABLE
   ) SEGMENT CREATION IMMEDIATE
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  TABLESPACE "DWH_MTD" ;
  CREATE UNIQUE INDEX "DWH_MTD"."TAB_IDX" ON "DWH_MTD"."ETL_TABLES" ("TAB_NAME", "OWNER")
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "DWH_MTD" ;
ALTER TABLE "DWH_MTD"."ETL_TABLES" ADD CONSTRAINT "TAB_UK" UNIQUE ("TAB_NAME", "OWNER")
  USING INDEX "DWH_MTD"."TAB_IDX"  ENABLE;

-------------------
-- Zugehörige Kommentare
-------------------

   COMMENT ON COLUMN "DWH_MTD"."ETL_TABLES"."TAB_ID" IS 'ID from Sequence ETA_TAB_ID_SEQ';
   COMMENT ON COLUMN "DWH_MTD"."ETL_TABLES"."TAB_NAME" IS 'Tablename';
   COMMENT ON COLUMN "DWH_MTD"."ETL_TABLES"."OWNER" IS 'Schema';
   COMMENT ON COLUMN "DWH_MTD"."ETL_TABLES"."INST_DATE" IS 'Installation date';
   COMMENT ON COLUMN "DWH_MTD"."ETL_TABLES"."INST_VERSION" IS 'Version during installation date';
   COMMENT ON COLUMN "DWH_MTD"."ETL_TABLES"."SOURCE" IS 'ABBA or HF';
   COMMENT ON COLUMN "DWH_MTD"."ETL_TABLES"."CLASS_TYPE" IS 'Fakt, Dimension, Bridge, Configuration, Hub, Satellite oder Link';
   COMMENT ON COLUMN "DWH_MTD"."ETL_TABLES"."CLASS_STYLE" IS 'DV oder BC';
   COMMENT ON COLUMN "DWH_MTD"."ETL_TABLES"."COPY_TYPE" IS 'ORIG, A1 or A2';
   COMMENT ON COLUMN "DWH_MTD"."ETL_TABLES"."STATUS" IS 'ACTIVE, DEPRICATED or DELETED';
   COMMENT ON TABLE "DWH_MTD"."ETL_TABLES"  IS 'Table with table infos';

-------------------
-- Zugehörige Indizes
-------------------

-- PK- und UK-Indizes werden nicht separat ausgewiesen

-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_MTD"."ETL_TABLES" TO "DWH_CORE";
  GRANT UPDATE ON "DWH_MTD"."ETL_TABLES" TO "DWH_CORE";
  GRANT INSERT ON "DWH_MTD"."ETL_TABLES" TO "DWH_DM";
  GRANT SELECT ON "DWH_MTD"."ETL_TABLES" TO "DWH_DM";
  GRANT UPDATE ON "DWH_MTD"."ETL_TABLES" TO "DWH_DM";
  GRANT SELECT ON "DWH_MTD"."ETL_TABLES" TO "HISI";
  GRANT INSERT ON "DWH_MTD"."ETL_TABLES" TO "DWH_WORK";
  GRANT SELECT ON "DWH_MTD"."ETL_TABLES" TO "DWH_WORK";
  GRANT UPDATE ON "DWH_MTD"."ETL_TABLES" TO "DWH_WORK";
  GRANT INSERT ON "DWH_MTD"."ETL_TABLES" TO "DWH_CORE";

