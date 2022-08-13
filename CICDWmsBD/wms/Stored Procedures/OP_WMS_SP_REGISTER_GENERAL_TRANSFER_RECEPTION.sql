-- ================================================================================================================
-- Autor:               DENIS.VILLAGRÁN
-- Fecha de Creación:   1/29/2020 GForce@Paris
-- Historia/Bug:        Product Backlog Item 34673: Traslado Físcal a General
-- Descripción:         1/29/2020 - SP que registra la recepción del traslado general cada que se va a ubicar la
--                      licencia
-- ================================================================================================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REGISTER_GENERAL_TRANSFER_RECEPTION]
    @pLOGIN_ID VARCHAR(25),
    @pMATERIAL_ID VARCHAR(50),
    @pSOURCE_LICENSE NUMERIC(18, 0),
    @pTARGET_LICENSE NUMERIC(18, 0),
    @pTARGET_LOCATION VARCHAR(25),
    @pPOLICY_CODE VARCHAR(25),
    @pWAVE_PICKING_ID NUMERIC(18, 0),
    @pSERIAL_NUMBER NUMERIC(18, 0),
    @pTRANS_MT2 NUMERIC(18, 2),
    @pRESULT VARCHAR(300) OUTPUT,
    @pTASK_ID NUMERIC(18, 0) = NULL,
    @pTOTAL_POSITION INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    --

    DECLARE @ErrorCode INT,
            @TASK_IS_PAUSED INT,
            @TASK_IS_CANCELED INT,
            @MATERIAL_ID_LOCAL VARCHAR(50),
            @MATERIAL_BARCODE VARCHAR(25),  --
            @QUANTITY_UNITS NUMERIC(18, 4), --
            @CLIENT_OWNER_LOCAL VARCHAR(25),
            @CLIENT_ID_LOCAL VARCHAR(50),
            @IS_MASTER_PACK INT,
            @HANDLE_BATCH INT,
            @ALLOW_FAST_PICKING INT,
            @TRADE_AGREEMENT VARCHAR(25);

    --
    BEGIN TRY
        -- ------------------------------------------------------------------------
        -- OBTENEMOS VARIABLES INICIALES
        -- ------------------------------------------------------------------------
        SELECT @MATERIAL_BARCODE = @MATERIAL_BARCODE
        FROM [wms].[OP_WMS_MATERIALS]
        WHERE [MATERIAL_ID] = @pMATERIAL_ID;

        SELECT SUM([QUANTITY_UNITS])
        FROM [wms].[OP_WMS_TRANS]
        WHERE [WAVE_PICKING_ID] = @QUANTITY_UNITS;

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
                      [BARCODE_ID] = @MATERIAL_BARCODE
                      OR [ALTERNATE_BARCODE] = @MATERIAL_BARCODE
                  )
                  AND [CLIENT_OWNER] = @CLIENT_OWNER_LOCAL
        );

        IF @MATERIAL_ID_LOCAL IS NULL
        BEGIN
            SELECT @pRESULT = 'ERROR, SKU Inválido: [' + @MATERIAL_BARCODE + '/' + @CLIENT_OWNER_LOCAL + '] verifique.';
            RETURN -1;
        END;

        IF (@pSOURCE_LICENSE IS NULL)
           OR (@pSOURCE_LICENSE = 0)
        BEGIN
            SELECT @pRESULT = 'ERROR, Licencia Inválido: [' + @pSOURCE_LICENSE + '] verifique.';
            RETURN -1;
        END;
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
            @MATERIAL_BARCODE,                                                                            -- MATERIAL_BARCODE
            @MATERIAL_ID_LOCAL,                                                                           -- MATERIAL_CODE
            (
                SELECT *
                FROM [wms].[OP_WMS_FUNC_GETMATERIAL_DESC](@MATERIAL_BARCODE, @CLIENT_OWNER_LOCAL)
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
            '',                                                                                           -- SOURCE_LOCATION
            @pTARGET_LOCATION,                                                                            -- TARGET_LOCATION
            @CLIENT_OWNER_LOCAL,                                                                          -- CLIENT_OWNER
            (
                SELECT * FROM [wms].[OP_WMS_FUNC_GETCLIENT_NAME](@CLIENT_OWNER_LOCAL)
            ),                                                                                            -- CLIENT_NAME
            (@QUANTITY_UNITS * -1),                                                                       -- QUANTITY_UNITS
            NULL,                                                                                         -- SOURCE_WAREHOUSE
            ISNULL(
            (
                SELECT ISNULL([WAREHOUSE_PARENT], 'BODEGA_DEF')
                FROM [wms].[OP_WMS_SHELF_SPOTS]
                WHERE [LOCATION_SPOT] = @pTARGET_LOCATION
            ),
            'BODEGA_DEF'
                  ),                                                                                      -- TARGET_WAREHOUSE
            'RECEPCIÓN GENERAL',                                                                          -- TRANS_SUBTYPE
            @pPOLICY_CODE,                                                                                -- CODIGO_POLIZA
            @pSOURCE_LICENSE,                                                                             -- LICENSE_ID
            'PROCESSED',                                                                                  -- STATUS
            @pWAVE_PICKING_ID,                                                                            -- WAVE_PICKING_ID
            @pTRANS_MT2,                                                                                  -- TRANS_MT2
            @pTASK_ID                                                                                     -- TASK_ID
            );


        ---------------------------------------------------------------------------------
        -- INSERTAR LA UBICACIÓN
        ---------------------------------------------------------------------------------  
        INSERT INTO [wms].[OP_WMS_REALLOCS_X_LICENSE]
        (
            [LICENSE_ID],
            [TARGET_LOCATION],
            [TRANS_TYPE],
            [LAST_UPDATED],
            [LAST_UPDATED_BY]
        )
        VALUES
        (   @pTARGET_LICENSE,   -- LICENSE_ID
            @pTARGET_LOCATION,  -- TARGET_LOCATION
            'TRASLADO GENERAL', -- TRANS_TYPE
            GETDATE(),          -- LAST_UPDATED
            @pLOGIN_ID          -- LOGIN_ID
            );


        -- ------------------------------------------------------------------------
        -- OBTENEMOS LOS ACUERDOS COMERCIALES
        -- ------------------------------------------------------------------------
        SELECT @TRADE_AGREEMENT = CASE
                                      WHEN [PH].[ACUERDO_COMERCIAL] IS NOT NULL
                                           AND [PH].[ACUERDO_COMERCIAL] <> ''
                                           AND [PH].[ACUERDO_COMERCIAL] <> '9999' THEN
                                          [PH].[ACUERDO_COMERCIAL]
                                      ELSE
                                          [AC].[ACUERDO_COMERCIAL]
                                  END
        FROM [wms].[OP_WMS_POLIZA_HEADER] [PH]
            INNER JOIN [wms].[OP_WMS_ACUERDOS_X_CLIENTE] [AC]
                ON [PH].[CLIENT_CODE] = [AC].[CLIENT_ID]
        WHERE [PH].[CODIGO_POLIZA] = @pPOLICY_CODE;
        -- ------------------------------------------------------------------------
        -- ACTUALIZAMOS EL INVENTARIO POR LICENCIA
        -- ------------------------------------------------------------------------
        UPDATE [wms].[OP_WMS_INV_X_LICENSE]
        SET [TERMS_OF_TRADE] = [TERMS_OF_TRADE],
            [TOTAL_POSITION] = @pTOTAL_POSITION
        WHERE [LICENSE_ID] = @pTARGET_LICENSE;

        -- ------------------------------------------------------------------------
        -- OBTENEMOS VALORES PARA VALIDAR
        -- ------------------------------------------------------------------------
        SELECT TOP (1)
               @MATERIAL_ID_LOCAL = [MATERIAL_ID],
               @IS_MASTER_PACK = ISNULL([M].[IS_MASTER_PACK], 0),
               @HANDLE_BATCH = ISNULL([M].[BATCH_REQUESTED], 0)
        FROM [wms].[OP_WMS_MATERIALS] [M]
        WHERE (
                  [M].[BARCODE_ID] = @MATERIAL_BARCODE
                  OR [M].[ALTERNATE_BARCODE] = @MATERIAL_BARCODE
              )
              AND [M].[CLIENT_OWNER] = @CLIENT_ID_LOCAL;


        SELECT TOP 1
               @ALLOW_FAST_PICKING = [S].[ALLOW_FAST_PICKING]
        FROM [wms].[OP_WMS_SHELF_SPOTS] [S]
        WHERE [S].[LOCATION_SPOT] = @pTARGET_LOCATION;
        -- ------------------------------------------------------------------------------------
        -- SI ESTAMOS UBICANDO EN UNA UBICACION CON LA PROPIEDAD ALLOW_FAST_PICKING = TRUE
        -- DEBEMOS TRASLADAR EL INVENTARIO DE LA LICENCIA CREADA EN LA RECEPCION HACIA UNA
        -- LICENCIA PREVIAMENTE CREADA EN DICHA UBICACION
        -- ------------------------------------------------------------------------------------
        IF @ALLOW_FAST_PICKING = 1
        BEGIN
            EXEC [wms].[OP_WMS_SP_UPDATE_LICENSE_FAST_PICKING] @LOGIN_ID = @pLOGIN_ID,           -- varchar(50)
                                                                   @LICENSE_ID = @pTARGET_LICENSE,   -- int
                                                                   @LOCATION_ID = @pTARGET_LOCATION, -- varchar(25)
                                                                   @TRANS_TYPE = 'TRASLADO_GENERAL', -- varchar(25)
                                                                   @TASK_ID = @pTASK_ID;             -- int

        END;



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