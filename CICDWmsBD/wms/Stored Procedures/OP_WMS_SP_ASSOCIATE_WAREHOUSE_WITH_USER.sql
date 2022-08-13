-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-30 @ Team ERGON - Sprint ERGON II
-- Description:	 Obtiene todas las bodegas asociadas a un usuario




/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_ASSOCIATE_WAREHOUSE_WITH_USER] @LOGIN_ID = 'ACAMACHO', WAREHOUSE = 'BODEGA_02'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_ASSOCIATE_WAREHOUSE_WITH_USER] (@LOGIN_ID VARCHAR(25)
, @WAREHOUSE VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  INSERT INTO [wms].[OP_WMS_WAREHOUSE_BY_USER] ([LOGIN_ID], [WAREHOUSE_ID])
    VALUES (@LOGIN_ID, @WAREHOUSE);
END