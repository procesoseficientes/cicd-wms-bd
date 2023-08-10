-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		7/6/2017 @ NEXUS-Team Sprint AgeOfEmpires 
-- Description:			    Retorna el inventario del masterpack incluyendo lo que puede ser armado a un nivel

-- Autor:					fabrizio.delcompare
-- Fecha de creación:       4/18/2020 @ GForce-Paris
-- Descripción:				El calculo de potencial a armar con masterpacks ahora lo realiza de forma recursiva

/*
-- Ejemplo de Ejecucion:
        SELECT [wms].[OP_WMS_FN_GET_AVAILABLE_INVENTORY_FOR_MASTERPACK]('wms/C00000261','BODEGA_01')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_AVAILABLE_INVENTORY_FOR_MASTERPACK]
(
	@MASTER_PACK_CODE VARCHAR(50)
	,@WAREHOUSE_ID VARCHAR(25)
)
RETURNS int
AS
BEGIN
	DECLARE @COMPONENT_INVENTORY TABLE(
		MATERIAL_ID VARCHAR(50)
		,QTY INT
		,QTY_NEEDED INT
		,REAL_QTY INT
	)
	DECLARE @QTYMP INT = 0, @QTYCOMPS INT = 0
	-- ------------------------------------------------------------------------------------
	-- Se obtiene el inventario fisico que se tiene del masterpack
	-- ------------------------------------------------------------------------------------
	SELECT @QTYMP = SUM(ISNULL([QTY],0))
	FROM [wms].[OP_WMS_VIEW_INVENTORY_FOR_PICKING] WITH (NOLOCK)
	WHERE [MATERIAL_ID] = @MASTER_PACK_CODE AND @WAREHOUSE_ID = [CURRENT_WAREHOUSE]
	-- ------------------------------------------------------------------------------------
	-- Se insertan todos los componentes en una tabla temporal.
	-- ------------------------------------------------------------------------------------
	INSERT INTO @COMPONENT_INVENTORY
			(
				[MATERIAL_ID]
				,[QTY]
				,[QTY_NEEDED]
				,[REAL_QTY]
			)
	SELECT 
		[CXMP].[COMPONENT_MATERIAL]
		, SUM(ISNULL([IXW].[QTY],0))
		, [CXMP].[QTY] [QTY_NEEDED]
		, CAST(SUM(ISNULL([IXW].[QTY], 0)) / [CXMP].[QTY] AS INT)  REAL_QTY
	FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [CXMP] WITH (NOLOCK)
	LEFT JOIN [wms].[OP_WMS_VIEW_INVENTORY_FOR_PICKING] [IXW]  WITH (NOLOCK)
	ON [IXW].[MATERIAL_ID] = [CXMP].[COMPONENT_MATERIAL] 
	AND [IXW].[CURRENT_WAREHOUSE] = @WAREHOUSE_ID 
	
	WHERE [CXMP].[MASTER_PACK_CODE] = @MASTER_PACK_CODE 
	GROUP BY [CXMP].[COMPONENT_MATERIAL]
			,[CXMP].[QTY]
			
	-- ------------------------------------------------------------------------------------
	-- Los subcomponentes, de tener alguno, se agrega a una tabla temporal
	-- ------------------------------------------------------------------------------------
	DECLARE @COMPONENTS_TEMP_TABLE TABLE(
		MATERIAL_ID VARCHAR(50)
		,QTY INT
		,QTY_NEEDED INT
		,REAL_QTY INT
	)

	INSERT INTO @COMPONENTS_TEMP_TABLE
			(
				[MATERIAL_ID]
				,[QTY]
				,[QTY_NEEDED]
				,[REAL_QTY]
			)
	SELECT * FROM @COMPONENT_INVENTORY

	DECLARE @SubComponentMaterial varchar(50) -- Esta variable guarda el nombre de material del subcomponente corriente en el while Loop
	DECLARE @SubComponentQTY INT -- Esta variable guarda la cantidad de material del subcomponente corriente en el while Loop
	DECLARE @SubComponentQTY_NEEDED INT -- Esta variable guarda la cantidad necesaria para armar al padre del subcomponente corriente en el while Loop
	
	WHILE (SELECT COUNT(*) FROM @COMPONENTS_TEMP_TABLE) > 0
	BEGIN
		SELECT TOP 1 @SubComponentMaterial = MATERIAL_ID FROM @COMPONENTS_TEMP_TABLE
		SELECT TOP 1 @SubComponentQTY_NEEDED = QTY_NEEDED FROM @COMPONENTS_TEMP_TABLE
		
		UPDATE @COMPONENT_INVENTORY 
		SET REAL_QTY = CAST([wms].[OP_WMS_FN_GET_AVAILABLE_INVENTORY_FOR_MASTERPACK](@SubComponentMaterial, @WAREHOUSE_ID) / @SubComponentQTY_NEEDED AS INT)
		WHERE MATERIAL_ID = @SubComponentMaterial

		DECLARE @TEST int
		SELECT TOP 1 @TEST = REAL_QTY FROM @COMPONENT_INVENTORY
		
		DELETE @COMPONENTS_TEMP_TABLE WHERE MATERIAL_ID = @SubComponentMaterial
	END
			
	-- ------------------------------------------------------------------------------------
	-- Obtenemos la cantidad minima de masterpacks a ensamblar
	-- ------------------------------------------------------------------------------------
	
	SELECT TOP 1 @QTYCOMPS = ISNULL([REAL_QTY],0) 
	FROM @COMPONENT_INVENTORY
	ORDER BY [REAL_QTY]  ASC
	
	--
	RETURN ISNULL(@QTYCOMPS,0) + ISNULL(@QTYMP, 0)
END