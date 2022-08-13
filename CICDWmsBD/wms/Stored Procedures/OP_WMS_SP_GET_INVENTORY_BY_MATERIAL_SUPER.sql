-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	20191114 GForce@Lima
-- Description:	        sp que devuelve el inventario por ubicacion e indica si el inventario esta disponible o reservado

-- Modificacion			6-Dic-19 @ G-Force Team Sprint Lima
-- autor:				jonathan.salvador
-- Historia/Bug:		34584: No se toma en cuenta inventario reservador por un proyecto
-- Descripcion:			Se agrega columna para QTY_RESERVED_BY_PROJECT para mostrar inventario reservado en un proyecto 
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_INVENTORY_BY_MATERIAL]
					@MATERIAL_ID = 'viscosa/VCA1030',@LOGIN_ID = 'MARVIN'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INVENTORY_BY_MATERIAL_SUPER]
(
    @MATERIAL_ID VARCHAR(50),
    @LOGIN_ID VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    --

    DECLARE @MATERIAL_ID_SEARCH VARCHAR(50);

    SELECT TOP 1
           @MATERIAL_ID_SEARCH = [MATERIAL_ID]
    FROM [wms].[OP_WMS_MATERIALS]
    WHERE [MATERIAL_ID] = @MATERIAL_ID
          OR [BARCODE_ID] = @MATERIAL_ID
          OR [ALTERNATE_BARCODE] = @MATERIAL_ID;
    PRINT @MATERIAL_ID_SEARCH;
    SELECT [WAREHOUSE_ID]
    INTO [#WAREHOUSES_BY_USER]
    FROM [wms].[OP_WMS_WAREHOUSE_BY_USER]
    WHERE [LOGIN_ID] = @LOGIN_ID;

    SELECT SUM([IL].[QTY]) [TOTAL_LOCATION],
           [L].[CURRENT_LOCATION]
    INTO [#TOTAL_LOCATION]
    FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
        INNER JOIN [wms].[OP_WMS_LICENSES] [L]
            ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
        INNER JOIN [#WAREHOUSES_BY_USER] [WU]
            ON [WU].[WAREHOUSE_ID] = [L].[CURRENT_WAREHOUSE]
        INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S]
            ON [L].[CURRENT_LOCATION] = [S].[LOCATION_SPOT]
        INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML]
            ON [SML].[STATUS_ID] = [IL].[STATUS_ID]
        INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
            ON [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
        LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TC]
            ON [TC].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID]
        LEFT JOIN [wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT] [IRP]
            ON (
                   [IL].[PK_LINE] = [IRP].[PK_LINE]
                   AND [IL].[PROJECT_ID] = [IRP].[PROJECT_ID]
               )
        LEFT JOIN [wms].[OP_WMS_PROJECT] [P]
            ON ([IRP].[PROJECT_ID] = [P].[ID])
    WHERE [IL].[MATERIAL_ID] = @MATERIAL_ID_SEARCH
          AND [IL].[QTY] > 0
    GROUP BY [IL].[MATERIAL_ID],
             [L].[CURRENT_LOCATION];


    SELECT SUM([IL].[QTY]) [TOTAL_LOCATION_LOCKED],
           [L].[CURRENT_LOCATION]
    INTO [#TOTAL_LOCATION_LOCKED]
    FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
        INNER JOIN [wms].[OP_WMS_LICENSES] [L]
            ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
        INNER JOIN [#WAREHOUSES_BY_USER] [WU]
            ON [WU].[WAREHOUSE_ID] = [L].[CURRENT_WAREHOUSE]
        INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S]
            ON [L].[CURRENT_LOCATION] = [S].[LOCATION_SPOT]
        INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML]
            ON [SML].[STATUS_ID] = [IL].[STATUS_ID]
        INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
            ON [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
        LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TC]
            ON [TC].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID]
        LEFT JOIN [wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT] [IRP]
            ON (
                   [IL].[PK_LINE] = [IRP].[PK_LINE]
                   AND [IL].[PROJECT_ID] = [IRP].[PROJECT_ID]
               )
        LEFT JOIN [wms].[OP_WMS_PROJECT] [P]
            ON ([IRP].[PROJECT_ID] = [P].[ID])
    WHERE [IL].[MATERIAL_ID] = @MATERIAL_ID_SEARCH
          AND [IL].[LOCKED_BY_INTERFACES] = 1
          AND [IL].[QTY] > 0
    GROUP BY [IL].[MATERIAL_ID],
             [L].[CURRENT_LOCATION];


    SELECT [S].[LOCATION_SPOT] [LOCATION],
           [IL].[MATERIAL_ID],
           [IL].[MATERIAL_NAME],
           [TL].[TOTAL_LOCATION],
           [L].[LICENSE_ID],
           SUM([IL].[QTY]) - ISNULL(SUM([CIL].[COMMITED_QTY]), 0)
           - ISNULL([IRP].[QTY_RESERVED], 0)  [QTY_AVAILABLE],
           ISNULL(MAX([CIL].[COMMITED_QTY]), 0) [QTY_RESERVED],
           ISNULL([IRP].[QTY_RESERVED], 0)  [QTY_RESERVED_BY_PROJECT],
           [IL].[BATCH],
           [IL].[DATE_EXPIRATION],
           [TC].[TONE],
           [TC].[CALIBER],
           [M].[SERIAL_NUMBER_REQUESTS],
           [M].[BATCH_REQUESTED],
           [M].[HANDLE_TONE],
           [M].[HANDLE_CALIBER],
           [SML].[STATUS_NAME],
           [IL].[LOCKED_BY_INTERFACES],
           CASE
               WHEN [TL].[TOTAL_LOCATION] = [TLO].[TOTAL_LOCATION_LOCKED] THEN
                   1
               ELSE
                   0
           END [LOCATION_LOCKED],
           [L].[REGIMEN],
           [L].[CODIGO_POLIZA],
           [L].[CLIENT_OWNER],
           [P].[OPPORTUNITY_CODE] [PROJECT_CODE],
           [P].[OPPORTUNITY_NAME] [PROJECT_NAME]
    FROM [wms].[OP_WMS_LICENSES] [L]
        INNER JOIN [#TOTAL_LOCATION] [TL]
            ON [TL].[CURRENT_LOCATION] = [L].[CURRENT_LOCATION]
        LEFT JOIN [#TOTAL_LOCATION_LOCKED] [TLO]
            ON [TLO].[CURRENT_LOCATION] = [L].[CURRENT_LOCATION]
        INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S]
            ON [L].[CURRENT_LOCATION] = [S].[LOCATION_SPOT]
        INNER JOIN [#WAREHOUSES_BY_USER] [WU]
            ON [WU].[WAREHOUSE_ID] = [L].[CURRENT_WAREHOUSE]
        INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
            ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
        INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML]
            ON [SML].[STATUS_ID] = [IL].[STATUS_ID]
        INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
            ON [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
        LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TC]
            ON [TC].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID]
        LEFT JOIN [wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT] [IRP]
            ON (
                   [IL].[PK_LINE] = [IRP].[PK_LINE]
                   AND [IL].[PROJECT_ID] = [IRP].[PROJECT_ID]
               )
        LEFT JOIN [wms].[OP_WMS_PROJECT] [P]
            ON ([IRP].[PROJECT_ID] = [P].[ID])
        LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CIL]
            ON (
                   [IL].[LICENSE_ID] = [CIL].[LICENCE_ID]
                   AND [IL].[MATERIAL_ID] = [CIL].[MATERIAL_ID]
                   AND [L].[CLIENT_OWNER] = [CIL].[CLIENT_OWNER]
               )
    WHERE [IL].[MATERIAL_ID] = @MATERIAL_ID_SEARCH

    GROUP BY [S].[LOCATION_SPOT],
             [IL].[MATERIAL_ID],
             [IL].[MATERIAL_NAME],
             [TL].[TOTAL_LOCATION],
             [TLO].[TOTAL_LOCATION_LOCKED],
             [L].[LICENSE_ID],
             [IL].[BATCH],
             [IL].[DATE_EXPIRATION],
             [TC].[TONE],
             [TC].[CALIBER],
             [M].[SERIAL_NUMBER_REQUESTS],
             [M].[BATCH_REQUESTED],
             [M].[HANDLE_TONE],
             [M].[HANDLE_CALIBER],
             [SML].[STATUS_NAME],
             [L].[CODIGO_POLIZA],
             [L].[CLIENT_OWNER],
             [IL].[LOCKED_BY_INTERFACES],
             [L].[REGIMEN],
             [L].[CODIGO_POLIZA],
             [L].[CLIENT_OWNER],
             [IRP].[QTY_RESERVED],
             [IRP].[QTY_DISPATCHED],
             [P].[OPPORTUNITY_CODE],
             [P].[OPPORTUNITY_NAME];


END;