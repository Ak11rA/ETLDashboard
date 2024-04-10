/*-----------------------------------------------------------------------------
|| Tabellen-Skript der Tabelle ETL_CONFIGURATION
*/-----------------------------------------------------------------------------


  CREATE TABLE "DWH_MTD"."ETL_CONFIGURATION"
   (	"PROCESS_NAME" VARCHAR2(255 CHAR) NOT NULL ENABLE,
	"CONFIGURATION" VARCHAR2(255 CHAR) NOT NULL ENABLE,
	"CHAR_VALUE" VARCHAR2(255 CHAR),
	"DATE_VALUE" DATE,
	"NUMBER_VALUE" NUMBER,
	"CONFIGURATION_DESCRIPTION" VARCHAR2(4000 CHAR),
	"CREATED_AT" DATE DEFAULT sysdate NOT NULL ENABLE,
	"CREATED_BY" VARCHAR2(255 CHAR) NOT NULL ENABLE,
	"UPDATED_AT" DATE,
	"UPDATED_BY" VARCHAR2(255 CHAR),
	 CONSTRAINT "ETL_CONFIGURATION_PK" PRIMARY KEY ("PROCESS_NAME", "CONFIGURATION")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "DWH_MTD"  ENABLE
   ) SEGMENT CREATION IMMEDIATE
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  TABLESPACE "DWH_MTD" ;

-------------------
-- Zugehörige Kommentare
-------------------

   COMMENT ON COLUMN "DWH_MTD"."ETL_CONFIGURATION"."PROCESS_NAME" IS 'ETL process for this configuration';
   COMMENT ON COLUMN "DWH_MTD"."ETL_CONFIGURATION"."CONFIGURATION" IS 'Name of this configuration (unique for this process)';
   COMMENT ON COLUMN "DWH_MTD"."ETL_CONFIGURATION"."CHAR_VALUE" IS 'Character configuration value';
   COMMENT ON COLUMN "DWH_MTD"."ETL_CONFIGURATION"."DATE_VALUE" IS 'Date configuration value';
   COMMENT ON COLUMN "DWH_MTD"."ETL_CONFIGURATION"."NUMBER_VALUE" IS 'Numeric configuration value';
   COMMENT ON COLUMN "DWH_MTD"."ETL_CONFIGURATION"."CONFIGURATION_DESCRIPTION" IS 'Optional description for this configuration';
   COMMENT ON COLUMN "DWH_MTD"."ETL_CONFIGURATION"."CREATED_AT" IS 'Creation time of this configuration';
   COMMENT ON COLUMN "DWH_MTD"."ETL_CONFIGURATION"."CREATED_BY" IS 'Database user who set this configuration initally';
   COMMENT ON COLUMN "DWH_MTD"."ETL_CONFIGURATION"."UPDATED_AT" IS 'Time of last change';
   COMMENT ON COLUMN "DWH_MTD"."ETL_CONFIGURATION"."UPDATED_BY" IS 'Database user who introduces last change';
   COMMENT ON TABLE "DWH_MTD"."ETL_CONFIGURATION"  IS 'ETL coniguration table';

-------------------
-- Zugehörige Indizes
-------------------

-- PK- und UK-Indizes werden nicht separat ausgewiesen

-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_MTD"."ETL_CONFIGURATION" TO "DWH_WORK";
  GRANT DELETE ON "DWH_MTD"."ETL_CONFIGURATION" TO "DWH_WORK";
  GRANT INSERT ON "DWH_MTD"."ETL_CONFIGURATION" TO "DWH_WORK";
  GRANT UPDATE ON "DWH_MTD"."ETL_CONFIGURATION" TO "DWH_WORK";
  GRANT SELECT ON "DWH_MTD"."ETL_CONFIGURATION" TO "OBIEE_BEDIAN";

