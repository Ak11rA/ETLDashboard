/*-----------------------------------------------------------------------------
|| Skript der View V_ODI_SCEN_STATS
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE FORCE EDITIONABLE VIEW "DWH_MTD"."V_ODI_SCEN_STATS" ("TAG", "MAPPING", "LAUFZEIT_MINUTEN", "ZEILEN_BEWEGT", "ZEILEN_PRO_MINUTE") AS
  select
    day                             as Tag,
    mapping                         as Mapping,
    round(session_duration/60,1)    as Laufzeit_Minuten,
    rows_moved                      as Zeilen_bewegt,
    round(rows_moved/(session_duration/60)) as Zeilen_pro_Minute
from (
    select
        trunc(sess_beg)     as day,
        scen_name           as mapping,
        --sess_beg,
        --sess_end,
        sum(sess_dur)       as session_duration,
        sum(nb_row)         as rows_moved
    from odiebiv_odi_repo.snp_session
    where   1=1
        and trunc(sess_beg) is not null
        and sess_dur > 5
    group by trunc(sess_beg), scen_name
    --order by trunc(sess_beg) desc
    )
order by
    tag desc,
    zeilen_pro_minute;

-------------------
-- Zugehörige Kommentare
-------------------
-- keine Kommentare vorhanden


-------------------
-- Zugehörige Grants
-------------------

  GRANT SELECT ON "DWH_MTD"."V_ODI_SCEN_STATS" TO "DWH_WORK";
  GRANT SELECT ON "DWH_MTD"."V_ODI_SCEN_STATS" TO "HISI";

