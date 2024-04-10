/*-----------------------------------------------------------------------------
|| Skript der View V_VAL_LAST_GENERATED_CODE
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DWH_MTD"."V_VAL_LAST_GENERATED_CODE" ("CONTENT") AS
  select content from gen_exec_log
WHERE 1=1
AND time_stamp = (select max(time_stamp) from gen_exec_log where text = 'Table generation completed');

-------------------
-- Zugehörige Kommentare
-------------------
-- keine Kommentare vorhanden


-------------------
-- Zugehörige Grants
-------------------
-- keine Grants vorhanden

