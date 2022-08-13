-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-Oct-17 @ Nexus Team Sprint ewms 
-- Description:			SP que valida la configuracion de materiales
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_VALIDATE_MATERIALS]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_MATERIALS]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @MATERIAL_BY_LOCATION TABLE (
		[MATERIAL_ID] VARCHAR(50) NOT NULL
		,[LINE_ID] VARCHAR(15) NOT NULL
	)
	--
	DECLARE @RESULT TABLE (
		[MATERIAL_ID] VARCHAR(50) NOT NULL PRIMARY KEY
		,[MESSAGE] VARCHAR(2000) NOT NULL
	)

	-- ------------------------------------------------------------------------------------
	-- Valida si tiene configurado si utiliza o no linea de picking
	-- ------------------------------------------------------------------------------------
	INSERT INTO @RESULT
			([MATERIAL_ID], [MESSAGE])
	SELECT
		[M].[MATERIAL_ID]
		,'El material ' + [M].[MATERIAL_ID] + ' no tiene un valor correto en el campo de usa linea de picking'
	FROM [wms].[OP_WMS_MATERIALS] [M]
	WHERE [M].[USE_PICKING_LINE] NOT IN (0,1)
	
	-- ------------------------------------------------------------------------------------
	-- Valida que solo este en una ubicacion por linea
	-- ------------------------------------------------------------------------------------
	INSERT INTO @MATERIAL_BY_LOCATION
			([MATERIAL_ID], [LINE_ID])
	SELECT
		[M].[MATERIAL_ID]
		,[SS].[LINE_ID]
	FROM [wms].[OP_WMS_MATERIALS] [M]
	INNER JOIN [wms].[OP_WMS_MATERIALS_JOIN_SPOTS] [MJS] ON ([MJS].[MATERIAL_ID] = [M].[MATERIAL_ID])
	INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [SS] ON ([SS].[LOCATION_SPOT] = [MJS].[LOCATION_SPOT])
	WHERE [M].[USE_PICKING_LINE] = 1
		AND [SS].[LINE_ID] != 'N/A'
	GROUP BY [M].[MATERIAL_ID],[SS].[LINE_ID]
	HAVING COUNT([M].[MATERIAL_ID]) > 1
	--
	INSERT INTO @RESULT
			([MATERIAL_ID], [MESSAGE])
	SELECT
		[M].[MATERIAL_ID]
		,'El material ' + [M].[MATERIAL_ID] + ' esta en dos ubicaciones de la liena ' + [M].[LINE_ID]
	FROM @MATERIAL_BY_LOCATION [M]

	-- ------------------------------------------------------------------------------------
	-- Valida si tiene configurado si es o no master pack
	-- ------------------------------------------------------------------------------------
	INSERT INTO @RESULT
			([MATERIAL_ID], [MESSAGE])
	SELECT
		[M].[MATERIAL_ID]
		,'El material ' + [M].[MATERIAL_ID] + ' no tiene un valor correto en el campo indica si es master pack'
	FROM [wms].[OP_WMS_MATERIALS] [M]
	WHERE [M].[IS_MASTER_PACK] NOT IN (0,1)

	-- ------------------------------------------------------------------------------------
	-- Valida la configuracion de master pack
	-- ------------------------------------------------------------------------------------
	INSERT INTO @RESULT
			([MATERIAL_ID], [MESSAGE])
	SELECT
		[M].[MASTER_PACK_CODE]
		,'El master pack ' + [M].[MASTER_PACK_CODE] + ' esta configurado como que el mismo es uno de sus componentes'
	FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [M]
	WHERE [M].[MASTER_PACK_COMPONENT_ID] > 0
		AND [M].[MASTER_PACK_CODE] = [M].[COMPONENT_MATERIAL]
	--
	INSERT INTO @RESULT
			([MATERIAL_ID], [MESSAGE])
	SELECT
		[M].[MASTER_PACK_CODE]
		,'El master pack ' + [M].[MASTER_PACK_CODE] + ' tiene componentes con catidad menor o igual a cero'
	FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [M]
	WHERE [M].[MASTER_PACK_COMPONENT_ID] > 0
		AND [M].[QTY] <= 0
	--
	INSERT INTO @RESULT
			([MATERIAL_ID], [MESSAGE])
	SELECT
		[M].[MATERIAL_ID]
		,'El master pack ' + [M].[MATERIAL_ID] + ' no tiene componentes'
	FROM [wms].[OP_WMS_MATERIALS] [M]
	LEFT JOIN [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [CMP] ON ([M].[MATERIAL_ID] = [CMP].[MASTER_PACK_CODE])
	WHERE [M].[IS_MASTER_PACK] = 1
		AND [CMP].[MASTER_PACK_COMPONENT_ID] IS NULL
	--
	INSERT INTO @RESULT
			([MATERIAL_ID], [MESSAGE])
	SELECT
		[M1].[MATERIAL_ID]
		,'El master pack ' + [M2].[MATERIAL_ID] + ' tiene como padre e hijo al master pack ' + [M1].[MATERIAL_ID]
	FROM [wms].[OP_WMS_MATERIALS] [M1]
	INNER JOIN [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [CMP1] ON ([M1].[MATERIAL_ID] = [CMP1].[MASTER_PACK_CODE])
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M2] ON ([M2].[MATERIAL_ID] = [CMP1].[COMPONENT_MATERIAL])
	INNER JOIN [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [CMP2] ON ([M2].[MATERIAL_ID] = [CMP2].[MASTER_PACK_CODE])
	WHERE [M1].[IS_MASTER_PACK] = 1
		AND [M2].[IS_MASTER_PACK] = 1
		AND [M1].[MATERIAL_ID] = [CMP2].[COMPONENT_MATERIAL]

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	SELECT 
		[R].[MATERIAL_ID]
		,[R].[MESSAGE]
	FROM @RESULT [R]
END