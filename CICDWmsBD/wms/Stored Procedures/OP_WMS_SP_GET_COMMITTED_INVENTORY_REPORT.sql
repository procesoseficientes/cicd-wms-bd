-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	1/9/2018 @ Reborn-TEAM Sprint Ramsey
-- Description:			SP que obtiene los registros de las demandas de despacho de entrega no inmediata

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_COMMITTED_INVENTORY_REPORT]
				@INIT_DATE = '2014-01-09 09:31:03.710'
				,@END_DATE = '2018-01-09 09:31:03.710'
				,@LOGIN_ID = 'ADMIN'
*/
-- =================================================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_COMMITTED_INVENTORY_REPORT] (
		@INIT_DATE DATETIME
		,@END_DATE DATETIME
		,@LOGIN_ID VARCHAR(50)
	)
AS
BEGIN
    --
	SET NOCOUNT ON;

    --
	SELECT
		[DH].[PICKING_DEMAND_HEADER_ID]
		,[DH].[DOC_NUM] [DOC_NUM]
		, --[DH].[DOC_NUM],
		CAST([DH].[DEMAND_DELIVERY_DATE] AS DATE) AS [DELIVERY_DATE]
		,[DH].[CLIENT_CODE]
		,[DH].[CLIENT_NAME]
		,(CASE	WHEN [DH].[IS_FROM_ERP] = 1 THEN 'SI'
				WHEN [DH].[IS_FROM_ERP] = 0 THEN 'NO'
				ELSE 'NO'
			END) [IS_FROM_ERP]
		,(CASE	WHEN [DH].[IS_FROM_SONDA] = 1 THEN 'SI'
				WHEN [DH].[IS_FROM_SONDA] = 0 THEN 'NO'
				ELSE 'NO'
			END) [IS_FROM_SONDA]
		,[DH].[WAVE_PICKING_ID]
		,(CASE	WHEN [DH].[DEMAND_TYPE] = 'TRANSFER_REQUEST'
				THEN 'Solicitud de Transferencia'
				ELSE [DH].[TYPE_DEMAND_NAME]
			END) [DEMAND_TYPE]
		,[DH].[PROJECT]
	FROM
		[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] AS [DH]
	INNER JOIN [wms].[OP_WMS_WAREHOUSE_BY_USER] AS [WBU] ON ([WBU].[WAREHOUSE_ID] = [DH].[CODE_WAREHOUSE])
	INNER JOIN [wms].[OP_WMS_LICENSES] [l] ON [l].[WAVE_PICKING_ID] = [DH].[WAVE_PICKING_ID]
	INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [il] ON [il].[LICENSE_ID] = [l].[LICENSE_ID]
											AND [il].[QTY] > 0
	INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [T].[WAVE_PICKING_ID] = [DH].[WAVE_PICKING_ID]
	WHERE
		[WBU].[LOGIN_ID] = @LOGIN_ID
		AND [DH].[CREATED_DATE] BETWEEN @INIT_DATE
								AND		@END_DATE
	GROUP BY
		[DH].[DOC_NUM]
		,[DH].[IS_FROM_ERP]
		,[DH].[DEMAND_DELIVERY_DATE]
		,[DH].[IS_FROM_SONDA]
		,[DH].[TYPE_DEMAND_NAME]
		,[DH].[DEMAND_TYPE]
		,[DH].[PICKING_DEMAND_HEADER_ID]
		,[DH].[CLIENT_CODE]
		,[DH].[CLIENT_NAME]
		,[DH].[WAVE_PICKING_ID]
		,[DH].[PROJECT];
END;
