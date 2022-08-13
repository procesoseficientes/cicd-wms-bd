
 

-- =============================================
-- Autor:                Gildardo.Alvarado @ProcesosEficientes        
-- Fecha de Creacion:     19/02/2021
-- Description:            Trae el inventario en linea segun los permisos del usuario

 

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].[OP_WMS_FUN_INVENTORY_ONLINE_BY_USER]('ADMIN')
*/
-- =============================================

 

CREATE FUNCTION [wms].[OP_WMS_FUN_INVENTORY_ONLINE_BY_USER] (
    @pLOGIN_ID VARCHAR(50)
)
RETURNS TABLE 
AS
RETURN (
    SELECT [ID].[PK_LINE],
           [ID].[BATCH_REQUESTED],
           [ID].[STATUS_ID],
           [ID].[HANDLE_TONE],
           [ID].[HANDLE_CALIBER],
           [ID].[TONE_AND_CALIBER_ID],
           [ID].[CLIENT_NAME],
           [ID].[NUMERO_ORDEN],
           [ID].[NUMERO_DUA],
           [ID].[FECHA_LLEGADA],
           [ID].[LICENSE_ID],
           [ID].[TERMS_OF_TRADE],
           [ID].[MATERIAL_ID],
           [ID].[MATERIAL_CLASS],
           [ID].[BARCODE_ID],
           [ID].[VOLUME_FACTOR],
           [ID].[ALTERNATE_BARCODE],
           [ID].[MATERIAL_NAME],
           [ID].[QTY],
           ISNULL([CI].[COMMITED_QTY], 0) AS COMMITED_QTY,
           [ID].[CLIENT_OWNER],
           [ID].[REGIMEN],
           [ID].[CODIGO_POLIZA],
           [ID].[CURRENT_LOCATION],
           [ID].[VOLUMEN],
           [ID].[TOTAL_VOLUMEN],
           COALESCE([ID].[LAST_UPDATED_BY], [TH].[LAST_UPDATED_BY]) [LAST_UPDATED_BY],
           [ID].[SERIAL_NUMBER],
           [ID].[SKU_SERIE],
           [ID].[DATE_EXPIRATION],
           [ID].[BATCH],
           [ID].[CURRENT_WAREHOUSE],
           [ID].[DOC_ID],
           [ID].[USED_MT2],
           [ID].[VIN],
           [ID].[PENDIENTE_RECTIFICACION],
           [TH].[ACUERDO_COMERCIAL_ID],
           [TH].[ACUERDO_COMERCIAL_NOMBRE],
           [TH].[VALID_FROM],
           [TH].[VALID_TO],
           [TH].[EXPIRES],
           [TH].[CURRENCY],
           [TH].[STATUS],
           [TH].[WAREHOUSE_WEATHER],
           [TH].[LAST_UPDATED],
           [TH].[LAST_UPDATED_AUTH_BY],
           [TH].[COMMENTS],
           [TH].[AUTHORIZER],
           [PH].[REGIMEN] [REGIMEN_DOCUMENTO],
           [C].[SPARE1] AS [GRUPO_REGIMEN],
           [ID].[CODE_SUPPLIER],
           [ID].[NAME_SUPPLIER],
           [ID].[ZONE],
           CASE
               WHEN ISNULL([ID].[LOCKED_BY_INTERFACES], 0) = 1 THEN
                   0
               ELSE
           ([ID].[QTY] - ISNULL([CI].[COMMITED_QTY], 0))
           END AS [AVAILABLE_QTY],
           [V].[VALOR_UNITARIO],
           [V].[TOTAL_VALOR],
           CASE [ID].[HANDLE_SERIAL]
               WHEN 1 THEN
                   'Si'
               WHEN 0 THEN
                   'No'
               ELSE
                   'No'
           END [HANDLE_SERIAL],
           CASE [ID].[IS_EXTERNAL_INVENTORY]
               WHEN 1 THEN
                   'SI'
               ELSE
                   'NO'
           END AS [IS_EXTERNAL_INVENTORY],
           [PH].[FECHA_DOCUMENTO],
           CASE [PH].[WAREHOUSE_REGIMEN]
               WHEN 'FISCAL' THEN
                   [wms].[OP_WMS_FN_GET_DAYS_BY_REGIMEN]([PH].[REGIMEN])
               ELSE
                   NULL
           END [DIAS_REGIMEN],
           CASE [PH].[WAREHOUSE_REGIMEN]
               WHEN 'FISCAL' THEN
                   DATEDIFF(DAY, GETDATE(), [wms].[OP_WMS_FN_GET_EXPIRATION_DATE_FOR_POLIZA]([PH].[CODIGO_POLIZA]))
               ELSE
                   NULL
           END [DIAS_PARA_VENCER],
           CASE [PH].[WAREHOUSE_REGIMEN]
               WHEN 'FISCAL' THEN
                   [wms].[OP_WMS_FN_GET_EXPIRATION_DATE_FOR_POLIZA]([PH].[CODIGO_POLIZA])
               ELSE
                   NULL
           END [FECHA_VENCIMIENTO],
           CASE
               WHEN [PH].[WAREHOUSE_REGIMEN] = 'FISCAL'
                    AND DATEDIFF(
                                    DAY,
                                    GETDATE(),
                                    [wms].[OP_WMS_FN_GET_EXPIRATION_DATE_FOR_POLIZA]([PH].[CODIGO_POLIZA])
                                ) < 1 THEN
                   'Bloqueado'
               ELSE
                   'Libre'
           END [ESTADO_REGIMEN],
           [ID].[STATUS_NAME],
           [ID].[STATUS_CODE],
           [ID].[BLOCKS_INVENTORY],
           [ID].[COLOR],
           [ID].[TONE],
           [ID].[CALIBER],
           [DH].[DOC_NUM] AS [SALE_ORDER_ID],
           [DH].[PROJECT],
           [DH].[CLIENT_NAME] AS [CUSTOMER_NAME],
           CASE
               WHEN [ID].[LOCKED_BY_INTERFACES] = 1 THEN
                   'Si'
               WHEN [ID].[LOCKED_BY_INTERFACES] = 0 THEN
                   'No'
           END [LOCKED_BY_INTERFACES],
           [ID].[WEIGTH],
           [ID].[WEIGHT_MEASUREMENT],
           [L].[WAVE_PICKING_ID],
           [ID].[PROJECT_CODE],
           [ID].[PROJECT_SHORT_NAME],
           ISNULL(
           (
               SELECT TOP (1)
                      IXL.TOTAL_POSITION
               FROM [wms].OP_WMS_INV_X_LICENSE AS IXL
               WHERE IXL.LICENSE_ID = ID.LICENSE_ID
               ORDER BY IXL.LICENSE_ID
           ),
           1
                 ) [TOTAL_POSITION]
    FROM [wms].[OP_WMS_VIEW_INVENTORY_DETAIL_WHITH_SERIES] [ID]
        INNER JOIN [wms].[OP_WMS_TARIFICADOR_HEADER] [TH]
            ON ([ID].[TERMS_OF_TRADE] = CAST([TH].[ACUERDO_COMERCIAL_ID] AS VARCHAR(50)))
        LEFT JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH]
            ON ([PH].[CODIGO_POLIZA] = [ID].[CODIGO_POLIZA])
        LEFT JOIN [wms].[OP_WMS_CONFIGURATIONS] [C]
            ON (
                   [C].[PARAM_GROUP] = 'REGIMEN'
                   AND [C].[PARAM_NAME] = [PH].[REGIMEN]
               )
        INNER JOIN [wms].[OP_WMS_FUNC_GET_WAREHOUSE_BY_USER](@pLOGIN_ID) [W]
            ON [W].[WAREHOUSE_ID] = [ID].[CURRENT_WAREHOUSE] COLLATE DATABASE_DEFAULT
        LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CI]
            ON (
                   [ID].[MATERIAL_ID] = [CI].[MATERIAL_ID]
                   AND [ID].[CLIENT_OWNER] = [CI].[CLIENT_OWNER]
                   AND [CI].[LICENCE_ID] = [ID].[LICENSE_ID]
               )
        LEFT JOIN wms.OP_WMS_VIEW_VALORIZACION_BY_INVENTORY_ONLINE [V]
            ON (
                   [V].[LICENSE_ID] = [ID].[LICENSE_ID]
                   AND [ID].[MATERIAL_ID] = [V].[MATERIAL_ID]
               )
        LEFT JOIN [wms].[OP_WMS_LICENSES] AS [L]
            ON ([L].[LICENSE_ID] = [ID].[LICENSE_ID])
        LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] AS [DH]
            ON ([DH].[PICKING_DEMAND_HEADER_ID] = [L].[PICKING_DEMAND_HEADER_ID])
    WHERE [ID].[QTY] > 0
)