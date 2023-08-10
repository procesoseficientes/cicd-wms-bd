CREATE FUNCTION [SONDA].[SWIFT_FN_GET_LABOR_DAYS]
(@FechaInicial DATETIME, 
@FechaFinal DATETIME,
@INCLUDE_SATURDAY BIT ) 
RETURNS INT 
AS 
BEGIN 

DECLARE @varfecha DATETIME 
DECLARE @diaslaborales int 

SET @varfecha = @FechaInicial 
SET @diaslaborales = 0 

IF @INCLUDE_SATURDAY = 1
BEGIN
	WHILE ((@fechafinal + 1) > @varfecha) 
	BEGIN 
	IF (DATEPART(dw,@varfecha) NOT IN (7)) 
	BEGIN 
	SET @diaslaborales = @diaslaborales +1 
	END 
	SET @varfecha = @varfecha + 1 
	END 
END
ELSE
BEGIN
	WHILE ((@fechafinal + 1) > @varfecha) 
	BEGIN 
	IF (DATEPART(dw,@varfecha) NOT IN (6,7)) 
	BEGIN 
	SET @diaslaborales = @diaslaborales +1 
	END 
	SET @varfecha = @varfecha + 1 
	END 
END
RETURN @diaslaborales 
END
