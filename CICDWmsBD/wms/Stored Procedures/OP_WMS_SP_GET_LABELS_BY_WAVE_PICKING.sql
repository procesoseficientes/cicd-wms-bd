-- =============================================
-- Autor:            hector.gonzalez
-- Fecha de Creacion:     2018-01-05 @ Team REBORN - Sprint 
-- Description:            
/*
-- Ejemplo de Ejecucion:
            EXEC [wms].OP_WMS_SP_GET_LABELS_BY_WAVE_PICKING 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LABELS_BY_WAVE_PICKING] (@WAVE_PICKING_ID INT)
AS
    BEGIN
        SET NOCOUNT ON;
        DECLARE @IS_COMPLETED INT = 1;
        
        SELECT TOP 1
                @IS_COMPLETED = 0
        FROM    [wms].[OP_WMS_VIEW_TASK] [VT]
        WHERE   [VT].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
                AND ([VT].[IS_COMPLETED] = 'INCOMPLETA'
                     OR [VT].[IS_COMPLETED] = 'ACEPTADA'
                    );

		
  --
        SELECT TOP 1
                [DH].[PICKING_DEMAND_HEADER_ID]
               ,[DH].[DOC_NUM]
               ,[DH].[CLIENT_CODE]
               ,[DH].[CODE_ROUTE]
               ,[DH].[CODE_SELLER]
               ,[DH].[TOTAL_AMOUNT]
               ,[DH].[SERIAL_NUMBER]
               ,[DH].[DOC_NUM_SEQUENCE]
               ,[DH].[EXTERNAL_SOURCE_ID]
               ,[DH].[IS_FROM_ERP]
               ,[DH].[IS_FROM_SONDA]
               ,[DH].[LAST_UPDATE]
               ,[DH].[LAST_UPDATE_BY]
               ,[DH].[IS_COMPLETED]
               ,[DH].[WAVE_PICKING_ID]
               ,[DH].[CODE_WAREHOUSE]
               ,[DH].[IS_AUTHORIZED]
               ,[DH].[ATTEMPTED_WITH_ERROR]
               ,[DH].[IS_POSTED_ERP]
               ,[DH].[POSTED_ERP]
               ,[DH].[POSTED_RESPONSE]
               ,[DH].[ERP_REFERENCE]
               ,[DH].[CLIENT_NAME]
               ,[DH].[CREATED_DATE]
               ,[DH].[ERP_REFERENCE_DOC_NUM]
               ,[DH].[DOC_ENTRY]
               ,[DH].[IS_CONSOLIDATED]
               ,[DH].[PRIORITY]
               ,[DH].[HAS_MASTERPACK]
               ,[DH].[POSTED_STATUS]
               ,[DH].[OWNER]
               ,[DH].[CLIENT_OWNER]
               ,[DH].[MASTER_ID_SELLER]
               ,[DH].[SELLER_OWNER]
               ,[DH].[SOURCE_TYPE]
               ,[DH].[INNER_SALE_STATUS]
               ,[DH].[INNER_SALE_RESPONSE]
               ,[DH].[DEMAND_TYPE]
               ,[DH].[TRANSFER_REQUEST_ID]
               ,[DH].[ADDRESS_CUSTOMER]
               ,[DH].[STATE_CODE]
               ,[DH].[DISCOUNT]
               ,[DH].[UPDATED_VEHICLE]
               ,[DH].[UPDATED_VEHICLE_RESPONSE]
               ,[DH].[UPDATED_VEHICLE_ATTEMPTED_WITH_ERROR]
               ,[DH].[DELIVERY_NOTE_INVOICE]
               ,[DH].[DEMAND_SEQUENCE]
               ,[DH].[IS_CANCELED_FROM_SONDA_SD]
               ,[DH].[TYPE_DEMAND_CODE]
               ,[DH].[TYPE_DEMAND_NAME]
               ,[DH].[IS_FOR_DELIVERY_IMMEDIATE]
               ,[DDH].[DELIVERED_DISPATCH_HEADER_ID]
               ,[DDH].[STATUS] AS [DELIVERED_STATUS]
        FROM    [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH]
                LEFT JOIN [wms].[OP_WMS_DELIVERED_DISPATCH_HEADER] [DDH] ON ([DDH].[PICKING_DEMAND_HEADER_ID] = [DH].[PICKING_DEMAND_HEADER_ID])
        WHERE   [DH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
                AND [DH].[IS_FOR_DELIVERY_IMMEDIATE] = 0
                AND @IS_COMPLETED = 1;
    END;