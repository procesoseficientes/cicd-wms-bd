
-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	21-07-2016
-- Description:			Obtiene el numero de clientes de un poligono

/*
	SELECT [SONDA].SWIFT_GET_CUSTOMERS_COUNT_BY_GEOMETRY_POLYGON ( [SONDA].SWIFT_GET_GEOMETRY_POLYGON_BY_POLIGON_ID (9) ) AS VALUE
*/
-- =============================================
CREATE FUNCTION [SONDA].SWIFT_GET_CUSTOMERS_COUNT_BY_GEOMETRY_POLYGON (@POLYGON GEOMETRY)
RETURNS INT
AS
BEGIN

  DECLARE @TOTAL_POLIGONO INT
  -- ------------------------------------------------------------------------------------
  -- Verifica si el punto esta en el poligono
  -- ------------------------------------------------------------------------------------

  SELECT
    @TOTAL_POLIGONO = SUM(CAST(@POLYGON.MakeValid().STContains(geometry ::Point(ISNULL(C.LATITUDE, 0), ISNULL(C.LONGITUDE, 0), 0)) AS INT))
  FROM [SONDA].SWIFT_VIEW_ALL_COSTUMER C
  WHERE GPS <> '0,0'
  AND GPS IS NOT NULL

  -- ------------------------------------------------------------------------------------
  -- Muestra quienes estan en el poligono
  -- ------------------------------------------------------------------------------------


  RETURN @TOTAL_POLIGONO
END
