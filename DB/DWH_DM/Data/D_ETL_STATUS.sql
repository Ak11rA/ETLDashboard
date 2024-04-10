/*------------------------------------------------------------------------------
||
|| Skript zum Einfügen der Werte in die Dimension D_ETL_STATUS
|| Die Werte werden hier manuell eingefügt, da die möglichen Ausprägungen fix sind.
||
*/------------------------------------------------------------------------------
INSERT INTO D_ETL_STATUS (DETLST_ID, STATUS_CODE, STATUS) VALUES (-1, 'X', 'Status unbekannt');

INSERT INTO D_ETL_STATUS (DETLST_ID, STATUS_CODE, STATUS) VALUES (1, 'D', 'Erfolgreich');

INSERT INTO D_ETL_STATUS (DETLST_ID, STATUS_CODE, STATUS) VALUES (2, 'E', 'Fehler');

INSERT INTO D_ETL_STATUS (DETLST_ID, STATUS_CODE, STATUS) VALUES (3, 'R', 'laufend');

INSERT INTO D_ETL_STATUS (DETLST_ID, STATUS_CODE, STATUS) VALUES (4, 'W', 'wartend');

INSERT INTO D_ETL_STATUS (DETLST_ID, STATUS_CODE, STATUS) VALUES (5, 'Q', 'in Warteschlange');

INSERT INTO D_ETL_STATUS (DETLST_ID, STATUS_CODE, STATUS) VALUES (6, 'M', 'Warnung');
 
COMMIT;