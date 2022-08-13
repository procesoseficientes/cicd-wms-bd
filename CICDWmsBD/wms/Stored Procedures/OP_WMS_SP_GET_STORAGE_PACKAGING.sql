-- =============================================
-- Autor:				marvin.garcia
-- Fecha de Creacion: 	5/29/2018 A-Team Sprint Dinosaurio 
-- Description:			SP que obtiene las unidades de medida del tipo almacenamiento y el grupo tipos de empaque
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_STORAGE_PACKAGING]
				@MATERIAL_ID = 'arium/100011'

				EXEC [wms].[OP_WMS_SP_GET_STORAGE_PACKAGING]
				@MATERIAL_ID = 'arium/100011'
				@PARAM_NAME = 'Caja'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_STORAGE_PACKAGING](
	@MATERIAL_ID VARCHAR(50)
	,@PARAM_NAME  VARCHAR(50)
)
AS
BEGIN
	SELECT 
		[C].PARAM_NAME
		,[C].TEXT_VALUE
	FROM [wms].[OP_WMS_CONFIGURATIONS] [C]
	LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [M] ON( ([M].MEASUREMENT_UNIT = [C].PARAM_NAME) AND (M.MATERIAL_ID = @MATERIAL_ID))
	WHERE 
			[C].PARAM_TYPE = 'ALMACENAMIENTO'
		AND [C].PARAM_GROUP = 'TIPOS_EMPAQUE'	
		AND [M].MEASUREMENT_UNIT_ID IS NULL
	UNION
	SELECT
		[C].PARAM_NAME
		,[C].TEXT_VALUE
	FROM [wms].[OP_WMS_CONFIGURATIONS] [C]
	WHERE
			[C].PARAM_NAME = @PARAM_NAME
	AND [C].PARAM_TYPE = 'ALMACENAMIENTO'
	AND [C].PARAM_GROUP = 'TIPOS_EMPAQUE'	
END