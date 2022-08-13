
-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	28-10-2016 @ TEAM-A SPRINT 4
-- Description:			Funcion que genera una tabla de un split del caracter indicado

-- Modificado:			hector.gonzalez
-- Fecha de Creacion: 	08-11-2016 @ TEAM-A SPRINT 4
-- Description:			Se modifico la funcion ya que esta no soportaba mas de 100 registros en el split  Pagina Web:http://stackoverflow.com/questions/10914576/t-sql-split-string
/*
-- Ejemplo de Ejecucion:
       
        --
        SELECT * FROM [wms].[OP_WMS_FUNC_SPLIT]('A|B|C|D','|')
*/
-- =============================================
CREATE FUNCTION [wms].OP_WMS_FUNC_SPLIT (@STRING VARCHAR(MAX),
@DELIMITER NCHAR(1))
RETURNS TABLE
AS
  RETURN (SELECT
    [VALUE]   
    ,GETDATE()AS  DATE1
  FROM (SELECT
      [Value] = LTRIM(RTRIM(SUBSTRING(@STRING, [number],
      CHARINDEX(@DELIMITER, @STRING + @DELIMITER, [number]) - [number])))
    

    FROM (SELECT
        Number = ROW_NUMBER() OVER (ORDER BY [name])
      FROM sys.all_objects) AS x
    WHERE number <= LEN(@STRING)
    AND SUBSTRING(@DELIMITER + @STRING, [number], LEN(@DELIMITER)) = @DELIMITER) AS y
  );