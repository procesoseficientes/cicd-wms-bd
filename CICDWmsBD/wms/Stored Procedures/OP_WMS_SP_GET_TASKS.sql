-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		13-02-2018 @ Reborn Team Sprint Ulrich
-- Description:			    SP que obtiene las tareas para ser posteadas en la BD de PouchDB para 3pl-mobile

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[OP_WMS_SP_GET_TASKS]
			@TASK_LIST = '
				
			'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TASKS] (@TASK_LIST XML)
AS
	BEGIN
		--
		SET NOCOUNT ON;
		
		--
		DECLARE @TASK TABLE(
			[SERIAL_NUMBER] INT
		)

		--
		INSERT INTO @TASK
				([SERIAL_NUMBER])
		SELECT
		 [x].[Rec].[query]('./SERIAL_NUMBER').[value]('.', 'int')     
		FROM @TASK_LIST.[nodes]('/ArrayOfTarea/Tarea') AS [x] ([Rec]);

		--
		SELECT
			[TL].[SERIAL_NUMBER] AS [id]
			,[TL].[WAVE_PICKING_ID] AS [wavePickingId]
			,[TL].[TRANS_OWNER] AS [transOwner]
			,[TL].[TASK_TYPE] AS [taskType]
			,[TL].[TASK_SUBTYPE] AS [taskSubType]
			,[TL].[TASK_OWNER] AS [taskkOwer]
			,[TL].[TASK_ASSIGNEDTO] AS [taskAssignedTo]
			,[TL].[TASK_COMMENTS] AS [taskComments]
			,[TL].[ASSIGNED_DATE] AS [assignedDate]
			,[TL].[QUANTITY_PENDING] AS [quantityPending]
			,[TL].[QUANTITY_ASSIGNED] AS [quantityAssigned]
			,[TL].[CODIGO_POLIZA_SOURCE] AS [sourcePolicyCode]
			,[TL].[CODIGO_POLIZA_TARGET] AS [targetPolicyCode]
			,[TL].[LICENSE_ID_SOURCE] AS [licenseIdSource]
			,[TL].[REGIMEN] AS [regime]
			,[TL].[IS_COMPLETED] AS [isCompleted]
			,[TL].[IS_DISCRETIONAL] AS [isDiscretional]
			,[TL].[IS_PAUSED] AS [isPaused]
			,[TL].[IS_CANCELED] AS [isCanceled]
			,[TL].[MATERIAL_ID] AS [materialId]
			,[TL].[BARCODE_ID] AS [barcodeId]
			,[TL].[ALTERNATE_BARCODE] AS [alternateBarcode]
			,[TL].[MATERIAL_NAME] AS [materialName]
			,[TL].[WAREHOUSE_SOURCE] AS [warehouseSource]
			,[TL].[WAREHOUSE_TARGET] AS [warehouseTarget]
			,[TL].[LOCATION_SPOT_SOURCE] AS [locationSpotSource]
			,[TL].[LOCATION_SPOT_TARGET] AS [locationSpotTarget]
			,[TL].[CLIENT_OWNER] AS [clientOwner]
			,[TL].[CLIENT_NAME] AS [clientName]
			,[TL].[ACCEPTED_DATE] AS [acceptedDate]
			,[TL].[COMPLETED_DATE] AS [completedDate]
			,[TL].[CANCELED_DATETIME] AS [canceledDatetime]
			,[TL].[CANCELED_BY] AS [canceledBy]
			,[TL].[MATERIAL_SHORT_NAME] AS [materialShortName]
			,[TL].[IS_lOCKED] AS [isLocked]
			,[TL].[IS_DISCRETIONARY] AS [isDiscretionary]
			,[TL].[TYPE_DISCRETIONARY] AS [typeDiscretionary]
			,[TL].[LINE_NUMBER_POLIZA_SOURCE] AS [lineNumberSourcePolicy]
			,[TL].[LINE_NUMBER_POLIZA_TARGET] AS [lineNumberTargetPolicy]
			,[TL].[DOC_ID_SOURCE] AS [docIdSource]
			,[TL].[DOC_ID_TARGET] AS [docIdTarget]
			,[TL].[IS_ACCEPTED] AS [isAccepted]
			,[TL].[IS_FROM_SONDA] AS [isFromSonda]
			,[TL].[IS_FROM_ERP] AS [isFromErp]
			,[TL].[PRIORITY] AS [priority]
			,[TL].[REPLENISH_MATERIAL_ID_TARGET] AS [replenishMaterialIdTarget]
			,[TL].[FROM_MASTERPACK] AS [fromMaterpack]
			,[TL].[MASTER_PACK_CODE] AS [masterPackCode]
			,[TL].[OWNER] AS [owner]
			,[TL].[SOURCE_TYPE] AS [sourceType]
			,[TL].[TRANSFER_REQUEST_ID] AS [tranferRequestId]
			,[TL].[TONE] AS [tone]
			,[TL].[CALIBER] AS [caliber]
			,[TL].[LICENSE_ID_TARGET] AS [licenseIdTarget]
			,[TL].[IN_PICKING_LINE] AS [inPickingLine]
			,[TL].[IS_FOR_DELIVERY_IMMEDIATE] AS [isForDeliveryImmediate]
		FROM
			[wms].[OP_WMS_TASK_LIST] [TL]
		INNER JOIN @TASK [T] ON(
			[TL].[SERIAL_NUMBER] = [T].[SERIAL_NUMBER]
		)
	END;