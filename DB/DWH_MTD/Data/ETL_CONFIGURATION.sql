-- Einstellungen f�r das Fehlermailing
INSERT INTO DWH_MTD.ETL_CONFIGURATION (PROCESS_NAME, CONFIGURATION, CHAR_VALUE, NUMBER_VALUE, CONFIGURATION_DESCRIPTION, CREATED_AT, CREATED_BY )
VALUES ('ALLGEMEIN', 'Mailserver','10.130.164.XX',25, 'Konfiguration des Mailservers, der f�r das Versenden von Mails aus dem ODI zu nutzen ist. CHAR_VALUE gibt dabei den Host (IP) an und NUMBER_VALUE den zugeh�rigen Port.', sysdate, user );

-- Empf�nger(-Liste) f�r Fehlermeldungen zum KraftSt-BI-Prozess aus dem ODI
INSERT INTO DWH_MTD.ETL_CONFIGURATION (PROCESS_NAME, CONFIGURATION, CHAR_VALUE, CONFIGURATION_DESCRIPTION, CREATED_AT, CREATED_BY )
VALUES ('BEDIAN', 'Fehlermailing_Empfaenger','xxx@itzbund.de', 'Konfiguration des Empf�ngerliste, die Fehlerbenachrichtigungen aus dem BeDiAn - Prozess erhalten soll.', sysdate, user );
 
-- Einstellung f�r das Bereinigen der Stage
INSERT INTO DWH_MTD.ETL_CONFIGURATION (PROCESS_NAME, CONFIGURATION, NUMBER_VALUE, CONFIGURATION_DESCRIPTION, CREATED_AT, CREATED_BY )
VALUES ('BEDIAN', 'Tage_Stage_behalten', 0, 'Angabe einer Anzahl von Tagen (NUMBER_VALUE), nach denen erfolgreich verarbeitete Stage-Daten gel�scht werden.', sysdate, user );

-- Konfiguration der Empf�nger-Liste f�r die (t�gliche) KraftSt-BI-Statusmail
INSERT INTO DWH_MTD.ETL_CONFIGURATION (PROCESS_NAME, CONFIGURATION, CHAR_VALUE, CONFIGURATION_DESCRIPTION, CREATED_AT, CREATED_BY )
VALUES ('BEDIAN', 'Statusmail_Empfaenger','xxx@itzbund.de', 'Konfiguration des Empf�ngerliste, die Statusbenachrichtigungen aus dem BEDIAN - Prozess erhalten soll.', sysdate, user );

-- Flag zum An-/Abschalten des Versandes der (t�glichen) KraftSt-BI-Statusmail
INSERT INTO DWH_MTD.ETL_CONFIGURATION (PROCESS_NAME, CONFIGURATION, CHAR_VALUE, CONFIGURATION_DESCRIPTION, CREATED_AT, CREATED_BY )
VALUES ('BEDIAN', 'Statusmail_Aktivierung','aktiv', 'Konfiguration �ber die sich der Versand der t�glichen BeDiAn-Statusmail aktivieren (CHAR_VALUE = ''aktiv'') bzw. deaktivieren (CHAR_VALUE = ''inaktiv'') l�sst. Insbesondere, um ggf. auf den vorproduktiven Umgebungen den Mail-Versand auszuschalten.', SYSDATE, USER );

commit;
