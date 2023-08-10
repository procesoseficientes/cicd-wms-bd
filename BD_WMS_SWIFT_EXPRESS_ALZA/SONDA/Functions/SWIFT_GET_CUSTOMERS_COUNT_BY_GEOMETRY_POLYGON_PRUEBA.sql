

-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	21-07-2016
-- Description:			Obtiene el numero de clientes de un poligono

/*
	SELECT [SONDA].SWIFT_GET_CUSTOMERS_COUNT_BY_GEOMETRY_POLYGON ( [SONDA].SWIFT_GET_GEOMETRY_POLYGON_BY_POLIGON_ID (9) ) AS VALUE
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_GET_CUSTOMERS_COUNT_BY_GEOMETRY_POLYGON_PRUEBA] (@POLYGON GEOMETRY, @TVP CUSTOMER_POSITION_TYPE READONLY  )
RETURNS INT
AS
BEGIN

  DECLARE @TOTAL_POLIGONO INT
  -- ------------------------------------------------------------------------------------
  -- Verifica si el punto esta en el poligono
  -- ------------------------------------------------------------------------------------

  SELECT
    @TOTAL_POLIGONO = SUM(CAST(@POLYGON.MakeValid().STContains(geometry ::Point(ISNULL(C.LATITUDE, 0), ISNULL(C.LONGITUDE, 0), 0)) AS INT))
  FROM @TVP C
 
  -- ------------------------------------------------------------------------------------
  -- Muestra quienes estan en el poligono
  -- ------------------------------------------------------------------------------------


  RETURN @TOTAL_POLIGONO
END
