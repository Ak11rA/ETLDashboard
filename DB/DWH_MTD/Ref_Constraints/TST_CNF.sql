/*-----------------------------------------------------------------------------
|| Ref-Constraints der Tabelle TST_CNF
*/-----------------------------------------------------------------------------


  ALTER TABLE "DWH_MTD"."TST_CNF" ADD CONSTRAINT "TST_CNF_DEF_FK" FOREIGN KEY ("TEST")
	  REFERENCES "DWH_MTD"."TST_DEF" ("ID") ENABLE;

