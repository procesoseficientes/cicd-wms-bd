-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-02-16 @ Team ERGON - Sprint ERGON 
-- Description:	        

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_GET_CLIENTS_FOR_MANIFIEST_REPORT] @MANIFEST_HEADER_ID = 5 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_CLIENTS_FOR_MANIFIEST_REPORT] (@MANIFEST_HEADER_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [MD].[CLIENT_CODE]
  FROM [wms].[OP_WMS_MANIFEST_HEADER] [MH]
  INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD]
    ON [MH].[MANIFEST_HEADER_ID] = [MD].[MANIFEST_HEADER_ID]
  WHERE [MH].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID

END