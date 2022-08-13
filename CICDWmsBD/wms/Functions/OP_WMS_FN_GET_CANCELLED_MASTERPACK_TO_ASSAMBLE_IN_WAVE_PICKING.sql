-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		7/6/2017 @ NEXUS-Team Sprint AgeOfEmpires 
-- Description:			    Devuelve la cantidad de inventario posible a ensamblar de un masterpack

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM  [wms].[OP_WMS_FN_GET_CANCELLED_MASTERPACK_TO_ASSAMBLE_IN_WAVE_PICKING]('17190') 
		SELECT * FROM [wms].[OP_WMS_TASK_LIST] WHERE [WAVE_PICKING_ID] = 17190
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_CANCELLED_MASTERPACK_TO_ASSAMBLE_IN_WAVE_PICKING] (
		@WAVE_PICKING_ID NUMERIC(18, 0)
	)
RETURNS @COMPONENT_INVENTORY TABLE (
		[MATERIAL_ID] VARCHAR(50)
		,[QTY] INT
		,[QTY_NEEDED] INT
		,[REAL_QTY] INT
		,[MATER_PACK_CODE] VARCHAR(50)
	)
AS
BEGIN
	
	DECLARE	@QTYCOMPS INT = 0;
	-- ------------------------------------------------------------------------------------
	-- Se insertan todos los componentes en una tabla temporal.
	-- ------------------------------------------------------------------------------------
	INSERT	INTO @COMPONENT_INVENTORY
			(
				[MATERIAL_ID]
				,[QTY]
				,[QTY_NEEDED]
				,[REAL_QTY]
				,[MATER_PACK_CODE]
			)
	SELECT
		[CXMP].[COMPONENT_MATERIAL]
		,SUM(ISNULL([T].[QUANTITY_PENDING], 0))
		,[CXMP].[QTY] [QTY_NEEDED]
		,CAST(SUM(ISNULL([T].[QUANTITY_PENDING], 0))
		/ [CXMP].[QTY] AS INT) [REAL_QTY]
		,[CXMP].[MASTER_PACK_CODE]
	FROM
		 [wms].[OP_WMS_TASK_LIST] [T]  		 
	INNER JOIN  ( SELECT [D].[MATERIAL_ID] , MAX([H].[WAVE_PICKING_ID]) [WAVE_PICKING_ID] FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H] 
	INNER JOIN  [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D]  ON [D].[PICKING_DEMAND_HEADER_ID] = [H].[PICKING_DEMAND_HEADER_ID]											
											
											WHERE [H].[WAVE_PICKING_ID] = @WAVE_PICKING_ID AND [D].[WAS_IMPLODED] = 1
											GROUP BY [D].[MATERIAL_ID]
											) AS HD  ON [HD].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID]
	INNER JOIN [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [CXMP]  ON [T].[WAVE_PICKING_ID] = [HD].[WAVE_PICKING_ID]
											AND [T].[IS_COMPLETED] = 1
											AND [T].[MATERIAL_ID] = [CXMP].[COMPONENT_MATERIAL]
											AND [HD].[MATERIAL_ID] = [CXMP].[MASTER_PACK_CODE]

											WHERE T.[WAVE_PICKING_ID] = @WAVE_PICKING_ID
	GROUP BY
		[CXMP].[COMPONENT_MATERIAL]
		,[CXMP].[MASTER_PACK_CODE]
		,[CXMP].[QTY];




	--
	--RETURN @COMPONENT_INVENTORY

	RETURN;  
END;