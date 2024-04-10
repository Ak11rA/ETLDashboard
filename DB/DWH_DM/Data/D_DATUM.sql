/*------------------------------------------------------------------------------
||
|| Daten für die Datums-Dimension generieren
|| Alle Tage für die Jahre 2001-2030 und der 01.01.1900
||
*/------------------------------------------------------------------------------
INSERT INTO D_DATUM (DDATU_ID, H0L1_DATUM, H0L1_TAG_MON_JAHR_BEZ_D, H0L1_TAG_MON_JAHR_BEZ_E, 
                     H0L1_TAGKURZ_BEZ_D, H0L1_TAGKURZ_BEZ_E, H0L1_TAGLANG_BEZ_D, H0L1_TAGLANG_BEZ_E, 
                     H0L1_WOCHENTAG_NR, H0L1_MONATSTAG_NR, H0L1_JAHRTAGNR, H0L1_GESTERN_ID, 
                     H1L2_JAHR_MONAT_ID, H1L2_MONAT_KURZ_D, H1L2_MONAT_KURZ_E, H1L2_MONAT_LANG_BEZ_D, 
                     H1L2_MONAT_LANG_BEZ_E, H1L2_MONAT_LANG_BEZ_JAHR_D, H1L2_MONAT_LANG_BEZ_JAHR_E, H1L2_MONAT_NR, 
                     H1L2_MONATSTAGE_NR, H1L2_MONATANFANG_ID, H1L2_MONATENDE_ID, H1L2_LETZTERMONAT_ID, 
                     H1L3_QUARTAL_ID, H1L3_QUARTAL_NR, H1L3_QUARTALLANG_BEZ, H1L3_QUARTALTAGE_NR, 
                     H1L3_QUARTALANFANG_ID, H1L3_QUARTALENDE_ID, H1L3_LETZTESQUARTAL_ID, 
                     H1L4_HALBJAHRANFANG_ID, H1L4_HALBJAHRENDE_ID, H1L4_HALBJAHR_NR, H1L4_HALBJAHR_ID, 
                     H1L5_JAHR_ID, H1L5_JAHR_BEZ, H1L5_TAGEIMJAHR_NR, H1L5_JAHRANFANG_ID, H1L5_JAHRENDE_ID, 
                     H1L5_LETZTESJAHR_ID, H2L2_KW_ID, H2L2_KW_NR, H2L2_KW_TAGE_NR, H2L2_KW_LANG_BEZ_D, 
                     H2L2_KW_LANG_BEZ_E, H2L2_KWANFANG_ID, H2L2_KWENDE_ID, H2L2_LETZTEKW_ID,
					 h2l2_kwanfang_datum, h2l2_kwende_datum)
SELECT
-- TAG LEVEL
       CASE WHEN def_date = 1 THEN -1 ELSE TO_NUMBER(TO_CHAR(AKTUELLER_TAG, 'YYYYMMDD')) END AS DDATU_ID
      ,AKTUELLER_TAG AS H0L1_DATUM
      ,INITCAP(TO_CHAR(AKTUELLER_TAG,'DD. fmMonth YYYY','nls_date_language=German')) AS H0L1_TAG_MON_JAHR_BEZ_D
      ,INITCAP(TO_CHAR(AKTUELLER_TAG,'fmMonth DD, YYYY','nls_date_language=English')) AS H0L1_TAG_MON_JAHR_BEZ_E
      ,SUBSTR(INITCAP(TO_CHAR(AKTUELLER_TAG, 'fmDAY','nls_date_language=German')),1,2) AS H0L1_TAGKURZ_BEZ_D
      ,SUBSTR(INITCAP(TO_CHAR(AKTUELLER_TAG, 'fmDAY','nls_date_language=English')),1,2) AS H0L1_TAGKURZ_BEZ_E
      ,INITCAP(TO_CHAR(AKTUELLER_TAG, 'fmDAY','nls_date_language=German')) AS H0L1_TAGLANG_BEZ_D
      ,INITCAP(TO_CHAR(AKTUELLER_TAG, 'fmDAY','nls_date_language=English')) AS H0L1_TAGLANG_BEZ_E
      ,TO_NUMBER(TO_CHAR(AKTUELLER_TAG, 'D')) AS H0L1_WOCHENTAG_NR
      ,TO_NUMBER(TO_CHAR(AKTUELLER_TAG, 'DD')) AS H0L1_MONATSTAG_NR
      ,TO_NUMBER(TO_CHAR(AKTUELLER_TAG, 'DDD')) H0L1_JAHRTAGNR
      ,TO_NUMBER(TO_CHAR(AKTUELLER_TAG - 1,'YYYYMMDD')) AS H0L1_GESTERN_ID
-- MONAT LEVEL
      ,TO_NUMBER(TO_CHAR(AKTUELLER_TAG, 'YYYYMM')) AS H1L2_JAHR_MONAT_ID
      ,SUBSTR(TO_CHAR(AKTUELLER_TAG, 'fmMonth YYYY','nls_date_language=German'),1,3) AS H1L2_MONAT_KURZ_D
      ,SUBSTR(TO_CHAR(AKTUELLER_TAG, 'fmMonth YYYY','nls_date_language=English'),1,3) AS H1L2_MONAT_KURZ_E
      ,TO_CHAR(AKTUELLER_TAG, 'fmMonth','nls_date_language=German') AS H1L2_MONAT_LANG_BEZ_D
      ,TO_CHAR(AKTUELLER_TAG, 'fmMonth','nls_date_language=English') AS H1L2_MONAT_LANG_BEZ_E
      ,TO_CHAR(AKTUELLER_TAG, 'fmMonth YYYY','nls_date_language=German') AS H1L2_MONAT_LANG_BEZ_JAHR_D
      ,TO_CHAR(AKTUELLER_TAG, 'fmMonth YYYY','nls_date_language=English') AS H1L2_MONAT_LANG_BEZ_JAHR_E
      ,TO_NUMBER(TO_CHAR(AKTUELLER_TAG, 'MM')) AS H1L2_MONAT_NR
      ,TO_NUMBER(TO_CHAR(LAST_DAY(AKTUELLER_TAG),'DD')) AS H1L2_MONATSTAGE_NR
      ,TO_NUMBER(TO_CHAR(ADD_MONTHS(LAST_DAY(AKTUELLER_TAG),-1)+1,'YYYYMMDD')) AS H1L2_MONATANFANG_ID
      ,TO_NUMBER(TO_CHAR(LAST_DAY(AKTUELLER_TAG),'YYYYMMDD')) AS H1L2_MONATENDE_ID
      ,TO_NUMBER(TO_CHAR(ADD_MONTHS(AKTUELLER_TAG,-1),'YYYYMM')) AS H1L2_LETZTERMONAT_ID
-- QUARTAL LEVEL
      ,TO_CHAR(AKTUELLER_TAG, 'YYYY"-Q"Q') AS H1L3_QUARTAL_ID
      ,TO_NUMBER(TO_CHAR(AKTUELLER_TAG, 'Q')) AS H1L3_QUARTAL_NR
      ,INITCAP(TO_CHAR(AKTUELLER_TAG, 'fmQ". Quartal" YYYY')) AS H1L3_QUARTALLANG_BEZ
      ,TO_NUMBER((TRUNC(ADD_MONTHS(AKTUELLER_TAG,3), 'Q') - 1) - (TRUNC(AKTUELLER_TAG, 'Q') - 1)) AS H1L3_QUARTALTAGE_NR
      ,TO_NUMBER(TO_CHAR(TRUNC(AKTUELLER_TAG, 'Q'),'YYYYMMDD')) AS H1L3_QUARTALANFANG_ID
      ,TO_NUMBER(TO_CHAR(TRUNC(ADD_MONTHS(AKTUELLER_TAG,3), 'Q') - 1,'YYYYMMDD')) AS H1L3_QUARTALENDE_ID
      ,TO_CHAR(TRUNC(ADD_MONTHS(AKTUELLER_TAG,-3), 'Q'),'YYYY"-Q"Q') AS H1L3_LETZTESQUARTAL_ID
-- HALBJAHR LEVEL
      ,CASE 
         WHEN TO_CHAR(AKTUELLER_TAG, 'MM') IN ('01','02','03','04','05','06') 
         THEN TO_NUMBER(TO_CHAR(TRUNC(AKTUELLER_TAG, 'YYYY'),'YYYYMMDD')) 
         ELSE TO_NUMBER(TO_CHAR(TRUNC(AKTUELLER_TAG, 'YYYY'),'YYYY') || '0701') 
       END AS H1L4_HALBJAHRANFANG_ID
      ,CASE 
         WHEN TO_CHAR(AKTUELLER_TAG, 'MM') IN ('01','02','03','04','05','06') 
         THEN TO_NUMBER(TO_CHAR(TRUNC(AKTUELLER_TAG, 'YYYY'),'YYYY') || '0630')
         ELSE TO_NUMBER(TO_CHAR(TRUNC(ADD_MONTHS(AKTUELLER_TAG,12), 'YYYY') - 1,'YYYYMMDD')) 
       END AS H1L4_HALBJAHRENDE_ID
      ,CASE 
         WHEN TO_CHAR(AKTUELLER_TAG, 'MM') IN ('01','02','03','04','05','06') 
         THEN 1 
         ELSE 2 
       END AS H1L4_HALBJAHR_NR
      ,CASE 
         WHEN TO_CHAR(AKTUELLER_TAG, 'MM') IN ('01','02','03','04','05','06') 
         THEN TO_CHAR(TRUNC(AKTUELLER_TAG, 'YYYY'),'YYYY') || 'H1' 
         ELSE TO_CHAR(TRUNC(AKTUELLER_TAG, 'YYYY'),'YYYY') || 'H2' 
       END AS H1L4_HALBJAHR_ID
-- JAHR LEVEL
      ,TO_NUMBER(TO_CHAR(AKTUELLER_TAG, 'YYYY')) AS H1L5_JAHR_ID
      ,TO_CHAR(AKTUELLER_TAG, 'YYYY') AS H1L5_JAHR_BEZ
      ,TO_NUMBER((TRUNC(ADD_MONTHS(AKTUELLER_TAG,12), 'YYYY') - 1) - (TRUNC(AKTUELLER_TAG, 'YYYY') - 1)) AS H1L5_TAGEIMJAHR_NR
      ,TO_NUMBER(TO_CHAR(TRUNC(AKTUELLER_TAG, 'YYYY'),'YYYYMMDD')) AS H1L5_JAHRANFANG_ID
      ,TO_NUMBER(TO_CHAR(TRUNC(ADD_MONTHS(AKTUELLER_TAG,12), 'YYYY') - 1,'YYYYMMDD')) AS H1L5_JAHRENDE_ID
      ,TO_NUMBER(TO_CHAR(ADD_MONTHS(AKTUELLER_TAG,-12),'YYYY')) AS H1L5_LETZTESJAHR_ID
-- KALENDERWOCHE LEVEL
      ,TO_CHAR(AKTUELLER_TAG, 'IYYY') || '-KW' || TO_CHAR(AKTUELLER_TAG, 'IW') AS H2L2_KW_ID
      ,TO_NUMBER(TO_CHAR(AKTUELLER_TAG, 'IW')) AS H2L2_KW_NR
      ,7 AS H2L2_KW_TAGE_NR
      ,INITCAP(TO_CHAR(AKTUELLER_TAG, 'fmIW". Woche" IYYY')) || ', endet am ' || TO_CHAR(TRUNC(AKTUELLER_TAG + 7, 'IW') - 1, 'DD. fmMonth YYYY','nls_date_language=German') AS H2L2_KW_LANG_BEZ_D
      ,INITCAP(TO_CHAR(AKTUELLER_TAG, 'fmIW". week" IYYY')) || ', ends on ' || TO_CHAR(TRUNC(AKTUELLER_TAG + 7, 'IW') - 1, 'fmMonth DD, YYYY','nls_date_language=English') AS H2L2_KW_LANG_BEZ_E
      ,TO_NUMBER(TO_CHAR(TRUNC(AKTUELLER_TAG, 'IW'),'YYYYMMDD')) AS H2L2_KWANFANG_ID
      ,TO_NUMBER(TO_CHAR(TRUNC(AKTUELLER_TAG + 7, 'IW') - 1,'YYYYMMDD')) AS H2L2_KWENDE_ID
      ,TO_CHAR(AKTUELLER_TAG-7, 'IYYY') || '-KW' || TO_CHAR(AKTUELLER_TAG-7, 'IW') AS H2L2_LETZTEKW_ID,
	  TRUNC(AKTUELLER_TAG, 'IW') as h2l2_kwanfang_datum,
	  TRUNC(AKTUELLER_TAG + 7, 'IW') - 1 as h2l2_kwende_datum
FROM
-- generierte Quelle
      (SELECT 
-- Starttag:
              TO_DATE('01.01.2001','DD.MM.YYYY') -1 + NUMTODSINTERVAL(LEVEL,'day') AKTUELLER_TAG, 0 def_date
       FROM DUAL
-- Zeitraum des zu generierenden Kalenders als Angabe BIS - VON (um Anzahl der notwendigen CONNECT-Level zu ermitteln:
       CONNECT BY LEVEL <= TO_DATE('31.12.2030','DD.MM.YYYY')-TO_DATE('01.01.2001','DD.MM.YYYY')+1
       union all
	   SELECT TO_DATE('01.01.1900','DD.MM.YYYY'), 1 def_date FROM   DUAL );

COMMIT;

update dwh_dm.d_datum set H0L1_ARBEITSTAG_BW = 'JA' where H0L1_TAGKURZ_BEZ_D not in ('Sa','So');
update dwh_dm.d_datum set H0L1_ARBEITSTAG_BW = 'NEIN' where H0L1_TAGKURZ_BEZ_D in ('Sa','So');

commit;

-- Fix for BEDIAN-73
Insert into DWH_DM.D_DATUM (DDATU_ID,H0L1_DATUM,H0L1_TAG_MON_JAHR_BEZ_D,H0L1_TAG_MON_JAHR_BEZ_E,H0L1_TAGKURZ_BEZ_D,H0L1_TAGKURZ_BEZ_E,H0L1_TAGLANG_BEZ_D,H0L1_TAGLANG_BEZ_E,H0L1_WOCHENTAG_NR,H0L1_MONATSTAG_NR,H0L1_JAHRTAGNR,H0L1_GESTERN_ID,H0L1_ARBEITSTAG_BW,H1L2_JAHR_MONAT_ID,H1L2_MONAT_KURZ_D,H1L2_MONAT_KURZ_E,H1L2_MONAT_LANG_BEZ_D,H1L2_MONAT_LANG_BEZ_E,H1L2_MONAT_LANG_BEZ_JAHR_D,H1L2_MONAT_LANG_BEZ_JAHR_E,H1L2_MONAT_NR,H1L2_MONATSTAGE_NR,H1L2_MONATANFANG_ID,H1L2_MONATENDE_ID,H1L2_LETZTERMONAT_ID,H1L3_QUARTAL_ID,H1L3_QUARTAL_NR,H1L3_QUARTALLANG_BEZ,H1L3_QUARTALTAGE_NR,H1L3_QUARTALANFANG_ID,H1L3_QUARTALENDE_ID,H1L3_LETZTESQUARTAL_ID,H1L4_HALBJAHRANFANG_ID,H1L4_HALBJAHRENDE_ID,H1L4_HALBJAHR_NR,H1L4_HALBJAHR_ID,H1L5_JAHR_ID,H1L5_JAHR_BEZ,H1L5_TAGEIMJAHR_NR,H1L5_JAHRANFANG_ID,H1L5_JAHRENDE_ID,H1L5_LETZTESJAHR_ID,H2L2_KW_ID,H2L2_KW_NR,H2L2_KW_TAGE_NR,H2L2_KW_LANG_BEZ_D,H2L2_KW_LANG_BEZ_E,H2L2_KWANFANG_ID,H2L2_KWENDE_ID,H2L2_LETZTEKW_ID) values ('99991231',to_date('31.12.9999 00:00:00','DD.MM.YYYY HH24:MI:SS'),'31. Dezember 9999','December 31, 9999',null,null,null,null,null,null,null,'99991230',null,'999912','Dez','Dec','Dezember','December',null,null,null,null,null,null,null,null,'4',null,null,null,null,null,null,null,null,null,null,null,null,null,null,'9998',null,null,null,null,null,null,null,null);
commit;

INSERT INTO d_datum (
    ddatu_id
    , h0l1_datum
    , h0l1_tag_mon_jahr_bez_d
    , h0l1_tag_mon_jahr_bez_e
    , h0l1_tagkurz_bez_d
    , h0l1_tagkurz_bez_e
    , h0l1_taglang_bez_d
    , h0l1_taglang_bez_e
    , h0l1_wochentag_nr
    , h0l1_monatstag_nr
    , h0l1_jahrtagnr
    , h0l1_gestern_id
    , h0l1_arbeitstag_bw
    , h1l2_jahr_monat_id
    , h1l2_monat_kurz_d
    , h1l2_monat_kurz_e
    , h1l2_monat_lang_bez_d
    , h1l2_monat_lang_bez_e
    , h1l2_monat_lang_bez_jahr_d
    , h1l2_monat_lang_bez_jahr_e
    , h1l2_monat_nr
    , h1l2_monatstage_nr
    , h1l2_monatanfang_id
    , h1l2_monatende_id
    , h1l2_letztermonat_id
    , h1l3_quartal_id
    , h1l3_quartal_nr
    , h1l3_quartallang_bez
    , h1l3_quartaltage_nr
    , h1l3_quartalanfang_id
    , h1l3_quartalende_id
    , h1l3_letztesquartal_id
    , h1l4_halbjahranfang_id
    , h1l4_halbjahrende_id
    , h1l4_halbjahr_nr
    , h1l4_halbjahr_id
    , h1l5_jahr_id
    , h1l5_jahr_bez
    , h1l5_tageimjahr_nr
    , h1l5_jahranfang_id
    , h1l5_jahrende_id
    , h1l5_letztesjahr_id
    , h2l2_kw_id
    , h2l2_kw_nr
    , h2l2_kw_tage_nr
    , h2l2_kw_lang_bez_d
    , h2l2_kw_lang_bez_e
    , h2l2_kwanfang_id
    , h2l2_kwende_id
    , h2l2_letztekw_id
    , h2l2_kwanfang_datum
    , h2l2_kwende_datum
    , h1l2_monatanfang_datum
    , h1l2_monatende_datum
    , h1l3_quartalanfang_datum
    , h1l3_quartalende_datum
    , h1l5_jahranfang_datum
    , h1l5_jahrende_datum
    , h2l2_kw_jahr
) VALUES (
    19700101
  , to_date('19700101','YYYYMMDD')
  , '01. Januar 1970'
  , 'January 1, 1970'
  , 'Do'
  , 'Th'
  , 'Donnerstag'
  , 'Thursday'
  , 4
  , 1
  , 1
  , 19691231
  , 0
  , 197001
  , 'Jan'
  , 'Jan'
  , 'Januar'
  , 'January'
  , 'Januar 1970'
  , 'January 1970'
  , 1
  , 31
  , 19700101
  , 19700131
  , 196912
  , '1970-Q1'
  , 1
  , '1. Quartal 1970'
  , 90
  , 19700101
  , 19700331
  , '1969-Q4'
  , 19700101
  , 19700630
  , 1
  , '1970H1'
  , 1970
  , 1970
  , 365
  , 19700101
  , 19701231
  , 1969
  , '1970-KW01'
  , 1
  , 7
  , '1. Woche 1970, endet am 04. Januar 1970'
  , '1. Week 1970, ends on January 4, 1970'
  , 19691229
  , 19700104
  , '1969-KW52'
  , to_date('19691229','YYYYMMDD')
  , to_date('19700104','YYYYMMDD')
  , to_date('19700101','YYYYMMDD')
  , to_date('19700131','YYYYMMDD')
  , to_date('19700101','YYYYMMDD')
  , to_date('19700331','YYYYMMDD')
  , to_date('19700101','YYYYMMDD')
  , to_date('19701231','YYYYMMDD')
  , 1969
);
commit;
