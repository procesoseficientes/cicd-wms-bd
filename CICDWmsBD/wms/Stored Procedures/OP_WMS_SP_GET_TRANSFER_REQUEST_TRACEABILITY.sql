-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/1/2017 @ NEXUS-Team Sprint CommandAndConquer 
-- Description:			Obtiene la trazabilidad de las solicitudes de traslado

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_TRANSFER_REQUEST_TRACEABILITY]
					@TRANSFER_REQUEST_ID = 75
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TRANSFER_REQUEST_TRACEABILITY](
	@TRANSFER_REQUEST_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	CREATE TABLE [#TRACEABILITY](
		[TRANSFER_REQUEST_ID] INT
		,[TRANS_TYPE] VARCHAR(25)
		,[TASK_ID] INT
		,[CREATED_DATE] DATETIME
		,[QTY] DECIMAL(18,6)
		,[PROCESSED_QUANTITY] DECIMAL(18,6)
		,[TASK_ASSIGNED_TO] VARCHAR(50)
		,[DRIVER] VARCHAR(50)
		,[VEHICLE] VARCHAR(50)
	)
	-- ------------------------------------------------------------------------------------
	-- Obtiene los pickings y los inserta en la tabla de TRAZABILIDAD
	-- ------------------------------------------------------------------------------------
	INSERT INTO [#TRACEABILITY]
	SELECT
		[DH].[TRANSFER_REQUEST_ID]
		,'Picking' [TRANS_TYPE]
		,[TL].[WAVE_PICKING_ID] [TASK_ID]
		,[DH].[CREATED_DATE]
		,SUM([TL].[QUANTITY_ASSIGNED]) [QTY]
		,CASE WHEN SUM([TL].[QUANTITY_PENDING]) != SUM([TL].[QUANTITY_PENDING])
		THEN SUM([TL].[QUANTITY_ASSIGNED]) - SUM([TL].[QUANTITY_PENDING])
		ELSE SUM([TL].[QUANTITY_ASSIGNED])
		END [PROCESSED_QUANTITY]
		,[TL].[TASK_ASSIGNEDTO]
		,NULL
		,NULL
	FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH]
		INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON [TL].[WAVE_PICKING_ID] = [DH].[WAVE_PICKING_ID]
	WHERE [DH].[TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
	GROUP BY [DH].[TRANSFER_REQUEST_ID]
			,[TL].[WAVE_PICKING_ID]
			,[DH].[CREATED_DATE]
			,[TL].[TASK_ASSIGNEDTO]

	-- ------------------------------------------------------------------------------------
	-- Obtiene las recepciones a la tabla de TRAZABILIDAD
	-- ------------------------------------------------------------------------------------
	INSERT INTO [#TRACEABILITY]
	SELECT [MH].[TRANSFER_REQUEST_ID]
			,'Recepción' [TRANS_TYPE]
			,[TL].[SERIAL_NUMBER] [TASK_ID]
			,[MH].[CREATED_DATE]
			,SUM([MD].[QTY]) [QTY]
			,SUM([IXL].[ENTERED_QTY]) [PROCESSED_QUANTITY]
			,[TL].[TASK_ASSIGNEDTO]
			,[MH].[DRIVER]
			,[MH].[VEHICLE]
	FROM [wms].[OP_WMS_MANIFEST_HEADER] [MH]
		INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD] ON [MD].[MANIFEST_HEADER_ID] = [MH].[MANIFEST_HEADER_ID]
		INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH] ON [RH].[DOC_NUM] = [MH].[MANIFEST_HEADER_ID] AND [RH].[IS_FROM_WAREHOUSE_TRANSFER] = 1
		INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON [TL].[SERIAL_NUMBER] = [RH].[TASK_ID]
		INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[CODIGO_POLIZA] = [TL].[CODIGO_POLIZA_SOURCE]
		INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IXL] ON [L].[LICENSE_ID] = [IXL].[LICENSE_ID]
	WHERE [MH].[TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
	GROUP BY [MH].[TRANSFER_REQUEST_ID]
			,[TL].[SERIAL_NUMBER]
			,[MH].[CREATED_DATE]
			,[TL].[TASK_ASSIGNEDTO]
			,[MH].[DRIVER]
			,[MH].[VEHICLE]
	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado final
	-- ------------------------------------------------------------------------------------
	SELECT [TRANSFER_REQUEST_ID]
			,[TRANS_TYPE]
			,[TASK_ID]
			,[CREATED_DATE]
			,[QTY]
			,[PROCESSED_QUANTITY]
			,[TASK_ASSIGNED_TO]
			,[DRIVER]
			,[DRIVER] + '-' + [VEHICLE] [VEHICLE]
	FROM [#TRACEABILITY]
END