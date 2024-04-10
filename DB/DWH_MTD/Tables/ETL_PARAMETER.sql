/*-----------------------------------------------------------------------------
|| Tabellen-Skript der Tabelle ETL_PARAMETER
*/-----------------------------------------------------------------------------


  CREATE TABLE "DWH_MTD"."ETL_PARAMETER"
   (	"PARAMETER_NAME" VARCHAR2(255 CHAR) NOT NULL ENABLE,
	"CHAR_VALUE_1" VARCHAR2(4000 CHAR),
	"CHAR_VALUE_2" VARCHAR2(4000 CHAR),
	"DATE_VALUE_1" DATE,
	"DATE_VALUE_2" DATE,
	"NUMBER_VALUE_1" NUMBER,
	"NUMBER_VALUE_2" NUMBER,
	"PARAMETER_DESCRIPTION" VARCHAR2(4000 CHAR) DEFAULT '~',
	"CREATED_AT" DATE DEFAULT sysdate NOT NULL ENABLE,
	"CREATED_BY" VARCHAR2(255 CHAR) NOT NULL ENABLE,
	"UPDATED_AT" DATE,
	"UPDATED_BY" VARCHAR2(255 CHAR),
	 CONSTRAINT "ETL_PARAMETER_PK" PRIMARY KEY ("PARAMETER_NAME")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "DWH_MTD"  ENABLE
   ) SEGMENT CREATION IMMEDIATE
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  TABLESPACE "DWH_MTD" ;

-------------------
-- Zugehörige Kommentare
-------------------

   COMMENT ON COLUMN "DWH_MTD"."ETL_PARAMETER"."PARAMETER_NAME" IS 'Unique name of variable or entry';
   COMMENT ON COLUMN "DWH_MTD"."ETL_PARAMETER"."CHAR_VALUE_1" IS 'Value as VARCHAR2 for text';
   COMMENT ON COLUMN "DWH_MTD"."ETL_PARAMETER"."CHAR_VALUE_2" IS 'Value as VARCHAR2 for text';
   COMMENT ON COLUMN "DWH_MTD"."ETL_PARAMETER"."DATE_VALUE_1" IS 'Value as DATE for date';
   COMMENT ON COLUMN "DWH_MTD"."ETL_PARAMETER"."DATE_VALUE_2" IS 'Value as DATE for date';
   COMMENT ON COLUMN "DWH_MTD"."ETL_PARAMETER"."NUMBER_VALUE_1" IS 'Value as NUMBER for numbers';
   COMMENT ON COLUMN "DWH_MTD"."ETL_PARAMETER"."NUMBER_VALUE_2" IS 'Value as NUMBER for numbers';
   COMMENT ON COLUMN "DWH_MTD"."ETL_PARAMETER"."PARAMETER_DESCRIPTION" IS 'Optional description for this entry';
   COMMENT ON COLUMN "DWH_MTD"."ETL_PARAMETER"."CREATED_AT" IS 'Creation time';
   COMMENT ON COLUMN "DWH_MTD"."ETL_PARAMETER"."CREATED_BY" IS 'Creating user';
   COMMENT ON COLUMN "DWH_MTD"."ETL_PARAMETER"."UPDATED_AT" IS 'Update time';
   COMMENT ON COLUMN "DWH_MTD"."ETL_PARAMETER"."UPDATED_BY" IS 'Updating user';
   COMMENT ON TABLE "DWH_MTD"."ETL_PARAMETER"  IS 'Generic table for DWH workflow parameters';

-------------------
-- Zugehörige Indizes
-------------------

-- PK- und UK-Indizes werden nicht separat ausgewiesen

-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_MTD"."ETL_PARAMETER" TO "DWH_WORK";
  GRANT INSERT ON "DWH_MTD"."ETL_PARAMETER" TO "DWH_WORK";
  GRANT DELETE ON "DWH_MTD"."ETL_PARAMETER" TO "DWH_WORK";
  GRANT UPDATE ON "DWH_MTD"."ETL_PARAMETER" TO "DWH_WORK";

