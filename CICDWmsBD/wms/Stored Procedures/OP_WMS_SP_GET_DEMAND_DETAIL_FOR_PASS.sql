-- =============================================
-- Autor:	rudi.garcia
-- Fecha de Creacion: 	24-Nov-2017 @ Team Reborn - Sprint Nach
-- Description:	 Sp que obtiene los detalles de las demandas.

/*
-- Ejemplo de Ejecucion:
EXEC [wms].[OP_WMS_SP_GET_DEMAND_DETAIL_FOR_PASS1] @PICKING_DEMAND_HEADER_ID = '107725', @DEMAND_TYPE = 'VENTA'
                                     

			SELECT * FROM [wms].[OP_WMS_TASK]
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_GET_DEMAND_DETAIL_FOR_PASS]
(
    @PICKING_DEMAND_HEADER_ID VARCHAR(MAX),
    @DEMAND_TYPE VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;
    --

    DECLARE @OP_WMS_PASS_DETAIL TABLE
    (
        [PICKING_DEMAND_HEADER_ID] INT,
        [WAVE_PICKING_ID] INT,
        [DOC_NUM] VARCHAR(50),
        [MATERIAL_ID] VARCHAR(50),
        [QTY] NUMERIC(18, 4),
        [LINE_NUM] INT
    );

    IF (@DEMAND_TYPE = 'GENERAL_DISPATCH')
    BEGIN
        INSERT INTO @OP_WMS_PASS_DETAIL
        (
            [PICKING_DEMAND_HEADER_ID],
            [WAVE_PICKING_ID],
            [DOC_NUM],
            [MATERIAL_ID],
            [QTY]
        )
        SELECT [PD].[PICKING_DEMAND_HEADER_ID],
               [PD].[WAVE_PICKING_ID],
               [PD].[DOC_NUM],
               [PD].[MATERIAL_ID],
               SUM([PD].[QTY]) [QTY]
        FROM [wms].[OP_WMS3PL_PASSES] [PH]
            INNER JOIN [wms].[OP_WMS_PASS_DETAIL] [PD]
                ON ([PH].[PASS_ID] = [PD].[PASS_HEADER_ID])
        WHERE [PH].[STATUS] <> 'CANCELED'
        GROUP BY [PD].[PICKING_DEMAND_HEADER_ID],
                 [PD].[WAVE_PICKING_ID],
                 [PD].[DOC_NUM],
                 [PD].[MATERIAL_ID];



        DECLARE @TASK_LIST TABLE
        (
            [CLIENT_CODE] VARCHAR(25),
            [CLIENT_NAME] VARCHAR(150),
            [WAVE_PICKING_ID] INT,
            [DOC_NUM] VARCHAR(50),
            [CREATED_DATE] DATETIME,
            [CODE_WAREHOUSE] VARCHAR(25),
            [MATERIAL_ID] VARCHAR(50),
            [MATERIAL_NAME] VARCHAR(200),
            [QTY] NUMERIC(18, 4)
        );

        DECLARE @TASK_LIST_TEMP TABLE
        (
            [WAVE_PICKING_ID] INT,
            [MATERIAL_ID] VARCHAR(50)
        );

        INSERT INTO @TASK_LIST_TEMP
        (
            [WAVE_PICKING_ID],
            [MATERIAL_ID]
        )
        SELECT [TL].[WAVE_PICKING_ID],
               [TL].[MATERIAL_ID]
        FROM [wms].[OP_WMS_TASK_LIST] [TL]
            INNER JOIN [wms].[OP_WMS_FN_SPLIT](@PICKING_DEMAND_HEADER_ID, '|') [PHID]
                ON ([PHID].[VALUE] = [TL].[WAVE_PICKING_ID])
        GROUP BY [TL].[WAVE_PICKING_ID],
                 [TL].[MATERIAL_ID]
        HAVING MIN([TL].[IS_COMPLETED]) = 1;


        INSERT INTO @TASK_LIST
        (
            [CLIENT_CODE],
            [CLIENT_NAME],
            [WAVE_PICKING_ID],
            [DOC_NUM],
            [CREATED_DATE],
            [CODE_WAREHOUSE],
            [MATERIAL_ID],
            [MATERIAL_NAME],
            [QTY]
        )
        SELECT DISTINCT
               [TL].[CLIENT_OWNER] AS [CLIENT_CODE],
               [TL].[CLIENT_NAME] AS [CLIENT_NAME],
               [TL].[WAVE_PICKING_ID],
               MAX([PH].[DOC_ID]) AS [DOC_NUM],
               MAX([TL].[ASSIGNED_DATE]) AS [CREATED_DATE],
               [L].[CURRENT_WAREHOUSE] [CODE_WAREHOUSE],
               [TL].[MATERIAL_ID],
               [TL].[MATERIAL_NAME],
               SUM([TL].[QUANTITY_ASSIGNED] - [TL].[QUANTITY_PENDING]) [QTY]
        FROM [wms].[OP_WMS_TASK_LIST] [TL]
            INNER JOIN @TASK_LIST_TEMP [TLT]
                ON (
                       [TLT].[WAVE_PICKING_ID] = [TL].[WAVE_PICKING_ID]
                       AND [TLT].[MATERIAL_ID] = [TL].[MATERIAL_ID]
                   )
            --      INNER JOIN [wms].[OP_WMS_FN_SPLIT](@PICKING_DEMAND_HEADER_ID, '|') [PHID] ON (
            --        [PHID].[VALUE] = [TL].[WAVE_PICKING_ID]
            --      )
            INNER JOIN [wms].[OP_WMS_LICENSES] [L]
                ON ([L].[LICENSE_ID] = [TL].[LICENSE_ID_SOURCE])
            INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH]
                ON ([PH].[CODIGO_POLIZA] = [TL].[CODIGO_POLIZA_TARGET])
            LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
                ON ([PDH].[WAVE_PICKING_ID] = [TL].[WAVE_PICKING_ID])
        WHERE [TL].[IS_COMPLETED] = 1
			  AND [TL].[IS_CANCELED] <> 1
              AND [TL].[QUANTITY_PENDING] <> [TL].[QUANTITY_ASSIGNED]
              AND [TL].[TASK_TYPE] = 'TAREA_PICKING'
              AND [PDH].[PICKING_DEMAND_HEADER_ID] IS NULL
        GROUP BY [TL].[CLIENT_OWNER],
                 [TL].[CLIENT_NAME],
                 [TL].[WAVE_PICKING_ID],
                 [TL].[MATERIAL_ID],
                 [TL].[MATERIAL_NAME],
                 [L].[CURRENT_WAREHOUSE]
        HAVING MIN([TL].[IS_COMPLETED]) = 1;

        SELECT [TL].[MATERIAL_ID],
               [TL].[MATERIAL_NAME],
               ([TL].[QTY] - ISNULL([PD].[QTY], 0)) AS [QTY],
               ([TL].[QTY] - ISNULL([PD].[QTY], 0)) AS [QTY_AVAILABLE],
               [TL].[CLIENT_CODE],
               [TL].[CLIENT_NAME],
               [TL].[CREATED_DATE],
               [TL].[WAVE_PICKING_ID],
               [TL].[DOC_NUM],
               NULL AS [TYPE_DEMAND_CODE],
               '' AS [TYPE_DEMAND_NAME],
               0 AS [PICKING_DEMAND_HEADER_ID],
               [TL].[CODE_WAREHOUSE]
        FROM @TASK_LIST [TL] --    INNER JOIN [wms].[OP_WMS_FN_SPLIT](@PICKING_DEMAND_HEADER_ID, '|') [PHID]
            --      ON (
            --      [PHID].[VALUE] = [TL].[WAVE_PICKING_ID]
            --      )
            LEFT JOIN @OP_WMS_PASS_DETAIL [PD]
                ON (
                       [PD].[WAVE_PICKING_ID] = [TL].[WAVE_PICKING_ID]
                       AND [PD].[MATERIAL_ID] = [TL].[MATERIAL_ID]
                   )
        WHERE (
                  [PD].[MATERIAL_ID] IS NULL
                  OR [PD].[MATERIAL_ID] = [TL].[MATERIAL_ID]
              )
              AND ([TL].[QTY] - ISNULL([PD].[QTY], 0)) > 0;
    END;
    ELSE
    BEGIN
        INSERT INTO @OP_WMS_PASS_DETAIL
        (
            [PICKING_DEMAND_HEADER_ID],
            [MATERIAL_ID],
            [QTY],
            [LINE_NUM]
        )
        SELECT [PD].[PICKING_DEMAND_HEADER_ID],
               [PD].[MATERIAL_ID],
               SUM([PD].[QTY]) [QTY],
               [PD].[LINE_NUM]
        FROM [wms].[OP_WMS3PL_PASSES] [PH]
            INNER JOIN [wms].[OP_WMS_PASS_DETAIL] [PD]
                ON ([PH].[PASS_ID] = [PD].[PASS_HEADER_ID])
            INNER JOIN [wms].[OP_WMS_FN_SPLIT](@PICKING_DEMAND_HEADER_ID, '|') [PHID]
                ON ([PHID].[VALUE] = [PD].[PICKING_DEMAND_HEADER_ID])
        WHERE [PH].[STATUS] <> 'CANCELED'
        GROUP BY [PD].[PICKING_DEMAND_HEADER_ID],
                 [PD].[MATERIAL_ID],
                 [PD].[LINE_NUM];


        SELECT distinct [PDD].[MATERIAL_ID],
               [M].[MATERIAL_NAME],
               ([PDD].[QTY] - ISNULL([PD].[QTY], 0)) AS [QTY],
               ([PDD].[QTY] - ISNULL([PD].[QTY], 0)) AS [QTY_AVAILABLE],
               [PDH].[CLIENT_CODE],
               [PDH].[CLIENT_NAME],
               [PDH].[CREATED_DATE],
               [PDH].[WAVE_PICKING_ID],
               [PDH].[DOC_NUM],
               [PDH].[TYPE_DEMAND_CODE],
               [PDH].[TYPE_DEMAND_NAME],
               [PDH].[PICKING_DEMAND_HEADER_ID],
               [PDH].[CODE_WAREHOUSE],
               [PDD].[LINE_NUM]
        FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
            INNER JOIN [wms].[OP_WMS_FN_SPLIT](@PICKING_DEMAND_HEADER_ID, '|') [PHID]
                ON ([PHID].[VALUE] = [PDH].[PICKING_DEMAND_HEADER_ID])
            INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD]
                ON ([PDD].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID])
            LEFT JOIN [wms].[OP_WMS_MATERIALS] [M]
                ON ([M].[MATERIAL_ID] = [PDD].[MATERIAL_ID])
			
            LEFT JOIN @OP_WMS_PASS_DETAIL [PD]
                ON (
                       [PDH].[PICKING_DEMAND_HEADER_ID] = [PD].[PICKING_DEMAND_HEADER_ID]
                       AND [PDD].[MATERIAL_ID] = [PD].[MATERIAL_ID]
                       AND [PDD].[LINE_NUM] = [PD].[LINE_NUM]
                   )
			INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL] 
				ON (
						[PDH].[WAVE_PICKING_ID] = [TL].[WAVE_PICKING_ID]
						)
        WHERE (
                  [PD].[MATERIAL_ID] IS NULL
                  OR ([PD].[MATERIAL_ID] = [PDD].[MATERIAL_ID]
				  AND [PD].[MATERIAL_ID] = [TL].[MATERIAL_ID])
              )
              AND ([PDD].[QTY] - ISNULL([PD].[QTY], 0)) > 0
			  AND [TL].[IS_COMPLETED] = 1
			  
		
    END;
END;