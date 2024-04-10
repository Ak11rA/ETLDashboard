/*------------------------------------------------------------------------------
||
|| Default-Wert für die Dimension D_ETL_LADEPLAN, falls eine Zuordnung nicht möglich ist
||
*/------------------------------------------------------------------------------
INSERT INTO D_ETL_LADEPLAN (DETLLP_ID, LADEPLAN)
VALUES (-1,'Ladeplan unbekannt');
        
COMMIT;
