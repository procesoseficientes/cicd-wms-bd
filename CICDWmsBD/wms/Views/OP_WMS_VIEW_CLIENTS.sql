-- =============================================
-- Autor:					
-- Fecha de Creacion: 		
-- Description:			    Vista de todos los clientes

-- Modificacion 8/9/2017 @ NEXUS-Team Sprint Banjo-Kazooie
					-- rodrigo.gomez
					-- Se agrega un union a la tabla de OP_WMS_COMPANY

-- Modificacion 8/29/2017 @ NEXUS-Team Sprint CommandAndConquer
					-- rodrigo.gomez
					-- Se agrega UNION a la tabla OP_SETUP_COMPANY

-- Modificacion 18-Jan-18 @ Nexus Team Sprint Strom
					-- alberto.ruiz
					-- Se agrega union all a la tabla OP_WMS_CLIENT y los campos [IS_ACTIVE] y [CAN_EDIT]

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].[OP_WMS_VIEW_CLIENTS]
*/
-- =============================================
CREATE VIEW [wms].[OP_WMS_VIEW_CLIENTS]
AS
	SELECT
		[CardCode] COLLATE DATABASE_DEFAULT AS [CLIENT_CODE]
		,[CardName] COLLATE DATABASE_DEFAULT AS [CLIENT_NAME]
		,'N/A' AS [CLIENT_ROUTE]
		,'AAA' AS [CLIENT_CLASS]
		,1 AS [CLIENT_STATUS]
		,'' AS [CLIENT_REGION]
		,'' AS [CLIENT_ADDRESS]
		,'9999' AS [CLIENT_CA]
		,[CardCode] COLLATE DATABASE_DEFAULT AS [CLIENT_ERP_CODE]
		,1 [IS_ACTIVE]
		,0 [CAN_EDIT]
	FROM [wms].[OP_WMS_SAP_CLIENTS]
	UNION ALL
	SELECT
		[CLIENT_CODE]
		,[COMPANY_NAME] [CLIENT_NAME]
		,'N/A' AS [CLIENT_ROUTE]
		,'AAA' AS [CLIENT_CLASS]
		,1 AS [CLIENT_STATUS]
		,'' AS [CLIENT_REGION]
		,'' AS [CLIENT_ADDRESS]
		,'9999' AS [CLIENT_CA]
		,[MASTER_ID_CLIENT_CODE] [CLIENT_ERP_CODE]
		,1 [IS_ACTIVE]
		,0 [CAN_EDIT]
	FROM [wms].[OP_WMS_COMPANY]
	WHERE [COMPANY_ID] > 0
	UNION ALL
	SELECT
		[COMPANY_CODE] [CLIENT_CODE]
		,[COMPANY_NAME] [CLIENT_NAME]
		,'N/A' AS [CLIENT_ROUTE]
		,'AAA' AS [CLIENT_CLASS]
		,1 AS [CLIENT_STATUS]
		,'' AS [CLIENT_REGION]
		,'' AS [CLIENT_ADDRESS]
		,'9999' AS [CLIENT_CA]
		,[COMPANY_CODE] COLLATE DATABASE_DEFAULT AS [CLIENT_ERP_CODE]
		,1 [IS_ACTIVE]
		,0 [CAN_EDIT]
	FROM [wms].[OP_SETUP_COMPANY]
	UNION ALL
	SELECT
		[C].[CLIENT_CODE] [CLIENT_CODE]
		,[C].[CLIENT_NAME] [CLIENT_NAME]
		,'N/A' AS [CLIENT_ROUTE]
		,'AAA' AS [CLIENT_CLASS]
		,1 AS [CLIENT_STATUS]
		,'' AS [CLIENT_REGION]
		,'' AS [CLIENT_ADDRESS]
		,'9999' AS [CLIENT_CA]		
		,[C].[CLIENT_CODE_ERP] [CLIENT_ERP_CODE]
		,[C].[IS_ACTIVE]
		,1 [CAN_EDIT]
	FROM [wms].[OP_WMS_CLIENT] [C]
	WHERE [C].[CLIENT_ID] > 0