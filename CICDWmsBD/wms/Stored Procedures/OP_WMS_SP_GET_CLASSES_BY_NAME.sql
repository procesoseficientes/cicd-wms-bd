-- =============================================
-- Autor:				marvin.garcia
-- Fecha de Creacion: 	13-Jun-18 @ A-TEAM Dinosaurio 
-- Description:			SP que devuelve el tipo de clase segun el nombre especificado como parametro

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_CLASSES_BY_NAME]
					@NAME = 'Baterias'
				-- 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_CLASSES_BY_NAME]
@NAME VARCHAR(50)
AS
BEGIN
	SELECT
		CLASS_ID ,
		CLASS_NAME
	FROM
		[wms].[OP_WMS_CLASS] [CL]
	JOIN
		[wms].[OP_WMS_CONFIGURATIONS] [CO] ON ([CL].[CLASS_TYPE] = [CO].[PARAM_NAME]
		AND [CO].[PARAM_TYPE] = 'SISTEMA'
		AND [CO].[PARAM_GROUP] = 'TIPOS_DE_CLASE')
		WHERE [CL].CLASS_NAME = @NAME
END