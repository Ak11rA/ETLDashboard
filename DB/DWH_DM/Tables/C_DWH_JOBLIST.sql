/*-----------------------------------------------------------------------------
|| Tabellen-Skript der Tabelle C_DWH_JOBLIST
*/-----------------------------------------------------------------------------


  CREATE TABLE "DWH_DM"."C_DWH_JOBLIST"
   (	"JOB_ID" NUMBER NOT NULL ENABLE,
	"JOB_NAME" VARCHAR2(20 CHAR),
	"IS_PERIODIC" NUMBER(1,0) NOT NULL ENABLE,
	"CHANGED_ON" DATE NOT NULL ENABLE,
	"LAST_EXECUTED_ON" TIMESTAMP (6),
	"LAST_FINISHED_ON" TIMESTAMP (6),
	"FIX_RUN_DATE" DATE,
	"MONTHS_LIST" VARCHAR2(255 BYTE) DEFAULT ON NULL '0' NOT NULL ENABLE,
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
	"SYNC_MODE" NUMBER(1,0) DEFAULT ON NULL 1 NOT NULL ENABLE,
	"ERROR_COUNTER" NUMBER DEFAULT 0,
	"SUCCESS_COUNTER" NUMBER DEFAULT 0,
	 CHECK ( is_periodic IN ( 0, 1 ) ) ENABLE,
	 CHECK ( ist_aktiv IN ( 0, 1 ) ) ENABLE,
	 CHECK ( asap IN ( 0, 1 ) ) ENABLE,
	 CHECK ( cmd_type IN ( 'LP', 'PCK', 'SCE' ) ) ENABLE,
	 CHECK ( restart_after_error IN ( 0, 1 ) ) ENABLE,
	 CHECK ( sync_mode IN ( 1, 2 ) ) ENABLE,
	 CONSTRAINT "JOB2_JOBNAME_UK" UNIQUE ("JOB_NAME")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "DWH_DM"  ENABLE
   ) SEGMENT CREATION IMMEDIATE
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  TABLESPACE "DWH_DM"
  INMEMORY PRIORITY NONE MEMCOMPRESS FOR QUERY LOW
  DISTRIBUTE AUTO NO DUPLICATE
 LOB ("LAST_ERROR") STORE AS SECUREFILE (
  TABLESPACE "DWH_DM" ENABLE STORAGE IN ROW CHUNK 8192
  NOCACHE LOGGING  NOCOMPRESS  KEEP_DUPLICATES ) ;
  CREATE UNIQUE INDEX "DWH_DM"."JOB2_JOB_ID_IDX" ON "DWH_DM"."C_DWH_JOBLIST" ("JOB_ID")
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "DWH_DM" ;
ALTER TABLE "DWH_DM"."C_DWH_JOBLIST" ADD CONSTRAINT "JOB2_PK" PRIMARY KEY ("JOB_ID")
  USING INDEX "DWH_DM"."JOB2_JOB_ID_IDX"  ENABLE;

-------------------
-- Zugehörige Kommentare
-------------------

   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."JOB_ID" IS 'ID/Nr des Jobs';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."JOB_NAME" IS 'Eindeutiger Kurz-Name zum einfachen identifizieren des Jobs';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."IS_PERIODIC" IS 'Einzel-Ausführung (0) oder zyklische Wiederholung (1)';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."CHANGED_ON" IS 'Datum, zu dem das Kommando eingegeben / editiert wurde';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."LAST_EXECUTED_ON" IS 'Datum, zu dem das Kommando gestartet wurde';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."LAST_FINISHED_ON" IS 'Datum, zu dem das Kommando zuletzt beendet wurde';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."FIX_RUN_DATE" IS 'Fester Startzeitpunkt bei Einfach-Ausführung';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."MONTHS_LIST" IS 'Liste von Monatszahlen, komma-separiert oder als Intervall, auch als Kombination, gültige Zahlen von 1 bis 12 und 0 für alle
BSP: 1,2,3,12
1-3,12';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."WEEK_OF_MONTHS_LIST" IS 'Liste von Wochenzahlen, komma-separiert oder als Intervall, auch als Kombination, gültige Zahlen von 1 bis 6, Wochenbeginn Montag, F für die erste vollständige Woche, L für die letzte vollständige Arbeits-Woche ( d.h. inkl. Freitag)
BSP: 1,2,3,5
1-3,5
F,L';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."WEEK_OF_YEAR_LIST" IS 'Liste von Wochenzahlen des Jahres, komma-separiert oder als Intervall, auch als Kombination, gültige Zahlen von 1 bis 53, Wochenbeginn Montag, F für die erste  Woche, L für die letzte Woche
BSP: 1,2,3,25
1-3,5
F,L';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."DAY_OF_MONTHS_LIST" IS 'Liste von Tagen, komma-separiert oder als Intervall, auch als Kombination, gültige Zahlen von 1 bis 31, L für Last-Day-of-Months, W für Last-WorkDay-of-Months, F für First-WorkDay-of-Months
BSP: 1,2,3,12, L
1-3,12, L';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."DAY_OF_WEEK_LIST" IS 'Liste von Kürzeln für Wochentage, komma-separiert oder als Intervall, auch als Kombination, gültige Werte MO(1),DI(2),MI(3),DO(4),FR(5),SA(6),SO(7)
BSP:1,2,7
1-5,7';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."HOUR_LIST" IS 'Liste von Stunden, komma-separiert oder als Intervall, auch als Kombination, gültige Zahlen von 0 bis 23
BSP: 1,2,3,12
1-3,12';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."MINUTE_LIST" IS 'Liste von Minuten, komma-separiert oder als Intervall, auch als Kombination, gültige Zahlen von 0 bis 59
Default 0, muss gefüllt sein, sonst würde jede Minute gestartet
BSP: 1,2,3,12
1-3,12';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."COMMAND" IS 'Auszuführender Befehl. Das kann sein:
Prozedur, Bsp: PCK_LOAD_ALL
LOAD_PLAN, Bsp: LOAD_DATA_MART
ODI-Prozedur, Bsp: TRUNCATE_XS_TABLES';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."ARG_LIST" IS 'Argumente für die Ausführung
--Format arg-List: Liste von Parameter-Namen mit Werten, separiert durch Semikolon ( A:1;B:2;C:3)
       --oder einfache Werte-Listen mit Semikolon ( 1;2;3 ).
       --In diesem Fall muss die Reihenfolge und Anzahl den Parametern im ODI-Repository entsprechen
       --i_type ist Name (''N'') oder Value (''V'')

select arg_list, scen_name, case when instr(svs.var_name,''.'') = 0 then svs.var_name else substr(svs.var_name,instr(svs.var_name,''.'')+1) end var_name, svs.var_param_order from dwh_dm.c_dwh_jobqueue2  cdj
                            join (
                            SELECT ssc.scen_name, nvl(nvl( sp.pack_name, map.name), trt.trt_name) obj_name, ssc.scen_no
                            FROM ODIEBIV_ODI_REPO.snp_scen ssc
                            left outer join ODIEBIV_ODI_REPO.snp_package sp on sp.i_package = ssc.i_package
                            left outer join ODIEBIV_ODI_REPO.snp_mapping map on map.i_mapping = ssc.i_mapping
                            left outer join ODIEBIV_ODI_REPO.snp_trt trt on trt.i_trt = ssc.i_trt
                            ) obj on obj.obj_name = cdj.command
                            left join ODIEBIV_ODI_REPO.snp_var_scen svs on obj.scen_no = svs.scen_no
                            where job_id = :i_job_id;';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."IST_AKTIV" IS 'Ist der Job aktiv (1) oder nicht (0)';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."ASAP" IS 'Ausführung so schnell wie möglich (1) oder normal (0). Dies erzwingt den Einzelmodus und hat höhere Prio als ein fixes Start-Datum.';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."LAST_ERROR" IS 'Session-Fehlerausgabe des letzten Laufes';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."CMD_TYPE" IS 'Command-Type :
PCK	ODI-Package
SCE	Szenario, d.h Mart oder Package
LP	LoadPlan';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."SCENARIO" IS 'auszuführendes Scenario, Default -1 bedeutet das neuste
Ansonsten Format: 02_04_00_00';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."INVALID_HOURS" IS 'Nach x Stunden kann der Prozess als gescheitert betrachtet werden';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."RESTART_AFTER_ERROR" IS 'Nach Fehler neu versuchen';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."SYNC_MODE" IS 'Synchron-Modus 1 Synchron ( Package wartet auf Command), 2 Asynchron ( Package läuft weiter und waret nicht auf COMMAND )';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."ERROR_COUNTER" IS 'Anzahl Fehlerläufe, interessant bei periodischen Jobs. Der explizite Fehler steht nur für den letzten Lauf in LAST_ERROR, für die früheren Läufe muss es aus den ODI-Logs gezogen werden.';
   COMMENT ON COLUMN "DWH_DM"."C_DWH_JOBLIST"."SUCCESS_COUNTER" IS 'Anzahl erfolgreicher Läufe, interessant bei periodischen Jobs.';
   COMMENT ON TABLE "DWH_DM"."C_DWH_JOBLIST"  IS 'Neue Jobqueue-Tabelle mit detaillierten Einstellmöglichkeiten für periodische Prozesse, aber auch mit ad hoc Befehlen und fixen Zeitpunkten';

-------------------
-- Zugehörige Indizes
-------------------

-- PK- und UK-Indizes werden nicht separat ausgewiesen

-------------------
-- Zugehörige Grants
-------------------

  GRANT INSERT ON "DWH_DM"."C_DWH_JOBLIST" TO "DWH_MTD";
  GRANT DELETE ON "DWH_DM"."C_DWH_JOBLIST" TO "DWH_WORK";
  GRANT INSERT ON "DWH_DM"."C_DWH_JOBLIST" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."C_DWH_JOBLIST" TO "DWH_WORK";
  GRANT UPDATE ON "DWH_DM"."C_DWH_JOBLIST" TO "DWH_WORK";
  GRANT DELETE ON "DWH_DM"."C_DWH_JOBLIST" TO "DWH_MTD";
  GRANT SELECT ON "DWH_DM"."C_DWH_JOBLIST" TO "DWH_MTD" WITH GRANT OPTION;
  GRANT UPDATE ON "DWH_DM"."C_DWH_JOBLIST" TO "DWH_MTD";
  GRANT SELECT ON "DWH_DM"."C_DWH_JOBLIST" TO "OBIEE_BEDIAN";
  GRANT SELECT ON "DWH_DM"."C_DWH_JOBLIST" TO "HISI";

