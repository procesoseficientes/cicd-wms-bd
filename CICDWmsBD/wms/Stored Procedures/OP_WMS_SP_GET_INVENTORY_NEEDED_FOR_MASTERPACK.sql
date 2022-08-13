-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	7/6/2017 @ NEXUS-Team Sprint AgeOfEmpires 
-- Description:			Obtiene el inventario de componentes necesario para formar los masterpacks enviados.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_INVENTORY_NEEDED_FOR_MASTERPACK]
				@MASTER_PACK_CODE = 'C00030/LECHEDESCRE'
				,@WAREHOUSE_ID = 'BODEGA_01'
				,@QTY = 10
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INVENTORY_NEEDED_FOR_MASTERPACK](
	@MASTER_PACK_CODE VARCHAR(50)
	,@WAREHOUSE_ID VARCHAR(25)
	,@QTY INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @INV_QTY_MP INT = 0
	--
	DECLARE @COMPONENT_INVENTORY TABLE(
		MASTER_PACK_ID VARCHAR(50)
		,MATERIAL_ID VARCHAR(50)
		,QTY INT
		,AVAILABLE INT
		,QTY_NEEDED INT
	)

	-- ------------------------------------------------------------------------------------
	-- Obtiene el inventario del masterpack por bodega 
	-- ------------------------------------------------------------------------------------

	SELECT @INV_QTY_MP = SUM(ISNULL([QTY], 0))
	FROM [wms].[OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL]
	WHERE [MATERIAL_ID] = @MASTER_PACK_CODE AND @WAREHOUSE_ID = [CURRENT_WAREHOUSE]

	-- ------------------------------------------------------------------------------------
	-- Reduce la variable @QTY con lo que actualmente se tiene del MP en inventario
	-- ------------------------------------------------------------------------------------
	
	SET @QTY = @QTY - ISNULL(@INV_QTY_MP, 0)

	-- ------------------------------------------------------------------------------------
	-- INSERTA EL INVENTARIO ACTUAL DE COMPONENTES EN UNA TABLA TEMPORAL
	-- ------------------------------------------------------------------------------------
	
	INSERT INTO @COMPONENT_INVENTORY
			(
				[MASTER_PACK_ID]
				,[MATERIAL_ID]
				,[QTY]
				,[AVAILABLE]
				,[QTY_NEEDED]
			)
	SELECT 
		@MASTER_PACK_CODE
		, [CXMP].[COMPONENT_MATERIAL]
		, ([CXMP].[QTY]) * @QTY
		, SUM(ISNULL([IXW].[QTY], 0)) QTY
		, CASE WHEN @QTY <= 0 
			THEN 0
			ELSE SUM(ISNULL([IXW].[QTY], 0)) - (([CXMP].[QTY]) * @QTY)
		  END QTY_NEEDED
	FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [CXMP]
		LEFT JOIN [wms].[OP_WMS_VIEW_PICKING_AVAILABLE_GENERAL] [IXW] ON [IXW].[MATERIAL_ID] = [CXMP].[COMPONENT_MATERIAL] AND [IXW].[CURRENT_WAREHOUSE] = @WAREHOUSE_ID
	WHERE [CXMP].[MASTER_PACK_CODE] = @MASTER_PACK_CODE
	GROUP BY [CXMP].[COMPONENT_MATERIAL]
		, [CXMP].[QTY]
	-- ------------------------------------------------------------------------------------
	-- Envia el resultado final
	-- ------------------------------------------------------------------------------------

	SELECT	[MATERIAL_ID],
			[QTY],
			[AVAILABLE],
			[QTY_NEEDED],
			[MASTER_PACK_ID]
	FROM @COMPONENT_INVENTORY WHERE [QTY_NEEDED] < 0
END