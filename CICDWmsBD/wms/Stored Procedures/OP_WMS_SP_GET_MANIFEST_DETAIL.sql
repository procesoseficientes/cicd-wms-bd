-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/28/2017 @ NEXUS-Team Sprint CommandAndConquer 
-- Description:			Se obtiene el detalle del manifiesto de carga por su HEADER_ID

-- Modificacion 08-Sep-17 @ Nexus Team Sprint CommandAndConquer
-- alberto.ruiz
-- Se agrega campo de peso

-- Modificacion 9/20/2017 @ NEXUS-Team Sprint DuckHunt
-- rodrigo.gomez
-- Se agrega campo de direccion

-- Modificacion 21-Sep-17 @ Nexus Team Sprint CommandAndConquer
-- alberto.ruiz
-- Se agrega el doc num del ERP y estado

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-18 @ Team REBORN - Sprint 
-- Description:	   Se agrega [MANIFEST_HEADER_ID]

-- Modificacion 13-Nov-17 @ Nexus Team Sprint F-Zero
-- alberto.ruiz
-- Se agrega fecha en la que se termino la tarea

-- Modificacion 22-Nov-2017 @ Reborn Team Sprint Nach
-- alberto.ruiz
-- Se agregaron las siguientes columnas [TYPE_DEMAND_CODE], [TYPE_DEMAND_NAME]

-- Modificacion 12/8/2017 @ NEXUS-Team Sprint HeyYouPikachu!
-- rodrigo.gomez
-- Se devuelven campos de precios y descuentos

-- Modificacion:		henry.rodriguez
-- Fecha modificacion:	03-Diciembre-2017 GForce@Kioto
-- Descripcion:			Se agregan validaciones correspondientes para la devolucion de material

-- Modificacion:		Elder Lucas
-- Fecha modificacion:	7 de febrero 2022
-- Descripcion:			se agrega manejo de decimales

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_MANIFEST_DETAIL]
					@MANIFEST_HEADER_ID = 'MC-4'
				--
				EXEC [wms].[OP_WMS_SP_GET_MANIFEST_DETAIL]
					@MANIFEST_HEADER_ID = '1163'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MANIFEST_DETAIL]
(@MANIFEST_HEADER_ID VARCHAR(25))
AS
BEGIN
    SET NOCOUNT ON;
    --
    DECLARE @TASK TABLE
    (
        [MANIFEST_HEADER_ID] INT NOT NULL,
        [WAVE_PICKING_ID] INT NOT NULL,
        [COMPLETED_DATE] DATETIME,
        PRIMARY KEY (
                        [MANIFEST_HEADER_ID],
                        [WAVE_PICKING_ID]
                    )
    );
    --
    DECLARE @DOCUMENT_PREFIX VARCHAR(10);
    --
    SELECT @DOCUMENT_PREFIX = [VALUE]
    FROM [wms].[OP_WMS_PARAMETER]
    WHERE [GROUP_ID] = 'PREFIX'
          AND [PARAMETER_ID] = 'CARGO_MANIFEST';

    -- ------------------------------------------------------------------------------------
    -- DECLARAMOS LA TABLA PARA ALMACENAR NUESTRO RESULTADO
    -- ------------------------------------------------------------------------------------

    DECLARE @TEM_RESULT TABLE
    (
        [MANIFEST_DETAIL_ID] INT,
        [MANIFEST_HEADER_ID] INT,
        [CODE_ROUTE] VARCHAR(50),
        [CLIENT_CODE] VARCHAR(50),
        [CLIENT_NAME] VARCHAR(100),
        [WAVE_PICKING_ID] INT,
        [MATERIAL_ID] VARCHAR(50),
        [MATERIAL_NAME] VARCHAR(200),
        [QTY] DECIMAL(18,5),
        [STATUS] VARCHAR(50),
        [LAST_UPDATE] DATETIME,
        [LAST_UPDATE_BY] VARCHAR(50),
        [DOCUMENT_DATE] DATETIME,
        [WEIGHT] DECIMAL,
        [ADDRESS_CUSTOMER] VARCHAR(150),
        [ERP_REFERENCE_DOC_NUM] VARCHAR(50),
        [STATE_CODE] INT,
        [PICKING_DEMAND_HEADER_ID] INT,
        [LINE_NUM] INT,
        [COMPLETED_DATE] DATETIME,
        [TOTAL_VOLUME] DECIMAL,
        [PRICE] NUMERIC,
        [LINE_DISCOUNT] NUMERIC,
        [LINE_DISCOUNT_TYPE] VARCHAR(50),
        [HEADER_DISCOUNT] NUMERIC,
        [TYPE_DEMAND_CODE] INT,
        [TYPE_DEMAND_NAME] VARCHAR(50),
		[STATUS_CODE] VARCHAR(50)
    );

    --
    IF ISNUMERIC(@MANIFEST_HEADER_ID) = 0
    BEGIN
        IF EXISTS
        (
            SELECT TOP 1
                   1
            WHERE @MANIFEST_HEADER_ID LIKE @DOCUMENT_PREFIX + '%'
        )
        BEGIN
            SELECT @MANIFEST_HEADER_ID = [VALUE]
            FROM [wms].[OP_WMS_FN_SPLIT](@MANIFEST_HEADER_ID, '-')
            ORDER BY [ID] ASC;
        END;
        ELSE
        BEGIN
            RAISERROR('Id de documento invalido.', 16, 1);
            RETURN;
        END;
    END;

    -- ------------------------------------------------------------------------------------
    -- Obtiene la fecha de completado de las olas de picking
    -- ------------------------------------------------------------------------------------
    INSERT INTO @TASK
    (
        [MANIFEST_HEADER_ID],
        [WAVE_PICKING_ID],
        [COMPLETED_DATE]
    )
    SELECT [MD].[MANIFEST_HEADER_ID],
           [MD].[WAVE_PICKING_ID],
           MAX([T].[COMPLETED_DATE]) [COMPLETED_DATE]
    FROM [wms].[OP_WMS_MANIFEST_DETAIL] [MD]
        INNER JOIN [wms].[OP_WMS_TASK_LIST] [T]
            ON ([T].[WAVE_PICKING_ID] = [MD].[WAVE_PICKING_ID])
    WHERE [MD].[MANIFEST_DETAIL_ID] > 0
          AND [MD].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
    GROUP BY [MD].[MANIFEST_HEADER_ID],
             [MD].[WAVE_PICKING_ID];

    -- ------------------------------------------------------------------------------------
    -- Muestra el resultado final
    -- ------------------------------------------------------------------------------------

    IF (EXISTS
    (
        SELECT TOP 1
               1
        FROM [wms].[OP_WMS_MANIFEST_DETAIL] [MD]
            INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
                ON (
                       [PDH].[PICKING_DEMAND_HEADER_ID] = [MD].[PICKING_DEMAND_HEADER_ID]
                       AND [PDH].[CLIENT_CODE] = [MD].[CLIENT_CODE]
                       AND [PDH].[ADDRESS_CUSTOMER] = [MD].[ADDRESS_CUSTOMER]
                       AND [PDH].[WAVE_PICKING_ID] = [MD].[WAVE_PICKING_ID]
                   )
            INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD]
                ON (
                       [PDD].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
                       AND [PDD].[MATERIAL_ID] = [MD].[MATERIAL_ID]
                   )
    )
       )
    BEGIN

        INSERT INTO @TEM_RESULT
        (
            [MANIFEST_DETAIL_ID],
            [MANIFEST_HEADER_ID],
            [CODE_ROUTE],
            [CLIENT_CODE],
            [CLIENT_NAME],
            [WAVE_PICKING_ID],
            [MATERIAL_ID],
            [MATERIAL_NAME],
            [QTY],
            [STATUS],
            [LAST_UPDATE],
            [LAST_UPDATE_BY],
            [DOCUMENT_DATE],
            [WEIGHT],
            [ADDRESS_CUSTOMER],
            [ERP_REFERENCE_DOC_NUM],
            [STATE_CODE],
            [PICKING_DEMAND_HEADER_ID],
            [LINE_NUM],
            [COMPLETED_DATE],
            [TOTAL_VOLUME],
            [PRICE],
            [LINE_DISCOUNT],
            [LINE_DISCOUNT_TYPE],
            [HEADER_DISCOUNT],
            [TYPE_DEMAND_CODE],
            [TYPE_DEMAND_NAME],
			[STATUS_CODE]
        )
        SELECT [MD].[MANIFEST_DETAIL_ID],
               [MD].[MANIFEST_HEADER_ID],
               [MD].[CODE_ROUTE],
               [DH].[CLIENT_CODE],
               [DH].[CLIENT_NAME],
               [MD].[WAVE_PICKING_ID],
               [MD].[MATERIAL_ID],
               [MT].[MATERIAL_NAME],
               [MD].[QTY] [QTY],
               [MD].[STATUS],
               [MD].[LAST_UPDATE],
               [MD].[LAST_UPDATE_BY],
               [MH].[CREATED_DATE] [DOCUMENT_DATE],
               [wms].[OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT](
                                                                                 ISNULL(
                                                                                           (([MT].[WEIGTH])
                                                                                            * ([DD].[QTY])
                                                                                           ),
                                                                                           0
                                                                                       ),
                                                                                 [MT].[WEIGHT_MEASUREMENT]
                                                                             ) AS [WEIGHT],
               ISNULL([MD].[ADDRESS_CUSTOMER], '') [ADDRESS_CUSTOMER],
               [DD].[ERP_REFERENCE] [ERP_REFERENCE_DOC_NUM],
               [MD].[STATE_CODE],
               [MD].[PICKING_DEMAND_HEADER_ID],
               [MD].[LINE_NUM],
               [T].[COMPLETED_DATE],
               ([MT].[VOLUME_FACTOR] * [DD].[QTY]) [TOTAL_VOLUME],
               [MD].[PRICE],
               [MD].[LINE_DISCOUNT],
               [DD].[DISCOUNT_TYPE] [LINE_DISCOUNT_TYPE],
               [MD].[HEADER_DISCOUNT],
               [MD].[TYPE_DEMAND_CODE],
               [MD].[TYPE_DEMAND_NAME],
			   [MD].[STATUS_CODE]
        FROM [wms].[OP_WMS_MANIFEST_DETAIL] [MD]
            INNER JOIN @TASK [T]
                ON (
                       [T].[MANIFEST_HEADER_ID] = [MD].[MANIFEST_HEADER_ID]
                       AND [T].[WAVE_PICKING_ID] = [MD].[WAVE_PICKING_ID]
                   )
            INNER JOIN [wms].[OP_WMS_MATERIALS] [MT]
                ON ([MT].[MATERIAL_ID] = [MD].[MATERIAL_ID])
            INNER JOIN [wms].[OP_WMS_MANIFEST_HEADER] [MH]
                ON [MH].[MANIFEST_HEADER_ID] = [MD].[MANIFEST_HEADER_ID]
            LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH]
                ON (
                       [DH].[PICKING_DEMAND_HEADER_ID] = [MD].[PICKING_DEMAND_HEADER_ID]
                       AND [DH].[CLIENT_CODE] = [MD].[CLIENT_CODE]
                   )
            LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD]
                ON (
                       [DD].[PICKING_DEMAND_HEADER_ID] = [DH].[PICKING_DEMAND_HEADER_ID]
                       AND [DD].[MATERIAL_ID] = [MT].[MATERIAL_ID]
                       AND [DD].[LINE_NUM] = [MD].[LINE_NUM]
                   )
        WHERE [MH].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID;

    END;
    ELSE
    BEGIN
        INSERT INTO @TEM_RESULT
        (
            [MANIFEST_DETAIL_ID],
            [MANIFEST_HEADER_ID],
            [CODE_ROUTE],
            [CLIENT_CODE],
            [CLIENT_NAME],
            [WAVE_PICKING_ID],
            [MATERIAL_ID],
            [MATERIAL_NAME],
            [QTY],
            [STATUS],
            [LAST_UPDATE],
            [LAST_UPDATE_BY],
            [DOCUMENT_DATE],
            [WEIGHT],
            [ADDRESS_CUSTOMER],
            [ERP_REFERENCE_DOC_NUM],
            [STATE_CODE],
            [PICKING_DEMAND_HEADER_ID],
            [LINE_NUM],
            [COMPLETED_DATE],
            [TOTAL_VOLUME],
            [PRICE],
            [LINE_DISCOUNT],
            [LINE_DISCOUNT_TYPE],
            [HEADER_DISCOUNT],
            [TYPE_DEMAND_CODE],
            [TYPE_DEMAND_NAME],
			[STATUS_CODE]
        )
        SELECT [MD].[MANIFEST_DETAIL_ID],
               [MD].[MANIFEST_HEADER_ID],
               [MD].[CODE_ROUTE],
               [DH].[CLIENT_CODE],
               [DH].[CLIENT_NAME],
               [MD].[WAVE_PICKING_ID],
               [MD].[MATERIAL_ID],
               [MT].[MATERIAL_NAME],
               [MD].[QTY] [QTY],
               [MD].[STATUS],
               [MD].[LAST_UPDATE],
               [MD].[LAST_UPDATE_BY],
               [MH].[CREATED_DATE] [DOCUMENT_DATE],
               [wms].[OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT](
                                                                                 ISNULL(
                                                                                           (([MT].[WEIGTH])
                                                                                            * ([DD].[QTY])
                                                                                           ),
                                                                                           0
                                                                                       ),
                                                                                 [MT].[WEIGHT_MEASUREMENT]
                                                                             ) AS [WEIGHT],
               ISNULL([MD].[ADDRESS_CUSTOMER], '') [ADDRESS_CUSTOMER],
               [DD].[ERP_REFERENCE] [ERP_REFERENCE_DOC_NUM],
               [MD].[STATE_CODE],
               [MD].[PICKING_DEMAND_HEADER_ID],
               [MD].[LINE_NUM],
               [T].[COMPLETED_DATE],
               ([MT].[VOLUME_FACTOR] * [DD].[QTY]) AS [TOTAL_VOLUME],
               [MD].[PRICE],
               [MD].[LINE_DISCOUNT],
               [DD].[DISCOUNT_TYPE] [LINE_DISCOUNT_TYPE],
               [MD].[HEADER_DISCOUNT],
               [MD].[TYPE_DEMAND_CODE],
               [MD].[TYPE_DEMAND_NAME],
			   [MD].[STATUS_CODE]
        FROM [wms].[OP_WMS_MANIFEST_DETAIL] [MD]
            INNER JOIN @TASK [T]
                ON (
                       [T].[MANIFEST_HEADER_ID] = [MD].[MANIFEST_HEADER_ID]
                       AND [T].[WAVE_PICKING_ID] = [MD].[WAVE_PICKING_ID]
                   )
            INNER JOIN [wms].[OP_WMS_MATERIALS] [MT]
                ON ([MT].[MATERIAL_ID] = [MD].[MATERIAL_ID])
            INNER JOIN [wms].[OP_WMS_MANIFEST_HEADER] [MH]
                ON [MH].[MANIFEST_HEADER_ID] = [MD].[MANIFEST_HEADER_ID]
            LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH]
                ON (
                       [DH].[PICKING_DEMAND_HEADER_ID] = [MD].[PICKING_DEMAND_HEADER_ID]
                       AND [DH].[CLIENT_CODE] = [MD].[CLIENT_CODE]
                   )
            LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD]
                ON (
                       [DD].[PICKING_DEMAND_HEADER_ID] = [DH].[PICKING_DEMAND_HEADER_ID]
                       AND [DD].[MATERIAL_ID] = [MT].[MATERIAL_ID]
                       AND [DD].[LINE_NUM] = [MD].[LINE_NUM]
                   )
        WHERE [MH].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID;
    END;

    SELECT *
    FROM @TEM_RESULT;

END;