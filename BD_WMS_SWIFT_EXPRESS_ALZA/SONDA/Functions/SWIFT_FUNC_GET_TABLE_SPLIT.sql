-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	06-11-2015
-- Description:			Devuelve una tabla con los registro ya separados de la cadena entrante y el caracter que los va a serparara

/*
-- Ejemplo de Ejecucion:
				DROP TABLE #SplitPrueba
				DECLARE @DelimitedString NVARCHAR(128)
				SET @DelimitedString = 'Prueba01,Prueba02,TestUno,TestDos'
				SELECT * FROM #SplitPrueba(@DelimitedString, ',')
*/
-- =============================================

CREATE FUNCTION [SONDA].[SWIFT_FUNC_GET_TABLE_SPLIT]
(
    @String VARCHAR(MAX),
    @delimiter VARCHAR(50)
)
RETURNS @Table TABLE(
	Splitcolumn VARCHAR(MAX)
) 
BEGIN
     Declare @Xml AS XML
     SET @Xml = cast(('<A>'+replace(@String,@delimiter,'</A><A>')+'</A>') AS XML)
     INSERT INTO @Table SELECT A.value('.', 'varchar(max)') as [Column] FROM @Xml.nodes('A') AS FN(A)
RETURN
END
