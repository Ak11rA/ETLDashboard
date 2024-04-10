/*-----------------------------------------------------------------------------
|| Ref-Constraints der Tabelle TST_RUN
*/-----------------------------------------------------------------------------


  ALTER TABLE "DWH_MTD"."TST_RUN" ADD CONSTRAINT "TST_RUN_CNF_FK" FOREIGN KEY ("CONFIG")
	  REFERENCES "DWH_MTD"."TST_CNF" ("ID") ENABLE;

