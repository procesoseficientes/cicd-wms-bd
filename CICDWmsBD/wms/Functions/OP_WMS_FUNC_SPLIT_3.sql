
-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creación: 	2017-05-22 ErgonTeam@Sheik
-- Description:	 Se modifica para que la función de split devuelva el correlativo del split. 

/*
-- Ejemplo de Ejecucion:
    
        --
        SELECT * FROM [wms].OP_WMS_FUNC_SPLIT_3('A|B|C|D','|')
*/
-- =============================================
CREATE FUNCTION [wms].OP_WMS_FUNC_SPLIT_3 (@STRING VARCHAR(MAX),
@DELIMITER NCHAR(1))
RETURNS TABLE
AS
  RETURN (SELECT
    [VALUE]
   ,ROW_NUMBER() OVER (ORDER BY DATE1) ID
  FROM [wms].[OP_WMS_FUNC_SPLIT](@STRING, @DELIMITER)
  );