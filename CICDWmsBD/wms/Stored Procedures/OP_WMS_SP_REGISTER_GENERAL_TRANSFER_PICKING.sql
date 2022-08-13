-- ================================================================================================================
-- Autor:               DENIS.VILLAGRÁN
-- Fecha de Creación:   1/29/2020 GForce@Paris
-- Historia/Bug:        Product Backlog Item 34673: Traslado Físcal a General
-- Descripción:         1/29/2020 - Registra el picking del traslado general
-- ================================================================================================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REGISTER_GENERAL_TRANSFER_PICKING]
    @pLOGIN_ID VARCHAR(25),
    @pMATERIAL_ID VARCHAR(50),
    @pMATERIAL_BARCODE VARCHAR(25),
    @pSOURCE_LICENSE NUMERIC(18, 0),
    @pTARGET_LICENSE NUMERIC(18, 0),
    @pSOURCE_LOCATION VARCHAR(25),
    @pQUANTITY_UNITS NUMERIC(18, 4),
    @pPOLICY_CODE VARCHAR(25),
    @pWAVE_PICKING_ID NUMERIC(18, 0),
    @pSERIAL_NUMBER NUMERIC(18, 0),
    @pTRANS_MT2 NUMERIC(18, 2),
    @pLOCATION_TYPE VARCHAR(25),
    @pRESULT VARCHAR(300) OUTPUT,
    @pTASK_ID NUMERIC(18, 0) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --
    DECLARE @ErrorCode INT,
            @TASK_IS_PAUSED INT,
            @TASK_IS_CANCELED INT,
            @MATERIAL_NAME VARCHAR(200),
            @MATERIAL_ID_LOCAL VARCHAR(50),
            @TERMS_OF_TRADE VARCHAR(50),
            @CLIENT_OWNER_LOCAL VARCHAR(25),
            @CLIENT_ID_LOCAL VARCHAR(50),
            @VOLUME_FACTOR NUMERIC(18, 4),
            @BARCODE_ID VARCHAR(25),
            @DATE_EXPIRATION DATETIME,
            @BATCH VARCHAR(50),
            @VIN VARCHAR(40),
            @HANDLE_SERIAL INT,
            @STATUS_ID INT,
            @STATUS_CODE VARCHAR(50),
            @STATUS_NAME VARCHAR(100),
            @BLOCKS_INVENTORY VARCHAR(50),
            @ALLOW_REALLOC VARCHAR(50),
            @TARGET_LOCATION VARCHAR(50) = '',
            @DESCRIPTION VARCHAR(200),
            @COLOR VARCHAR(50),
            @TONE VARCHAR(25),
            @TONE_AND_CALIBER_ID INT = NULL,
            @CALIBER VARCHAR(25),
            @IS_MASTER_PACK INT;


    DECLARE @AVAILABLE_PICKING_LICENSE TABLE
    (
        [LICENSE_ID] INT,
        [MATERIAL_ID] VARCHAR(50),
        [QTY_AVAILABLE] DECIMAL(38, 4),
        [TONE] VARCHAR(20),
        [CALIBER] VARCHAR(20),
        [SPOT_TYPE] VARCHAR(25),
        [USED_MT2] NUMERIC(18, 2),
        [TASK_SUBTYPE] VARCHAR(25),
        [IS_DISCRETIONARY] INT,
        [QUANTITY_PENDING] NUMERIC(18, 4),
        [SERIAL_NUMBER_REQUESTS] NUMERIC
    );
    --
    BEGIN TRY

        -- ------------------------------------------------------------------------
        -- VALIDAMOS SI LA TAREA NO SE HA PAUSADO O CANCELADO
        -- ------------------------------------------------------------------------
        SELECT @TASK_IS_PAUSED =
        (
            SELECT [IS_PAUSED]
            FROM [wms].[OP_WMS_TASK_LIST]
            WHERE [SERIAL_NUMBER] = @pSERIAL_NUMBER
        );

        SELECT @TASK_IS_CANCELED =
        (
            SELECT [IS_CANCELED]
            FROM [wms].[OP_WMS_TASK_LIST]
            WHERE [SERIAL_NUMBER] = @pSERIAL_NUMBER
        );

        IF (@TASK_IS_PAUSED <> 0)
        BEGIN
            SELECT @pRESULT = 'ERROR, Tarea en PAUSA, verifique.';
            RETURN -1;
        END;

        IF (@TASK_IS_CANCELED <> 0)
        BEGIN
            SELECT @pRESULT = 'ERROR, Tarea cancelada, verifique.';
            RETURN -1;
        END;

        -- ------------------------------------------------------------------------
        -- VALIDAMOS QUE EL ID DEL MATERIAL Y LA LICENCIA DE ORIGEN SEAN CORRECTOS
        -- ------------------------------------------------------------------------
        SELECT @CLIENT_OWNER_LOCAL =
        (
            SELECT [CLIENT_OWNER]
            FROM [wms].[OP_WMS_LICENSES]
            WHERE [LICENSE_ID] = @pSOURCE_LICENSE
        );

        SELECT @MATERIAL_ID_LOCAL =
        (
            SELECT [MATERIAL_ID]
            FROM [wms].[OP_WMS_MATERIALS]
            WHERE (
                      [BARCODE_ID] = @pMATERIAL_BARCODE
                      OR [ALTERNATE_BARCODE] = @pMATERIAL_BARCODE
                  )
                  AND [CLIENT_OWNER] = @CLIENT_OWNER_LOCAL
        );

        IF @MATERIAL_ID_LOCAL IS NULL
        BEGIN
            SELECT @pRESULT
                = 'ERROR, SKU Invalido: [' + @pMATERIAL_BARCODE + '/' + @CLIENT_OWNER_LOCAL + '] verifique.';
            RETURN -1;
        END;

        IF @pSOURCE_LICENSE IS NULL
           OR @pSOURCE_LICENSE = 0
        BEGIN
            SELECT @pRESULT = 'ERROR, Licencia Invalido: [' + @pSOURCE_LICENSE + '] verifique.';
            RETURN -1;
        END;

        --
        BEGIN TRANSACTION;

        -- ------------------------------------------------------------------------
        -- INSERTAMOS LA TRANSACCIÓN DEL TRASLADO EN LA TABLA TRANS
        -- ------------------------------------------------------------------------
        INSERT INTO [wms].[OP_WMS_TRANS]
        (
            [TERMS_OF_TRADE],
            [TRANS_DATE],
            [LOGIN_ID],
            [LOGIN_NAME],
            [TRANS_TYPE],
            [TRANS_DESCRIPTION],
            [TRANS_EXTRA_COMMENTS],
            [MATERIAL_BARCODE],
            [MATERIAL_CODE],
            [MATERIAL_DESCRIPTION],
            [MATERIAL_TYPE],
            [MATERIAL_COST],
            [SOURCE_LICENSE],
            [TARGET_LICENSE],
            [SOURCE_LOCATION],
            [TARGET_LOCATION],
            [CLIENT_OWNER],
            [CLIENT_NAME],
            [QUANTITY_UNITS],
            [SOURCE_WAREHOUSE],
            [TARGET_WAREHOUSE],
            [TRANS_SUBTYPE],
            [CODIGO_POLIZA],
            [LICENSE_ID],
            [STATUS],
            [WAVE_PICKING_ID],
            [TRANS_MT2],
            [TASK_ID]
        )
        VALUES
        (   ISNULL(
            (
             SELECT [TERMS_OF_TRADE]
             FROM [wms].[OP_WMS_INV_X_LICENSE]
             WHERE [LICENSE_ID] = @pSOURCE_LICENSE
                   AND [MATERIAL_ID] = @MATERIAL_ID_LOCAL
            ),
            0
                  ),                                                                                      -- TERMS_OF_TRADE
            GETDATE(),                                                                                    -- TRANS_DATE
            @pLOGIN_ID,                                                                                   -- LOGIN_ID
            (
                SELECT * FROM [wms].[OP_WMS_FUNC_GETLOGIN_NAME](@pLOGIN_ID)
            ),                                                                                            -- LOGIN_NAME
            'TRASLADO_GENERAL',                                                                           -- TRANS_TYPE
            ISNULL(
            (
                SELECT [PARAM_CAPTION]
                FROM [wms].[OP_WMS_FUNC_GETTRANS_DESC]('TRASLADO_GENERAL')
            ),
            'TRASLADO GENERAL'
                  ),                                                                                      -- TRANS_DESCRIPTION
            NULL,                                                                                         -- TRANS_EXTRA_COMMENTS
            @pMATERIAL_BARCODE,                                                                           -- MATERIAL_BARCODE
            @MATERIAL_ID_LOCAL,                                                                           -- MATERIAL_CODE
            (
                SELECT *
                FROM [wms].[OP_WMS_FUNC_GETMATERIAL_DESC](@pMATERIAL_BARCODE, @CLIENT_OWNER_LOCAL)
            ),                                                                                            -- MATERIAL_DESCRIPTION
            ISNULL(
            (
                SELECT [MATERIAL_CLASS]
                FROM [wms].[OP_WMS_MATERIALS]
                WHERE [MATERIAL_ID] = @pMATERIAL_ID
            ),
            'N/A'
                  ),                                                                                      -- MATERIAL_TYPE
            [wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL](@MATERIAL_ID_LOCAL, @CLIENT_OWNER_LOCAL), -- MATERIAL_COST
            @pSOURCE_LICENSE,                                                                             -- SOURCE_LICENSE
            @pTARGET_LICENSE,                                                                             -- TARGET_LICENSE
            @pSOURCE_LOCATION,                                                                            -- SOURCE_LOCATION
            '',                                                                                           -- TARGET_LOCATION
            @CLIENT_OWNER_LOCAL,                                                                          -- CLIENT_OWNER
            (
                SELECT * FROM [wms].[OP_WMS_FUNC_GETCLIENT_NAME](@CLIENT_OWNER_LOCAL)
            ),                                                                                            -- CLIENT_NAME
            (@pQUANTITY_UNITS * -1),                                                                      -- QUANTITY_UNITS
            ISNULL(
            (
                SELECT ISNULL([WAREHOUSE_PARENT], 'BODEGA_DEF')
                FROM [wms].[OP_WMS_SHELF_SPOTS]
                WHERE [LOCATION_SPOT] = @pSOURCE_LOCATION
            ),
            'BODEGA_DEF'
                  ),                                                                                      -- SOURCE_WAREHOUSE
            NULL,                                                                                         -- TARGET_WAREHOUSE
            'PICKING FISCAL',                                                                             -- TRANS_SUBTYPE
            @pPOLICY_CODE,                                                                                -- CODIGO_POLIZA
            @pSOURCE_LICENSE,                                                                             -- LICENSE_ID
            'PROCESSED',                                                                                  -- STATUS
            @pWAVE_PICKING_ID,                                                                            -- WAVE_PICKING_ID
            @pTRANS_MT2,                                                                                  -- TRANS_MT2
            @pTASK_ID                                                                                     -- TASK_ID
            );


        -- ------------------------------------------------------------------------
        -- VALIDAMOS SI YA INGRESÓ EL PRODUCTO A LA LICENCIA
        -- ------------------------------------------------------------------------
        IF NOT EXISTS
        (
            SELECT [MATERIAL_ID]
            FROM [wms].[OP_WMS_INV_X_LICENSE]
            WHERE [LICENSE_ID] = @pTARGET_LICENSE
        )
        BEGIN
            -- ------------------------------------------------------------------------
            -- OBTENEMOS LAS VARIABLES PARA LLENAR EL ESTADO
            -- ------------------------------------------------------------------------
            SELECT TOP 1
                   @STATUS_CODE = [PARAM_NAME],
                   @STATUS_NAME = [PARAM_CAPTION],
                   @BLOCKS_INVENTORY = CASE [SPARE1]
                                           WHEN 'SI' THEN
                                               1
                                           WHEN '1' THEN
                                               1
                                           ELSE
                                               0
                                       END,
                   @ALLOW_REALLOC = CASE [SPARE2]
                                        WHEN 'SI' THEN
                                            1
                                        WHEN '1' THEN
                                            1
                                        ELSE
                                            0
                                    END,
                   @TARGET_LOCATION = [SPARE3],
                   @DESCRIPTION = [TEXT_VALUE],
                   @COLOR = [COLOR]
            FROM [wms].[OP_WMS_CONFIGURATIONS]
            WHERE [PARAM_TYPE] = 'ESTADO'
                  AND [PARAM_GROUP] = 'ESTADOS'
                  AND [NUMERIC_VALUE] = 1;

            ---------------------------------------------------------------------------------
            -- INSERTAMOS EL NUEVO ESTADO PARA EL NUEVO PRODUCTO
            ---------------------------------------------------------------------------------
            INSERT INTO [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE]
            (
                [STATUS_CODE],
                [STATUS_NAME],
                [BLOCKS_INVENTORY],
                [ALLOW_REALLOC],
                [TARGET_LOCATION],
                [DESCRIPTION],
                [COLOR],
                [LICENSE_ID]
            )
            VALUES
            (   @STATUS_CODE,      -- STATUS_CODE
                @STATUS_NAME,      -- STATUS_NAME
                @BLOCKS_INVENTORY, -- BLOCKS_INVENTORY
                @ALLOW_REALLOC,    -- ALLOW_REALLOC
                @TARGET_LOCATION,  -- TARGET_LOCATION
                @DESCRIPTION,      -- DESCRIPTION
                @COLOR,            -- COLOR
                @pTARGET_LICENSE   -- LICENSE_ID
                );
            SET @STATUS_ID = SCOPE_IDENTITY();

            -- ------------------------------------------------------------------------
            -- OBTENEMOS VARIABLES PARA INSERTAR INVENTARIO A LA LICENCIA
            -- ------------------------------------------------------------------------
            INSERT INTO @AVAILABLE_PICKING_LICENSE
            (
                [LICENSE_ID],
                [MATERIAL_ID],
                [QTY_AVAILABLE],
                [TONE],
                [CALIBER],
                [SPOT_TYPE],
                [USED_MT2],
                [TASK_SUBTYPE],
                [IS_DISCRETIONARY],
                [QUANTITY_PENDING],
                [SERIAL_NUMBER_REQUESTS]
            )
            EXEC [wms].[OP_WMS_SP_VALIDATE_IF_PICKING_LICENSE_IS_AVAILABLE] @WAVE_PICKING_ID = @pWAVE_PICKING_ID,
                                                                                @CURRENT_LOCATION = @pSOURCE_LOCATION,
                                                                                @MATERIAL_ID = @MATERIAL_ID_LOCAL,
                                                                                @LICENSE_ID = @pSOURCE_LICENSE,
                                                                                @LOGIN = @pLOGIN_ID;

            SELECT TOP 1
                   @CLIENT_ID_LOCAL = [L].[CLIENT_OWNER]
            FROM [wms].[OP_WMS_LICENSES] [L]
                INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C]
                    ON [C].[CLIENT_CODE] = [L].[CLIENT_OWNER]
            WHERE [L].[LICENSE_ID] = @pTARGET_LICENSE;

            SELECT TOP 1
                   @TONE = [APL].[TONE],
                   @CALIBER = [APL].[CALIBER]
            FROM @AVAILABLE_PICKING_LICENSE [APL];

            SELECT TOP (1)
                   @MATERIAL_ID_LOCAL = [MATERIAL_ID],
                   @HANDLE_SERIAL = ISNULL([M].[SERIAL_NUMBER_REQUESTS], 0),
                   @MATERIAL_NAME = [M].[MATERIAL_NAME]
            FROM [wms].[OP_WMS_MATERIALS] [M]
            WHERE (
                      [M].[BARCODE_ID] = @pMATERIAL_BARCODE
                      OR [M].[ALTERNATE_BARCODE] = @pMATERIAL_BARCODE
                  )
                  AND [M].[CLIENT_OWNER] = @CLIENT_ID_LOCAL;

            SELECT TOP 1
                   @VOLUME_FACTOR = [M].[VOLUME_FACTOR],
                   @BARCODE_ID = [M].[BARCODE_ID]
            FROM [wms].[OP_WMS_MATERIALS] [M]
            WHERE [M].[MATERIAL_ID] = @pMATERIAL_ID;

            SELECT TOP 1
                   @DATE_EXPIRATION = [IL].[DATE_EXPIRATION],
                   @BATCH = [IL].[BATCH],
                   @VIN = [IL].[VIN]
            FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
                LEFT JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML]
                    ON (
                           [IL].[LICENSE_ID] = [SML].[LICENSE_ID]
                           AND [IL].[STATUS_ID] = [SML].[STATUS_ID]
                       )
            WHERE [IL].[LICENSE_ID] = @pSOURCE_LICENSE
                  AND [IL].[MATERIAL_ID] = @MATERIAL_ID_LOCAL;

            SELECT @TERMS_OF_TRADE = ISNULL(   [ACUERDO_COMERCIAL],
                                     (
                                         SELECT [ACUERDO_COMERCIAL]
                                         FROM [wms].[OP_WMS_ACUERDOS_X_CLIENTE]
                                         WHERE [CLIENT_ID] = @CLIENT_ID_LOCAL
                                     )
                                           )

            FROM [wms].[OP_WMS_POLIZA_HEADER]
            WHERE [CODIGO_POLIZA] = @pPOLICY_CODE;

            SELECT @TONE_AND_CALIBER_ID = [TCM].[TONE_AND_CALIBER_ID]
            FROM [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM]
            WHERE [TCM].[MATERIAL_ID] = @pMATERIAL_ID
                  AND [TCM].[TONE] = @TONE
                  AND [TCM].[CALIBER] = @CALIBER;
            -- ------------------------------------------------------------------------
            -- INSERTAMOS EL MATERIAL A LA LICENCIA
            -- ------------------------------------------------------------------------
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
                [TOTAL_POSITION]
            )
            VALUES
            (   @pTARGET_LICENSE,     -- LICENSE_ID
                @pMATERIAL_ID,        -- MATERIAL_ID
                @MATERIAL_NAME,       -- MATERIAL_NAME
                @pQUANTITY_UNITS,     -- QTY
                @VOLUME_FACTOR,       -- VOLUME_FACTOR
                0,                    -- WEIGTH
                'N/A',                -- SERIAL_NUMBER
                'N/A',                -- COMMENTS
                GETDATE(),            -- LAST_UPDATED
                @pLOGIN_ID,           -- LAST_UPDATED_BY
                @BARCODE_ID,          -- BARCODE_ID
                @TERMS_OF_TRADE,      -- TERMS_OF_TRADE
                '',                   -- STATUS - varchar(25)
                GETDATE(),            -- CREATED_DATE - datetime
                @DATE_EXPIRATION,     -- DATE_EXPIRATION - date
                @BATCH,               -- BATCH - varchar(50)
                @pQUANTITY_UNITS,     -- ENTERED_QTY - numeric(18, 4)
                @VIN,                 -- VIN - varchar(40)
                @HANDLE_SERIAL,       -- HANDLE_SERIAL
                0,                    -- IS_EXTERNAL_INVENTORY
                0,                    -- IS_BLOCKED
                NULL,                 -- BLOCKED_STATUS
                @STATUS_ID,           -- STATUS_ID
                @TONE_AND_CALIBER_ID, -- TONE_AND_CALIBER_ID
                1,                    -- LOCKED_BY_INTERFACES
                1                     -- TOTAL_POSITION
                );

        END;
        ELSE
        BEGIN
            UPDATE [wms].[OP_WMS_INV_X_LICENSE]
            SET [QTY] = [QTY] + @pQUANTITY_UNITS
            WHERE [LICENSE_ID] = @pTARGET_LICENSE;
        END;
        -- ------------------------------------------------------------------------
        -- ACTUALIZAMOS EL INVENTARIO DE LAS LICENCIAS Y LA CANTIDAD PENTIENTE EN LA TAREA
        -- ------------------------------------------------------------------------
        UPDATE [wms].[OP_WMS_LICENSES]
        SET [LAST_UPDATED] = GETDATE(),
            [LAST_UPDATED_BY] = @pLOGIN_ID
        WHERE [LICENSE_ID] = @pTARGET_LICENSE;

        IF @pLOCATION_TYPE = 'PISO'
        BEGIN
            UPDATE [wms].[OP_WMS_LICENSES]
            SET [USED_MT2] = [USED_MT2] - @pTRANS_MT2
            WHERE [LICENSE_ID] = @pSOURCE_LICENSE;
        END;

        -- ------------------------------------------------------------------------
        -- DESPACHAMOS EL MASTER PACK
        -- ------------------------------------------------------------------------
        IF @IS_MASTER_PACK = 1
        BEGIN
            EXEC [wms].[OP_WMS_SP_DISPATCH_MASTER_PACK] @MATERIAL_ID = @MATERIAL_ID_LOCAL,
                                                            @LICENCE_ID = @pSOURCE_LICENSE,
                                                            @QTY_DISPATCH = @pQUANTITY_UNITS;
        END;

        -- ------------------------------------------------------------------------
        -- DESCONTAMOS EL INVENTARIO DE LA LICENCIA DE ORIGEN
        -- ------------------------------------------------------------------------
        UPDATE [wms].[OP_WMS_INV_X_LICENSE]
        SET [QTY] = [QTY] - @pQUANTITY_UNITS,
            [LAST_UPDATED] = CURRENT_TIMESTAMP,
            [LAST_UPDATED_BY] = @pLOGIN_ID
        WHERE [LICENSE_ID] = @pSOURCE_LICENSE
              AND [MATERIAL_ID] = @MATERIAL_ID_LOCAL;

        -- ------------------------------------------------------------------------
        -- ACTUALIZAMOS LA LICENCIA DE ORIGEN
        -- ------------------------------------------------------------------------
        UPDATE [wms].[OP_WMS_LICENSES]
        SET [LAST_UPDATED] = CURRENT_TIMESTAMP,
            [LAST_UPDATED_BY] = @pLOGIN_ID
        WHERE [LICENSE_ID] = @pSOURCE_LICENSE;

        -- ------------------------------------------------------------------------
        -- ACTUALIZAMOS LA CANTIDAD PENDIENTE DE LA TAREA
        -- ------------------------------------------------------------------------
        UPDATE [wms].[OP_WMS_TASK_LIST]
        SET [QUANTITY_PENDING] = [QUANTITY_PENDING] - @pQUANTITY_UNITS
        WHERE [WAVE_PICKING_ID] = @pWAVE_PICKING_ID
              AND [MATERIAL_ID] = @MATERIAL_ID_LOCAL
              AND [CODIGO_POLIZA_TARGET] = @pPOLICY_CODE;

        -- ------------------------------------------------------------------------
        -- ACTUALIZAMOS LA POLIZA
        -- ------------------------------------------------------------------------

        COMMIT TRANSACTION;

        SELECT @pRESULT = 'OK';

        SELECT 1 AS [Resultado],
               'Proceso Exitoso' [Mensaje],
               0 [Codigo],
               CAST(@pTARGET_LICENSE AS VARCHAR(50)) [DbData];
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        SELECT @ErrorCode = IIF(@@ERROR <> 0, @@ERROR, @ErrorCode);
        SELECT -1 AS [Resultado],
               ERROR_MESSAGE() AS [Mensaje],
               @ErrorCode AS [Codigo],
               '' AS [DbData];

        SELECT @pRESULT = ERROR_MESSAGE();
    END CATCH;
END;