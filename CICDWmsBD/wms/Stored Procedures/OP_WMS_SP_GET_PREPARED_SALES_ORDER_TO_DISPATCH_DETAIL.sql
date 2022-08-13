-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	4/12/2018 @ GForce-Team Sprint Buho
-- Description:			Consulta en inventario las ordenes de venta preparadas por los filtros enviados

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_PREPARED_SALES_ORDER_TO_DISPATCH_DETAIL]
					@PICKING_DEMAND_HEADERS = ''
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_PREPARED_SALES_ORDER_TO_DISPATCH_DETAIL]
    (
     @PICKING_DEMAND_HEADERS VARCHAR(MAX)
    )
AS
BEGIN
    SET NOCOUNT ON;
	--
    DECLARE
        @DELIMITER CHAR(1) = '|'
       ,@PICKING_DEMAND_HEADER_ID INT = 0
       ,@SALES_ORDER_ID INT = 0;
	--
    DECLARE @PARTIAL_DEMANDS TABLE
        (
         [DOC_NUM] INT
        ,MATERIAL_ID VARCHAR(50)
        ,[QTY] DECIMAL(18, 4)
        );

	-- ------------------------------------------------------------------------------------
	-- Obtiene los encabezados para obtener su detalle
	-- ------------------------------------------------------------------------------------
    SELECT
        [PDH].[ID] [ORDER]
       ,CAST([PDH].[VALUE] AS INT) [PICKING_DEMAND_HEADER_ID]
    INTO
        [#PICKING]
    FROM
        [wms].[OP_WMS_FN_SPLIT](@PICKING_DEMAND_HEADERS, @DELIMITER) [PDH];
	--
	SELECT [ORDER]
			,[PICKING_DEMAND_HEADER_ID] 
	INTO [#TEMPORAL_PICKING]
	FROM [#PICKING]
	--
    WHILE EXISTS ( SELECT TOP 1
                    1
                   FROM
                    [#TEMPORAL_PICKING] )
    BEGIN
		-- ------------------------------------------------------------------------------------
		-- Obtiene las variables
		-- ------------------------------------------------------------------------------------
        SELECT TOP 1
            @PICKING_DEMAND_HEADER_ID = [PICKING_DEMAND_HEADER_ID]
        FROM
            [#TEMPORAL_PICKING];
		--
        SELECT
            @SALES_ORDER_ID = [DOC_NUM]
        FROM
            [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
        WHERE
            [PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
            AND [IS_FOR_DELIVERY_IMMEDIATE] = 0;
		
		-- ------------------------------------------------------------------------------------
		-- Obtiene los detalles ya procesados
		-- ------------------------------------------------------------------------------------
        INSERT  INTO @PARTIAL_DEMANDS
        SELECT
            [PDH].[DOC_NUM] [SALES_ORDER_ID]
           ,[PDD].[MATERIAL_ID]
           ,SUM([PDD].[QTY]) [QTY_PROCESSED]
        FROM
            [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
        INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD] ON [PDD].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
        WHERE
            [PDH].[DOC_NUM] = @SALES_ORDER_ID AND [PDH].[IS_FOR_DELIVERY_IMMEDIATE] = 1
        GROUP BY
            [PDH].[DOC_NUM]
           ,[PDD].[MATERIAL_ID];

		-- ------------------------------------------------------------------------------------
		-- Elimina el picking ya procesado
		-- ------------------------------------------------------------------------------------
		DELETE FROM [#TEMPORAL_PICKING] WHERE [PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
    END;
	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado final
	-- ------------------------------------------------------------------------------------
    SELECT DISTINCT
        [PDH].[DOC_NUM] [SALES_ORDER_ID]
       ,[PDD].[MATERIAL_ID] [SKU]
       ,[PDD].[LINE_NUM] [LINE_SEQ]
       ,[PDD].[QTY] - ISNULL([PD].[QTY], 0) QTY
       ,[PDD].[QTY] - ISNULL([PD].[QTY], 0) [QTY_PENDING]
       ,[PDD].[QTY] [QTY_ORIGINAL]
       ,[PDD].[PRICE]
       ,[PDD].[DISCOUNT]
       ,[PDD].[PRICE] * [PDD].[QTY] [TOTAL_LINE]
       ,[PDH].[CREATED_DATE] [POSTED_DATETIME]
       ,[PDD].[IS_BONUS]
       ,[M].[MATERIAL_NAME] [DESCRIPTION_SKU]
       ,[M].[BARCODE_ID]
       ,[M].[ALTERNATE_BARCODE]
       ,[PDH].[EXTERNAL_SOURCE_ID]
       ,[ES].[SOURCE_NAME]
       ,[PDD].[ERP_OBJECT_TYPE]
       ,[M].[IS_MASTER_PACK]
       ,[PDD].[MATERIAL_OWNER]
       ,[PDD].[MASTER_ID_MATERIAL]
       ,[PDH].[OWNER] [SOURCE]
       ,[PDD].[DISCOUNT_TYPE]
       ,[M].[WEIGTH] [MATERIAL_WEIGHT]
       ,[M].[VOLUME_FACTOR] [MATERIAL_VOLUME]
       ,[M].[USE_PICKING_LINE]
    FROM
        [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
    INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD] ON [PDD].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
	INNER JOIN [#PICKING] P ON [P].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
    INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [PDD].[MATERIAL_ID]
    LEFT JOIN [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES] ON [ES].[EXTERNAL_SOURCE_ID] = [PDH].[EXTERNAL_SOURCE_ID]
    LEFT JOIN @PARTIAL_DEMANDS PD ON [PD].[DOC_NUM] = [PDH].[DOC_NUM] AND [PD].[MATERIAL_ID] = [PDD].[MATERIAL_ID]
    WHERE
        [PDD].[QTY] - ISNULL([PD].[QTY], 0) > 0;
END;