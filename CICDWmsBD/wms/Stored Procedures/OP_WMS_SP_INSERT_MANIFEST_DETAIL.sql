-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-02-13 @ Team ERGON - Sprint ERGON III
-- Description:	        Sp que hace un insert a la tabla [OP_WMS_MANIFEST_HEADER]

-- Modificacion 31-Aug-17 @ Nexus Team Sprint CommandAndConquer
-- alberto.ruiz
-- Se ajusto el cathc para que muestre el error de llave

-- Modificacion 9/20/2017 @ NEXUS-Team Sprint DuckHunt
-- rodrigo.gomez
-- Se insertan las direcciones, estado y se agrupa por cantidad en vez de sum para que al ser consolidado no se duplique y se agrega columna LINE_NUM

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-17 @ Team REBORN - Sprint Drache
-- Description:	   Se agrega insercion de etiquetas por manifiesto

-- Modificacion 11/29/2017 @ NEXUS-Team Sprint GTA
-- rodrigo.gomez
-- Se agrega el manejo para la implosion de materiales en DD.

-- Modificacion 12/8/2017 @ NEXUS-Team Sprint HeyYouPikachu!
-- rodrigo.gomez
-- Se agregan campos de descuentos y precios

-- Autor:				marvin.solares
-- Fecha de Creacion: 	01-Agosto-2019 GForce@Estambul
--Product Backlog Item 30564: Certificación de manifiesto con entrega de licencias de despacho
-- Description:			pongo como certificado el manifiesto si todas las olas asociadas ya estan despachadas

-- Autor:				marvin.solares
-- Fecha de Creacion: 	09-Agosto-2019 GForce@Estambul
--Bug 31212: no se logra crear manifiesto
-- Description:			se contempla escenario cuando se agregan tareas de una ola consolidada al manifiesto de carga

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	30-Noviembre-2019 GForce@Kioto
-- Description:			Se agrega validacion cuando se tiene producto por devolucion

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	30-Diciembre-2019 GForce@Oklahoma
-- Description:			Se agregan campos de peso, volumen y costo al detalle por material

-- Modificación:		Elder Lucas
-- Fecha Modificación: 	16 de marzo de 2022
-- Description:			Se obtiene el costo directamente de OP_WMS_VIEW_SAE_COST_BY_PRODUCT

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_INSERT_MANIFEST_DETAIL] 
				@MANIFEST_HEADER_ID = 10000
				,@PICKING_DEMAND_HEADER_ID = 1
				,@LAST_UPDATE_BY = 'YO'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_MANIFEST_DETAIL]
(
    @MANIFEST_HEADER_ID INT,
    @PICKING_DEMAND_HEADER_ID INT,
    @LAST_UPDATE_BY VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;
    ---------------------------------------------------------------------------------
    -- Declaramos variables y tablas temporales
    --------------------------------------------------------------------------------- 
    DECLARE @MANIFEST_DETAIL_ID INT,
            @MATERIAL_ID VARCHAR(50),
            @QTY_MANIFEST DECIMAL(18, 4),
            @QTY_LABEL DECIMAL(18, 4),
            @WAVE_PICKING_ID INT,
            @IS_FROM_MASTER_PACK INT,
            @LABEL_ID INT,
            @PENDING_DELIVERY INT = 0;

    DECLARE @COMPONENTS TABLE
    (
        [MATERIAL_ID] VARCHAR(50),
        [IS_FROM_MASTER_PACK] INT
    );

    DECLARE @MANIFEST_DETAIL_TEMP TABLE
    (
        [WAVE_PICKING_ID] INT,
        [MATERIAL_ID] VARCHAR(50),
        [QTY] DECIMAL(18, 4),
        [MANIFEST_DETAIL_ID] INT
    );

    DECLARE @LABELS_TEMP TABLE
    (
        [LABEL_ID] INT,
        [QTY] DECIMAL(18, 4),
        [MATERIAL_ID] VARCHAR(50),
        [IS_FROM_MASTER_PACK] INT
    );

    BEGIN TRY
        -- ------------------------------------------------------------------------------------
        -- Verificamos si el picking demand header id ya existe en el manifiesto de carga o si el manifiesto de carga ya se encuentra como certificado
        -- ------------------------------------------------------------------------------------
        IF EXISTS
        (
            SELECT TOP 1
                1
            FROM [wms].[OP_WMS_MANIFEST_DETAIL]
            WHERE [MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
                  AND [PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
        )
        BEGIN
            GOTO RESULT;
        END;

        IF EXISTS
        (
            SELECT TOP 1
                1
            FROM [wms].[OP_WMS_MANIFEST_HEADER]
            WHERE [STATUS] IN ( 'CERTIFIED', 'CANCELED' )
                  AND [MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
        )
        BEGIN
            RAISERROR(
                         N'El manifiesto de carga se encuentra cancelado o certificado por lo que no se pueden agregar mas lineas al detalle.',
                         16,
                         1
                     );
        END;

        -- ------------------------------------------------------------------------------------
        -- Verificamos que no tenga cantidades pendientes de entrega
        -- ------------------------------------------------------------------------------------


        DECLARE @MANIFEST_DETALLE TABLE
        (
            [MANIFEST_DETAIL_ID] INT,
            [PICKING_DEMAND_HEADER_ID] INT,
            [MATERIAL_ID] VARCHAR(50),
            [LINE_NUM] INT,
            [QTY_PENDING_DELIVERY] DECIMAL(18, 4),
            [QTY_DELIVERED] DECIMAL(18, 4),
            [ROW_NUMBER] INT
        );
        ---
        INSERT INTO @MANIFEST_DETALLE
        (
            [MANIFEST_DETAIL_ID],
            [PICKING_DEMAND_HEADER_ID],
            [MATERIAL_ID],
            [LINE_NUM],
            [QTY_PENDING_DELIVERY],
            [QTY_DELIVERED],
            [ROW_NUMBER]
        )
        SELECT [D].[MANIFEST_DETAIL_ID],
               [D].[PICKING_DEMAND_HEADER_ID],
               [D].[MATERIAL_ID],
               [D].[LINE_NUM],
               [D].[QTY_PENDING_DELIVERY],
               [D].[QTY_DELIVERED],
               ROW_NUMBER() OVER (PARTITION BY [D].[PICKING_DEMAND_HEADER_ID],
                                               [D].[LINE_NUM],
                                               [D].[MATERIAL_ID]
                                  ORDER BY [H].[CREATED_DATE] DESC
                                 ) AS [rn]
        FROM [wms].[OP_WMS_MANIFEST_DETAIL] [D]
            INNER JOIN [wms].[OP_WMS_MANIFEST_HEADER] [H]
                ON [H].[MANIFEST_HEADER_ID] = [D].[MANIFEST_HEADER_ID]
        WHERE [H].[STATUS] <> 'CANCELED';

        -- ------------------------------------------------------------------------------------
        -- Insertamos el detalle
        -- ------------------------------------------------------------------------------------

        INSERT [wms].[OP_WMS_MANIFEST_DETAIL]
        (
            [MANIFEST_HEADER_ID],
            [CODE_ROUTE],
            [CLIENT_CODE],
            [WAVE_PICKING_ID],
            [MATERIAL_ID],
            [QTY],
            [LAST_UPDATE],
            [LAST_UPDATE_BY],
            [ADDRESS_CUSTOMER],
            [CLIENT_NAME],
            [STATE_CODE],
            [PICKING_DEMAND_HEADER_ID],
            [LINE_NUM],
            [TYPE_DEMAND_CODE],
            [TYPE_DEMAND_NAME],
            [PRICE],
            [LINE_DISCOUNT],
            [LINE_TOTAL],
            [HEADER_DISCOUNT],
            [VOLUME_FACTOR_X_UNIT],
            [WEIGHT_X_UNIT],
            [VOLUME_FACTOR_X_LINE],
            [WEIGHT_X_LINE],
            [WEIGHT_MEASUREMENT],
            [CURRENT_COST_BY_PRODUCT],
			[STATUS_CODE]
        )
        SELECT @MANIFEST_HEADER_ID [MANIFEST_HEADER_ID],
               [DH].[CODE_ROUTE],
               [DH].[CLIENT_CODE],
               [DH].[WAVE_PICKING_ID],
               [DD].[MATERIAL_ID],
               CASE
                   WHEN [MD].[QTY_PENDING_DELIVERY] > 0 THEN
                       [MD].[QTY_PENDING_DELIVERY]
                   ELSE
                       [DD].[QTY]
               END [QTY],
               GETDATE() [LAST_UPDATE],
               @LAST_UPDATE_BY [LAST_UPDATE_BY],
               [DH].[ADDRESS_CUSTOMER],
               [DH].[CLIENT_NAME],
               [DH].[STATE_CODE],
               [DH].[PICKING_DEMAND_HEADER_ID],
               [DD].[LINE_NUM],
               CASE [DH].[IS_CONSOLIDATED]
                   WHEN 1 THEN
                       NULL
                   ELSE
                       [DH].[TYPE_DEMAND_CODE]
               END AS [TYPE_DEMAND_CODE],
               CASE [DH].[IS_CONSOLIDATED]
                   WHEN 1 THEN
                       NULL
                   ELSE
                       [DH].[TYPE_DEMAND_NAME]
               END AS [TYPE_DEMAND_NAME],
               [DD].[PRICE],
               [DD].[DISCOUNT],
               CASE
                   WHEN [DD].[DISCOUNT_TYPE] = 'PERCENTAGE'
                        AND [MD].[QTY_PENDING_DELIVERY] > 0 --SI SE TIENEN PENDIENTE DE ENTREGA
               THEN
               ([DD].[PRICE] * [MD].[QTY_PENDING_DELIVERY])
               - (([DD].[PRICE] * [MD].[QTY_PENDING_DELIVERY]) * ([DD].[DISCOUNT] / 100))
                   WHEN [DD].[DISCOUNT_TYPE] = 'PERCENTAGE'
                        AND [DD].[QTY] > 0 --SI NO SE TIENEN ENTREGAS PENDIENTES
               THEN
               ([DD].[PRICE] * [DD].[QTY]) - (([DD].[PRICE] * [DD].[QTY]) * ([DD].[DISCOUNT] / 100))
                   ELSE
                       CASE
                           WHEN [MD].[QTY_PENDING_DELIVERY] > 0 THEN
               ([DD].[PRICE] * [MD].[QTY_PENDING_DELIVERY]) - [DD].[DISCOUNT]
                           ELSE
               ([DD].[PRICE] * [DD].[QTY]) - [DD].[DISCOUNT]
                       END
               END [LINE_TOTAL],
               [DH].[DISCOUNT],
               ISNULL([M].[VOLUME_FACTOR], 0),
               ISNULL([M].[WEIGTH], 0),
               CASE
                   WHEN [MD].[QTY_PENDING_DELIVERY] > 0 THEN
                       [MD].[QTY_PENDING_DELIVERY] * ISNULL([M].[VOLUME_FACTOR], 0)
                   ELSE
                       [DD].[QTY] * ISNULL([M].[VOLUME_FACTOR], 0)
               END [VOLUME_FACTOR_X_LINE],
               CASE
                   WHEN [MD].[QTY_PENDING_DELIVERY] > 0 THEN
                       [MD].[QTY_PENDING_DELIVERY] * ISNULL([M].[WEIGTH], 0)
                   ELSE
                       [DD].[QTY] * ISNULL([M].[WEIGTH], 0)
               END [WEIGTH_X_LINE],
               [M].[WEIGHT_MEASUREMENT],
               ISNULL([CBP].[COSTO_PROM], 0),
			   [DD].STATUS_CODE
        FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD]
            INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH]
                ON [DH].[PICKING_DEMAND_HEADER_ID] = [DD].[PICKING_DEMAND_HEADER_ID]
            LEFT JOIN @MANIFEST_DETALLE [MD]
                ON [MD].[PICKING_DEMAND_HEADER_ID] = [DD].[PICKING_DEMAND_HEADER_ID]
                   AND [MD].[LINE_NUM] = [DD].[LINE_NUM]
                   AND [MD].[MATERIAL_ID] = [DD].[MATERIAL_ID]
                   AND [MD].[ROW_NUMBER] = 1
            LEFT JOIN [wms].[OP_WMS_MATERIALS] [M]
                ON ([M].[MATERIAL_ID] = [DD].[MATERIAL_ID])
			LEFT JOIN [wms].[OP_WMS_VIEW_SAE_COST_BY_PRODUCT] [CBP]
				ON [CBP].[CVE_ART] = [M].[ITEM_CODE_ERP] COLLATE DATABASE_DEFAULT
        WHERE [DH].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
              AND
              (
                  [MD].[PICKING_DEMAND_HEADER_ID] IS NULL
                  OR [MD].[QTY_PENDING_DELIVERY] > 0
              );


        INSERT INTO @MANIFEST_DETAIL_TEMP
        SELECT [MD].[WAVE_PICKING_ID],
               [MD].[MATERIAL_ID],
               [MD].[QTY],
               [MD].[MANIFEST_DETAIL_ID]
        FROM [wms].[OP_WMS_MANIFEST_DETAIL] [MD]
            INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL]
                ON (
                       [TL].[WAVE_PICKING_ID] = [MD].[WAVE_PICKING_ID]
                       AND [TL].[MATERIAL_ID] = [MD].[MATERIAL_ID]
                   )
        WHERE [MD].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
              AND [MD].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
              AND [MD].[MANIFEST_DETAIL_ID] > 0;



        WHILE EXISTS (SELECT TOP 1 1 FROM @MANIFEST_DETAIL_TEMP)
        BEGIN

            SELECT TOP 1
                @WAVE_PICKING_ID = [WAVE_PICKING_ID],
                @MATERIAL_ID = [MATERIAL_ID],
                @QTY_MANIFEST = [QTY],
                @MANIFEST_DETAIL_ID = [MANIFEST_DETAIL_ID]
            FROM @MANIFEST_DETAIL_TEMP
            ORDER BY [MATERIAL_ID],
                     [QTY] DESC;

            INSERT INTO @COMPONENTS
            SELECT [COMPONENT_MATERIAL],
                   1
            FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK]
            WHERE @MATERIAL_ID = [MASTER_PACK_CODE];
            --
            INSERT INTO @COMPONENTS
            VALUES
            (@MATERIAL_ID, 0);

            INSERT INTO @LABELS_TEMP
            SELECT [PL].[LABEL_ID],
                   [PL].[QTY],
                   [PL].[MATERIAL_ID],
                   [C].[IS_FROM_MASTER_PACK]
            FROM [wms].[OP_WMS_PICKING_LABELS] [PL]
                INNER JOIN @COMPONENTS [C]
                    ON [C].[MATERIAL_ID] = [PL].[MATERIAL_ID]
                LEFT JOIN [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST] [LBM]
                    ON (
                           [PL].[LABEL_ID] = [LBM].[LABEL_ID]
                           AND [PL].[MATERIAL_ID] = [LBM].[MATERIAL_ID]
                       )
            WHERE [PL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
                  AND
                  (
                      [LBM].[LABEL_ID] IS NULL
                      OR [LBM].[QTY] < [PL].[QTY]
                  );

            --
            DELETE @COMPONENTS;
            --

            WHILE EXISTS (SELECT TOP 1 1 FROM @LABELS_TEMP)
            BEGIN

                SELECT TOP 1
                    @LABEL_ID = [LABEL_ID],
                    @QTY_LABEL = [QTY],
                    @MATERIAL_ID = [MATERIAL_ID]
                FROM @LABELS_TEMP
                ORDER BY [QTY] ASC;

                IF @QTY_LABEL <= @QTY_MANIFEST
                   AND @IS_FROM_MASTER_PACK = 0
                BEGIN
                    INSERT [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST]
                    (
                        [LABEL_ID],
                        [MANIFEST_DETAIL_ID],
                        [MATERIAL_ID],
                        [QTY]
                    )
                    VALUES
                    (@LABEL_ID, @MANIFEST_DETAIL_ID, @MATERIAL_ID, @QTY_LABEL);

                    SET @QTY_MANIFEST = @QTY_MANIFEST - @QTY_LABEL;

                    IF @QTY_MANIFEST = 0
                    BEGIN
                        DELETE @LABELS_TEMP;
                        BREAK;
                    END;
                END;
                ELSE
                BEGIN
                    IF @IS_FROM_MASTER_PACK = 0
                    BEGIN
                        INSERT [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST]
                        (
                            [LABEL_ID],
                            [MANIFEST_DETAIL_ID],
                            [MATERIAL_ID],
                            [QTY]
                        )
                        VALUES
                        (@LABEL_ID, @MANIFEST_DETAIL_ID, @MATERIAL_ID, @QTY_MANIFEST);
                        DELETE @LABELS_TEMP;
                        BREAK;
                    END;
                    ELSE
                    BEGIN
                        INSERT [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST]
                        (
                            [LABEL_ID],
                            [MANIFEST_DETAIL_ID],
                            [MATERIAL_ID],
                            [QTY]
                        )
                        VALUES
                        (@LABEL_ID, @MANIFEST_DETAIL_ID, @MATERIAL_ID, @QTY_LABEL);
                    END;
                END;

                DELETE FROM @LABELS_TEMP
                WHERE [LABEL_ID] = @LABEL_ID;

            END;

            DELETE @MANIFEST_DETAIL_TEMP
            WHERE [MANIFEST_DETAIL_ID] = @MANIFEST_DETAIL_ID;
        END;

        -- ------------------------------------------------------------------------------------
        -- cada vez que asocio una ola al manifiesto valido si todas las olas asociadas ya fueron despachadas 
        -- y si todas fueron despachadas se marca como certificado el manifiesto
        -- ------------------------------------------------------------------------------------
        DECLARE @WAVES_BY_MANIFEST TABLE
        (
            [WAVE_PICKING_ID] INT
        );

        INSERT INTO @WAVES_BY_MANIFEST
        (
            [WAVE_PICKING_ID]
        )
        SELECT [WAVE_PICKING_ID]
        FROM [wms].[OP_WMS_MANIFEST_DETAIL]
        WHERE [MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
        GROUP BY [WAVE_PICKING_ID];

        DECLARE @DOCUMENTS_PICKING_BY_WAVE TABLE
        (
            [PICKING_DEMAND_HEADER_ID] INT
        );
        -- ------------------------------------------------------------------------------------
        -- obtengo e inserto todos los documentos asociados a las olas que a su vez ingrese al manifiesto de carga
        -- esto para contemplar el escenario de olas consolidadas
        -- ------------------------------------------------------------------------------------
        INSERT INTO @DOCUMENTS_PICKING_BY_WAVE
        (
            [PICKING_DEMAND_HEADER_ID]
        )
        SELECT [PDD].[PICKING_DEMAND_HEADER_ID]
        FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDD]
            INNER JOIN @WAVES_BY_MANIFEST [WM]
                ON [WM].[WAVE_PICKING_ID] = [PDD].[WAVE_PICKING_ID]
            INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL]
                ON [PDD].[WAVE_PICKING_ID] = [TL].[WAVE_PICKING_ID]
            INNER JOIN [wms].[OP_WMS_LICENSES] [L]
                ON (
                       [L].[LICENSE_ID] > 0
                       AND [TL].[WAVE_PICKING_ID] = [L].[WAVE_PICKING_ID]
                   )
        WHERE [TL].[IS_COMPLETED] = 1
              AND [TL].[DISPATCH_LICENSE_EXIT_COMPLETED] = 1
        GROUP BY [PDD].[PICKING_DEMAND_HEADER_ID];

        IF NOT EXISTS
        (
            SELECT TOP 1
                1 --[TL].[WAVE_PICKING_ID] 
            FROM [wms].[OP_WMS_TASK_LIST] [TL]
                INNER JOIN [wms].[OP_WMS_LICENSES] [L]
                    ON (
                           [L].[LICENSE_ID] > 0
                           AND [TL].[WAVE_PICKING_ID] = [L].[WAVE_PICKING_ID]
                       )
                INNER JOIN @WAVES_BY_MANIFEST [WM]
                    ON [WM].[WAVE_PICKING_ID] = [TL].[WAVE_PICKING_ID]
                       AND [TL].[IS_COMPLETED] = 1
                       AND [TL].[DISPATCH_LICENSE_EXIT_COMPLETED] = 0
            GROUP BY [TL].[WAVE_PICKING_ID]
        )
        BEGIN
            -- ------------------------------------------------------------------------------------
            -- si todas las olas ya fueron despachadas y todos los documentos de la ola pertenecen al manifiesto marcamos el manifiesto como CERTIFICADO
            -- ------------------------------------------------------------------------------------

            IF
            (
                SELECT COUNT(1) FROM @DOCUMENTS_PICKING_BY_WAVE
            ) =
            (
                SELECT COUNT(1)
                FROM [wms].[OP_WMS_MANIFEST_DETAIL]
                WHERE [MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
            )
            BEGIN
                UPDATE [wms].[OP_WMS_MANIFEST_HEADER]
                SET [STATUS] = 'CERTIFIED'
                WHERE [MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID;

            END;
        END;

        --
        RESULT:
        SELECT 1 AS [Resultado],
               'Proceso Exitoso' [Mensaje],
               0 [Codigo],
               '0' [DbData];


    END TRY
    BEGIN CATCH
        SELECT -1 AS [Resultado],
               CASE CAST(@@ERROR AS VARCHAR)
                   WHEN '547' THEN
                       'Error al agregar el detalle al manifiesto de carga, no existe el ID del manifiesto'
                   ELSE
                       ERROR_MESSAGE()
               END [Mensaje],
               @@ERROR [Codigo];
    END CATCH;


END;