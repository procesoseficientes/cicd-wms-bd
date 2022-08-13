-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-13 @ Team ERGON - Sprint ERGON 1
-- Description:	        Consulta los clientes de fuente externa

-- Modificacion 09-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
					-- alberto.ruiz
					-- Se agrega join a OP_WMS_COMPANY


/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_CLIENTS_FROM_EXTERNAL_SOURCE]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_CLIENTS_FROM_EXTERNAL_SOURCE]
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[ES].[EXTERNAL_SOURCE_ID]
		,[ES].[SOURCE_NAME]
		,[ES].[DATA_BASE_NAME]
		,[ES].[SCHEMA_NAME]
		,[ES].[COMMENT]
		,[ES].[INTERFACE_DATA_BASE_NAME]
		,[C].[COMPANY_ID]
		,[C].[COMPANY_NAME]
		,[C].[CLIENT_CODE]
	FROM
		[wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
	INNER JOIN [wms].[OP_WMS_COMPANY] [C] ON ([C].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID])
	WHERE
		[C].[COMPANY_ID] > 0
		AND [ES].[READ_ERP] = 1;
END;