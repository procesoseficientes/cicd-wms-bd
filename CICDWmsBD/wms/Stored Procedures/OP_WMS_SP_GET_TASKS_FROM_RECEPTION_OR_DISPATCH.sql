-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		13-02-2018 @ Reborn Team Sprint Ulrich
-- Description:			    SP que obtiene las tareas para ser posteadas en la BD de PouchDB para 3pl-mobile

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[OP_WMS_SP_GET_TASKS_FROM_RECEPTION_OR_DISPATCH]
			@SERIAL_NUMBER = 0
			,@WAVE_PICKING_ID = 4873'
				
			'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TASKS_FROM_RECEPTION_OR_DISPATCH]
	(
		@SERIAL_NUMBER INT = NULL
		,@WAVE_PICKING_ID INT = NULL
	)
AS
	BEGIN
		--
		SET NOCOUNT ON;		
		
		IF @SERIAL_NUMBER IS NOT NULL AND @SERIAL_NUMBER != 0
		BEGIN
			SELECT
				CAST([TL].[SERIAL_NUMBER] AS INT) AS [id]
				,CAST(ISNULL([TL].[WAVE_PICKING_ID], 0) AS INT) AS [wavePickingId]
				,CAST(ISNULL([TL].[TRANS_OWNER],0) AS INT) AS [transOwner]
				,[TL].[TASK_TYPE] AS [taskType]
				,[TL].[TASK_SUBTYPE] AS [taskSubType]
				,[TL].[TASK_OWNER] AS [taskkOwer]
				,[TL].[TASK_ASSIGNEDTO] AS [taskAssignedTo]
				,ISNULL([TL].[TASK_COMMENTS],'') AS [taskComments]
				,[TL].[ASSIGNED_DATE] AS [assignedDate]
				,[TL].[QUANTITY_PENDING] AS [quantityPending]
				,[TL].[QUANTITY_ASSIGNED] AS [quantityAssigned]
				,ISNULL([TL].[CODIGO_POLIZA_SOURCE],'') AS [sourcePolicyCode]
				,ISNULL([TL].[CODIGO_POLIZA_TARGET],'') AS [targetPolicyCode]
				,CAST(ISNULL([TL].[LICENSE_ID_SOURCE],0) AS INT)  AS [licenseIdSource]
				,ISNULL([TL].[REGIMEN],'') AS [regime]
				,CAST(ISNULL([TL].[IS_COMPLETED],0) AS INT) AS [isCompleted]
				,[TL].[IS_DISCRETIONAL] AS [isDiscretional]
				,CAST(ISNULL([TL].[IS_PAUSED],0) AS INT) AS [isPaused]
				,CAST(ISNULL([TL].[IS_CANCELED],0) AS INT) AS [isCanceled]
				,[TL].[MATERIAL_ID] AS [materialId]
				,[TL].[BARCODE_ID] AS [barcodeId]
				,[TL].[ALTERNATE_BARCODE] AS [alternateBarcode]
				,[TL].[MATERIAL_NAME] AS [materialName]
				,ISNULL([TL].[WAREHOUSE_SOURCE],'') AS [warehouseSource]
				,ISNULL([TL].[WAREHOUSE_TARGET],'') AS [warehouseTarget]
				,ISNULL([TL].[LOCATION_SPOT_SOURCE],'') AS [locationSpotSource]
				,ISNULL([TL].[LOCATION_SPOT_TARGET],'') AS [locationSpotTarget]
				,ISNULL([TL].[CLIENT_OWNER],'') AS [clientOwner]
				,ISNULL([TL].[CLIENT_NAME],'') AS [clientName]
				,ISNULL([TL].[ACCEPTED_DATE],GETDATE()) AS [acceptedDate]
				,ISNULL([TL].[COMPLETED_DATE],GETDATE()) AS [completedDate]
				,ISNULL([TL].[CANCELED_DATETIME],GETDATE()) AS [canceledDatetime]
				,ISNULL([TL].[CANCELED_BY],'') AS [canceledBy]
				,ISNULL([TL].[MATERIAL_SHORT_NAME],'') AS [materialShortName]
				,ISNULL([TL].[IS_lOCKED],'0') AS [isLocked]
				,[TL].[IS_DISCRETIONARY] AS [isDiscretionary]
				,ISNULL([TL].[TYPE_DISCRETIONARY],'') AS [typeDiscretionary]
				,ISNULL([TL].[LINE_NUMBER_POLIZA_SOURCE],0) AS [lineNumberSourcePolicy]
				,ISNULL([TL].[LINE_NUMBER_POLIZA_TARGET],0) AS [lineNumberTargetPolicy]
				,CAST(ISNULL([TL].[DOC_ID_SOURCE],0) AS int) AS [docIdSource]
				,CAST(ISNULL([TL].[DOC_ID_TARGET],0) AS INT) AS [docIdTarget]
				,ISNULL([TL].[IS_ACCEPTED],0) AS [isAccepted]
				,ISNULL([TL].[IS_FROM_SONDA],0) AS [isFromSonda]
				,[TL].[IS_FROM_ERP] AS [isFromErp]
				,[TL].[PRIORITY] AS [priority]
				,ISNULL([TL].[REPLENISH_MATERIAL_ID_TARGET],'') AS [replenishMaterialIdTarget]
				,[TL].[FROM_MASTERPACK] AS [fromMaterpack]
				,ISNULL([TL].[MASTER_PACK_CODE],'') AS [masterPackCode]
				,ISNULL([TL].[OWNER],'') AS [owner]
				,ISNULL([TL].[SOURCE_TYPE],'') AS [sourceType]
				,ISNULL([TL].[TRANSFER_REQUEST_ID],0) AS [tranferRequestId]
				,ISNULL([TL].[TONE],'') AS [tone]
				,ISNULL([TL].[CALIBER],'') AS [caliber]
				,ISNULL([TL].[LICENSE_ID_TARGET],0) AS [licenseIdTarget]
				,[TL].[IN_PICKING_LINE] AS [inPickingLine]
				,[TL].[IS_FOR_DELIVERY_IMMEDIATE] AS [isForDeliveryImmediate]
			FROM
				[wms].[OP_WMS_TASK_LIST] [TL]
			WHERE
				[TL].[SERIAL_NUMBER] = @SERIAL_NUMBER;
		END;
		ELSE
		BEGIN
			SELECT
				CAST([TL].[SERIAL_NUMBER] AS INT) AS [id]
				,CAST(ISNULL([TL].[WAVE_PICKING_ID], 0) AS INT) AS [wavePickingId]
				,CAST(ISNULL([TL].[TRANS_OWNER],0) AS INT) AS [transOwner]
				,[TL].[TASK_TYPE] AS [taskType]
				,[TL].[TASK_SUBTYPE] AS [taskSubType]
				,[TL].[TASK_OWNER] AS [taskkOwer]
				,[TL].[TASK_ASSIGNEDTO] AS [taskAssignedTo]
				,ISNULL([TL].[TASK_COMMENTS],'') AS [taskComments]
				,[TL].[ASSIGNED_DATE] AS [assignedDate]
				,[TL].[QUANTITY_PENDING] AS [quantityPending]
				,[TL].[QUANTITY_ASSIGNED] AS [quantityAssigned]
				,ISNULL([TL].[CODIGO_POLIZA_SOURCE],'') AS [sourcePolicyCode]
				,ISNULL([TL].[CODIGO_POLIZA_TARGET],'') AS [targetPolicyCode]
				,CAST(ISNULL([TL].[LICENSE_ID_SOURCE],0) AS INT)  AS [licenseIdSource]
				,ISNULL([TL].[REGIMEN],'') AS [regime]
				,CAST(ISNULL([TL].[IS_COMPLETED],0) AS INT) AS [isCompleted]
				,[TL].[IS_DISCRETIONAL] AS [isDiscretional]
				,CAST(ISNULL([TL].[IS_PAUSED],0) AS INT) AS [isPaused]
				,CAST(ISNULL([TL].[IS_CANCELED],0) AS INT) AS [isCanceled]
				,[TL].[MATERIAL_ID] AS [materialId]
				,[TL].[BARCODE_ID] AS [barcodeId]
				,[TL].[ALTERNATE_BARCODE] AS [alternateBarcode]
				,[TL].[MATERIAL_NAME] AS [materialName]
				,ISNULL([TL].[WAREHOUSE_SOURCE],'') AS [warehouseSource]
				,ISNULL([TL].[WAREHOUSE_TARGET],'') AS [warehouseTarget]
				,ISNULL([TL].[LOCATION_SPOT_SOURCE],'') AS [locationSpotSource]
				,ISNULL([TL].[LOCATION_SPOT_TARGET],'') AS [locationSpotTarget]
				,ISNULL([TL].[CLIENT_OWNER],'') AS [clientOwner]
				,ISNULL([TL].[CLIENT_NAME],'') AS [clientName]
				,ISNULL([TL].[ACCEPTED_DATE],GETDATE()) AS [acceptedDate]
				,ISNULL([TL].[COMPLETED_DATE],GETDATE()) AS [completedDate]
				,ISNULL([TL].[CANCELED_DATETIME],GETDATE()) AS [canceledDatetime]
				,ISNULL([TL].[CANCELED_BY],'') AS [canceledBy]
				,ISNULL([TL].[MATERIAL_SHORT_NAME],'') AS [materialShortName]
				,ISNULL([TL].[IS_lOCKED],'0') AS [isLocked]
				,[TL].[IS_DISCRETIONARY] AS [isDiscretionary]
				,ISNULL([TL].[TYPE_DISCRETIONARY],'') AS [typeDiscretionary]
				,ISNULL([TL].[LINE_NUMBER_POLIZA_SOURCE],0) AS [lineNumberSourcePolicy]
				,ISNULL([TL].[LINE_NUMBER_POLIZA_TARGET],0) AS [lineNumberTargetPolicy]
				,CAST(ISNULL([TL].[DOC_ID_SOURCE],0) AS int) AS [docIdSource]
				,CAST(ISNULL([TL].[DOC_ID_TARGET],0) AS INT) AS [docIdTarget]
				,ISNULL([TL].[IS_ACCEPTED],0) AS [isAccepted]
				,ISNULL([TL].[IS_FROM_SONDA],0) AS [isFromSonda]
				,[TL].[IS_FROM_ERP] AS [isFromErp]
				,[TL].[PRIORITY] AS [priority]
				,ISNULL([TL].[REPLENISH_MATERIAL_ID_TARGET],'') AS [replenishMaterialIdTarget]
				,[TL].[FROM_MASTERPACK] AS [fromMaterpack]
				,ISNULL([TL].[MASTER_PACK_CODE],'') AS [masterPackCode]
				,ISNULL([TL].[OWNER],'') AS [owner]
				,ISNULL([TL].[SOURCE_TYPE],'') AS [sourceType]
				,ISNULL([TL].[TRANSFER_REQUEST_ID],0) AS [tranferRequestId]
				,ISNULL([TL].[TONE],'') AS [tone]
				,ISNULL([TL].[CALIBER],'') AS [caliber]
				,ISNULL([TL].[LICENSE_ID_TARGET],0) AS [licenseIdTarget]
				,[TL].[IN_PICKING_LINE] AS [inPickingLine]
				,[TL].[IS_FOR_DELIVERY_IMMEDIATE] AS [isForDeliveryImmediate]
			FROM
				[wms].[OP_WMS_TASK_LIST] [TL]
			WHERE
				[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;
		END;
		
	END;