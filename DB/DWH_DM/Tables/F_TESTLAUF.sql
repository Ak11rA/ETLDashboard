/*-----------------------------------------------------------------------------
|| Tabellen-Skript der Tabelle F_TESTLAUF
*/-----------------------------------------------------------------------------


  CREATE TABLE "DWH_DM"."F_TESTLAUF"
   (	"DWH_LADE_ID" NUMBER NOT NULL ENABLE,
	"D_TSTDEF_ID" NUMBER NOT NULL ENABLE,
	"DDATU_ID_START" NUMBER NOT NULL ENABLE,
	"RUN_ID" NUMBER NOT NULL ENABLE,
	"START_ZEIT" DATE,
	"ENDE_ZEIT" DATE,
	"DAUER_IN_SEK" NUMBER,
	"ERFOLG" NUMBER,
	"TESTERGEBNIS" NUMBER,
	"SCHWELLWERT" NUMBER,
	 CONSTRAINT "F_TESTLAUF_PK" PRIMARY KEY ("RUN_ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "DWH_DM"  ENABLE
   ) SEGMENT CREATION IMMEDIATE
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  TABLESPACE "DWH_DM"
  PARALLEL ;

-------------------
-- Zugehörige Kommentare
-------------------

   COMMENT ON COLUMN "DWH_DM"."F_TESTLAUF"."DWH_LADE_ID" IS 'Schlüssel zu den Laufzeitinformationen des Prozesses der die Daten in die Tabelle eingefügt bzw. bearbeitet hat.';
   COMMENT ON COLUMN "DWH_DM"."F_TESTLAUF"."D_TSTDEF_ID" IS 'Ausgeführter Test. Fremdschlüssel zur Dimension D_TESTDEFINITION.';
   COMMENT ON COLUMN "DWH_DM"."F_TESTLAUF"."DDATU_ID_START" IS 'Tag, an dem der Test gestartet wurde. Fremdschlüssel zur Dimension D_DATUM.';
   COMMENT ON COLUMN "DWH_DM"."F_TESTLAUF"."RUN_ID" IS 'ID des Testlaufes, vergeben durch das Test-Framework.
';
   COMMENT ON COLUMN "DWH_DM"."F_TESTLAUF"."START_ZEIT" IS 'Genauer Zeitpunkt, an dem der Test gestartet wurde.';
   COMMENT ON COLUMN "DWH_DM"."F_TESTLAUF"."ENDE_ZEIT" IS 'Genauer Zeitpunkt, an dem die Ausführung des Tests beendet wurde.';
   COMMENT ON COLUMN "DWH_DM"."F_TESTLAUF"."DAUER_IN_SEK" IS 'Ausführungszeit (Sekunden), die der Test benötigt hat.';
   COMMENT ON COLUMN "DWH_DM"."F_TESTLAUF"."ERFOLG" IS 'Numerisches Flag, das den Testerfolg darstellt (1=erfolgreich, 0=fehlerhaft, -1=Testabbruch).
';
   COMMENT ON COLUMN "DWH_DM"."F_TESTLAUF"."TESTERGEBNIS" IS '(Numerisches) Ergebnis ds Tests.';
   COMMENT ON COLUMN "DWH_DM"."F_TESTLAUF"."SCHWELLWERT" IS 'Schwellwert, ab dem das numerische Testergebnis als Fehler gewertet wird.
';
   COMMENT ON TABLE "DWH_DM"."F_TESTLAUF"  IS 'Übersicht über alle mit dem Test-Framework ausgeführten automatischen Tests.
Diese Tests prüfen interne Zusammenhänge in den Daten des data Warehouse und können auf möglichen Probleme hinweisen.
';

-------------------
-- Zugehörige Indizes
-------------------

-- PK- und UK-Indizes werden nicht separat ausgewiesen

-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_DM"."F_TESTLAUF" TO "HISI";
  GRANT SELECT ON "DWH_DM"."F_TESTLAUF" TO "OBIEE_BEDIAN";
  GRANT UPDATE ON "DWH_DM"."F_TESTLAUF" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."F_TESTLAUF" TO "DWH_WORK";
  GRANT INSERT ON "DWH_DM"."F_TESTLAUF" TO "DWH_WORK";
  GRANT DELETE ON "DWH_DM"."F_TESTLAUF" TO "DWH_WORK";

