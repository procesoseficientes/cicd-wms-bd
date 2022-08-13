-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	27-11-2017 Reborn@nach
-- Description:			Calcula la distancia entre dos puntos

/*
-- Ejemplo de Ejecucion:
				-- 
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_CALCULATE_DISTANCE]
    (
      @ORIGIN VARCHAR(MAX) ,
      @DESTINY VARCHAR(MAX)
    )
RETURNS FLOAT
AS
    BEGIN
        DECLARE @DISTANCE FLOAT = 0.00;
	
        IF @ORIGIN IS NOT NULL
            AND @DESTINY IS NOT NULL
            BEGIN
                DECLARE @P1 GEOGRAPHY = geography::Point(SUBSTRING(@ORIGIN, 1,
                                                              CHARINDEX(',',
                                                              @ORIGIN) - 1),
                                                         SUBSTRING(@ORIGIN,
                                                              CHARINDEX(',',
                                                              @ORIGIN) + 1,
                                                              LEN(@ORIGIN)),
                                                         4326);
                DECLARE @P2 GEOGRAPHY = geography::Point(SUBSTRING(@DESTINY, 1,
                                                              CHARINDEX(',',
                                                              @DESTINY) - 1),
                                                         SUBSTRING(@DESTINY,
                                                              CHARINDEX(',',
                                                              @DESTINY) + 1,
                                                              LEN(@DESTINY)),
                                                         4326);
		
		--Dividido 1000 para que muestre el resultado en kilometros
                SET @DISTANCE = ROUND(( @P1.STDistance(@P2) / 1000 ), 4);
            END;

        RETURN @DISTANCE;
    END;