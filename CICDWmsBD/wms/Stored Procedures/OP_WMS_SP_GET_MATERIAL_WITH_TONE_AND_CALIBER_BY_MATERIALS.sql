
-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-12 @ Team REBORN - Sprint Collin
-- Description:	        Sp que trae los materiales, sus tonos y calibres

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_MATERIAL_WITH_TONE_AND_CALIBER_BY_MATERIALS] @MATERIAL_ID = 'arium/100089', @WAREHOUSE_ID ='BODEGA_01'
    
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MATERIAL_WITH_TONE_AND_CALIBER_BY_MATERIALS]
(
    @MATERIAL_ID VARCHAR(MAX),
    @WAREHOUSE_ID VARCHAR(25)
)
AS
BEGIN
    SET NOCOUNT ON;
    --

    DECLARE @DELIMITER CHAR(1) = '|';
    DECLARE @MATERIAL TABLE
    (
        [MATERIAL_ID] VARCHAR(50)
    );


    INSERT INTO @MATERIAL
    (
        [MATERIAL_ID]
    )
    SELECT DISTINCT
           [M].[VALUE]
    FROM [wms].[OP_WMS_FUNC_SPLIT_3](@MATERIAL_ID, @DELIMITER) [M]
        INNER JOIN [wms].[OP_WMS_MATERIALS] [M2]
            ON ([M2].[MATERIAL_ID] = [M].[VALUE])
    WHERE [M2].[HANDLE_TONE] = 1
          OR [M2].[HANDLE_CALIBER] = 1;

    DECLARE @MATERIAL_PICKING TABLE
    (
        [MATERIAL_ID] VARCHAR(50),
        [QTY_PICKED] NUMERIC(18, 4),
        [TONE] VARCHAR(20),
        [CALIBER] VARCHAR(20)
    );

    INSERT INTO @MATERIAL_PICKING
    (
        [MATERIAL_ID],
        [QTY_PICKED],
        [TONE],
        [CALIBER]
    )
    SELECT [M].[MATERIAL_ID],
           ISNULL(SUM([TL].[QUANTITY_ASSIGNED]) - SUM([TL].[QUANTITY_PENDING]), 0) AS [QTY_PICKED],
           [TL].[TONE],
           [TL].[CALIBER]
    FROM @MATERIAL [M]
        INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL]
            ON ([TL].[MATERIAL_ID] = [M].[MATERIAL_ID])
    WHERE [TL].[CANCELED_DATETIME] IS NULL
          AND [TL].[TONE] IS NOT NULL
          OR [TL].[CALIBER] IS NOT NULL
    GROUP BY [M].[MATERIAL_ID],
             [TL].[TONE],
             [TL].[CALIBER];


    SELECT [M].[MATERIAL_ID],
           [TCM].[TONE],
           [TCM].[CALIBER],
           ISNULL(SUM(   CASE
                             WHEN [IXL].[LOCKED_BY_INTERFACES] = 1 THEN
                                 0
                             WHEN [S].[BLOCKS_INVENTORY] = 1 THEN
                                 0
                             ELSE
                                 [IXL].[QTY]
                         END
                     ) - ISNULL(SUM([CIL].[COMMITED_QTY]), 0),
                  0
                 ) [QTY],
           ISNULL(SUM(   CASE
                             WHEN [IXL].[LOCKED_BY_INTERFACES] = 1 THEN
                                 0
                             WHEN [S].[BLOCKS_INVENTORY] = 1 THEN
                                 0
                             ELSE
                                 [IXL].[QTY]
                         END
                     ) - ISNULL(SUM([CIL].[COMMITED_QTY]), 0),
                  0
                 ) [QTY_AVAILABLE],
           ISNULL(MAX([MP].[QTY_PICKED]), 0) [QTY_PICKED],
           0.0000 [QTY_ORDER]
    FROM @MATERIAL [M]
        LEFT JOIN [wms].[OP_WMS_INV_X_LICENSE] [IXL]
            ON ([IXL].[MATERIAL_ID] = [M].[MATERIAL_ID])
        LEFT JOIN [wms].[OP_WMS_LICENSES] [L]
            ON ([IXL].[LICENSE_ID] = [L].[LICENSE_ID])
        LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM]
            ON ([IXL].[TONE_AND_CALIBER_ID] = [TCM].[TONE_AND_CALIBER_ID])
        LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CIL]
            ON (
                   [IXL].[LICENSE_ID] = [CIL].[LICENCE_ID]
                   AND [IXL].[MATERIAL_ID] = [CIL].[MATERIAL_ID]
               )
        LEFT JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [S]
            ON ([IXL].[STATUS_ID] = [S].[STATUS_ID])
        LEFT JOIN @MATERIAL_PICKING [MP]
            ON (
                   [MP].[MATERIAL_ID] = [IXL].[MATERIAL_ID]
                   AND [TCM].[TONE] = [MP].[TONE]
                   AND [TCM].[CALIBER] = [MP].[CALIBER]
               )
    WHERE (
              [L].[CURRENT_WAREHOUSE] IS NULL
              OR [L].[CURRENT_WAREHOUSE] = @WAREHOUSE_ID
          )
          AND [IXL].[QTY] > 0
    GROUP BY [M].[MATERIAL_ID],
             [TCM].[TONE],
             [TCM].[CALIBER]
    --HAVING (COUNT([M].[MATERIAL_ID]) > 0 AND ([TCM].[TONE] IS NOT NULL OR [TCM].[CALIBER] IS NOT NULL)) OR (COUNT([M].[MATERIAL_ID]) = 1 AND ([TCM].[TONE] IS NULL OR [TCM].[CALIBER] IS NULL))
    HAVING ISNULL(SUM(   CASE
                             WHEN [IXL].[LOCKED_BY_INTERFACES] = 1 THEN
                                 0
                             WHEN [S].[BLOCKS_INVENTORY] = 1 THEN
                                 0
                             ELSE
                                 [IXL].[QTY]
                         END
                     ) - ISNULL(SUM([CIL].[COMMITED_QTY]), 0),
                  0
                 ) > 0
    ORDER BY [M].[MATERIAL_ID] DESC;


END;