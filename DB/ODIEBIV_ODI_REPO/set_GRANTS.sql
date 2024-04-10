-- Rechte auf Tabellen mit benötigten Laufzeitinformationen gesetzt
GRANT SELECT ON SNP_SESSION TO DWH_WORK, DWH_MTD;
GRANT SELECT ON SNP_STEP_LOG TO DWH_WORK, DWH_MTD;
GRANT SELECT ON SNP_SESS_TASK_LOG TO DWH_WORK, DWH_MTD;
GRANT SELECT ON SNP_LPI_STEP_LOG TO DWH_WORK, DWH_MTD, DWH_DM with grant option;
GRANT SELECT ON SNP_LPI_EXC_LOG TO DWH_WORK, DWH_MTD, DWH_DM with grant option;
GRANT SELECT ON SNP_LP_INST TO DWH_WORK, DWH_MTD, DWH_DM with grant option;

GRANT SELECT ON SNP_SCEN TO DWH_WORK, DWH_MTD;

GRANT SELECT ON SNP_LPI_RUN TO DWH_WORK, DWH_MTD, DWH_DM with grant option;
GRANT SELECT ON SNP_LPI_STEP TO DWH_WORK, DWH_MTD, DWH_DM with grant option;

GRANT SELECT ON SNP_LOAD_PLAN TO DWH_WORK, DWH_DM with grant option;
GRANT SELECT ON SNP_LP_STEP TO DWH_WORK, DWH_DM with grant option;

GRANT SELECT ON snp_scen_report TO DWH_WORK, DWH_MTD, DWH_DM with grant option;
GRANT SELECT ON snp_scen_task TO DWH_WORK, DWH_MTD, DWH_DM with grant option;
GRANT SELECT ON snp_scen_step TO DWH_WORK, DWH_MTD, DWH_DM with grant option;
GRANT SELECT ON snp_sess_task_log TO DWH_WORK, DWH_MTD, DWH_DM with grant option;
GRANT SELECT ON snp_scen TO DWH_WORK, DWH_MTD, DWH_DM with grant option;
GRANT SELECT ON snp_package TO DWH_WORK, DWH_MTD, DWH_DM with grant option;
GRANT SELECT ON snp_mapping TO DWH_WORK, DWH_MTD, DWH_DM with grant option;
GRANT SELECT ON snp_trt TO DWH_WORK, DWH_MTD, DWH_DM with grant option;
GRANT SELECT ON snp_var_scen TO DWH_WORK, DWH_MTD, DWH_DM with grant option;
GRANT SELECT ON snp_load_plan TO DWH_WORK, DWH_MTD, DWH_DM with grant option;
GRANT SELECT ON snp_lp_var TO DWH_WORK, DWH_MTD, DWH_DM with grant option;


BEGIN
    FOR curs_grants IN (SELECT * FROM user_tables) LOOP
      
      execute immediate 'GRANT SELECT ON "' || user || '"."' || curs_grants.table_name || '" TO "HISI"';
      
    END LOOP;
END;
/