-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	22-Jul-2019 G-FORCE@Dublin
-- Historia:    Product Backlog Item 30143: Visualización de proyecto en operación de HH 
-- Description:			obtiene las tareas asignadas al usuario

-- Autor:				kevin.guerra
-- Fecha de Creacion: 	10-Dic-2019 G-FORCE@Madagascar@SWIFT
-- Historia:    Product Backlog Item 34676: Recepcion/Despacho Físcal Panel de Tareas HH
-- Description:			Se modifica el SP para obtener tareas fiscales

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_TASKS_BY_USER] @LOGIN_ID='MARVIN'
					
   */
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TASKS_BY_USER]
(@LOGIN_ID VARCHAR(50))
AS
BEGIN
    SELECT [TaskList].[SERIAL_NUMBER] AS [id],
           [TaskList].[WAVE_PICKING_ID] AS [wavePickingId],
           [TaskList].[TRANS_OWNER] AS [transOwner],
		 --  CASE
   --            WHEN [TaskList].[TASK_SUBTYPE] = 'REUBICACION_BUFFER' THEN
   --                'TAREA_REABASTECIMIENTO' 
   --            ELSE
   --                [TaskList].[TASK_TYPE] 
			--END AS [taskType],
           [TaskList].[TASK_TYPE] AS [taskType],
           [TaskList].[TASK_SUBTYPE] AS [taskSubtype],
           [TaskList].[TASK_OWNER] AS [taskOwner],
           [TaskList].[TASK_ASSIGNEDTO] AS [taskAssignedTo],
           [TaskList].[TASK_COMMENTS] AS [taskComments],
           [TaskList].[ASSIGNED_DATE] AS [assignedDate],
           [TaskList].[QUANTITY_PENDING] AS [quantityPending],
           [TaskList].[QUANTITY_ASSIGNED] AS [quantityAssigned],
           [TaskList].[CODIGO_POLIZA_SOURCE] AS [sourcePolicyCode],
           [TaskList].[CODIGO_POLIZA_TARGET] AS [targetPolicyCode],
           [TaskList].[LICENSE_ID_SOURCE] AS [licenseIdSource],
           [TaskList].[REGIMEN] AS [regime],
           [TaskList].[IS_COMPLETED] AS [isCompleted],
           [TaskList].[IS_DISCRETIONAL] AS [isDiscretional],
           [TaskList].[IS_PAUSED] AS [isPaused],
           [TaskList].[IS_CANCELED] AS [isCanceled],
           [TaskList].[MATERIAL_ID] AS [materialId],
           [TaskList].[BARCODE_ID] AS [barcodeId],
           [TaskList].[ALTERNATE_BARCODE] AS [alternateBarcode],
           [TaskList].[MATERIAL_NAME] AS [materialName],
           [TaskList].[WAREHOUSE_SOURCE] AS [warehouseSource],
           [TaskList].[WAREHOUSE_TARGET] AS [warehouseTarget],
           [TaskList].[LOCATION_SPOT_SOURCE] AS [locationSpotSource],
           [TaskList].[LOCATION_SPOT_TARGET] AS [locationSpotTarget],
           [TaskList].[CLIENT_OWNER] AS [clientOwner],
           [TaskList].[CLIENT_NAME] AS [clientName],
           [TaskList].[ACCEPTED_DATE] AS [acceptedDate],
           [TaskList].[COMPLETED_DATE] AS [completedDate],
           [TaskList].[CANCELED_DATETIME] AS [canceledDatetime],
           [TaskList].[CANCELED_BY] AS [canceledBy],
           [TaskList].[MATERIAL_SHORT_NAME] AS [materialShortName],
           [TaskList].[IS_lOCKED] AS [isLocked],
           [TaskList].[IS_DISCRETIONARY] AS [isDiscretionary],
           [TaskList].[TYPE_DISCRETIONARY] AS [typeDiscretionary],
           [TaskList].[LINE_NUMBER_POLIZA_SOURCE] AS [lineNumberSourcePolicy],
           [TaskList].[LINE_NUMBER_POLIZA_TARGET] AS [lineNumberTargetPolicy],
           [TaskList].[DOC_ID_SOURCE] AS [docIdSource],
           [TaskList].[DOC_ID_TARGET] AS [docIdTarget],
           [TaskList].[IS_ACCEPTED] AS [isAccepted],
           [TaskList].[IS_FROM_SONDA] AS [isFromSonda],
           [TaskList].[IS_FROM_ERP] AS [isFromErp],
           [TaskList].[PRIORITY] AS [priority],
           [TaskList].[REPLENISH_MATERIAL_ID_TARGET] AS [replenishMaterialIdTarget],
           [TaskList].[FROM_MASTERPACK] AS [fromMasterpack],
           [TaskList].[MASTER_PACK_CODE] AS [masterPackCode],
           [TaskList].[OWNER] AS [owner],
           [TaskList].[SOURCE_TYPE] AS [sourceType],
           [TaskList].[TRANSFER_REQUEST_ID] AS [transferRequestId],
           [TaskList].[TONE] AS [tone],
           [TaskList].[CALIBER] AS [caliber],
           [TaskList].[LICENSE_ID_TARGET] AS [licenseIdTarget],
           [TaskList].[IN_PICKING_LINE] AS [inPickingLine],
           [TaskList].[IS_FOR_DELIVERY_IMMEDIATE] AS [isForDeliveryImmediate],
           [TaskList].[PROJECT_ID] AS [projectId],
           [TaskList].[PROJECT_CODE] AS [projectCode],
           [TaskList].[PROJECT_NAME] AS [projectName],
           [TaskList].[PROJECT_SHORT_NAME] AS [projectShortName],
           [TaskList].[PRIORITY],
           [TaskList].[MATERIAL_ID],
           [TaskList].[LICENSE_ID_SOURCE],
           [Material].[MATERIAL_ID] AS [MmaterialId],
           [Material].[CLIENT_OWNER] AS [MclientOwner],
           [Material].[BARCODE_ID] AS [MbarcodeId],
           [Material].[ALTERNATE_BARCODE] AS [MalternateBarcode],
           [Material].[MATERIAL_NAME] AS [MmaterialName],
           [Material].[SHORT_NAME] AS [MshortName],
           [Material].[VOLUME_FACTOR] AS [MvolumeFactor],
           [Material].[MATERIAL_CLASS] AS [MmaterialClass],
           [Material].[HIGH] AS [Mhigh],
           [Material].[LENGTH] AS [Mlength],
           [Material].[WIDTH] AS [Mwidth],
           [Material].[MAX_X_BIN] AS [MmaxXBin],
           [Material].[SCAN_BY_ONE] AS [MscanByOne],
           [Material].[REQUIRES_LOGISTICS_INFO] AS [MrequiresLogisticsInfo],
           [Material].[WEIGTH] AS [Mweight],
           [Material].[IMAGE_1] AS [Mimage1],
           [Material].[IMAGE_2] AS [Mimage2],
           [Material].[IMAGE_3] AS [Mimage3],
           [Material].[LAST_UPDATED] AS [MlastUpdated],
           [Material].[LAST_UPDATED_BY] AS [MlastUpdatedBy],
           [Material].[IS_CAR] AS [MisCar],
           [Material].[MT3] AS [Mmt3],
           [Material].[BATCH_REQUESTED] AS [MbatchRequested],
           [Material].[SERIAL_NUMBER_REQUESTS] AS [MserialNumberRequests],
           [Material].[IS_MASTER_PACK] AS [MisMasterPack],
           [Material].[ERP_AVERAGE_PRICE] AS [MerpAveragePrice],
           [Material].[WEIGHT_MEASUREMENT] AS [MweightMeasurement],
           [Material].[EXPLODE_IN_RECEPTION] AS [MexplodeInReception],
           [Material].[HANDLE_TONE] AS [MhandleTone],
           [Material].[HANDLE_CALIBER] AS [MhandleCaliber],
           [Material].[USE_PICKING_LINE] AS [MusePickingLine],
           [Material].[ITEM_CODE_ERP] AS [MitemCodeErp],
           [Material].[MATERIAL_CLASS] AS [MmaterialClass],
           [Material].[CLIENT_OWNER] AS [MclientOwner],
           [Configuration].[PARAM_TYPE] AS [CparamType],
           [Configuration].[PARAM_GROUP] AS [CparamGroup],
           [Configuration].[PARAM_GROUP_CAPTION] AS [CparamGroupCaption],
           [Configuration].[PARAM_NAME] AS [CparamName],
           [Configuration].[PARAM_CAPTION] AS [CparamCaption],
           [Configuration].[NUMERIC_VALUE] AS [CnumericValue],
           [Configuration].[MONEY_VALUE] AS [CmoneyValue],
           [Configuration].[TEXT_VALUE] AS [CtextValue],
           [Configuration].[DATE_VALUE] AS [CdateValue],
           [Configuration].[RANGE_NUM_START] AS [CrangeNumStart],
           [Configuration].[RANGE_NUM_END] AS [CrangeNumEnd],
           [Configuration].[RANGE_DATE_START] AS [CrangeDateStart],
           [Configuration].[RANGE_DATE_END] AS [CrangeDateEnd],
           [Configuration].[SPARE1] AS [Cspare1],
           [Configuration].[SPARE2] AS [Cspare2],
           [Configuration].[DECIMAL_VALUE] AS [CdecimalValue],
           [Configuration].[SPARE3] AS [Cspare3],
           [Configuration].[SPARE4] AS [Cspare4],
           [Configuration].[SPARE5] AS [Cspare5],
           [Configuration].[COLOR] AS [Ccolor],
           [License].[LICENSE_ID] AS [LlicenseId],
           [License].[CLIENT_OWNER] AS [LclientOwner],
           [License].[CODIGO_POLIZA] AS [LpolicyCode],
           [License].[CURRENT_WAREHOUSE] AS [LcurrentWarehouse],
           [License].[CURRENT_LOCATION] AS [LcurrentLocation],
           [License].[LAST_LOCATION] AS [LlastLocation],
           [License].[LAST_UPDATED] AS [LlastUpdated],
           [License].[LAST_UPDATED_BY] AS [LlastUpdatedBy],
           [License].[STATUS] AS [Lstatus],
           [License].[REGIMEN] AS [Lregime],
           [License].[CREATED_DATE] AS [LcreatedDate],
           [License].[USED_MT2] AS [LusedMt2],
           [License].[CODIGO_POLIZA_RECTIFICACION] AS [LpolicyCodeRectification],
           [License].[PICKING_DEMAND_HEADER_ID] AS [LpickingDemandHeaderId],
           [License].[WAVE_PICKING_ID] AS [LwavePickingId],
           CASE
               WHEN [TaskList].[TASK_TYPE] = 'TAREA_RECEPCION' THEN
                   [PHR].[NUMERO_ORDEN]
               WHEN [TaskList].[TASK_TYPE] = 'TAREA_PICKING' THEN
                   [PH].[NUMERO_ORDEN]
               ELSE
                   ''
           END AS [reference]
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
    WHERE NOT ([TaskList].[TASK_TYPE] = N'IMPLOSION_INVENTARIO')
          AND [TaskList].[TASK_ASSIGNEDTO] = @LOGIN_ID
          AND [TaskList].[IS_COMPLETED] = 0
          AND [TaskList].[IS_PAUSED] = 0
          AND [TaskList].[IS_CANCELED] = 0;
END;

