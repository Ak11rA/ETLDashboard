/*-----------------------------------------------------------------------------
|| Skript der View V_ODI_LPI_HIERARCHY
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DWH_MTD"."V_ODI_LPI_HIERARCHY" ("SCEN_NO", "SCEN_RUN_NO", "PCK_NAME", "PCK_SCEN_VERSION", "LP_NAME", "LP_START", "LP_END", "LP_STATUS", "LP_ERROR_MESSAGE", "I_LP_INST", "LP_STEP", "LP_STEP_SCEN_NAME", "LP_STEP_START_DATE", "LP_STEP_END_DATE", "LP_STEP_STATUS", "LP_STEP_ERROR_MESSAGE", "LP_STEP_RETURN_CODE") AS
  SELECT ssr.scen_no,  ssr.scen_run_no, ssc1.scen_name pck_name, ssc1.scen_version pck_scen_version,
       ssr.step_name lp_name, ssr.step_beg lp_start, ssr.step_end lp_end, ssr.step_status lp_status, ssr.error_message lp_error_message,
       slr.i_lp_inst,
       sls.map_lp_step_name lp_step, sls.scen_name lp_step_scen_name,
       slsl.start_date lp_step_start_date, slsl.end_date lp_step_end_date, slsl.status lp_step_status, slsl.error_message lp_step_error_message, slsl.return_code lp_step_return_code
       --,ssr.*
FROM odiebiv_odi_repo.SNP_STEP_REPORT  ssr
join odiebiv_odi_repo.snp_scen ssc1 on ssc1.scen_no = ssr.scen_no
left join odiebiv_odi_repo.snp_lpi_run slr on slr.load_plan_name = ssr.step_name and abs(ssr.step_beg - slr.start_date) < 1/(24*60*6)
left join odiebiv_odi_repo.snp_lpi_step_log slsl on slsl.i_lp_inst = slr.i_lp_inst
left join (
    SELECT sli.load_plan_name, sli.i_load_plan, par.i_lp_step root_i_lp_step, chi.par_i_lp_step fold_par_i_lp_step, map.par_i_lp_step map_par_i_lp_step, coalesce(map.i_lp_step, chi.i_lp_step, par.i_lp_step) i_lp_step, chi.i_lp_step fold_i_lp_step, map.i_lp_step map_i_lp_step, par.lp_step_name root_lp_step_name, chi.lp_step_name fold_lp_step_name, map.lp_step_name map_lp_step_name, nvl(map.scen_name, chi.scen_name) scen_name, par.step_order root_step_order, chi.step_order fold_step_order, map.step_order map_step_order
    FROM (select distinct i_load_plan, load_plan_name from odiebiv_odi_repo.snp_lp_inst) sli
    join odiebiv_odi_repo.snp_lp_step par on par.i_load_plan = sli.i_load_plan
    join odiebiv_odi_repo.snp_lp_step chi on (chi.par_i_lp_step = par.i_lp_step) or  (chi.i_lp_step = par.i_lp_step and chi.par_i_lp_step is null and chi.i_load_plan = par.i_load_plan)
    left join odiebiv_odi_repo.snp_lp_step map on (map.par_i_lp_step = chi.i_lp_step) or  (map.i_lp_step = chi.i_lp_step and map.i_load_plan = chi.i_load_plan and chi.lp_step_name = map.lp_step_name)
    where par.par_i_lp_step is null
      and nvl(par.ind_enabled,1) = 1 and nvl(chi.ind_enabled, 1) = 1 and nvl(map.ind_enabled, 1) = 1
      and not (chi.par_i_lp_step is null and map.par_i_lp_step is not null)
) sls on sls.i_lp_step = slsl.i_lp_step
--where ssr.scen_no = 55522
  --and ssr.scen_run_no = 188004
order by ssr.scen_run_no desc, ssr.execution_order desc, sls.root_step_order desc, sls.fold_step_order desc, sls.map_step_order desc;

-------------------
-- Zugehörige Kommentare
-------------------
-- keine Kommentare vorhanden


-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_MTD"."V_ODI_LPI_HIERARCHY" TO "DWH_WORK";
  GRANT SELECT ON "DWH_MTD"."V_ODI_LPI_HIERARCHY" TO "DWH_CORE";
  GRANT SELECT ON "DWH_MTD"."V_ODI_LPI_HIERARCHY" TO "DWH_DM";
  GRANT SELECT ON "DWH_MTD"."V_ODI_LPI_HIERARCHY" TO "HISI";

