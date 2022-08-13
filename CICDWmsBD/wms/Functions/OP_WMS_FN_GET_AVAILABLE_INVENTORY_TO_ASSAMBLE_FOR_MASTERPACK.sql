-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		7/6/2017 @ NEXUS-Team Sprint AgeOfEmpires 
-- Description:			    Devuelve la cantidad de inventario posible a ensamblar de un masterpack

-- Autor:					fabrizio.delcompare
-- Fecha de creación:       4/18/2020 @ GForce-Paris
-- Descripción:				El calculo de potencial a armar con masterpacks ahora lo realiza de forma recursiva

/*
-- Ejemplo de Ejecucion:
        SELECT [wms].[OP_WMS_FN_GET_AVAILABLE_INVENTORY_TO_ASSAMBLE_FOR_MASTERPACK]('arium/fa1002','BODEGA_01')
		
		SELECT [wms].[OP_WMS_FN_GET_AVAILABLE_INVENTORY_TO_ASSAMBLE_FOR_MASTERPACK]('alza/1111M','BODEGA_SPS')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_AVAILABLE_INVENTORY_TO_ASSAMBLE_FOR_MASTERPACK]
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
	DECLARE @QTYCOMPS INT = 0
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
		,case when isnull([CXMP].[QTY],0)=0 then 0 else  (SUM( ISNULL([IXW].[QTY], 0) / [CXMP].[QTY])) end  REAL_QTY
	FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [CXMP]
	LEFT JOIN [wms].[OP_WMS_VIEW_INVENTORY_FOR_PICKING] [IXW] 
	ON [IXW].[MATERIAL_ID] = [CXMP].[COMPONENT_MATERIAL] 
	AND [IXW].[CURRENT_WAREHOUSE] = @WAREHOUSE_ID
	
	WHERE [CXMP].[MASTER_PACK_CODE] = @MASTER_PACK_CODE
	GROUP BY [CXMP].[COMPONENT_MATERIAL]
			,[CXMP].[QTY]
			
	-- ------------------------------------------------------------------------------------
	-- Los subcomponentes, de tener alguno, se agrega a una tabla temporal
	-- ------------------------------------------------------------------------------------
	select @QTYCOMPS = MIN(REAL_QTY) FROM @COMPONENT_INVENTORY
	
	--
	RETURN ISNULL(@QTYCOMPS, 0)
END