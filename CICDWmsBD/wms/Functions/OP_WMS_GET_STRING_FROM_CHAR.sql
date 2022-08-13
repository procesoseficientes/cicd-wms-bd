-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-18 @ Team ERGON - Sprint ERGON 1
-- Description:	        Funcion que devuelve una subcadena de una cadena a partir de un caracter hacia la derecha

/*
-- Ejemplo de Ejecucion:
			SELECT [wms].OP_WMS_GET_STRING_FROM_CHAR ('wms/1/0001/sdf30', '/')
*/
-- =============================================
CREATE FUNCTION [wms].OP_WMS_GET_STRING_FROM_CHAR (@STRING VARCHAR(50), @CHAR CHAR)
RETURNS VARCHAR(100)
AS
BEGIN

  DECLARE @SUB_STRING VARCHAR(MAX);

  SELECT
    @SUB_STRING =
    SUBSTRING(@STRING, CHARINDEX(@CHAR, @STRING) + 1, LEN(@STRING))

  RETURN @SUB_STRING
END;