-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	22-Jul-2019 G-FORCE@Dublin
-- Historia:    Product Backlog Item 30143: Visualización de proyecto en operación de HH 
-- Description:			obtiene el detalle de tareas para una ola de picking

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	09-Diciembre-2019 G-Force@Kioto
-- Description:			Se elimina fitro de regimen

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_TASKS_BY_WAVE_PICKING_ID] @LOGIN_ID='MARVIN',@WAVE_PICKING_ID = 10306
					
   */
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TASKS_BY_WAVE_PICKING_ID]
(
    @LOGIN_ID VARCHAR(50),
    @WAVE_PICKING_ID NUMERIC(18)
)
AS
BEGIN
    SELECT MAX([TaskList].[SERIAL_NUMBER]) AS [id],
           MAX([TaskList].[WAVE_PICKING_ID]) AS [wavePickingId],
           MAX([TaskList].[TRANS_OWNER]) AS [transOwner],
           MAX([TaskList].[TASK_TYPE]) AS [taskType],
           MAX([TaskList].[TASK_SUBTYPE]) AS [taskSubtype],
           MAX([TaskList].[TASK_OWNER]) AS [taskOwner],
           MAX([TaskList].[TASK_ASSIGNEDTO]) AS [taskAssignedTo],
           MAX([TaskList].[TASK_COMMENTS]) AS [taskComments],
           MAX([TaskList].[ASSIGNED_DATE]) AS [assignedDate],
           SUM([TaskList].[QUANTITY_PENDING]) AS [quantityPending],
           SUM([TaskList].[QUANTITY_ASSIGNED]) AS [quantityAssigned],
           MAX([TaskList].[CODIGO_POLIZA_SOURCE]) AS [sourcePolicyCode],
           MAX([TaskList].[CODIGO_POLIZA_TARGET]) AS [targetPolicyCode],
           [TaskList].[LICENSE_ID_SOURCE] AS [licenseIdSource],
           MAX([TaskList].[REGIMEN]) AS [regime],
		   --IIF(ISNULL((SELECT TOP 1 1 FROM [wms].[OP_WMS_TASK_LIST] WHERE LICENSE_ID_SOURCE = [TaskList].[LICENSE_ID_SOURCE] AND MATERIAL_ID = MAX([TaskList].[MATERIAL_ID]) AND IS_COMPLETED = 0), 0) = 1, 0, MAX([TaskList].[IS_COMPLETED])) AS [isCompleted],
           min([TaskList].[IS_COMPLETED]) AS [isCompleted],
           MAX([TaskList].[IS_DISCRETIONAL]) AS [isDiscretional],
           MAX([TaskList].[IS_PAUSED]) AS [isPaused],
           MAX([TaskList].[IS_CANCELED]) AS [isCanceled],
           MAX([TaskList].[MATERIAL_ID]) AS [materialId],
           MAX([TaskList].[BARCODE_ID]) AS [barcodeId],
           MAX([TaskList].[ALTERNATE_BARCODE]) AS [alternateBarcode],
           MAX([TaskList].[MATERIAL_NAME]) AS [materialName],
           MAX([TaskList].[WAREHOUSE_SOURCE]) AS [warehouseSource],
           MAX([TaskList].[WAREHOUSE_TARGET]) AS [warehouseTarget],
           MAX([TaskList].[LOCATION_SPOT_SOURCE]) AS [locationSpotSource],
           MAX([TaskList].[LOCATION_SPOT_TARGET]) AS [locationSpotTarget],
           MAX([TaskList].[CLIENT_OWNER]) AS [clientOwner],
           MAX([TaskList].[CLIENT_NAME]) AS [clientName],
           MAX([TaskList].[ACCEPTED_DATE]) AS [acceptedDate],
           MAX([TaskList].[COMPLETED_DATE]) AS [completedDate],
           MAX([TaskList].[CANCELED_DATETIME]) AS [canceledDatetime],
           MAX([TaskList].[CANCELED_BY]) AS [canceledBy],
           MAX([TaskList].[MATERIAL_SHORT_NAME]) AS [materialShortName],
           MAX([TaskList].[IS_lOCKED]) AS [isLocked],
           MAX([TaskList].[IS_DISCRETIONARY]) AS [isDiscretionary],
           MAX([TaskList].[TYPE_DISCRETIONARY]) AS [typeDiscretionary],
           MAX([TaskList].[LINE_NUMBER_POLIZA_SOURCE]) AS [lineNumberSourcePolicy],
           MAX([TaskList].[LINE_NUMBER_POLIZA_TARGET]) AS [lineNumberTargetPolicy],
           MAX([TaskList].[DOC_ID_SOURCE]) AS [docIdSource],
           MAX([TaskList].[DOC_ID_TARGET]) AS [docIdTarget],
           MAX([TaskList].[IS_ACCEPTED]) AS [isAccepted],
           MAX([TaskList].[IS_FROM_SONDA]) AS [isFromSonda],
           MAX([TaskList].[IS_FROM_ERP]) AS [isFromErp],
           MAX([TaskList].[PRIORITY]) AS [priority],
           MAX([TaskList].[REPLENISH_MATERIAL_ID_TARGET]) AS [replenishMaterialIdTarget],
           MAX([TaskList].[FROM_MASTERPACK]) AS [fromMasterpack],
           MAX([TaskList].[MASTER_PACK_CODE]) AS [masterPackCode],
           MAX([TaskList].[OWNER]) AS [owner],
           MAX([TaskList].[SOURCE_TYPE]) AS [sourceType],
           MAX([TaskList].[TRANSFER_REQUEST_ID]) AS [transferRequestId],
           MAX([TaskList].[TONE]) AS [tone],
           MAX([TaskList].[CALIBER]) AS [caliber],
           MAX([TaskList].[LICENSE_ID_TARGET]) AS [licenseIdTarget],
           MAX([TaskList].[IN_PICKING_LINE]) AS [inPickingLine],
           MAX([TaskList].[IS_FOR_DELIVERY_IMMEDIATE]) AS [isForDeliveryImmediate],
           MAX([TaskList].[PROJECT_ID]) AS [projectId],
           MAX([TaskList].[PROJECT_CODE]) AS [projectCode],
           MAX([TaskList].[PROJECT_NAME]) AS [projectName],
           MAX([TaskList].[PROJECT_SHORT_NAME]) AS [projectShortName],
           MAX([TaskList].[PRIORITY]),
           [TaskList].[MATERIAL_ID],
           [TaskList].[LICENSE_ID_SOURCE],
           MAX([TaskList].[STATUS_CODE]) [STATUS_CODE],
           MAX([Material].[MATERIAL_ID]) AS [MmaterialId],
           MAX([Material].[CLIENT_OWNER]) AS [MclientOwner],
           MAX([Material].[BARCODE_ID]) AS [MbarcodeId],
           MAX([Material].[ALTERNATE_BARCODE]) AS [MalternateBarcode],
           MAX([Material].[MATERIAL_NAME]) AS [MmaterialName],
           MAX([Material].[SHORT_NAME]) AS [MshortName],
           MAX([Material].[VOLUME_FACTOR]) AS [MvolumeFactor],
           MAX([Material].[MATERIAL_CLASS]) AS [MmaterialClass],
           MAX([Material].[HIGH]) AS [Mhigh],
           MAX([Material].[LENGTH]) AS [Mlength],
           MAX([Material].[WIDTH]) AS [Mwidth],
           MAX([Material].[MAX_X_BIN]) AS [MmaxXBin],
           MAX([Material].[SCAN_BY_ONE]) AS [MscanByOne],
           MAX([Material].[REQUIRES_LOGISTICS_INFO]) AS [MrequiresLogisticsInfo],
           MAX([Material].[WEIGTH]) AS [Mweight],
           NULL AS [Mimage1],
           NULL AS [Mimage2],
           NULL AS [Mimage3],
           MAX([Material].[LAST_UPDATED]) AS [MlastUpdated],
           MAX([Material].[LAST_UPDATED_BY]) AS [MlastUpdatedBy],
           MAX([Material].[IS_CAR]) AS [MisCar],
           MAX([Material].[MT3]) AS [Mmt3],
           MAX([Material].[BATCH_REQUESTED]) AS [MbatchRequested],
           MAX([Material].[SERIAL_NUMBER_REQUESTS]) AS [MserialNumberRequests],
           MAX([Material].[IS_MASTER_PACK]) AS [MisMasterPack],
           MAX([Material].[ERP_AVERAGE_PRICE]) AS [MerpAveragePrice],
           MAX([Material].[WEIGHT_MEASUREMENT]) AS [MweightMeasurement],
           MAX([Material].[EXPLODE_IN_RECEPTION]) AS [MexplodeInReception],
           MAX([Material].[HANDLE_TONE]) AS [MhandleTone],
           MAX([Material].[HANDLE_CALIBER]) AS [MhandleCaliber],
           MAX([Material].[USE_PICKING_LINE]) AS [MusePickingLine],
           MAX([Material].[ITEM_CODE_ERP]) AS [MitemCodeErp],
           MAX([Material].[MATERIAL_CLASS]) AS [MmaterialClass],
           MAX([Material].[CLIENT_OWNER]) AS [MclientOwner],
           MAX([Configuration].[PARAM_TYPE]) AS [CparamType],
           MAX([Configuration].[PARAM_GROUP]) AS [CparamGroup],
           MAX([Configuration].[PARAM_GROUP_CAPTION]) AS [CparamGroupCaption],
           MAX([Configuration].[PARAM_NAME]) AS [CparamName],
           MAX([Configuration].[PARAM_CAPTION]) AS [CparamCaption],
           MAX([Configuration].[NUMERIC_VALUE]) AS [CnumericValue],
           MAX([Configuration].[MONEY_VALUE]) AS [CmoneyValue],
           MAX([Configuration].[TEXT_VALUE]) AS [CtextValue],
           MAX([Configuration].[DATE_VALUE]) AS [CdateValue],
           MAX([Configuration].[RANGE_NUM_START]) AS [CrangeNumStart],
           MAX([Configuration].[RANGE_NUM_END]) AS [CrangeNumEnd],
           MAX([Configuration].[RANGE_DATE_START]) AS [CrangeDateStart],
           MAX([Configuration].[RANGE_DATE_END]) AS [CrangeDateEnd],
           MAX([Configuration].[SPARE1]) AS [Cspare1],
           MAX([Configuration].[SPARE2]) AS [Cspare2],
           MAX([Configuration].[DECIMAL_VALUE]) AS [CdecimalValue],
           MAX([Configuration].[SPARE3]) AS [Cspare3],
           MAX([Configuration].[SPARE4]) AS [Cspare4],
           MAX([Configuration].[SPARE5]) AS [Cspare5],
           MAX([Configuration].[COLOR]) AS [Ccolor],
           [License].[LICENSE_ID] AS [LlicenseId],
           MAX([License].[CLIENT_OWNER]) AS [LclientOwner],
           MAX([License].[CODIGO_POLIZA]) AS [LpolicyCode],
           MAX([License].[CURRENT_WAREHOUSE]) AS [LcurrentWarehouse],
           MAX([License].[CURRENT_LOCATION]) AS [LcurrentLocation],
           MAX([License].[LAST_LOCATION]) AS [LlastLocation],
           MAX([License].[LAST_UPDATED]) AS [LlastUpdated],
           MAX([License].[LAST_UPDATED_BY]) AS [LlastUpdatedBy],
           MAX([License].[STATUS]) AS [Lstatus],
           MAX([License].[REGIMEN]) AS [Lregime],
           MAX([License].[CREATED_DATE]) AS [LcreatedDate],
           MAX([License].[USED_MT2]) AS [LusedMt2],
           MAX([License].[CODIGO_POLIZA_RECTIFICACION]) AS [LpolicyCodeRectification],
           MAX([License].[PICKING_DEMAND_HEADER_ID]) AS [LpickingDemandHeaderId],
           MAX([License].[WAVE_PICKING_ID]) AS [LwavePickingId],
           CASE
               WHEN MAX([TaskList].[TASK_TYPE]) = 'TAREA_RECEPCION' THEN
                   MAX([PHR].[NUMERO_ORDEN])
               WHEN MAX([TaskList].[TASK_TYPE]) = 'TAREA_PICKING' THEN
                   MAX([PH].[NUMERO_ORDEN])
               ELSE
                   ''
           END [reference]
    FROM [wms].[OP_WMS_TASK_LIST] AS [TaskList]
        LEFT OUTER JOIN [wms].[OP_WMS_MATERIALS] AS [Material]
            ON [TaskList].[MATERIAL_ID] = [Material].[MATERIAL_ID]
        INNER JOIN [wms].[OP_WMS_CONFIGURATIONS] AS [Configuration]
            ON [TaskList].[PRIORITY] = [Configuration].[NUMERIC_VALUE]
               AND [Configuration].[PARAM_TYPE] = N'SISTEMA'
               AND [Configuration].[PARAM_GROUP] = N'PRIORITY'
        LEFT OUTER JOIN [wms].[OP_WMS_LICENSES] AS [License]
            ON [TaskList].[LICENSE_ID_SOURCE] = [License].[LICENSE_ID]
        LEFT OUTER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH]
            ON [TaskList].[CODIGO_POLIZA_TARGET] = [PH].[CODIGO_POLIZA]
        LEFT OUTER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PHR]
            ON [TaskList].[CODIGO_POLIZA_SOURCE] = [PHR].[CODIGO_POLIZA]
    WHERE [TaskList].[TASK_ASSIGNEDTO] = @LOGIN_ID
          AND [TaskList].[IS_PAUSED] = 0
          AND [TaskList].[IS_CANCELED] = 0
          AND [TaskList].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
	GROUP BY [TaskList].[LICENSE_ID_SOURCE], [License].LICENSE_ID, [License].[CURRENT_LOCATION],[TaskList].[MATERIAL_ID]
    ORDER BY [License].[CURRENT_LOCATION] ASC;
END;
