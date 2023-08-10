-- =============================================
-- Autor:				juancarlos.escalante
-- Fecha de Creacion: 	28-09-2016
-- Description:			Selecciona las rutas Asociadas al vendedor elegido

/*
	Ejemplo Ejecucion: 
    EXEC [SONDA].[SWIFT_SP_GET_ROUTES_BY_SELLER] @SELLER_CODE = N'-1'
 */
-- =============================================

CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ROUTES_BY_SELLER]
	@SELLER_CODE VARCHAR(50)
AS
BEGIN

	SELECT
		[ROUTE]
		,[CODE_ROUTE]
		,[NAME_ROUTE]
		,[GEOREFERENCE_ROUTE]
		,[COMMENT_ROUTE]
		,[LAST_UPDATE]
		,[LAST_UPDATE_BY]
		,[IS_ACTIVE_ROUTE]
		,[CODE_COUNTRY]
		,[NAME_COUNTRY]
		,[SELLER_CODE]
	FROM [SWIFT_EXPRESS].[SONDA].[SWIFT_ROUTES]
	WHERE [SELLER_CODE] = @SELLER_CODE;

END
