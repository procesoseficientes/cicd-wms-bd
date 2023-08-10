-- =============================================
-- Autor:				juancarlos.escalante
-- Fecha de Creacion: 	28-09-2016
-- Description:			Selecciona los poligonos de  rutas asociadas a la ruta que se le mande como parametro

/*
	Ejemplo Ejecucion: 
    EXEC [SONDA].[SWIFT_SP_GET_POLYGONS_BY_ROUTE] @CODE_ROUTE = N'3111'
 */
-- =============================================

CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_POLYGONS_BY_ROUTE]
	@CODE_ROUTE VARCHAR(50)
AS
BEGIN
	
	SELECT
		Poly.[POLYGON_ID]
		,Poly.[POLYGON_NAME]
		,Poly.[POLYGON_DESCRIPTION]
		,Poly.[COMMENT]
		,Poly.[LAST_UPDATE_BY]
		,Poly.[LAST_UPDATE_DATETIME]
		,Parent.POLYGON_NAME AS PARENT_NAME
		,Poly.[POLYGON_TYPE]
		,Poly.[SUB_TYPE]
		,Poly.[OPTIMIZE]
		,Poly.[TYPE_TASK]
		,Poly.[CODE_WAREHOUSE]
		,Poly.[LAST_OPTIMIZATION]
	FROM [SWIFT_EXPRESS].[SONDA].SWIFT_VIEW_ALL_ROUTE Routes
	INNER JOIN [SWIFT_EXPRESS].[SONDA].[SWIFT_POLYGON_BY_ROUTE] PbR
		on Routes.ROUTE = PbR.ROUTE
	INNER JOIN [SWIFT_EXPRESS].[SONDA].[SWIFT_POLYGON] Poly
		on Poly.POLYGON_ID = PbR.POLYGON_ID
  LEFT JOIN [SWIFT_EXPRESS].[SONDA].[SWIFT_POLYGON] Parent 
    ON Poly.POLYGON_ID = Parent.POLYGON_ID_PARENT
	where Routes.[CODE_ROUTE] = @CODE_ROUTE
  
END
