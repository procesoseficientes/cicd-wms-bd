-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		15-07-2016
-- Description:			    Obtiene todos los usuarios de un tipo de usuario o todos los usuarios

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_GET_USER_BY_TYPE]
		--
		EXEC [SONDA].[SWIFT_SP_GET_USER_BY_TYPE]
			@USER_TYPE = 'BOD'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_USER_BY_TYPE]
	@USER_TYPE VARCHAR(50) = NULL
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[O].[CORRELATIVE]
		,[O].[LOGIN]
		,[O].[NAME_USER]
		,[O].[TYPE_USER]
		,[O].[PASSWORD]
		,[O].[ENTERPRISE]
		,[O].[IMAGE]
		,[O].[RELATED_SELLER]
		,[O].[SELLER_ROUTE]
		,[O].[USER_TYPE]
		,[O].[DEFAULT_WAREHOUSE]
		,[O].[USER_ROLE]
		,[O].[PRESALE_WAREHOUSE]
		,[O].[ROUTE_RETURN_WAREHOUSE]
	FROM [SONDA].[SWIFT_VIEW_OPERATOR] [O]
	WHERE @USER_TYPE IS NULL OR [O].[USER_TYPE] = @USER_TYPE
END
