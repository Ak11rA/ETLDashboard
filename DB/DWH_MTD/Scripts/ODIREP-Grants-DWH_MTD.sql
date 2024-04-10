-- Project BEDIAN
-- Grant necessary privileges to DWH_MTD

set define off
--set verify off
--set pause on
set encoding UTF8

WHENEVER SQLERROR EXIT SQL.SQLCODE ROLLBACK

--create tablespace DWH_META datafile size 5G;
--create user dwh_meta identified by dwh_meta default tablespace dwh_meta temporary tablespace temp;

--grant connect, resource to dwh_meta;
grant create view to dwh_mtd;
grant create database link to dwh_mtd;

grant select on ODIEBIV_ODI_REPO.SNP_LPI_STEP_LOG to dwh_mtd;
grant select on ODIEBIV_ODI_REPO.SNP_LP_INST to dwh_mtd;
grant select on ODIEBIV_ODI_REPO.SNP_SESSION to dwh_mtd;
grant select on ODIEBIV_ODI_REPO.SNP_SESS_TASK_LOG to dwh_mtd;
grant select on ODIEBIV_ODI_REPO.SNP_SCEN to dwh_mtd;
grant select on ODIEBIV_ODI_REPO.SNP_LPI_EXC_LOG to dwh_mtd;

--alter user dwh_meta quota unlimited on DWH_META;

exit
-- EOF
