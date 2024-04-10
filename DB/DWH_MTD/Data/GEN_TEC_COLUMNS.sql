/*------------------------------------------------------------------------------
||
|| Initial-Werte für die Tabelle GEN_TEC_COLUMNS
||
*/------------------------------------------------------------------------------
INSERT INTO "DWH_MTD"."GEN_TEC_COLUMNS" (column_name, column_data_type, column_nullable, column_behavior, column_order, used_in_layer, description) 
VALUES ('DWH_LOAD_ID', 'NUMBER', 'N', 'P_ID', 1, 'STG;PSA', 'ID of ODI-Process which inserted this row.');

INSERT INTO "DWH_MTD"."GEN_TEC_COLUMNS" (column_name, column_data_type, column_nullable, column_behavior, column_order, used_in_layer, description) 
VALUES ('DWH_REC_SRC_SYSTEM', 'VARCHAR2(50 CHAR)', 'N', 'RS', 2, 'STG;PSA', 'Source system of this row.');

INSERT INTO "DWH_MTD"."GEN_TEC_COLUMNS" (column_name, column_data_type, column_nullable, column_behavior, column_order, used_in_layer, description) 
VALUES ('DWH_VALID_FROM', 'DATE', 'N', 'VF', 3, 'STG;PSA', 'Begin of technical validity in DWH.');

INSERT INTO "DWH_MTD"."GEN_TEC_COLUMNS" (column_name, column_data_type, column_nullable, column_behavior, column_order, used_in_layer, description) 
VALUES ('DWH_VALID_TO', 'DATE', 'Y', 'VT', 4, 'PSA', 'End of technical validity.');

INSERT INTO "DWH_MTD"."GEN_TEC_COLUMNS" (column_name, column_data_type, column_nullable, column_behavior, column_order, used_in_layer, description) 
VALUES ('DWH_ACTIVE', 'NUMBER(1,0)', 'Y', 'ACT', 5, 'PSA', 'Current record flag.');

Commit;
