-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	27-01-2016
-- Description:			Obtiene los puntos del departamento solicitado

/*
-- Ejemplo de Ejecucion:
				-- 
				SELECT * FROM [SONDA].[SWIFT_FN_GET_POLYGON_BY_DEPARTMENT](1) D ORDER BY D.DEPARTMENT_ID,D.POSITION
				-- 
				SELECT * FROM [SONDA].[SWIFT_FN_GET_POLYGON_BY_DEPARTMENT](NULL) D ORDER BY D.DEPARTMENT_ID,D.POSITION
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_FN_GET_POLYGON_BY_DEPARTMENT]
(	
	@DEPARTMENT_ID INT = NULL
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		D.POSITION
		,D.DEPARTMENT_ID
		,D.LATITUDE
		,D.LONGITUDE
	FROM [SONDA].[SWIFT_POLYGON_BY_DEPARTMENT_DETAIL] D
	WHERE D.DEPARTMENT_ID = @DEPARTMENT_ID OR @DEPARTMENT_ID IS NULL
)
