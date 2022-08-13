CREATE PROCEDURE [wms].[OP_WMS_SP_REGISTER_LICENSE_RECEPTION]
(
    @LOGIN_ID VARCHAR(50),
    @TRANS_TYPE VARCHAR(25),
    @LICENSE_ID INT,
    @LOCATION_ID VARCHAR(25),
    @MT2 DECIMAL(18, 2),
    @TASK_ID INT,
    @TOTAL_POSITION INT = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        ---------------------------------------------------------------------------------
        -- Declaramos las variables necesarias
        ---------------------------------------------------------------------------------  
        DECLARE @LOGIN_NAME VARCHAR(50),
                @TRANS_TYPE_NAME VARCHAR(100),
                @WAREHOUSE_ID VARCHAR(50),
                @IS_FROM_SONDA INT,
                @CODE_SUPPLIER VARCHAR(50),
                @NAME_SUPPLIER VARCHAR(100),
                @TRANSFER_REQUEST_ID INT,
                @SOURCE_TYPE VARCHAR(50),
                @DOC_ID INT,
                @TRADE_AGREEMENT VARCHAR(25),
                @TRANS_SUBTYPE VARCHAR(25),
                @EXPLODE_IN_RECEPTION INT = 0,
                @EXPLOSION_TYPE VARCHAR(50),
                @IS_FROM_ERP INT = 0,
                @ALLOW_FAST_PICKING INT = 0;

        DECLARE @MATERIALS TABLE
        (
            [MATERIAL_ID] VARCHAR(50),
            [QTY] NUMERIC(18, 4)
        );


        SELECT TOP 1
               @LOGIN_ID = [VALUE]
        FROM [wms].[OP_WMS_FUNC_SPLIT](@LOGIN_ID, '@');

        ---------------------------------------------------------------------------------
        -- Obtenemos los datos necesarios
        ---------------------------------------------------------------------------------  

        SELECT TOP 1
               @EXPLOSION_TYPE = [C].[TEXT_VALUE]
        FROM [wms].[OP_WMS_CONFIGURATIONS] [C]
        WHERE [C].[PARAM_TYPE] = 'SISTEMA'
              AND [C].[PARAM_GROUP] = 'MASTER_PACK_SETTINGS'
              AND [C].[PARAM_NAME] = 'TIPO_EXPLOSION_RECEPCION';

        SELECT TOP 1
               @LOGIN_NAME = [L].[LOGIN_ID]
        FROM [wms].[OP_WMS_LOGINS] [L]
        WHERE [L].[LOGIN_ID] = @LOGIN_ID;


        SELECT TOP 1
               @WAREHOUSE_ID = [S].[WAREHOUSE_PARENT],
               @ALLOW_FAST_PICKING = [S].[ALLOW_FAST_PICKING]
        FROM [wms].[OP_WMS_SHELF_SPOTS] [S]
        WHERE [S].[LOCATION_SPOT] = @LOCATION_ID;

        SELECT TOP 1
               @CODE_SUPPLIER = [RDH].[CODE_SUPPLIER],
               @NAME_SUPPLIER = [RDH].[NAME_SUPPLIER],
               @IS_FROM_ERP = 1
        FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
        WHERE [RDH].[TASK_ID] = @TASK_ID;


        SELECT TOP 1
               @TRANSFER_REQUEST_ID = [TL].[TRANSFER_REQUEST_ID],
               @SOURCE_TYPE = [TL].[SOURCE_TYPE],
               @DOC_ID = ISNULL([TL].[DOC_ID_SOURCE], PH.DOC_ID),
               @TRANS_SUBTYPE = [TL].[TASK_SUBTYPE]
        FROM [wms].[OP_WMS_TASK_LIST] [TL]
            LEFT JOIN wms.OP_WMS_POLIZA_HEADER [PH]
                ON (PH.CODIGO_POLIZA = TL.CODIGO_POLIZA_TARGET)
        WHERE [TL].[SERIAL_NUMBER] = @TASK_ID;


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
        WHERE [PH].[DOC_ID] = @DOC_ID;

        SELECT TOP 1
               @TRANS_TYPE_NAME = [C].[PARAM_CAPTION]
        FROM [wms].[OP_WMS_CONFIGURATIONS] [C]
        WHERE [C].[PARAM_TYPE] = 'SISTEMA'
              AND [C].[PARAM_GROUP] = 'TRANS_TYPES'
              AND [C].[PARAM_NAME] = @TRANS_TYPE;

        BEGIN TRANSACTION;

        ---------------------------------------------------------------------------------
        -- Insertamos las transacciones
        ---------------------------------------------------------------------------------  

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
            [MATERIAL_COST],
            [TARGET_LICENSE],
            [TARGET_LOCATION],
            [CLIENT_OWNER],
            [CLIENT_NAME],
            [QUANTITY_UNITS],
            [TARGET_WAREHOUSE],
            [TRANS_SUBTYPE],
            [CODIGO_POLIZA],
            [LICENSE_ID],
            [STATUS],
            [TRANS_MT2],
            [VIN],
            [TASK_ID],
            [IS_FROM_SONDA],
            [SERIAL],
            [BATCH],
            [DATE_EXPIRATION],
            [CODE_SUPPLIER],
            [NAME_SUPPLIER],
            [SOURCE_TYPE],
            [TRANSFER_REQUEST_ID],
            [TONE],
            [CALIBER],
            [ORIGINAL_LICENSE],
            [ENTERED_MEASUREMENT_UNIT],
            [ENTERED_MEASUREMENT_UNIT_QTY],
            [ENTERED_MEASUREMENT_UNIT_CONVERSION_FACTOR],
            [STATUS_CODE]
        )
        SELECT @TRADE_AGREEMENT,
               GETDATE(),
               @LOGIN_ID,
               @LOGIN_NAME,
               IIF(@TRANS_SUBTYPE = 'TRASLADO_GENERAL', 'INGRESO_GENERAL', @TRANS_TYPE),
               IIF(@TRANS_SUBTYPE = 'TRASLADO_GENERAL', 'INGRESO_GENERAL', @TRANS_TYPE_NAME),
               [Il].[COMMENTS],
               [Il].[BARCODE_ID],
               [Il].[MATERIAL_ID],
               [Il].[MATERIAL_NAME],
               [wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL]([Il].[MATERIAL_ID], [L].[CLIENT_OWNER]),
               @LICENSE_ID,
               @LOCATION_ID,
               [L].[CLIENT_OWNER],
               [V].[CLIENT_NAME],
               CASE
                   WHEN [MXSN].[CORRELATIVE] IS NULL THEN
                       [Il].[QTY]
                   ELSE
                       1
               END,
               @WAREHOUSE_ID,
               @TRANS_SUBTYPE,
               [L].[CODIGO_POLIZA],
               @LICENSE_ID,
               'PROCESSED',
               @MT2,
               [Il].[VIN],
               @TASK_ID,
               0,
               [MXSN].[SERIAL],
               [Il].[BATCH],
               [Il].[DATE_EXPIRATION],
               @CODE_SUPPLIER,
               @NAME_SUPPLIER,
               @SOURCE_TYPE,
               @TRANSFER_REQUEST_ID,
               [TCM].[TONE],
               [TCM].[CALIBER],
               @LICENSE_ID,
               [Il].[ENTERED_MEASUREMENT_UNIT],
               [Il].[ENTERED_MEASUREMENT_UNIT_QTY],
               [Il].[ENTERED_MEASUREMENT_UNIT_CONVERSION_FACTOR],
               [SML].[STATUS_CODE]
        FROM [wms].[OP_WMS_INV_X_LICENSE] [Il]
            INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML]
                ON [SML].[LICENSE_ID] = [Il].[LICENSE_ID]
                   AND [SML].[STATUS_ID] = [Il].[STATUS_ID]
            INNER JOIN [wms].[OP_WMS_LICENSES] [L]
                ON ([Il].[LICENSE_ID] = [L].[LICENSE_ID])
            INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
                ON ([M].[MATERIAL_ID] = [Il].[MATERIAL_ID])
            INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [V]
                ON ([V].[CLIENT_CODE] = [L].[CLIENT_OWNER])
            LEFT JOIN [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [MXSN]
                ON (
                       [MXSN].[LICENSE_ID] = [Il].[LICENSE_ID]
                       AND [MXSN].[MATERIAL_ID] = [Il].[MATERIAL_ID]
                       AND [MXSN].[STATUS] > 0
                   )
            LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM]
                ON ([TCM].[TONE_AND_CALIBER_ID] = [Il].[TONE_AND_CALIBER_ID])
        WHERE [Il].[LICENSE_ID] = @LICENSE_ID;


        ---------------------------------------------------------------------------------
        -- RECORD THE REALLOC
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
        (@LICENSE_ID, @LOCATION_ID, @TRANS_TYPE, GETDATE(), @LOGIN_ID);


        ---------------------------------------------------------------------------------
        -- Actualiza el inventario de la licencia
        ---------------------------------------------------------------------------------  
        UPDATE [wms].[OP_WMS_INV_X_LICENSE]
        SET [TERMS_OF_TRADE] = @TRADE_AGREEMENT,
            [TOTAL_POSITION] = @TOTAL_POSITION
        WHERE [LICENSE_ID] = @LICENSE_ID;

        ---------------------------------------------------------------------------------
        -- Actualiza la licencia 
        ---------------------------------------------------------------------------------  
        UPDATE [wms].[OP_WMS_LICENSES]
        SET [LAST_LOCATION] = [CURRENT_LOCATION],
            [CURRENT_LOCATION] = @LOCATION_ID,
            [LAST_UPDATED_BY] = @LOGIN_ID,
            [CURRENT_WAREHOUSE] = @WAREHOUSE_ID,
            [STATUS] = 'ALLOCATED',
            [USED_MT2] = @MT2
        WHERE [LICENSE_ID] = @LICENSE_ID;

        ---------------------------------------------------------------------------------
        -- Actualiza la licencia 
        ---------------------------------------------------------------------------------  

        UPDATE [wms].[OP_WMS_POLIZA_HEADER]
        SET [STATUS] = 'COMPLETED',
            [LAST_UPDATED] = GETDATE(),
            [LAST_UPDATED_BY] = @LOGIN_ID
        WHERE [DOC_ID] = @DOC_ID;

        -- ------------------------------------------------------------------------------------
        -- Validamos y bloqueamos el inventario si viene de una solicitud de traslado
        -- ------------------------------------------------------------------------------------

        IF @TRANSFER_REQUEST_ID IS NOT NULL
        BEGIN

            UPDATE [wms].[OP_WMS_INV_X_LICENSE]
            SET [IS_BLOCKED] = 1
            WHERE [LICENSE_ID] = @LICENSE_ID;
        END;

        ---------------------------------------------------------------------------------
        -- Obtenemos los materiales de tipo master pack 
        ---------------------------------------------------------------------------------  

        INSERT INTO @MATERIALS
        (
            [MATERIAL_ID],
            [QTY]
        )
        SELECT [IL].[MATERIAL_ID],
               [IL].[QTY]
        FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
            INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
                ON ([M].[MATERIAL_ID] = [IL].[MATERIAL_ID])
        WHERE [M].[IS_MASTER_PACK] = 1
              AND [IL].[LICENSE_ID] = @LICENSE_ID;

        ---------------------------------------------------------------------------------
        -- Recorremos el listado obtenido de los materiales master pack
        ---------------------------------------------------------------------------------  

        WHILE EXISTS (SELECT TOP 1 1 FROM @MATERIALS [M])
        BEGIN
            DECLARE @MATERIAL_ID VARCHAR(50),
                    @QTY NUMERIC(18, 4);

            SELECT TOP 1
                   @MATERIAL_ID = [MATERIAL_ID],
                   @QTY = [QTY]
            FROM @MATERIALS;


            ---------------------------------------------------------------------------------
            -- registrar datos de masterpack ingresado 
            ---------------------------------------------------------------------------------  
            EXEC [wms].[OP_WMS_SP_INSERT_MASTER_PACK] @MATERIAL_ID_MASTER_PACK = @MATERIAL_ID,
														 -- @TASK_ID = @TASK_ID,
                                                          @LICENSE_ID = @LICENSE_ID,
                                                          @LAST_UPDATE_BY = @LOGIN_ID,
                                                          @QTY = @QTY;

            SELECT TOP 1
                   @MATERIAL_ID = [M].[MATERIAL_ID],
                   @EXPLODE_IN_RECEPTION = ISNULL([PW].[VALUE], [M].[EXPLODE_IN_RECEPTION])
            FROM [wms].[OP_WMS_MATERIALS] [M]
                LEFT JOIN [wms].[OP_WMS_MATERIAL_PROPERTY_BY_WAREHOUSE] [PW]
                    ON (
                           [PW].[MATERIAL_ID] = [M].[MATERIAL_ID]
                           AND [PW].[WAREHOUSE_ID] = @WAREHOUSE_ID
                       )
                LEFT JOIN [wms].[OP_WMS_MATERIAL_PROPERTY] [MP]
                    ON (
                           [MP].[MATERIAL_PROPERTY_ID] = [PW].[MATERIAL_PROPERTY_ID]
                           AND [MP].[NAME] = 'EXPLODE_IN_RECEPTION'
                       )
            WHERE [M].[MATERIAL_ID] = @MATERIAL_ID;
            ---------------------------------------------------------------------------------
            -- Si esta activada la bandera de explota en recepción realizar explosión.
            ---------------------------------------------------------------------------------  
            IF @EXPLODE_IN_RECEPTION = 1
               AND @IS_FROM_ERP = 0
            BEGIN

                ---------------------------------------------------------------------------------
                -- validar si explotara en cascada o directo al ultimo nivel 
                ---------------------------------------------------------------------------------  
                IF @EXPLOSION_TYPE = 'EXPLOSION_CASCADA'
                BEGIN
                    EXEC [wms].[OP_WMS_SP_EXPLODE_CASCADE_IN_RECEPTION] @LICENSE_ID = @LICENSE_ID,
                                                                            @LOGIN_ID = @LOGIN_ID,
                                                                            @MATERIAL_ID = @MATERIAL_ID;
                END;
                ELSE
                BEGIN
                    EXEC [wms].[OP_WMS_EXPLODE_MASTER_PACK] @LICENSE_ID = @LICENSE_ID,
                                                                @MATERIAL_ID = @MATERIAL_ID,
                                                                @LAST_UPDATE_BY = @LOGIN_ID,
                                                                @MANUAL_EXPLOTION = 0;
                END;
            END;
            DELETE FROM @MATERIALS
            WHERE [MATERIAL_ID] = @MATERIAL_ID;
        END;

        -- ------------------------------------------------------------------------------------
        -- si estamos ubicando en una ubicacion con la propiedad ALLOW_FAST_PICKING = TRUE
        -- debemos trasladar el inventario de la licencia creada en la recepcion hacia 
        -- una licencia previamente creada en dicha ubicacion
        -- ------------------------------------------------------------------------------------
        IF @ALLOW_FAST_PICKING = 1
        BEGIN
            EXEC [wms].[OP_WMS_SP_UPDATE_LICENSE_FAST_PICKING] @LOGIN_ID = @LOGIN_ID,       -- varchar(50)
                                                                   @LICENSE_ID = @LICENSE_ID,   -- int
                                                                   @LOCATION_ID = @LOCATION_ID, -- varchar(25)
                                                                   @TRANS_TYPE = @TRANS_TYPE,   -- varchar(25)
                                                                   @TASK_ID = @TASK_ID          -- int

            ;
        END;


        COMMIT TRANSACTION;
        ---------------------------------------------------------------------------------
        -- Retornamos el objeto resultado
        ---------------------------------------------------------------------------------  
        SELECT 1 AS [Resultado],
               'Proceso Exitoso' [Mensaje],
               0 [CODIGO],
               CAST('' AS VARCHAR) [DbData];
    END TRY
    BEGIN CATCH

        SELECT -1 AS [Resultado],
               ERROR_MESSAGE() AS [Mensaje],
               @@ERROR AS [CODIGO],
               '' AS [DbData];

        IF XACT_STATE() <> 0
        BEGIN
            ROLLBACK TRANSACTION;
        END;
    END CATCH;


END;