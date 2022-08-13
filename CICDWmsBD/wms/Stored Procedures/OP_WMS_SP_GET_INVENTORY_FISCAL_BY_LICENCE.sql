-- =============================================
-- Autor:    rudi.garcia
-- Fecha de Creacion:     2017-04-12 @ Team ERGON - Sprint ERGON EPONA
-- Description:     Sp que obtiene el inventario fiscal por licencia.

-- Autor:		henry.rodriguez
-- Fecha:		26-Diciembre-2019 G-Force@Napoles-Swift
-- Description: Se modifica query para obtener los materiales de la poliza,
--				encabezado y detalle.

-- Autor:		fabrizio.delcompare
-- Fecha:		21-mayo-2020
-- Description: Cambio menor en el query que no funcionaba en polizas viejas

/*
-- Ejemplo de Ejecucion:
            EXEC [wms].[OP_WMS_SP_GET_INVENTORY_FISCAL_BY_LICENCE] 
       @DOC_ID  = 122274
      ,@LINENO_POLIZA = 1
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INVENTORY_FISCAL_BY_LICENCE]
(
	@DOC_ID INT = NULL
	,@LINENO_POLIZA INT = NULL
)
AS
BEGIN

    DECLARE @POLIZA TABLE
    (
        [DOC_ID] NUMERIC,
        [CODIGO_POLIZA] VARCHAR(25),
        [LICENSE_ID] INT,
        [MATERIAL_ID] VARCHAR(50)
    );

    INSERT INTO @POLIZA
    (
        [DOC_ID],
        [CODIGO_POLIZA],
        [LICENSE_ID],
        [MATERIAL_ID]
    )
    SELECT DISTINCT
           [PH].[DOC_ID],
           [PH].[CODIGO_POLIZA],
           [T].[LICENSE_ID],
           [T].[MATERIAL_CODE]
    FROM [wms].[OP_WMS_POLIZA_HEADER] [PH]
        INNER JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PD]
            ON ([PD].[DOC_ID] = [PH].[DOC_ID])
        INNER JOIN [wms].[OP_WMS_TRANS] [T]
            ON (
                   [T].[CODIGO_POLIZA] = [PD].[CODIGO_POLIZA_ORIGEN]
                   AND [T].[STATUS] = 'PROCESSED'
               )
    WHERE [PH].[DOC_ID] = @DOC_ID
          AND [PD].[ORIGIN_LINE_NUMBER] = @LINENO_POLIZA
          AND [PH].[WAREHOUSE_REGIMEN] = 'FISCAL'
          AND ([T].[TRANS_SUBTYPE] = 'INGRESO_FISCAL' OR [T].[TRANS_SUBTYPE] = '')
          AND [T].[LICENSE_ID] IS NOT NULL
          AND [PD].MATERIAL_ID = [T].MATERIAL_CODE


    INSERT INTO @POLIZA
    (
        [DOC_ID],
        [CODIGO_POLIZA],
        [LICENSE_ID],
        [MATERIAL_ID]
    )
    SELECT [PH].[DOC_ID],
           [PH].[CODIGO_POLIZA],
           [T].[LICENSE_ID],
           [PTM].[MATERIAL_CODE]
    FROM [wms].[OP_WMS_TRANS] [T]
        INNER JOIN [wms].[OP_WMS3PL_POLIZA_TRANS_MATCH] [PTM]
            ON (
                   [PTM].[LICENSE_ID] = [T].[ORIGINAL_LICENSE]
                   AND [PTM].[MATERIAL_CODE] = [T].[MATERIAL_CODE]
               )
        INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH]
            ON ([PH].[DOC_ID] = [PTM].[DOC_ID])
        INNER JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PD]
            ON (
                   [PD].[DOC_ID] = [PH].[DOC_ID]
                   AND [PD].[LINE_NUMBER] = [PTM].[LINENO_POLIZA]
               )
    WHERE [T].[STATUS] = 'PROCESSED'
          AND [PH].[DOC_ID] = @DOC_ID
          AND [PD].[LINE_NUMBER] = @LINENO_POLIZA;

    SELECT [P].[DOC_ID],
           [P].[CODIGO_POLIZA],
           @LINENO_POLIZA AS [LINENO_POLIZA],
           [IL].[LICENSE_ID],
           [IL].[MATERIAL_ID],
           [IL].[MATERIAL_NAME],
           [IL].[BARCODE_ID],
           [IL].[QTY] - ISNULL([CIL].[COMMITED_QTY], 0) AS [AVAILABLE],
           0 AS [QTY_TRANS],
           [IL].[BATCH],
           [IL].[DATE_EXPIRATION],
           [IL].[VIN]
    FROM @POLIZA [P]
        INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
            ON (
                   [IL].[LICENSE_ID] = [P].[LICENSE_ID]
                   AND [IL].[MATERIAL_ID] = [P].[MATERIAL_ID]
               )
        LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() AS [CIL]
            ON (
                   [IL].[LICENSE_ID] = [CIL].[LICENCE_ID]
                   AND [IL].[MATERIAL_ID] = [CIL].[MATERIAL_ID]
               )
    WHERE [IL].[QTY] > 0
    ORDER BY [IL].[DATE_EXPIRATION] ASC;
END;