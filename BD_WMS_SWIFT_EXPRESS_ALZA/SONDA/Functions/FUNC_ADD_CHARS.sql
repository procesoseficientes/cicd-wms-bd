
-- =============================================
-- Autor:	alejandro.ochoa
-- Fecha de Creacion: 	2018-08-29
-- Description:	 Se agrega funcion para rellenar de Caracteres una cadena de texto hasta que alcance una longitud deseada

/*
-- Ejemplo de Ejecucion:
		SELECT [SONDA].[FUNC_ADD_CHARS] ('1234','0',8)
*/
-- =============================================
CREATE FUNCTION [SONDA].[FUNC_ADD_CHARS] ( @DocNo AS VARCHAR(MAX), @CharToFill VARCHAR(1), @LengthToFill INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
    DECLARE @DocNoFilled VARCHAR(MAX);

	SELECT @DocNoFilled = @DocNo;

    WHILE (LEN(@DocNoFilled)<@LengthToFill)
    BEGIN
        SELECT @DocNoFilled = CONCAT(@CharToFill,@DocNoFilled);
    END;

    RETURN @DocNoFilled;
END;







