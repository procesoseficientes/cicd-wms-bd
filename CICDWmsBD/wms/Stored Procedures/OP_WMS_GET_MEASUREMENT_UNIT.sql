-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	08-Dec-16 @ A-TEAM Sprint 6 
-- Description:			SP que obtiene los empaques

-- Modificacion 26-Ene-17 @Team ERGON - Sprint ERGON II
-- rudi.garcia
-- Se modifico para que leera la vista "[OP_WMS_VIEW_CLIENTS]" en ves de "[OP_WMS_SAP_CLIENTS]"


/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_GET_MEASUREMENT_UNIT]
				--
				EXEC [wms].[OP_WMS_GET_MEASUREMENT_UNIT]
					@CLIENT_ID = 'C00015'
					,@MATERIAL_ID = 'C00015/AMERQUIM'
				--
				EXEC [wms].[OP_WMS_GET_MEASUREMENT_UNIT]
					@CLIENT_ID = 'C00015'
				--
				EXEC [wms].[OP_WMS_GET_MEASUREMENT_UNIT]
					@MATERIAL_ID = 'C00015/AMERQUIM'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_MEASUREMENT_UNIT] (
		@CLIENT_ID VARCHAR(25) = NULL
		,@MATERIAL_ID VARCHAR(50) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@MATERIAL TABLE (
			[CLIENT_ID] VARCHAR(25)
			,[MATERIAL_ID] VARCHAR(50)
		);
	--
	DECLARE	@CLIENT TABLE (
			[CLIENT_ID] VARCHAR(25)
		);
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene los materiales a buscar
	-- ------------------------------------------------------------------------------------
	INSERT	INTO @MATERIAL
			(
				[CLIENT_ID]
				,[MATERIAL_ID]
			)
	SELECT
		[CLIENT_OWNER]
		,[MATERIAL_ID]
	FROM
		[wms].[OP_WMS_MATERIALS] [M]
	WHERE
		@MATERIAL_ID IS NULL
		OR [M].[MATERIAL_ID] = @MATERIAL_ID;
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene los clientes a buscar
	-- ------------------------------------------------------------------------------------
	INSERT	INTO @CLIENT
			(
				[CLIENT_ID]
			)
	SELECT
		[C].[CLIENT_CODE]
	FROM
		[wms].[OP_WMS_VIEW_CLIENTS] [C]
	WHERE
		@CLIENT_ID IS NULL
		OR [C].[CLIENT_CODE] = @CLIENT_ID;
	--
	SELECT
		[UM].[MEASUREMENT_UNIT_ID]
		,[UM].[CLIENT_ID]
		,[UM].[MATERIAL_ID]
		,[UM].[MEASUREMENT_UNIT]
		,ISNULL([CONF].[TEXT_VALUE], 'Unidad base') [DESCRIPTION]
		,[UM].[QTY]
		,[UM].[BARCODE]
		,[UM].[ALTERNATIVE_BARCODE]
	FROM
		[wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UM]
	INNER JOIN @MATERIAL [M] ON (
									[M].[CLIENT_ID] = [UM].[CLIENT_ID]
									AND [M].[MATERIAL_ID] = [UM].[MATERIAL_ID]
								)
	INNER JOIN @CLIENT [C] ON ([C].[CLIENT_ID] = [UM].[CLIENT_ID])
	LEFT JOIN [wms].[OP_WMS_CONFIGURATIONS] [CONF] ON [CONF].[PARAM_NAME] = [UM].[MEASUREMENT_UNIT];
END;