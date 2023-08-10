-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	19-07-2016
-- Description:			Obtiene los puntos del poligono solicitado

/*
-- Ejemplo de Ejecucion:
				-- 
				SELECT * FROM [SONDA].[SWIFT_FN_GET_POLYGON](1)  
				-- 
				SELECT * FROM [SONDA].[SWIFT_FN_GET_POLYGON] (NULL) 
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_FN_GET_POLYGON]
(	
	@POLYGON_ID  INT = NULL
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		P.POLYGON_ID
		,P.POSITION
		,P.LATITUDE
		,P.LONGITUDE
	FROM [SONDA].SWIFT_POLYGON_POINT P
	WHERE P.POLYGON_ID = @POLYGON_ID OR @POLYGON_ID IS NULL
)
