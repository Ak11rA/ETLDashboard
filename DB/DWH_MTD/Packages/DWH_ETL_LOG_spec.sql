/*-----------------------------------------------------------------------------
|| DDL for Package DWH_ETL_LOG
*/-----------------------------------------------------------------------------


  CREATE OR REPLACE PACKAGE "DWH_MTD"."DWH_ETL_LOG"
AS

  PROCEDURE SET_RUNNING (
      I_ODI_ID                IN NUMBER,
      I_DWH_DELTA_DATE        IN DATE,
      I_SCHEMA_NAME           IN VARCHAR2,
      I_TABLE_NAME            IN VARCHAR2,
      I_MAPPING_NAME          IN VARCHAR2,
      I_SRC_DELTA_TYPE        IN VARCHAR2 DEFAULT NULL,
      I_LOW_WM_SRC_DELTA      IN VARCHAR2 DEFAULT NULL,
      I_HIGH_WM_SRC_DELTA     IN VARCHAR2 DEFAULT NULL,
      I_ODI_ID_PARENT         IN NUMBER  DEFAULT NULL
      );

  PROCEDURE SET_SUCCESS (
      I_ODI_ID                IN NUMBER,
      I_ROWS                  IN NUMBER DEFAULT NULL
      );


  PROCEDURE SET_ERROR (
      I_ODI_ID                IN NUMBER,
      I_ROWS                  IN NUMBER DEFAULT NULL
      );

  PROCEDURE SET_ERROR_FROM_LOADPLAN (
      I_ODI_LOADPLAN_GUID                IN VARCHAR2,
      I_RUN_NUMBER                       IN NUMBER DEFAULT 1
      );

  PROCEDURE CLEAR_STAGE (
      I_STAGE_SCHEMA                    IN VARCHAR2,
      I_PSA_SCHEMA                      in varchar2
      );

  FUNCTION GET_LAST_HIGH_WM_SRC_DELTA (
      I_SCHEMA_NAME           IN VARCHAR2,
      I_TABLE_NAME            IN VARCHAR2)
    RETURN VARCHAR2;

  FUNCTION GET_LAST_DELTA_DATE (
      I_SCHEMA_NAME           IN VARCHAR2,
      I_TABLE_NAME            IN VARCHAR2,
      I_MAPPING_NAME          IN VARCHAR2)
    RETURN DATE;

  FUNCTION GET_NEXT_DELTA_DATE (
      I_SOURCE_TAB_LIST       IN VARCHAR2,
      I_SCHEMA_NAME           IN VARCHAR2 DEFAULT NULL,
      I_TABLE_NAME            IN VARCHAR2 DEFAULT NULL,
      I_MAPPING_NAME          IN VARCHAR2 DEFAULT NULL
      )
    RETURN DATE;

  FUNCTION GET_MAX_SRC_DELTA_DATE (
      I_SOURCE_TAB_LIST       IN VARCHAR2,
      I_SCHEMA_NAME           IN VARCHAR2 DEFAULT NULL,
      I_TABLE_NAME            IN VARCHAR2 DEFAULT NULL,
      I_MAPPING_NAME          IN VARCHAR2 DEFAULT NULL
      )
    RETURN DATE;

  FUNCTION GET_DELTA_DATE_FROM_LOG (
      I_ODI_ID                IN NUMBER
      )
    RETURN DATE;

  FUNCTION GET_ODI_SESS_INS_UPD (
      I_ODI_ID                IN NUMBER
      )
    RETURN NUMBER;

  PROCEDURE SET_PARAMETER (
      I_PARAMETER_NAME        IN VARCHAR2,
      I_CHAR_VALUE_1          IN VARCHAR2 DEFAULT NULL,
      I_CHAR_VALUE_2          IN VARCHAR2 DEFAULT NULL,
      I_DATE_VALUE_1          IN DATE DEFAULT NULL,
      I_DATE_VALUE_2          IN DATE DEFAULT NULL,
      I_NUMBER_VALUE_1        IN NUMBER DEFAULT NULL,
      I_NUMBER_VALUE_2        IN NUMBER DEFAULT NULL,
      I_PARAMETER_DESCRIPTION IN VARCHAR2 DEFAULT NULL
  );


  PROCEDURE SET_PARAMETER_SCEN_VERSION (
      I_MAPPING_NAME        IN VARCHAR2
  );


  FUNCTION IS_SCEN_VERSION_PARAM_ACTUAL (
      I_MAPPING_NAME        IN VARCHAR2
  )
  RETURN CHAR;

END DWH_ETL_LOG;
/


-------------------
-- Zugehörige Grants
-------------------

  GRANT EXECUTE ON "DWH_MTD"."DWH_ETL_LOG" TO "DWH_WORK";

