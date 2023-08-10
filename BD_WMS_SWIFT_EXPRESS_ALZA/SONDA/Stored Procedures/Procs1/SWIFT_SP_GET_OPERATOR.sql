-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	04-04-2016
-- Description:			obtiene los operadores

/*
-- Ejemplo de Ejecucion:
        USE SWIFT_EXPRESS
        GO
        --
        EXEC [SONDA].[SWIFT_SP_GET_OPERATOR]
			@LOGIN = 'OPER200@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_OPERATOR]
	@LOGIN VARCHAR(50) = NULL
AS
BEGIN
	SELECT
		O.CORRELATIVE
		,O.LOGIN
		,O.NAME_USER
		,O.TYPE_USER
		,O.PASSWORD
		,O.ENTERPRISE
		,O.IMAGE
		,O.RELATED_SELLER
		,O.SELLER_ROUTE
		,O.USER_TYPE
		,O.DEFAULT_WAREHOUSE
		,O.USER_ROLE
		,O.PRESALE_WAREHOUSE
	FROM [SONDA].[SWIFT_VIEW_OPERATOR] O
	WHERE @LOGIN IS NULL OR O.LOGIN = @LOGIN
END
