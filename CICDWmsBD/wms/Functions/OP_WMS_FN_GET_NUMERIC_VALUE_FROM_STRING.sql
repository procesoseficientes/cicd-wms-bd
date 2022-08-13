-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-02 @ Team ERGON - Sprint ERGON II
-- Description:	 Funcion para obtener un valor numerico de un string




/*
-- Ejemplo de Ejecucion:
			DECLARE @ERP_REF VARCHAR(50) = 'No. Salida: 6;No. Entrada: 19;'
      SELECT  @ERP_REF
        ,[wms].[OP_WMS_FN_GET_NUMERIC_VALUE_FROM_STRING](@ERP_REF) 
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_NUMERIC_VALUE_FROM_STRING] (@strAlphaNumeric VARCHAR(256))
RETURNS VARCHAR(256)
AS
BEGIN
  DECLARE @intAlpha INT
  SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric)
  BEGIN
    WHILE @intAlpha > 0
    BEGIN
      SET @strAlphaNumeric = STUFF(@strAlphaNumeric, @intAlpha, 1, '')
      SET @intAlpha = PATINDEX('%[^0-9]%', @strAlphaNumeric)
    END
  END
  RETURN ISNULL(@strAlphaNumeric, 0)
END