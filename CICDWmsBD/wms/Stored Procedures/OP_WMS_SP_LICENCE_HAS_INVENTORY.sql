
-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2016-11-29
-- Description:	 Se eliminar cualquier operación que se haya realizado sobre una licencia 




/*
-- Ejemplo de Ejecucion:
	  EXEC [wms].[OP_WMS_SP_LICENCE_HAS_INVENTOR] @LICENCE_ID = 189	
    SELECT * FROM [wms].[OP_WMS_LICENSES] [OWL]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_LICENCE_HAS_INVENTORY] (@LICENCE_ID NUMERIC(18, 0))
AS
BEGIN

  SET NOCOUNT ON;
  DECLARE @RESULT INT = 0

  SELECT TOP 1
    @RESULT = 1
  FROM [wms].[OP_WMS_INV_X_LICENSE] [I]
    WHERE [I].[LICENSE_ID] = @LICENCE_ID
    AND [I].[QTY] > 0

    SELECT @RESULT AS RESULT 

END