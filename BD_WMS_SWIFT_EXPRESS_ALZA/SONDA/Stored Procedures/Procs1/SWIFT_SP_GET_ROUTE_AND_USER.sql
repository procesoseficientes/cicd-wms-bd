-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		15-06-2016
-- Description:			    SP para obtener a los usuarios con su ruta asociada

/*
-- Ejemplo de Ejecucion:
				--
				EXEC [SONDA].[SWIFT_SP_GET_ROUTE_AND_USER]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ROUTE_AND_USER]
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[R].[CODE_ROUTE]
		,[R].[NAME_ROUTE]
		,[U].[LOGIN]
		,[U].[NAME_USER]
	FROM [SONDA].[USERS] [U]
	INNER JOIN [SONDA].[SWIFT_ROUTES] [R] ON (
		[U].[SELLER_ROUTE] = [R].[CODE_ROUTE]
	)
END
