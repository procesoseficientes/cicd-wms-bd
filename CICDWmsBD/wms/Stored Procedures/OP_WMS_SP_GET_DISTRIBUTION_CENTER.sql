-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	1/10/2017 @ A-TEAM Sprint Balder 
-- Description:			Trae todos los centros de distribucion de la tabla OP_WMS_CONFIGURATIONS donde PARAM_TYPE = 'DISTRIBUTION_CENTER'

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_DISTRIBUTION_CENTER]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_DISTRIBUTION_CENTER]
AS
BEGIN
	SET NOCOUNT ON;
	--
	
	SELECT [PARAM_TYPE]
			,[PARAM_GROUP]
			,[PARAM_GROUP_CAPTION]
			,[PARAM_NAME]
			,[PARAM_CAPTION]
			,[NUMERIC_VALUE]
			,[TEXT_VALUE]
	FROM [wms].[OP_WMS_CONFIGURATIONS] 
	WHERE [PARAM_GROUP] = 'DISTRIBUTION_CENTER'

END