/*-----------------------------------------------------------------------------
|| DDL for Procedure REFRESH_MV_LADELAUF
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE EDITIONABLE PROCEDURE "DWH_DM"."REFRESH_MV_LADELAUF"
 as
 begin
 DBMS_MVIEW.REFRESH('DWH_DM.MV_LADELAUF');
 end;
/


-------------------
-- Zugehörige Grants
-------------------

  GRANT EXECUTE ON "DWH_DM"."REFRESH_MV_LADELAUF" TO "DWH_WORK";

