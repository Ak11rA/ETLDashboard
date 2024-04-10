/*-----------------------------------------------------------------------------
|| DDL for Package DBATOOLS
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE PACKAGE "DWH_MTD"."DBATOOLS"

    AUTHID CURRENT_USER

AS

    -- (c) Loopback.ORG GmbH, info@loopback.org
    -- (o) https://stash.loopback.org/projects/LDEV/repos/dbatools/browse/DBATOOLS.sql

  procedure check_fk_constraints(schemalist in varchar2, result_n out number, result_t out varchar2);
  procedure dmesg(p_text in varchar2, p_scope in varchar2 default 'DBATools', p_severity in number default 0);
  procedure debug(i_scope in varchar2, i_text in clob);

  FUNCTION get_sorted_concat_string (
    i_concatenated_string   IN VARCHAR2,
    i_used_seperator        IN VARCHAR2 DEFAULT ';'
    )
    RETURN VARCHAR2 DETERMINISTIC PARALLEL_ENABLE;

  FUNCTION get_standard_char_format (
      p_VALUE  NUMBER)
    RETURN VARCHAR2 DETERMINISTIC PARALLEL_ENABLE;

  FUNCTION get_standard_char_format (
      p_VALUE  DATE)
    RETURN VARCHAR2 DETERMINISTIC PARALLEL_ENABLE;

  FUNCTION get_standard_char_format (
      p_VALUE  TIMESTAMP)
    RETURN VARCHAR2 DETERMINISTIC PARALLEL_ENABLE;

  function Easter_Sunday          (yr in number) return date;
  function Carnival_Monday        (yr in number) return date;
  function Mardi_Gras             (yr in number) return date;
  function Ash_Wednesday          (yr in number) return date;
  function Palm_Sunday            (yr in number) return date;
  function Easter_Friday          (yr in number) return date;
  function Easter_Saturday        (yr in number) return date;
  function Easter_Monday          (yr in number) return date;
  function Ascension_of_Christ    (yr in number) return date;
  function Whitsunday             (yr in number) return date;
  function Whitmonday             (yr in number) return date;
  function Feast_of_Corpus_Christi(yr in number) return date;

END DBATOOLS;
/


-------------------
-- Zugehörige Grants
-------------------

  GRANT EXECUTE ON "DWH_MTD"."DBATOOLS" TO "DWH_DM";
  GRANT EXECUTE ON "DWH_MTD"."DBATOOLS" TO "DWH_CORE";
  GRANT EXECUTE ON "DWH_MTD"."DBATOOLS" TO "DWH_WORK";

