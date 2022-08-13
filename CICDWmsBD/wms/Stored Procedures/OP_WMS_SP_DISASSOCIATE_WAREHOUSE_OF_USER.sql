-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-30 @ Team ERGON - Sprint ERGON II
-- Description:	 Obtiene todas las bodegas asociadas a un usuario




/*
-- Ejemplo de Ejecucion:
  SELECT * FROM  [wms].[OP_WMS_WAREHOUSE_BY_USER]
			EXEC [wms].[OP_WMS_SP_DISASSOCIATE_WAREHOUSE_OF_USER] @WAREHOUSE_BY_USER_ID = 1
  SELECT * FROM  [wms].[OP_WMS_WAREHOUSE_BY_USER]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DISASSOCIATE_WAREHOUSE_OF_USER] (@WAREHOUSE_BY_USER_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DELETE [wms].[OP_WMS_WAREHOUSE_BY_USER]
  WHERE [WAREHOUSE_BY_USER_ID] = @WAREHOUSE_BY_USER_ID
END