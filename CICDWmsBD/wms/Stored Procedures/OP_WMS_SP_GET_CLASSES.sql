-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/14/2017 @ NEXUS-Team Sprint  
-- Description:			Obtiene todos los registros de la tabla OP_WMS_CLASS 

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_CLASSES]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_CLASSES]
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[CLASS_ID]
	   ,[CLASS_NAME]
	   ,[CLASS_DESCRIPTION]
	   ,[CLASS_TYPE]
	   ,[CREATED_BY]
	   ,[CREATED_DATETIME]
	   ,[LAST_UPDATED_BY]
	   ,[LAST_UPDATED]
	   ,[C].[PARAM_CAPTION] [CLASS_TYPE_DESCRIPTION]
	   ,[CL].[PRIORITY]
	  FROM [wms].[OP_WMS_CLASS] [CL]
	  INNER JOIN [wms].[OP_WMS_CONFIGURATIONS] [C]
		ON [C].[PARAM_NAME] = [CLASS_TYPE]
		AND [C].[PARAM_TYPE] = 'SISTEMA'
		AND [C].[PARAM_GROUP] = 'TIPOS_DE_CLASE'
	  WHERE [CLASS_ID] > 0
END