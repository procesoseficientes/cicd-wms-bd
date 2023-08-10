-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	6/8/2017 @ A-TEAM Sprint Jibade
-- Description:			Obtiene las etiquetas por el tipo del parametro que recibe.

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_GET_TAGS_BY_TYPE]
				@TYPE_TAGS = 'CUSTOMER'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_TAGS_BY_TYPE](
	@TYPE_TAGS VARCHAR(250)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT [TAG_COLOR]
		,[TAG_VALUE_TEXT]
		,[TAG_PRIORITY]
		,[TAG_COMMENTS]
		,[LAST_UPDATE]
		,[LAST_UPDATE_BY]
		,[TYPE]
		,[QRY_GROUP] FROM [SONDA].[SWIFT_TAGS]
	WHERE [TYPE] = @TYPE_TAGS
END
