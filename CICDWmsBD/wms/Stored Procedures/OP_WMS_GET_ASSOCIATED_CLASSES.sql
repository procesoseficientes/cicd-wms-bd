-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/12/2017 @ NEXUS-Team Sprint DuckHunt 
-- Description:			Obtiene las clases asociadas a otra por su ID

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_GET_ASSOCIATED_CLASSES]
					@CLASS_ID = 1
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_ASSOCIATED_CLASSES](
	@CLASS_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT [C].[CLASS_ID]
			,[C].[CLASS_NAME]
			,[C].[CLASS_DESCRIPTION]
			,[C].[CLASS_TYPE]
			,[CONF].[PARAM_CAPTION] [CLASS_TYPE_DESCRIPTION]
			,[C].[CREATED_BY]
			,[C].[CREATED_DATETIME]
			,[C].[LAST_UPDATED_BY]
			,[C].[LAST_UPDATED]
			,[C].[PRIORITY]
	FROM [wms].[OP_WMS_CLASS] [C]
		INNER JOIN [wms].[OP_WMS_CLASS_ASSOCIATION] [CA] ON [CA].[CLASS_ID] = [C].[CLASS_ID]
		INNER JOIN [wms].[OP_WMS_CONFIGURATIONS] [CONF] ON [CONF].[PARAM_NAME] = [C].[CLASS_TYPE]
	WHERE [CA].[CLASS_ASSOCIATED_ID] = @CLASS_ID
END