
-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		8/25/2017 @ NEXUS-Team Sprint 
-- Description:			    Inserta todas las listas de precio asignadas a los proveedores y clientes en la tabla OP_WMS_COMPANY de OP_WMS

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [OP_WMS_SERVER].[OP_WMS_wms].[wms].[OP_WMS_PRICE_LIST_FOR_INTERCOMPANY]
		--
		EXEC [wms].[BULK_DATA_SP_IMPORT_PRICE_LIST_FOR_INTERCOMPANY_FOR_OP_WMS]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_IMPORT_PRICE_LIST_FOR_INTERCOMPANY_FOR_OP_WMS]
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [MASTER_ID_SUPPLIER] [MASTER_ID_COMPANY] INTO [#COMPANIES]
  FROM [OP_WMS_wms].[wms].[OP_WMS_COMPANY]
  WHERE [MASTER_ID_SUPPLIER] <> ''
  --
  INSERT INTO [#COMPANIES]
    SELECT
      [MASTER_ID_CLIENT_CODE] [MASTER_ID_COMPANY]
    FROM [OP_WMS_wms].[wms].[OP_WMS_COMPANY]
    WHERE [MASTER_ID_CLIENT_CODE] <> ''
  --
  DELETE FROM [OP_WMS_wms].[wms].[OP_WMS_PRICE_LIST_FOR_INTERCOMPANY]
  --
  INSERT INTO [OP_WMS_wms].[wms].[OP_WMS_PRICE_LIST_FOR_INTERCOMPANY] ([MASTER_ID_CUSTOMER]
  , [PRICE_LIST]
  , [MATERIAL_ID]
  , [PRICE]
  , [SOURCE])
    SELECT
      [CS].[MASTER_ID]
     ,[CS].[PRICE_LIST]
     ,[PLS].[ITEM_CODE]
     ,[PLS].[PRICE]
     ,[CS].[SOURCE]
    FROM [SWIFT_INTERFACES_ONLINE].[wms].[ERP_VIEW_PRICE_LIST_SOURCE] [PLS]
    INNER JOIN [SWIFT_INTERFACES_ONLINE].[wms].[ERP_VIEW_CUSTOMER_SOURCE] [CS]
      ON [CS].[PRICE_LIST] = [PLS].[PRICE_LIST]
        AND [CS].[SOURCE] = [PLS].[SOURCE]
    INNER JOIN [#COMPANIES] [C]
      ON [CS].[MASTER_ID] = [C].[MASTER_ID_COMPANY] COLLATE DATABASE_DEFAULT
END


