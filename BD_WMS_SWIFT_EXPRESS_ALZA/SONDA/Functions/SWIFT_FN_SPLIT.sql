-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	05-04-2016
-- Description:			Funcion que genera una tabla de un split del caracter indicado
/*
-- Ejemplo de Ejecucion:
        USE SWIFT_EXPRESS
        GO
        --
        SELECT * FROM [SONDA].[SWIFT_FN_SPLIT]('A|B|C|D','|')
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_FN_SPLIT]
(
    @STRING NVARCHAR(4000),
    @DELIMITER NCHAR(1)
)
RETURNS TABLE
AS
RETURN
(
    WITH SPLIT(STPOS,ENDPOS)
    AS(
        SELECT 
			0 AS STPOS
			,CHARINDEX(@DELIMITER,@STRING) AS ENDPOS
        UNION ALL
        SELECT 
			ENDPOS+1
			,CHARINDEX(@DELIMITER,@STRING,ENDPOS+1)
        FROM SPLIT
        WHERE ENDPOS > 0
    )
    SELECT 'ID' = ROW_NUMBER() OVER (ORDER BY (SELECT 1)),
        'VALUE' = SUBSTRING(@STRING,STPOS,COALESCE(NULLIF(ENDPOS,0),LEN(@STRING)+1)-STPOS)
    FROM SPLIT
)
