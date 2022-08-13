-- =============================================
-- Autor:				kevin.guerra
-- Fecha de Creacion: 	24-03-2020 GForce@B 
-- Description:			SP que devuelve el tipo de sub clase segun el nombre especificado como parametro

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_SUB_CLASSES_BY_NAME]
					@NAME = 'familia1'
				-- 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_SUB_CLASSES_BY_NAME]
@NAME VARCHAR(50)
AS
BEGIN
	SELECT
		SUB_CLASS_ID ,
		SUB_CLASS_NAME
	FROM [wms].[OP_WMS_SUB_CLASS] [CL]
	WHERE [CL].SUB_CLASS_NAME = @NAME
END