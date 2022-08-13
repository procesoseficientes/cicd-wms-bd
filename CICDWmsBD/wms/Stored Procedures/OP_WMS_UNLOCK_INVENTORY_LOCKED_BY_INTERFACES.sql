
-- =============================================
-- Autor:	rudi.garcia
-- Fecha de Creacion: 	2017-09-19 @ Team Reborn - Sprint Collin
-- Description:	 Desbloquea el inventario de la recepcion de erp
/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_UNLOCK_INVENTORY_LOCKED_BY_INTERFACES  @RECEPTION_DOCUMENT_ID = 456
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_UNLOCK_INVENTORY_LOCKED_BY_INTERFACES  (@RECEPTION_DOCUMENT_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @CLIENT_CODE VARCHAR(50)
         ,@EXPLODE_IN_RECEPTION INT
         ,@LOGIN_NAME VARCHAR(50)
         ,@AUTOMATIC_AUTHORIZATION INT = 0


  ---------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------
  -- Se desbloquea el inventario
  ---------------------------------------------------------------------------------  
  ---------------------------------------------------------------------------------
  
  
  UPDATE [IL] SET
    [IL].[LOCKED_BY_INTERFACES] = 0
  FROM [wms].[OP_WMS_INV_X_LICENSE] [IL] 
  INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON(
    [IL].[LICENSE_ID] = [L].[LICENSE_ID]
  )
  INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON (
    [L].[CODIGO_POLIZA] = [TL].[CODIGO_POLIZA_SOURCE]
  )
  INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH] ON (
    [RDH].[TASK_ID] = [TL].[SERIAL_NUMBER]
  )
  WHERE [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID


END