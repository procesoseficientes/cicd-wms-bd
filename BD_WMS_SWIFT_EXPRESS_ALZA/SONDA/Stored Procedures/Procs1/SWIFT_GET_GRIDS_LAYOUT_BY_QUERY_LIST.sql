-- =============================================
-- Autor:				Yaqueline Canahui
-- Fecha de Creacion: 	08-08-2018 @ G-Force Sprint Hormiga
-- Description:			SP que obtiene el layout para query list

/*

*/
-- =============================================

CREATE PROCEDURE [SONDA].[SWIFT_GET_GRIDS_LAYOUT_BY_QUERY_LIST] (@QUERY_LIST_ID INT
, @LOGIN_ID VARCHAR(50))
AS
BEGIN

  SELECT
    [QG].[QUERY_LIST_ID]
   ,[QG].[LOGIN_ID]
   ,[QG].[LAYOUT_XML]
  FROM [SONDA].[SWIFT_QUERY_LIST_BY_GRIDS_LAYOUT] [QG]
  WHERE [QG].[QUERY_LIST_ID] = @QUERY_LIST_ID
  AND [QG].[LOGIN_ID] = @LOGIN_ID


END
