-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	18-Jun-2019 G-FORCE@Cancun-Swift3PL
-- Description:			Sp que crea una nueva licencia para los productos incompatbiles para la ubicacion.,

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].OP_WMS_SP_CREATE_LICENSE_BY_SUGGESTED_LOCATIONS						
					@LICENSE_ID = 469790
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CREATE_LICENSE_BY_SUGGESTED_LOCATIONS]
(
    @LOGIN VARCHAR(50),
    @ZONE VARCHAR(50),
    @WAREHOUSE_CODE VARCHAR(50),
    @LOCATION VARCHAR(50),
    @LICENSE_ID INT = 51111
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;
        DECLARE @NEW_LICENSE INT;

        DECLARE @MATERIAL_LICENSE_TABLE TABLE
        (
            [MATERIAL_CODE] VARCHAR(50)
        );

        -- ----------------------------------------
        -- Se obtienen los productos compatilbes con la ubicacion
        -- ----------------------------------------
        INSERT INTO @MATERIAL_LICENSE_TABLE
        (
            [MATERIAL_CODE]
        )
        SELECT DISTINCT
               [IL].[MATERIAL_ID]
        FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
            INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
                ON ([IL].[MATERIAL_ID] = [M].[MATERIAL_ID])
            INNER JOIN [wms].[OP_WMS_CLASS] [C]
                ON ([M].[MATERIAL_CLASS] = [C].[CLASS_ID])
            INNER JOIN [wms].[OP_WMS_SLOTTING_ZONE_BY_CLASS] [SZC]
                ON ([C].[CLASS_ID] = [SZC].[CLASS_ID])
            INNER JOIN [wms].[OP_WMS_SLOTTING_ZONE] [SZ]
                ON ([SZC].[ID_SLOTTING_ZONE] = [SZ].[ID])
            INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [SS]
                ON (
                       [SZ].[ZONE] = [SS].[ZONE]
                       AND [SZ].[WAREHOUSE_CODE] = [SS].[WAREHOUSE_PARENT]
                   )
        WHERE [SZ].[ZONE] = @ZONE
              AND [SZ].[WAREHOUSE_CODE] = @WAREHOUSE_CODE
              AND [SS].[LOCATION_SPOT] = @LOCATION
              AND [SS].[ALLOW_STORAGE] = 1
              AND [IL].[LICENSE_ID] = @LICENSE_ID;

        -- ----------------------------------------
        -- Creamos la licencia para los productos que no so compatibles
        -- ----------------------------------------
        INSERT INTO [wms].[OP_WMS_LICENSES]
        (
            [CLIENT_OWNER],
            [CODIGO_POLIZA],
            [CURRENT_WAREHOUSE],
            [CURRENT_LOCATION],
            [LAST_LOCATION],
            [LAST_UPDATED],
            [LAST_UPDATED_BY],
            [STATUS],
            [REGIMEN],
            [CREATED_DATE],
            [USED_MT2],
            [CODIGO_POLIZA_RECTIFICACION],
            [PICKING_DEMAND_HEADER_ID],
            [WAVE_PICKING_ID],
            [TARGET_LOCATION_REPLENISHMENT],
            [LAST_LICENSE_USED_IN_FAST_PICKING]
        )
        SELECT [L].[CLIENT_OWNER],
               [L].[CODIGO_POLIZA],
               [L].[CURRENT_WAREHOUSE],
               [L].[CURRENT_LOCATION],
               [L].[LAST_LOCATION],
               [L].[LAST_UPDATED],
               [L].[LAST_UPDATED_BY],
               [L].[STATUS],
               [L].[REGIMEN],
               [L].[CREATED_DATE],
               [L].[USED_MT2],
               [L].[CODIGO_POLIZA_RECTIFICACION],
               [L].[PICKING_DEMAND_HEADER_ID],
               [L].[WAVE_PICKING_ID],
               [L].[TARGET_LOCATION_REPLENISHMENT],
               [L].[LAST_LICENSE_USED_IN_FAST_PICKING]
        FROM [wms].[OP_WMS_LICENSES] [L]
        WHERE [L].[LICENSE_ID] = @LICENSE_ID;

        -- ----------------------------------------
        -- Obtenemos la licencia nueva.
        -- ----------------------------------------
        SELECT @NEW_LICENSE = @@IDENTITY;

        -- ----------------------------------------
        -- Insertamos los productos que no son compatibles con la ubicacion
        -- ----------------------------------------
        INSERT INTO [wms].[OP_WMS_INV_X_LICENSE]
        (
            [LICENSE_ID],
            [MATERIAL_ID],
            [MATERIAL_NAME],
            [QTY],
            [VOLUME_FACTOR],
            [WEIGTH],
            [SERIAL_NUMBER],
            [COMMENTS],
            [LAST_UPDATED],
            [LAST_UPDATED_BY],
            [BARCODE_ID],
            [TERMS_OF_TRADE],
            [STATUS],
            [CREATED_DATE],
            [DATE_EXPIRATION],
            [BATCH],
            [ENTERED_QTY],
            [VIN],
            [HANDLE_SERIAL],
            [IS_EXTERNAL_INVENTORY],
            [IS_BLOCKED],
            [BLOCKED_STATUS],
            [STATUS_ID],
            [TONE_AND_CALIBER_ID],
            [LOCKED_BY_INTERFACES],
            [ENTERED_MEASUREMENT_UNIT],
            [ENTERED_MEASUREMENT_UNIT_QTY],
            [ENTERED_MEASUREMENT_UNIT_CONVERSION_FACTOR],
            [CODE_SUPPLIER],
            [NAME_SUPPLIER],
            [IDLE],
            [NUMBER_OF_COMPLETE_RELOCATIONS],
            [NUMBER_OF_PARTIAL_RELOCATIONS],
            [NUMBER_OF_PHYSICAL_COUNTS]
        )
        SELECT @NEW_LICENSE,
               [IL].[MATERIAL_ID],
               [IL].[MATERIAL_NAME],
               [IL].[QTY],
               [IL].[VOLUME_FACTOR],
               [IL].[WEIGTH],
               [IL].[SERIAL_NUMBER],
               [IL].[COMMENTS],
               [IL].[LAST_UPDATED],
               [IL].[LAST_UPDATED_BY],
               [IL].[BARCODE_ID],
               [IL].[TERMS_OF_TRADE],
               [IL].[STATUS],
               [IL].[CREATED_DATE],
               [IL].[DATE_EXPIRATION],
               [IL].[BATCH],
               [IL].[ENTERED_QTY],
               [IL].[VIN],
               [IL].[HANDLE_SERIAL],
               [IL].[IS_EXTERNAL_INVENTORY],
               [IL].[IS_BLOCKED],
               [IL].[BLOCKED_STATUS],
               [IL].[STATUS_ID],
               [IL].[TONE_AND_CALIBER_ID],
               [IL].[LOCKED_BY_INTERFACES],
               [IL].[ENTERED_MEASUREMENT_UNIT],
               [IL].[ENTERED_MEASUREMENT_UNIT_QTY],
               [IL].[ENTERED_MEASUREMENT_UNIT_CONVERSION_FACTOR],
               [IL].[CODE_SUPPLIER],
               [IL].[NAME_SUPPLIER],
               [IL].[IDLE],
               [IL].[NUMBER_OF_COMPLETE_RELOCATIONS],
               [IL].[NUMBER_OF_PARTIAL_RELOCATIONS],
               [IL].[NUMBER_OF_PHYSICAL_COUNTS]
        FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
            LEFT JOIN @MATERIAL_LICENSE_TABLE [MLT]
                ON ([IL].[MATERIAL_ID] = [MLT].[MATERIAL_CODE])
        WHERE [IL].[LICENSE_ID] = @LICENSE_ID
              AND [MLT].[MATERIAL_CODE] IS NULL;

        -- ----------------------------------------
        -- Eliminamos los productos de la licencia que no son compatibles con la ubicacion
        -- ----------------------------------------
        DELETE [IL]
        FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
            INNER JOIN @MATERIAL_LICENSE_TABLE [MLT]
                ON ([IL].[MATERIAL_ID] = [MLT].[MATERIAL_CODE])
        WHERE [IL].[LICENSE_ID] = @LICENSE_ID;

        SELECT 1 AS [Resultado],
               'Proceso Exitoso' [Mensaje],
               0 [Codigo],
               CONVERT(VARCHAR(20), @NEW_LICENSE) [DbData];

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        SELECT -1 AS [Resultado],
               ERROR_MESSAGE() [Mensaje],
               @@error [Codigo];

    END CATCH;

END;