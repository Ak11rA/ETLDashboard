/*------------------------------------------------------------------------------
|| Tabellen-Skript der Tabelle C_DWH_JOBQUEUE2
*/------------------------------------------------------------------------------


  CREATE TABLE "DWH_DM"."C_DWH_JOBQUEUE2"
   (	"JOB_ID" NUMBER NOT NULL ENABLE,
	"JOB_NAME" VARCHAR2(20 CHAR),
	"IS_PERIODIC" NUMBER(1,0) NOT NULL ENABLE,
	"CHANGED_ON" DATE NOT NULL ENABLE,
	"LAST_EXECUTED_ON" TIMESTAMP (6),
	"LAST_FINISHED_ON" TIMESTAMP (6),
	"FIX_RUN_DATE" DATE,
	"MONTHS_LIST" VARCHAR2(255) DEFAULT ON NULL '0' NOT NULL ENABLE,
	"WEEK_OF_MONTHS_LIST" VARCHAR2(255 CHAR) DEFAULT ON NULL '0' NOT NULL ENABLE,
	"WEEK_OF_YEAR_LIST" VARCHAR2(255 CHAR) DEFAULT ON NULL '0' NOT NULL ENABLE,
	"DAY_OF_MONTHS_LIST" VARCHAR2(255 CHAR) DEFAULT ON NULL '0' NOT NULL ENABLE,
	"DAY_OF_WEEK_LIST" VARCHAR2(255 CHAR) DEFAULT ON NULL '0' NOT NULL ENABLE,
	"HOUR_LIST" VARCHAR2(255 CHAR) DEFAULT ON NULL '-1' NOT NULL ENABLE,
	"MINUTE_LIST" VARCHAR2(255 CHAR) DEFAULT ON NULL '0' NOT NULL ENABLE,
	"COMMAND" VARCHAR2(2000 CHAR) NOT NULL ENABLE,
	"ARG_LIST" VARCHAR2(2000 CHAR),
	"IST_AKTIV" NUMBER(1,0),
	"ASAP" NUMBER(1,0),
	"LAST_ERROR" CLOB,
	"CMD_TYPE" VARCHAR2(3 CHAR) NOT NULL ENABLE,
	"SCENARIO" VARCHAR2(20 CHAR) DEFAULT '-1' NOT NULL ENABLE,
	"INVALID_HOURS" NUMBER(3,0) DEFAULT ON NULL 0 NOT NULL ENABLE,
	"RESTART_AFTER_ERROR" NUMBER(1,0) DEFAULT ON NULL 0 NOT NULL ENABLE,
	"VERSION" VARCHAR2(20 CHAR) DEFAULT ON NULL '-1' NOT NULL ENABLE,
	"SYNC_MODE" NUMBER(1,0) DEFAULT ON NULL 1 NOT NULL ENABLE,
	 CHECK ( is_periodic IN ( 0, 1 ) ) ENABLE,
	 CHECK ( ist_aktiv IN ( 0, 1 ) ) ENABLE,
	 CHECK ( asap IN ( 0, 1 ) ) ENABLE,
	 CHECK ( cmd_type IN ( 'LP', 'PCK', 'SCE' ) ) ENABLE,
	 CHECK ( restart_after_error IN ( 0, 1 ) ) ENABLE,
	 CHECK ( sync_mode IN ( 1, 2 ) ) ENABLE
   ) SEGMENT CREATION IMMEDIATE
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  TABLESPACE "DWH_DM"
 LOB ("LAST_ERROR") STORE AS SECUREFILE (
  TABLESPACE "DWH_DM" ENABLE STORAGE IN ROW CHUNK 8192
  NOCACHE LOGGING  NOCOMPRESS  KEEP_DUPLICATES ) ;
  CREATE UNIQUE INDEX "DWH_DM"."JOB2_JOB_ID_IDX" ON "DWH_DM"."C_DWH_JOBQUEUE2" ("JOB_ID")
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "DWH_DM" ;
ALTER TABLE "DWH_DM"."C_DWH_JOBQUEUE2" ADD CONSTRAINT "JOB2_PK" PRIMARY KEY ("JOB_ID")
  USING INDEX "DWH_DM"."JOB2_JOB_ID_IDX"  ENABLE;

--------------------
-- ZugehÃ¶rige Kommentare
--------------------

   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."JOB_ID" IS 'ID/Nr des Jobs';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."JOB_NAME" IS 'Eindeutiger Kurz-Name zum einfachen identifizieren des Jobs';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."IS_PERIODIC" IS 'Einzel-Ausführung (0) oder zyklische Wiederholung (1)';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."CHANGED_ON" IS 'Datum, zu dem das Kommando eingegeben / editiert wurde';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."LAST_EXECUTED_ON" IS 'Datum, zu dem das Kommando gestartet wurde';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."LAST_FINISHED_ON" IS 'Datum, zu dem das Kommando zuletzt beendet wurde';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."FIX_RUN_DATE" IS 'Fester Startzeitpunkt bei Einfach-Ausführung';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."MONTHS_LIST" IS 'Liste von Monatszahlen, komma-separiert oder als Intervall, auch als Kombination, gültige Zahlen von 1 bis 12 und 0 für alle
BSP: 1,2,3,12
1-3,12';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."WEEK_OF_MONTHS_LIST" IS 'Liste von Wochenzahlen, komma-separiert oder als Intervall, auch als Kombination, gültige Zahlen von 1 bis 6, Wochenbeginn Montag, F für die erste vollständige Woche, L für die letzte vollständige Arbeits-Woche ( d.h. inkl. Freitag)
BSP: 1,2,3,5
1-3,5
F,L';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."WEEK_OF_YEAR_LIST" IS 'Liste von Wochenzahlen des Jahres, komma-separiert oder als Intervall, auch als Kombination, gültige Zahlen von 1 bis 53, Wochenbeginn Montag, F für die erste  Woche, L für die letzte Woche
BSP: 1,2,3,25
1-3,5
F,L';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."DAY_OF_MONTHS_LIST" IS 'Liste von Tagen, komma-separiert oder als Intervall, auch als Kombination, gültige Zahlen von 1 bis 31, L für Last-Day-of-Months, W für Last-WorkDay-of-Months, F für First-WorkDay-of-Months
BSP: 1,2,3,12, L
1-3,12, L';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."DAY_OF_WEEK_LIST" IS 'Liste von Kürzeln für Wochentage, komma-separiert oder als Intervall, auch als Kombination, gültige Werte MO(1),DI(2),MI(3),DO(4),FR(5),SA(6),SO(7)
BSP:1,2,7
1-5,7';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."HOUR_LIST" IS 'Liste von Stunden, komma-separiert oder als Intervall, auch als Kombination, gültige Zahlen von 0 bis 23
BSP: 1,2,3,12
1-3,12';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."MINUTE_LIST" IS 'Liste von Minuten, komma-separiert oder als Intervall, auch als Kombination, gültige Zahlen von 0 bis 59
Default 0, muss gefüllt sein, sonst würde jede Minute gestartet
BSP: 1,2,3,12
1-3,12';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."COMMAND" IS 'Auszuführender Befehl. Das kann sein:
Prozedur, Bsp: PCK_LOAD_ALL
LOAD_PLAN, Bsp: LOAD_DATA_MART
ODI-Prozedur, Bsp: TRUNCATE_XS_TABLES';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."ARG_LIST" IS 'Argument 1 für die Ausführung';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."IST_AKTIV" IS 'Ist der Job aktiv (1) oder nicht (0)';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."ASAP" IS 'Ausführung so schnell wie möglich (1) oder normal (0). Dies erzwingt den Einzelmodus und hat höhere Prio als ein fixes Start-Datum.';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."LAST_ERROR" IS 'Session-Fehlerausgabe des letzten Laufes';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."CMD_TYPE" IS 'Command-Type :
PCK	ODI-Package
SCE	Szenario, d.h Mart oder Package
LP	LoadPlan';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."SCENARIO" IS 'auszuführendes Scenario, Default -1 bedeutet das neuste
Ansonsten Format: 02_04_00_00';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."INVALID_HOURS" IS 'Nach x Stunden kann der Prozess als gescheitert betrachtet werden';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."RESTART_AFTER_ERROR" IS 'Nach Fehler neu versuchen';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBQUEUE2"."SYNC_MODE" IS 'Synchron-Modus 1 Synchron ( Package wartet auf Command), 2 Asynchron ( Package läuft weiter und waret nicht auf COMMAND )';
   COMMENT ON TABLE "DWH_DM"."C_DWH_JOBQUEUE2"  IS 'Neue Jobqueue-Tabelle mit detaillierten Einstellmöglichkeiten für periodische Prozesse, aber auch mit ad hoc Befehlen und fixen Zeitpunkten';

--------------------
-- ZugehÃ¶rige Indizes
--------------------

-- PK- und UK-Indizes werden nicht separat ausgewiesen

--------------------
-- ZugehÃ¶rige Grants
--------------------

  GRANT DELETE ON "DWH_DM"."C_DWH_JOBQUEUE2" TO "DWH_WORK";
  GRANT INSERT ON "DWH_DM"."C_DWH_JOBQUEUE2" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."C_DWH_JOBQUEUE2" TO "DWH_WORK";
  GRANT UPDATE ON "DWH_DM"."C_DWH_JOBQUEUE2" TO "DWH_WORK";
  GRANT DELETE ON "DWH_DM"."C_DWH_JOBQUEUE2" TO "DWH_MTD";
  GRANT INSERT ON "DWH_DM"."C_DWH_JOBQUEUE2" TO "DWH_MTD";
  GRANT SELECT ON "DWH_DM"."C_DWH_JOBQUEUE2" TO "DWH_MTD";
  GRANT UPDATE ON "DWH_DM"."C_DWH_JOBQUEUE2" TO "DWH_MTD";
  GRANT SELECT ON "DWH_DM"."C_DWH_JOBQUEUE2" TO "OBIEE_BEDIAN";
  GRANT SELECT ON "DWH_DM"."C_DWH_JOBQUEUE2" TO "HISI";
  GRANT DELETE ON "DWH_DM"."C_DWH_JOBQUEUE2" TO "DWH_CORE";
  GRANT INSERT ON "DWH_DM"."C_DWH_JOBQUEUE2" TO "DWH_CORE";
  GRANT SELECT ON "DWH_DM"."C_DWH_JOBQUEUE2" TO "DWH_CORE";
  GRANT UPDATE ON "DWH_DM"."C_DWH_JOBQUEUE2" TO "DWH_CORE";

