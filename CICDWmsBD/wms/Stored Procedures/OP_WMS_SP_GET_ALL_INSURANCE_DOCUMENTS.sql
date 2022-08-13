-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	2017-11-06 @ Team NEXUS - F-Zero
-- Description:	        Devuelve todas las polzias de seguro

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].OP_WMS_SP_GET_ALL_INSURANCE_DOCUMENTS
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_ALL_INSURANCE_DOCUMENTS
AS
BEGIN
    SET NOCOUNT ON;
	--

	SELECT CAST([DOC_ID]AS VARCHAR) DOC_ID
          ,[COMPANY_ID]
          ,[AMOUNT]
          ,[AVAILABLE]
          ,[LAST_TXN_DATE]
          ,[CREATED_DATE]
          ,[CREATED_BY]
          ,[LAST_UPDATED]
          ,[LAST_UPDATED_BY]
          ,[CLIENT_CODE]
          ,[COVERAGE]
          ,[VALIN_FROM]
          ,[VALIN_TO]
          ,[POLIZA_INSURANCE]
          ,[INSURANCE_OWHEN]
	FROM [wms].[OP_WMS_INSURANCE_DOCS]
	WHERE [DOC_ID] > 0
	
END;