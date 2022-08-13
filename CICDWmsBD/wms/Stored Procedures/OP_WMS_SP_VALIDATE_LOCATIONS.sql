-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-Oct-17 @ Nexus Team Sprint ewms
-- Description:			SP que valida las ubicaciones
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_VALIDATE_LOCATIONS]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_LOCATIONS]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @RESULT TABLE (
		[LOCATION] VARCHAR(50)
		,[MESSAGE] VARCHAR(2000)
	)
	
	-- ------------------------------------------------------------------------------------
	-- Valida si las ubicaciones tienen linea asignada
	-- ------------------------------------------------------------------------------------
	INSERT INTO @RESULT
			([LOCATION], [MESSAGE])
	SELECT
		[SS].[LOCATION_SPOT]
		,'La ubicación ' + [SS].[LOCATION_SPOT] + ' no tiene linea asignada'
	FROM [wms].[OP_WMS_SHELF_SPOTS] [SS]
	WHERE [SS].[LINE_ID] IS NULL
		OR [SS].[LINE_ID] = ''

	-- ------------------------------------------------------------------------------------
	-- Valida si las ubicaciones tienen linea asignada
	-- ------------------------------------------------------------------------------------
	INSERT INTO @RESULT
			([LOCATION], [MESSAGE])
	SELECT
		[SS].[LOCATION_SPOT]
		,'La ubicación ' + [SS].[LOCATION_SPOT] + ' no tiene tramo asignado'
	FROM [wms].[OP_WMS_SHELF_SPOTS] [SS]
	WHERE [SS].[LINE_ID] IS NOT NULL
		AND [SS].[LINE_ID] != ''
		AND ([SS].[SECTION] IS NULL
		OR [SS].[SECTION] = '')

	-- ------------------------------------------------------------------------------------
	-- Muestra resultado
	-- ------------------------------------------------------------------------------------
	SELECT
		[LOCATION]
		,[MESSAGE]
	FROM @RESULT
END