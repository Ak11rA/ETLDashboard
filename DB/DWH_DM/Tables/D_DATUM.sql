/*-----------------------------------------------------------------------------
|| Tabellen-Skript der Tabelle D_DATUM
*/-----------------------------------------------------------------------------


  CREATE TABLE "DWH_DM"."D_DATUM"
   (	"DDATU_ID" NUMBER NOT NULL ENABLE,
	"H0L1_DATUM" DATE,
	"H0L1_TAG_MON_JAHR_BEZ_D" VARCHAR2(20 CHAR),
	"H0L1_TAG_MON_JAHR_BEZ_E" VARCHAR2(20 CHAR),
	"H0L1_TAGKURZ_BEZ_D" VARCHAR2(2 CHAR),
	"H0L1_TAGKURZ_BEZ_E" VARCHAR2(2 CHAR),
	"H0L1_TAGLANG_BEZ_D" VARCHAR2(10 CHAR),
	"H0L1_TAGLANG_BEZ_E" VARCHAR2(10 CHAR),
	"H0L1_WOCHENTAG_NR" NUMBER,
	"H0L1_MONATSTAG_NR" NUMBER,
	"H0L1_JAHRTAGNR" NUMBER,
	"H0L1_GESTERN_ID" NUMBER,
	"H0L1_ARBEITSTAG_BW" NUMBER,
	"H1L2_JAHR_MONAT_ID" NUMBER,
	"H1L2_MONAT_KURZ_D" VARCHAR2(3 CHAR),
	"H1L2_MONAT_KURZ_E" VARCHAR2(3 CHAR),
	"H1L2_MONAT_LANG_BEZ_D" VARCHAR2(10 CHAR),
	"H1L2_MONAT_LANG_BEZ_E" VARCHAR2(10 CHAR),
	"H1L2_MONAT_LANG_BEZ_JAHR_D" VARCHAR2(15 CHAR),
	"H1L2_MONAT_LANG_BEZ_JAHR_E" VARCHAR2(15 CHAR),
	"H1L2_MONAT_NR" NUMBER,
	"H1L2_MONATSTAGE_NR" NUMBER,
	"H1L2_MONATANFANG_ID" NUMBER,
	"H1L2_MONATANFANG_DATUM" DATE,
	"H1L2_MONATENDE_ID" NUMBER,
	"H1L2_MONATENDE_DATUM" DATE,
	"H1L2_LETZTERMONAT_ID" NUMBER,
	"H1L3_QUARTAL_ID" VARCHAR2(7 CHAR),
	"H1L3_QUARTAL_NR" NUMBER,
	"H1L3_QUARTALLANG_BEZ" VARCHAR2(15 CHAR),
	"H1L3_QUARTALTAGE_NR" NUMBER,
	"H1L3_QUARTALANFANG_ID" NUMBER,
	"H1L3_QUARTALANFANG_DATUM" DATE,
	"H1L3_QUARTALENDE_ID" NUMBER,
	"H1L3_QUARTALENDE_DATUM" DATE,
	"H1L3_LETZTESQUARTAL_ID" VARCHAR2(7 CHAR),
	"H1L4_HALBJAHRANFANG_ID" NUMBER,
	"H1L4_HALBJAHRENDE_ID" NUMBER,
	"H1L4_HALBJAHR_NR" NUMBER,
	"H1L4_HALBJAHR_ID" VARCHAR2(6 CHAR),
	"H1L5_JAHR_ID" NUMBER,
	"H1L5_JAHR_BEZ" VARCHAR2(4 CHAR),
	"H1L5_TAGEIMJAHR_NR" NUMBER,
	"H1L5_JAHRANFANG_ID" NUMBER,
	"H1L5_JAHRANFANG_DATUM" DATE,
	"H1L5_JAHRENDE_ID" NUMBER,
	"H1L5_JAHRENDE_DATUM" DATE,
	"H1L5_LETZTESJAHR_ID" NUMBER,
	"H2L2_KW_ID" VARCHAR2(9 CHAR),
	"H2L2_KW_NR" NUMBER,
	"H2L2_KW_JAHR" NUMBER,
	"H2L2_KW_TAGE_NR" NUMBER,
	"H2L2_KW_LANG_BEZ_D" VARCHAR2(45 CHAR),
	"H2L2_KW_LANG_BEZ_E" VARCHAR2(45 CHAR),
	"H2L2_KWANFANG_ID" NUMBER,
	"H2L2_KWENDE_ID" NUMBER,
	"H2L2_LETZTEKW_ID" VARCHAR2(9 CHAR),
	"H2L2_KWANFANG_DATUM" DATE,
	"H2L2_KWENDE_DATUM" DATE,
	 CONSTRAINT "DDATUM_PK" PRIMARY KEY ("DDATU_ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "DWH_DM"  ENABLE
   ) SEGMENT CREATION IMMEDIATE
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255
 NOCOMPRESS LOGGING
  TABLESPACE "DWH_DM" ;
  CREATE UNIQUE INDEX "DWH_DM"."DATUM_UK" ON "DWH_DM"."D_DATUM" ("H0L1_DATUM")
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS
  TABLESPACE "DWH_DM" ;
ALTER TABLE "DWH_DM"."D_DATUM" ADD CONSTRAINT "DDATUM_UK" UNIQUE ("H0L1_DATUM")
  USING INDEX "DWH_DM"."DATUM_UK"  ENABLE;

-------------------
-- Zugehörige Kommentare
-------------------

   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."DDATU_ID" IS '8-stellige Zahl (JJJJMMDD)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H0L1_DATUM" IS 'Datum des Tages (DD.MM.JJJJ)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H0L1_TAG_MON_JAHR_BEZ_D" IS 'Datum des Tages mit ausgeschriebenem Monatsnamen (deutsch)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H0L1_TAG_MON_JAHR_BEZ_E" IS 'Datum des Tages mit ausgeschriebenem Monatsnamen (englisch)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H0L1_TAGKURZ_BEZ_D" IS 'Kurzbezeichnung des Wochentags (2 Buchstaben, deutsch)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H0L1_TAGKURZ_BEZ_E" IS 'Kurzbezeichnung des Wochentags (2 Buchstaben, englisch)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H0L1_TAGLANG_BEZ_D" IS 'Bezeichnung des Wochentags (ausgeschrieben, deutsch)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H0L1_TAGLANG_BEZ_E" IS 'Bezeichnung des Wochentags (ausgeschrieben, englisch)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H0L1_WOCHENTAG_NR" IS 'Nummer des Tages in der laufenden Woche';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H0L1_MONATSTAG_NR" IS 'Nummer des Tages im laufenden Monat';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H0L1_JAHRTAGNR" IS 'Nummer des Tages im laufenden Jahr';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H0L1_GESTERN_ID" IS '8-stellige Zahl des Vortages (JJJJMMDD)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H0L1_ARBEITSTAG_BW" IS 'Flag (0/1), das bestimmt, ob dieser Tag ein (bundesweiter) Arbeitstag ist.
Arbeitstage sind diejenigen Tage, die nicht Wochenende oder ein bundesweiter gesetzlicher Feiertag sind.
Landesweite Feiertage befinden sich pro Dienststelle in der Dimension D_Feiertag.';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L2_JAHR_MONAT_ID" IS '6-stellige Zahl des Monats im Jahr (JJJJMM)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L2_MONAT_KURZ_D" IS 'Kurzbezeichnung des Monats (3 Buchstaben, deutsch)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L2_MONAT_KURZ_E" IS 'Kurzbezeichnung des Monats (3 Buchstaben, englisch)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L2_MONAT_LANG_BEZ_D" IS 'Bezeichnung des Monats (ausgeschrieben, deutsch)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L2_MONAT_LANG_BEZ_E" IS 'Bezeichnung des Monats (ausgeschrieben, englisch)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L2_MONAT_LANG_BEZ_JAHR_D" IS 'Bezeichnung des Monats mit Jahreszahl (ausgeschrieben, deutsch)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L2_MONAT_LANG_BEZ_JAHR_E" IS 'Bezeichnung des Monats mit Jahreszahl (ausgeschrieben, englisch)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L2_MONAT_NR" IS 'Nummer des Monats im laufenden Jahr';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L2_MONATSTAGE_NR" IS 'Anzahl der Tage des Monats';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L2_MONATANFANG_ID" IS '8-stellige Zahl des ersten Tages des Monats (JJJJMM01)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L2_MONATANFANG_DATUM" IS 'Datuml des ersten Tages des Monats ';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L2_MONATENDE_ID" IS '8-stellige Zahl des letzten Tages des Monats (JJJJMMDD)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L2_MONATENDE_DATUM" IS 'Datum des letzten Tages des Monats';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L2_LETZTERMONAT_ID" IS '6-stellige Zahl des Vormonats (JJJJMM)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L3_QUARTAL_ID" IS '7-stelliger Code des Quartals (JJJJ-Q?, ? ist die einstellige Nummer des Quartals)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L3_QUARTAL_NR" IS 'Nummer des Quartals (einstellig)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L3_QUARTALLANG_BEZ" IS 'gesamte Bezeichnung des Quartals (?. Quartal JJJJ, ? ist die einstellige Nummer des Quartals)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L3_QUARTALTAGE_NR" IS 'Anzahl der Tage im Quartal';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L3_QUARTALANFANG_ID" IS '8-stellige Zahl des ersten Tages des Quartals (JJJJMM01)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L3_QUARTALANFANG_DATUM" IS 'Datum des ersten Tages des Quartals ';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L3_QUARTALENDE_ID" IS '8-stellige Zahl des letzten Tages des Quartals (JJJJMMDD)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L3_QUARTALENDE_DATUM" IS 'Datum des letzten Tages des Quartals ';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L3_LETZTESQUARTAL_ID" IS '7-stelliger Code des letzten Quartals (JJJJ-Q?, ? ist die einstellige Nummer des Quartals)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L4_HALBJAHRANFANG_ID" IS '8-stellige Zahl des ersten Tages des Halbjahres (JJJJMM01)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L4_HALBJAHRENDE_ID" IS '8-stellige Zahl des letzten Tages des Halbjahres (JJJJMMDD)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L4_HALBJAHR_NR" IS 'Nummer des Halbjahres (einstellig)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L4_HALBJAHR_ID" IS '6-stelliger Code des Halbjahres (JJJJH?, ? ist die einstellige Nummer des Halbjahres)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L5_JAHR_ID" IS '4-stelliger Code des Jahres (JJJJ)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L5_JAHR_BEZ" IS '4-stelliger Code des Jahres (JJJJ) als Text';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L5_TAGEIMJAHR_NR" IS 'Anzahl der Tage des Jahres';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L5_JAHRANFANG_ID" IS 'erster Tag des Jahres (JJJJ0101)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L5_JAHRANFANG_DATUM" IS 'erster Tag des Jahres als Datum';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L5_JAHRENDE_ID" IS 'letzter Tag des Jahres (JJJJ1231)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L5_JAHRENDE_DATUM" IS 'letzter Tag des Jahres als Datum';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H1L5_LETZTESJAHR_ID" IS '4-stelliger Code des Vorjahres (JJJJ)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H2L2_KW_ID" IS '9-stelliger Code der Kalenderwoche (JJJJ-KW??, ?? ist die Nummer der Kalenderwoche)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H2L2_KW_NR" IS 'Nummer der Kalenderwoche';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H2L2_KW_JAHR" IS 'Jahr der Kalenderwoche (Anfang)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H2L2_KW_TAGE_NR" IS 'Anzahl der Tage in der Woche (7)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H2L2_KW_LANG_BEZ_D" IS 'Langtext der Kalenderwoche mit Hinweis auf deren Ende (?. Woche JJJJ, endet am ??. MMM JJJJ) auf deutsch';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H2L2_KW_LANG_BEZ_E" IS 'Langtext der Kalenderwoche mit Hinweis auf deren Ende (?. Woche JJJJ, endet am ??. MMM JJJJ) auf englisch';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H2L2_KWANFANG_ID" IS '8-stellige Zahl des ersten Tages der Kalenderwoche (JJJJMMDD)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H2L2_KWENDE_ID" IS '8-stellige Zahl des letzten Tages der Kalenderwoche (JJJJMMDD)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H2L2_LETZTEKW_ID" IS '9-stelliger Code der letzten Kalenderwoche (JJJJ-KW??, ?? ist die Nummer der Kalenderwoche)';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H2L2_KWANFANG_DATUM" IS 'Anfang der Kalenderwoche als Datum';
   COMMENT ON COLUMN "DWH_DM"."D_DATUM"."H2L2_KWENDE_DATUM" IS 'Ende der Kalenderwoche als Datum';
   COMMENT ON TABLE "DWH_DM"."D_DATUM"  IS 'Allgemeine Zeitdimension.';

-------------------
-- Zugehörige Indizes
-------------------

-- PK- und UK-Indizes werden nicht separat ausgewiesen

-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_DM"."D_DATUM" TO "DWH_MTD";
  GRANT DELETE ON "DWH_DM"."D_DATUM" TO "DWH_WORK";
  GRANT INSERT ON "DWH_DM"."D_DATUM" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."D_DATUM" TO "DWH_WORK";
  GRANT UPDATE ON "DWH_DM"."D_DATUM" TO "DWH_WORK";
  GRANT SELECT ON "DWH_DM"."D_DATUM" TO "OBIEE_BEDIAN";
  GRANT SELECT ON "DWH_DM"."D_DATUM" TO "HISI";

