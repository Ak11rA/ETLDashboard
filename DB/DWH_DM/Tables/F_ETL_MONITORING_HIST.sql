/*-----------------------------------------------------------------------------
|| Tabellen-Skript der Tabelle F_ETL_MONITORING_HIST
*/-----------------------------------------------------------------------------


  CREATE TABLE "DWH_DM"."F_ETL_MONITORING_HIST"
   (	"DWH_LADE_ID" NUMBER NOT NULL ENABLE,
	"FETLMONH_ID" NUMBER NOT NULL ENABLE,
	"FETLMONH2_ID" NUMBER DEFAULT 1 NOT NULL ENABLE,
	"DETLLP_ID" NUMBER NOT NULL ENABLE,
	"DDATU_ID_START" NUMBER NOT NULL ENABLE,
	"START_ZEIT" DATE,
	"DDATU_ID_ENDE" NUMBER NOT NULL ENABLE,
	"ENDE_ZEIT" DATE,
	"DETLST_ID" NUMBER NOT NULL ENABLE,
	"DAUER_IN_SEK" NUMBER,
	"DATENSAETZE_EINGEFUEGT" NUMBER,
	"DATENSAETZE_AKTUALISIERT" NUMBER,
	"DATENSAETZE_GELOESCHT" NUMBER,
	 CONSTRAINT "FETLMONH_PK" PRIMARY KEY ("FETLMONH_ID", "FETLMONH2_ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "DWH_DM"  ENABLE
   ) SEGMENT CREATION IMMEDIATE
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  TABLESPACE "DWH_DM" ;

-------------------
-- Zugehörige Kommentare
-------------------

   COMMENT ON COLUMN "DWH_DM"."F_ETL_MONITORING_HIST"."DWH_LADE_ID" IS 'Schlüssel zu den Laufzeitinformationen des Prozesses der die Daten in die Tabelle eingefügt bzw. bearbeitet hat.';
   COMMENT ON COLUMN "DWH_DM"."F_ETL_MONITORING_HIST"."FETLMONH_ID" IS 'Eindeutiger Schlüssel der Faktentabelle, entspricht der technischen ID aus dem ODI-Repository, die der Ladeplan-Ausführung zugeordnet wurde.';
   COMMENT ON COLUMN "DWH_DM"."F_ETL_MONITORING_HIST"."FETLMONH2_ID" IS 'Zweiter Bestandteil des eindeutiger Schlüssel der Faktentabelle, entspricht der hochzählenden Nummer NB_RUN für den Fall, dass ein abgebrochener Ladeplan restartet wird.';
   COMMENT ON COLUMN "DWH_DM"."F_ETL_MONITORING_HIST"."DETLLP_ID" IS 'Ladeplan. Fremdschlüssel zur Dimension D_LADEPLAN.';
   COMMENT ON COLUMN "DWH_DM"."F_ETL_MONITORING_HIST"."DDATU_ID_START" IS 'Tag, an dem die Ausführung des Ladeplans gestartet wurde. Fremdschlüssel zur Dimension D_DATUM.';
   COMMENT ON COLUMN "DWH_DM"."F_ETL_MONITORING_HIST"."START_ZEIT" IS 'Genauer Zeitpunkt, an dem die Ausführung des Ladeplans gestartet wurde.';
   COMMENT ON COLUMN "DWH_DM"."F_ETL_MONITORING_HIST"."DDATU_ID_ENDE" IS 'Tag, an dem die Ausführung des Ladeplans beendet wurde. Fremdschlüssel zur Dimension D_DATUM.';
   COMMENT ON COLUMN "DWH_DM"."F_ETL_MONITORING_HIST"."ENDE_ZEIT" IS 'Genauer Zeitpunkt, an dem die Ausführung des Ladeplans beendet wurde.';
   COMMENT ON COLUMN "DWH_DM"."F_ETL_MONITORING_HIST"."DETLST_ID" IS 'Status des ausgeführten/laufenden Ladeplans. Fremdschlüssel zur Dimension D_ETL_STATUS.';
   COMMENT ON COLUMN "DWH_DM"."F_ETL_MONITORING_HIST"."DAUER_IN_SEK" IS 'Ausführungszeit (Sekunden), die der Ladeplan benötigt hat.';
   COMMENT ON COLUMN "DWH_DM"."F_ETL_MONITORING_HIST"."DATENSAETZE_EINGEFUEGT" IS 'Anzahl der Datensätze die in den untergeordneten Schritten des Ladeplans eingefügt wurden.';
   COMMENT ON COLUMN "DWH_DM"."F_ETL_MONITORING_HIST"."DATENSAETZE_AKTUALISIERT" IS 'Anzahl der Datensätze die in den untergeordneten Schritten des Ladeplans aktualisiert wurden.';
   COMMENT ON COLUMN "DWH_DM"."F_ETL_MONITORING_HIST"."DATENSAETZE_GELOESCHT" IS 'Anzahl der Datensätze die in den untergeordneten Schritten des Ladeplans gelöscht wurden.';
   COMMENT ON TABLE "DWH_DM"."F_ETL_MONITORING_HIST"  IS 'Übersicht über alle mit dem ODI ausgeführten Ladepläne.
Die Faktentabelle enthält die historischen Daten bis zum letzten Ladezeitpunkt der Tabelle.
Alle danach folgenden Ausführungen (d.h. die aktuellen Ausführungen) werden über einen strukturell identischen View "V_F_ETL_MONITORING_AKT" abgebildet, der direkt auf das ODI-Repository zugreift.

Dient als Grundlage für ein Monitoring der ETL-Prozesse, z.B. über den OBIEE.';

-------------------
-- Zugehörige Indizes
-------------------

-- PK- und UK-Indizes werden nicht separat ausgewiesen

-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_DM"."F_ETL_MONITORING_HIST" TO "HISI";
  GRANT SELECT ON "DWH_DM"."F_ETL_MONITORING_HIST" TO "OBIEE_BEDIAN";
  GRANT UPDATE ON "DWH_DM"."F_ETL_MONITORING_HIST" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."F_ETL_MONITORING_HIST" TO "DWH_WORK";
  GRANT INSERT ON "DWH_DM"."F_ETL_MONITORING_HIST" TO "DWH_WORK";
  GRANT DELETE ON "DWH_DM"."F_ETL_MONITORING_HIST" TO "DWH_WORK";

