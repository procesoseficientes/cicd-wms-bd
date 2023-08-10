
-- =============================================
-- Autor:				alejandro.ochoa
-- Fecha de Creacion: 	21-07-2016
-- Description:			Calcula la distancia entre dos puntos y devuelve el resultado en mt o km

/*
-- Ejemplo de Ejecucion:
				--  Select [SONDA].[SWIFT_CALCULATE_DISTANCE] ('-14.2435029038,90.948543984','-14.909090989,90.098396567','K')
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_CALCULATE_DISTANCE]
(
	@ORIGIN VARCHAR(MAX)
	,@DESTINY VARCHAR(MAX)
	,@MEASURE VARCHAR(50)
)
RETURNS FLOAT
AS
BEGIN
	DECLARE @DISTANCE FLOAT = 0.00
	
	IF @ORIGIN IS NOT NULL AND @DESTINY IS NOT NULL AND @ORIGIN NOT IN ('null','undefined') AND @DESTINY NOT IN ('null','undefined')
	BEGIN
		DECLARE @P1 geography = geography::Point(SUBSTRING(@ORIGIN, 1, CHARINDEX(',', @ORIGIN) - 1),SUBSTRING(@ORIGIN, CHARINDEX(',', @ORIGIN) + 1, LEN(@ORIGIN)), 4326);
		DECLARE @P2 geography = geography::Point(SUBSTRING(@DESTINY, 1, CHARINDEX(',', @DESTINY) - 1),SUBSTRING(@DESTINY, CHARINDEX(',', @DESTINY) + 1, LEN(@DESTINY)), 4326);
		
		
		SET @DISTANCE = (CASE WHEN @MEASURE = 'K' THEN ROUND((@P1.STDistance(@P2) / 1000),4) ELSE ROUND(@P1.STDistance(@P2),4) END)
	END
	ELSE		
		SET @DISTANCE = -1

	RETURN @DISTANCE
END
