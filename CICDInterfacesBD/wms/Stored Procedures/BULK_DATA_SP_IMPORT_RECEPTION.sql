
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	29-02-2016
-- Description:			SP que importa recepciones

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [wms].[BULK_DATA_SP_IMPORT_RECEPTION]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_IMPORT_RECEPTION]
AS
BEGIN
  SET NOCOUNT ON;
  --
  DELETE FROM [wms].[SWIFT_ERP_RECEPTION]
  INSERT INTO [wms].[SWIFT_ERP_RECEPTION]
    SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[wms].[ERP_VIEW_RECEPTION]
END


