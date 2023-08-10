-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	22-01-2016
-- Description:			Obtiene los puntos del poligono solicitado o de todos

/*
-- Ejemplo de Ejecucion:
				-- 
				SELECT * FROM [SONDA].[SWIFT_FN_GET_POLYGON_BY_ROUTE]('001') P ORDER BY P.CODE_ROUTE,P.POSITION
				-- 
				SELECT * FROM [SONDA].[SWIFT_FN_GET_POLYGON_BY_ROUTE](NULL) P ORDER BY P.CODE_ROUTE,P.POSITION
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_FN_GET_POLYGON_BY_ROUTE]
(	
	@CODE_ROUTE VARCHAR(50) = NULL
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		P.POSITION
		,P.CODE_ROUTE
		,P.LATITUDE
		,P.LONGITUDE
	FROM [SONDA].[SWIFT_POLYGON_X_ROUTE] P 
	WHERE P.CODE_ROUTE = @CODE_ROUTE OR @CODE_ROUTE IS NULL
)
