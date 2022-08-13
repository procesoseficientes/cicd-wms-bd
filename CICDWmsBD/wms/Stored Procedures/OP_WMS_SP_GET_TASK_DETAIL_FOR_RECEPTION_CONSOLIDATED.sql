-- =============================================
-- Autor:                 marvin.solares
-- Fecha de Creacion:   20180723 GForce@FocaMonje
-- Description:          SP que obtiene el detalle de las recepciones desde una tarea, aplicado para varios documentos consolidados por tarea.

-- Autor:               henry.rodriguez
-- Fecha de Creacion:   12-Diciembre-2019 GForce@Kioto
-- Description:         Se agrega validacion de regimen fiscal para obtener la cantidad de material recepcionada de la poliza
/*|
-- Ejemplo de Ejecucion:
        EXEC [wms].[OP_WMS_SP_GET_TASK_DETAIL_FOR_RECEPTION_CONSOLIDATED]
          @SERIAL_NUMBER = 557967
		  SELECT * FROM [wms].OP_WMS_TASK_LIST
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TASK_DETAIL_FOR_RECEPTION_CONSOLIDATED] (@SERIAL_NUMBER INT)
AS
DECLARE @REGIME AS VARCHAR(50) = 'GENERAL';

SELECT @REGIME = [REGIMEN]
FROM [wms].[OP_WMS_TASK_LIST]
WHERE [SERIAL_NUMBER] = @SERIAL_NUMBER;

IF NOT EXISTS
(
    SELECT TOP 1
        1
    FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
    WHERE [TASK_ID] = @SERIAL_NUMBER
)
BEGIN

    -- ------------------------------------------------------------------------------------
    -- VALIDAMOS EL REGIMEN POR EL SERIA NUMBER
    -- ------------------------------------------------------------------------------------
    IF (@REGIME = 'FISCAL')
    BEGIN

        -- ------------------------------------------------------------------------------------
        -- OBTENEMOS EL MATERIA QUE SE YA SE RECEPCIONO
        -- ------------------------------------------------------------------------------------
        SELECT [IL].[MATERIAL_ID],
               [IL].[MATERIAL_NAME],
               SUM([IL].[QTY]) [QTY],
               0 AS [QTY_DOC],
               0 AS [QTY_DIFFERENCE],
               [TL].[TASK_COMMENTS],
               [TL].[SERIAL_NUMBER],
               [TL].[CODIGO_POLIZA_TARGET],
               [TL].[CODIGO_POLIZA_SOURCE]
        FROM [wms].[OP_WMS_POLIZA_HEADER] [PH]
            INNER JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PD]
                ON ([PD].[DOC_ID] = [PH].[DOC_ID])
            INNER JOIN [wms].[OP_WMS_TRANS] [TR]
                ON (
                       [TR].[CODIGO_POLIZA] = [PH].[CODIGO_POLIZA]
                       AND [TR].[MATERIAL_CODE] = [PD].[MATERIAL_ID]
                   )
            INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
                ON (
                       [IL].[LICENSE_ID] = [TR].[LICENSE_ID]
                       AND [IL].[MATERIAL_ID] = [TR].[MATERIAL_CODE]
                   )
            INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL]
                ON ([TL].[SERIAL_NUMBER] = [TR].[TASK_ID])
        WHERE [TL].[SERIAL_NUMBER] = @SERIAL_NUMBER
        GROUP BY [IL].[MATERIAL_ID],
                 [IL].[MATERIAL_NAME],
                 [TL].[TASK_COMMENTS],
                 [TL].[SERIAL_NUMBER],
                 [TL].[CODIGO_POLIZA_TARGET],
                 [TL].[CODIGO_POLIZA_SOURCE];

    END;
    ELSE
    BEGIN

        SELECT [TR].[MATERIAL_CODE] [MATERIAL_ID],
               [TR].[MATERIAL_DESCRIPTION] [MATERIAL_NAME],
               SUM([TR].[QUANTITY_UNITS]) AS [QTY],
               0 AS [QTY_DOC],
               0 AS [QTY_DIFFERENCE],
               MAX([T].[TASK_COMMENTS]) AS [TASK_COMMENTS],
               [TR].[MATERIAL_BARCODE] [BARCODE_ID],
               MAX([T].[SERIAL_NUMBER]) AS [SERIAL_NUMBER],
               MAX([T].[CODIGO_POLIZA_TARGET]) AS [CODIGO_POLIZA_TARGET],
               MAX([T].[CODIGO_POLIZA_SOURCE]) AS [CODIGO_POLIZA_SOURCE]
        FROM [wms].[OP_WMS_TASK_LIST] [T]
            INNER JOIN [wms].[OP_WMS_TRANS] [TR]
                ON [TR].[TASK_ID] = [T].[SERIAL_NUMBER]
                   AND [TR].[STATUS] = 'PROCESSED'
                   AND [TR].[TRANS_TYPE] = 'INGRESO_GENERAL'
        WHERE [T].[SERIAL_NUMBER] = @SERIAL_NUMBER
        GROUP BY [TR].[MATERIAL_CODE],
                 [TR].[MATERIAL_DESCRIPTION],
                 [TR].[MATERIAL_BARCODE];

    END;

END;
ELSE
BEGIN
    DECLARE @RESULT AS TABLE
    (
        [MATERIAL_ID] VARCHAR(50),
        [MATERIAL_NAME] VARCHAR(200),
        [QTY] NUMERIC(18, 4),
        [QTY_DOC] NUMERIC(18, 4),
        [QTY_DIFFERENCE] NUMERIC(18, 4),
        [TASK_COMMENTS] VARCHAR(50),
        [BARCODE_ID] VARCHAR(25),
        [SERIAL_NUMBER] INT,
        [CODIGO_POLIZA_TARGET] VARCHAR(25),
        [CODIGO_POLIZA_SOURCE] VARCHAR(25),
        [UNIT] VARCHAR(100)
    );

    DECLARE @CODIGO_POLIZA VARCHAR(25);

    SELECT TOP 1
        @CODIGO_POLIZA = [DOC_ID_POLIZA]
    FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
    WHERE [TASK_ID] = @SERIAL_NUMBER;

    SELECT [RDD].[MATERIAL_ID],
           SUM([RDD].[QTY] * ISNULL([UMM].[QTY], 1)) [QTY],
           MAX([RDH].[TASK_ID]) [SERIAL_NUMBER]
    INTO [#RECEPTION_DETAIL]
    FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
        INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RDD]
            ON [RDD].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
        LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM]
            ON [UMM].[MATERIAL_ID] = [RDD].[MATERIAL_ID]
               AND [RDD].[UNIT] = [UMM].[MEASUREMENT_UNIT]
    WHERE [RDH].[TASK_ID] = @SERIAL_NUMBER
    GROUP BY [RDD].[MATERIAL_ID];

    INSERT INTO @RESULT
    (
        [MATERIAL_ID],
        [MATERIAL_NAME],
        [QTY],
        [QTY_DOC],
        [QTY_DIFFERENCE],
        [TASK_COMMENTS],
        [BARCODE_ID],
        [SERIAL_NUMBER],
        [UNIT]
    )
    (SELECT [M].[MATERIAL_ID] AS [MATERIAL_ID],
            [M].[MATERIAL_NAME] AS [MATERIAL_NAME],
            SUM(ISNULL([TR].[QUANTITY_UNITS], 0)) AS [QTY],
            CAST(MAX([RDD].[QTY]) AS NUMERIC(18, 4)) AS [QTY_DOC],
            0 [QTY_DIFFERENCE],
            MAX(CAST([RDD].[SERIAL_NUMBER] AS VARCHAR)) AS [TASK_COMMENTS],
            [M].[BARCODE_ID] AS [BARCODE_ID],
            MAX([RDD].[SERIAL_NUMBER]) AS [SERIAL_NUMBER],
            'Unidad Base'
     FROM [#RECEPTION_DETAIL] [RDD]
         LEFT JOIN [wms].[OP_WMS_TRANS] [TR]
             ON [TR].[MATERIAL_CODE] = [RDD].[MATERIAL_ID]
                AND [TR].[TASK_ID] = [RDD].[SERIAL_NUMBER]
                AND [TR].[TRANS_TYPE] = 'INGRESO_GENERAL'
                AND [TR].[STATUS] = 'PROCESSED'
         INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
             ON [M].[MATERIAL_ID] = [RDD].[MATERIAL_ID]
     WHERE [RDD].[SERIAL_NUMBER] = @SERIAL_NUMBER
     GROUP BY [M].[MATERIAL_ID],
              [M].[MATERIAL_NAME],
              [M].[BARCODE_ID]
     UNION
     SELECT [M].[MATERIAL_ID] AS [MATERIAL_ID],
            [M].[MATERIAL_NAME] AS [MATERIAL_NAME],
            SUM(ISNULL([T].[QUANTITY_UNITS], 0)) AS [QTY],
            0 AS [QTY_DOC],
            0 [QTY_DIFFERENCE],
            CAST([T].[TASK_ID] AS VARCHAR) AS [TASK_COMMENTS],
            [M].[BARCODE_ID] AS [BARCODE_ID],
            [T].[TASK_ID] AS [SERIAL_NUMBER],
            'Unidad Base'
     FROM [wms].[OP_WMS_TRANS] [T]
         INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
             ON [T].[MATERIAL_CODE] = [M].[MATERIAL_ID]
         LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM]
             ON ([UMM].[MATERIAL_ID] = [T].[MATERIAL_CODE])
     WHERE [T].[TASK_ID] = @SERIAL_NUMBER
           AND [T].[TRANS_TYPE] = 'INGRESO_GENERAL'
           AND [T].[STATUS] = 'PROCESSED'
           AND [M].[MATERIAL_ID] NOT IN (
                                            SELECT DISTINCT [MATERIAL_ID] FROM [#RECEPTION_DETAIL]
                                        )
     GROUP BY CAST([T].[TASK_ID] AS VARCHAR),
              [M].[MATERIAL_ID],
              [M].[MATERIAL_NAME],
              [M].[BARCODE_ID],
              [T].[TASK_ID]);

    SELECT [MATERIAL_ID],
           MAX([MATERIAL_NAME]) AS [MATERIAL_NAME],
           MAX([QTY]) AS [QTY],
           SUM([QTY_DOC]) AS [QTY_DOC],
           CASE
               WHEN SUM([QTY_DOC]) - MAX([QTY]) = 0 THEN
                   0
               WHEN SUM([QTY_DOC]) - MAX([QTY]) > 0 THEN
           (SUM([QTY_DOC]) - MAX([QTY])) * -1
               WHEN SUM([QTY_DOC]) - MAX([QTY]) < 0 THEN
           (SUM([QTY_DOC]) - MAX([QTY])) * -1
               WHEN SUM([QTY_DOC]) IS NULL THEN
           (0 - SUM([QTY_DOC])) * -1
           END [QTY_DIFFERENCE],
           MAX([TASK_COMMENTS]) AS [TASK_COMMENTS],
           MAX([BARCODE_ID]) AS [BARCODE_ID],
           MAX([SERIAL_NUMBER]) AS [SERIAL_NUMBER],
           @CODIGO_POLIZA AS [CODIGO_POLIZA_SOURCE],
           @CODIGO_POLIZA AS [CODIGO_POLIZA_TARGET]
    FROM @RESULT
    GROUP BY [MATERIAL_ID];

END;