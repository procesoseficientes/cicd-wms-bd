-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	11-May-17 @ A-TEAM Sprint Issa 
-- Description:			SP que obtiene la configuracion de las etiquetas de un cliente con cambios

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_ALL_TAG_BY_CUSTOMER_CHANGE]
					@CUSTOMER = 3875
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ALL_TAG_BY_CUSTOMER_CHANGE](
	@CUSTOMER INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[T].[TAG_COLOR]
		,[T].[TAG_VALUE_TEXT]
		,[T].[TAG_PRIORITY]
		,[T].[TAG_COMMENTS]
		,[T].[LAST_UPDATE]
		,[T].[LAST_UPDATE_BY]
		,[T].[TYPE]
		,[T].[QRY_GROUP]
		,CASE
			WHEN [C].[TAG_COLOR] IS NULL THEN 0
			ELSE 1
		END [IS_CONFIG]
	FROM [SONDA].[SWIFT_TAGS] [T]
	LEFT JOIN [SONDA].[SWIFT_TAG_X_CUSTOMER_CHANGE] [C] ON (
		[C].[TAG_COLOR] = [T].[TAG_COLOR]
		AND [C].[CUSTOMER] = @CUSTOMER
	)
	WHERE [T].[QRY_GROUP] IS NOT NULL
END
