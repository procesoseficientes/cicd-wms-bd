-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-23 @ Team ERGON - Sprint ERGON III
-- Description:	 Consultar material 

-- Modificacion 6/25/2018 @ GFORCE-Team Sprint Elefante
					-- rodrigo.gomez
					-- Se puede buscar tambien por codigo de barras

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_MATERIAL_BY_BARCODE] @LICENCE_ID = 66724
                                                   ,@BARCODE_ID = 'LEC-DES-USA'

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MATERIAL_BY_BARCODE]
    (
     @LICENCE_ID INT
    ,@BARCODE_ID AS VARCHAR(25)
    )
AS
BEGIN
    SET NOCOUNT ON;
	--
    SELECT
        [M].[MATERIAL_ID]
       ,[M].[MATERIAL_NAME]
       ,[M].[SHORT_NAME]
       ,[M].[SERIAL_NUMBER_REQUESTS]
       ,[M].[BATCH_REQUESTED]
       ,[IL].[LICENSE_ID]
	   ,ISNULL([UMM].[MEASUREMENT_UNIT], 'Unidad Base') + ' 1x' + CAST(ISNULL([UMM].[QTY], 1) AS VARCHAR) [UNIT]
       ,ISNULL([UMM].[QTY], 1) [UNIT_QTY]
    FROM
        [wms].[OP_WMS_MATERIALS] [M]
    LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [UMM].[MATERIAL_ID] = [M].[MATERIAL_ID]
                                                              AND (
                                                              [UMM].[BARCODE] = @BARCODE_ID
                                                              OR [UMM].[ALTERNATIVE_BARCODE] = @BARCODE_ID
                                                              )
    LEFT JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON [IL].[LICENSE_ID] = @LICENCE_ID
                                                       AND [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
    WHERE
        (
         [M].[BARCODE_ID] = @BARCODE_ID
         OR [M].[ALTERNATE_BARCODE] = @BARCODE_ID
         OR [UMM].[BARCODE] = @BARCODE_ID
         OR [UMM].[ALTERNATIVE_BARCODE] = @BARCODE_ID
        )
    ORDER BY
        [IL].[LICENSE_ID] DESC;
END;