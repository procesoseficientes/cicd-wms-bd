-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	20191114 GForce@Lima
-- Description:	        sp que devuelve el inventario por ubicacion e indica si el inventario esta disponible o reservado

-- Modificacion         6-Dic-2019 @ G-Force Team Sprint Lima
-- autor:				jonathan.salvador
-- Historia/Bug:		34654: Error en la suma total de productos en una licencia 
-- Descripcion:			Se agregan tablas temporales para obtener la cantidad de productos en una licencia
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_INVENTORY_BY_LOCATION_SUPER]
					@MATERIAL_ID = 'viscosa/VCA1030',@LOGIN_ID = 'MARVIN'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INVENTORY_BY_LOCATION_SUPER]
(
    @LOCATION_SPOT VARCHAR(25),
    @LOGIN_ID VARCHAR(100)
)
AS
BEGIN
    SET NOCOUNT ON;
    --

    SELECT [WAREHOUSE_ID]
    INTO [#WAREHOUSES_BY_USER]
    FROM [wms].[OP_WMS_WAREHOUSE_BY_USER]
    WHERE [LOGIN_ID] = @LOGIN_ID;

    SELECT [L].[LICENSE_ID],
           SUM([IL].[QTY]) [TOTAL_LICENSE]
    INTO [#TOTAL_IN_LICENSE]
    FROM wms.[OP_WMS_LICENSES] [L]
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
               )
    WHERE [L].[CURRENT_LOCATION] = @LOCATION_SPOT
          AND [IL].[QTY] > 0
    GROUP BY [L].[LICENSE_ID];


    SELECT [L].[LICENSE_ID],
           SUM([IL].[QTY]) [LOCKED_IN_LICENSE]
    INTO [#TOTAL_LOCKED_IN_LICENSE]
    FROM [wms].[OP_WMS_LICENSES] [L]
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
               )
    WHERE [S].[LOCATION_SPOT] = @LOCATION_SPOT
          AND [IL].[LOCKED_BY_INTERFACES] = 1
          AND [IL].[QTY] > 0
    GROUP BY [L].[LICENSE_ID];

    SELECT [S].[LOCATION_SPOT] [LOCATION],
           [IL].[MATERIAL_ID],
           [IL].[MATERIAL_NAME],
           [LL].[TOTAL_LICENSE] [TOTAL_LOCATION],
           [L].[LICENSE_ID],
           ISNULL(MAX([IL].[QTY]), 0) [TOTAL_QTY],
           SUM(ISNULL(([IL].[QTY]), 0) - ISNULL(([CIL].[COMMITED_QTY]), 0)
               - ISNULL([IRP].[QTY_RESERVED], 0) 
              ) [QTY_AVAILABLE],
           ISNULL(MAX([CIL].[COMMITED_QTY]), 0) [QTY_RESERVED],
		   (ISNULL([IRP].[QTY_RESERVED], 0) - ISNULL([IRP].[QTY_DISPATCHED], 0)) [QTY_RESERVED_BY_PROJECT],
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
               WHEN [LL].[TOTAL_LICENSE] = [TLL].[LOCKED_IN_LICENSE] THEN
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
        LEFT JOIN [#TOTAL_IN_LICENSE] [LL]
            ON [LL].[LICENSE_ID] = [L].[LICENSE_ID]
        LEFT JOIN [#TOTAL_LOCKED_IN_LICENSE] [TLL]
            ON [TLL].[LICENSE_ID] = [L].LICENSE_ID
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
               )
    WHERE [S].[LOCATION_SPOT] = @LOCATION_SPOT
    GROUP BY [S].[LOCATION_SPOT],
             [IL].[MATERIAL_ID],
             [IL].[MATERIAL_NAME],
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
             [P].[OPPORTUNITY_CODE],
             [P].[OPPORTUNITY_NAME],
             [LL].[TOTAL_LICENSE],
             [TLL].[LOCKED_IN_LICENSE],
			 [IRP].[QTY_RESERVED],
			 [IRP].[QTY_DISPATCHED]
    HAVING ISNULL(MAX([IL].[QTY]), 0) > 0
    ORDER BY [L].[LICENSE_ID] ASC;
--ORDER BY
--	[IL].[QTY];


END;