-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-25 @ Team ERGON - Sprint ERGON 1
-- Description:	 Eliminar un componente de un master pack.




/*
-- Ejemplo de Ejecucion:
			  EXEC [wms].[OP_WMS_SP_INSERT_MASTER_PACK_COMPONENT] @MASTER_PACK_CODE = 'C00015/AMERQUIM'
                                                                   ,@COMPONENT_MATERIAL = 'C00015/BATIDORA'
                                                                   ,@MEASURE_UNIT_ID = 18
                                                                   ,@QTY = 5

  SELECT * FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_MASTER_PACK_COMPONENT] (@MASTER_PACK_COMPONENT_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DELETE [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] WHERE [MASTER_PACK_COMPONENT_ID] = @MASTER_PACK_COMPONENT_ID

END