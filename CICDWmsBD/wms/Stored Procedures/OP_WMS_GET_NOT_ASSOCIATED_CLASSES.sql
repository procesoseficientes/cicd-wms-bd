-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/12/2017 @ NEXUS-Team Sprint DuckHunt 
-- Description:			Obtiene las clases no asociadas a la otra por su ID

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_GET_NOT_ASSOCIATED_CLASSES]
					@CLASS_ID = 3
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_NOT_ASSOCIATED_CLASSES](
	@CLASS_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @PARAM_GROUP VARCHAR(25) = 'TIPOS_DE_CLASE'
	--
	SELECT DISTINCT
			[C].[CLASS_ID]
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
		LEFT JOIN [wms].[OP_WMS_CLASS_ASSOCIATION] [CA] ON [CA].[CLASS_ASSOCIATED_ID] = [C].[CLASS_ID] AND [CA].[CLASS_ID] = @CLASS_ID
		INNER JOIN [wms].[OP_WMS_CONFIGURATIONS] [CONF] ON [CONF].[PARAM_NAME] = [C].[CLASS_TYPE] AND [CONF].[PARAM_GROUP] = @PARAM_GROUP
	WHERE [CA].[CLASS_ID] IS NULL
		AND [C].[CLASS_ID] <> @CLASS_ID
END