-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/1/2017 @ NEXUS-Team Sprint CommandAndConquer 
-- Description:			Se obtienen las solicitudes de traslado por bodega, fecha y estado.

/*
-- Ejemplo de Ejecucion:
				DECLARE @START_DATETIME DATETIME = GETDATE()-2
						,@END_DATETIME DATETIME = GETDATE()
				--
				EXEC [wms].[OP_WMS_SP_GET_TRANSFER_REQUEST_BY_WAREHOUSE_AND_DATETIME] 
					@START_DATETIME = @START_DATETIME, -- datetime
					@END_DATETIME = @END_DATETIME, -- datetime
					@STATUS = 'CLOSED', -- varchar(25)
					@WAREHOUSES = 'BODEGA_02' -- varchar(max)
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TRANSFER_REQUEST_BY_WAREHOUSE_AND_DATETIME](
	@START_DATETIME DATETIME
	,@END_DATETIME DATETIME
	,@STATUS VARCHAR(25)
	,@WAREHOUSES VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	-- ------------------------------------------------------------------------------------
	-- Inserta las bodegas en una tabla temporal
	-- ------------------------------------------------------------------------------------
	SELECT
		[VALUE] [WAREHOUSE_ID]
	INTO
		[#WAREHOUSES]
	FROM
		[wms].[OP_WMS_FN_SPLIT](@WAREHOUSES, '|');
	-- ------------------------------------------------------------------------------------
	-- Inserta los centros de distribucion en una tabla temporal
	-- ------------------------------------------------------------------------------------
	SELECT
		[PARAM_CAPTION] [DISTRIBUTION_CENTER_NAME]
		,[TEXT_VALUE] [DISTRIBUTION_CENTER_ID]
	INTO
		[#DISTRIBUTION_CENTERS]
	FROM
		[wms].[OP_WMS_CONFIGURATIONS]
	WHERE
		[PARAM_GROUP] = 'DISTRIBUTION_CENTER';
	-- ------------------------------------------------------------------------------------
	-- Despliega el resultado final
	-- ------------------------------------------------------------------------------------
	SELECT 
			 [TRH].[TRANSFER_REQUEST_ID]
			,[W].[DISTRIBUTION_CENTER_ID]
			,[DC].[DISTRIBUTION_CENTER_NAME]
			,[TRH].[WAREHOUSE_TO]
			,[TRH].[WAREHOUSE_FROM]
			,[TRH].[REQUEST_DATE]
			,[TRH].[DELIVERY_DATE]
			,MAX([RDH].[LAST_UPDATE]) [RECEPTION_DATE]
			,CASE [TRD].[STATUS]
				WHEN 'OPEN' THEN 'ABIERTA'
				WHEN 'CLOSED' THEN 'CERRADA'
				ELSE [TRD].[STATUS]
			END [STATUS]
			,[TRD].[MATERIAL_ID]
			,[TRD].[MATERIAL_NAME]
			,CAST([TRD].[QTY] AS NUMERIC(18,2)) [QTY]
			,CAST([TRD].[QTY_PROCESSED] AS NUMERIC(18,2)) [PROCESSED_QTY]
			,CAST(([TRD].[QTY] - [TRD].[QTY_PROCESSED]) AS NUMERIC(18,2)) [PENDING_QTY]
			,[TRH].[DOC_NUM]
			,[TRH].[DOC_ENTRY]
			,[TRH].[IS_FROM_ERP] 
			,[TRH].[CREATED_BY]
	FROM [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [TRH]
		INNER JOIN [wms].[OP_WMS_TRANSFER_REQUEST_DETAIL] [TRD] ON [TRD].[TRANSFER_REQUEST_ID] = [TRH].[TRANSFER_REQUEST_ID]
		INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON [W].[WAREHOUSE_ID] = [TRH].[WAREHOUSE_TO]
		INNER JOIN [#DISTRIBUTION_CENTERS] [DC] ON [DC].[DISTRIBUTION_CENTER_ID] = [W].[DISTRIBUTION_CENTER_ID]
		INNER JOIN [#WAREHOUSES] [WF] ON [TRH].[WAREHOUSE_TO] = [WF].[WAREHOUSE_ID]
		LEFT JOIN [wms].[OP_WMS_MANIFEST_HEADER] [MH] ON [MH].[TRANSFER_REQUEST_ID] = [TRH].[TRANSFER_REQUEST_ID]
		LEFT JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH] ON [RDH].[DOC_NUM] = [MH].[MANIFEST_HEADER_ID] AND [RDH].[IS_FROM_WAREHOUSE_TRANSFER] = 1
	WHERE (@STATUS <> 'OPEN' OR [TRD].[STATUS] = @STATUS)
		AND [TRH].[REQUEST_DATE] BETWEEN @START_DATETIME AND @END_DATETIME
	GROUP BY [TRH].[TRANSFER_REQUEST_ID]
			,[W].[DISTRIBUTION_CENTER_ID]
			,[DC].[DISTRIBUTION_CENTER_NAME]
			,[TRH].[WAREHOUSE_TO]
			,[TRH].[WAREHOUSE_FROM]
			,[TRH].[REQUEST_DATE]
			,[TRH].[DELIVERY_DATE]
			,[TRD].[STATUS]
			,[TRD].[MATERIAL_ID]
			,[TRD].[MATERIAL_NAME]
			,[TRD].[QTY]
			,[TRH].[DOC_NUM]
			,[TRH].[DOC_ENTRY]
			,[TRH].[IS_FROM_ERP] 
			,[TRH].[CREATED_BY]
			,[TRD].[QTY_PROCESSED]
END