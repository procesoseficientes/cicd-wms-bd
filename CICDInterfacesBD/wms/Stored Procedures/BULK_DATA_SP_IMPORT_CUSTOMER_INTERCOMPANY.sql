
-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		08-Jun-17 @ A-Team Sprint Jibade
-- Description:			    SP para obtener el codigo de cliente por cada base de datos de la multiempresa

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[BULK_DATA_SP_IMPORT_CUSTOMER_INTERCOMPANY]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_IMPORT_CUSTOMER_INTERCOMPANY]
AS
BEGIN
  SET NOCOUNT ON;
  --
  TRUNCATE TABLE [SWIFT_EXPRESS].[wms].[SWIFT_CUSTOMER_INTERCOMPAY]
  --
  INSERT INTO [SWIFT_EXPRESS].[wms].[SWIFT_CUSTOMER_INTERCOMPAY] ([MASTER_ID]
  , [CARD_CODE]
  , [SOURCE])
    SELECT
      [MASTER_ID]
     ,[CARD_CODE]
     ,[SOURCE]
    FROM [SWIFT_INTERFACES_ONLINE].[wms].[ERP_VIEW_CUSTOMER_SOURCE]
END


