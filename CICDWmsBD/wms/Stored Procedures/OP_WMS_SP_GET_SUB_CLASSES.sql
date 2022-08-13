-- =============================================
-- Autor:				kevin.guerra
-- Fecha de Creacion: 	GForce@B
-- Description:			Obtiene todos los registros de la tabla OP_WMS_SUB_CLASS

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_SUB_CLASSES]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_SUB_CLASSES]
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[SUB_CLASS_ID]
	   ,[SUB_CLASS_NAME]
	   ,[CREATED_BY]
	   ,[CREATED_DATETIME]
	   ,[LAST_UPDATED_BY]
	   ,[LAST_UPDATED]
	  FROM [wms].[OP_WMS_SUB_CLASS]
END