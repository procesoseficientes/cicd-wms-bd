
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	29-02-2016
-- Description:			SP que importa inventario

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [wms].[BULK_DATA_SP_IMPORT_INVENTORY]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_IMPORT_INVENTORY]
AS
BEGIN
  SET NOCOUNT ON;
  --
  MERGE [SWIFT_EXPRESS].[wms].[SWIFT_INVENTORY] SIV
  USING (SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[wms].[ERP_VIEW_INVENTORY]) EVI
  ON (
    ISNULL(SIV.[SERIAL_NUMBER], '') = ISNULL(EVI.[SERIAL_NUMBER], '')
    AND SIV.[SKU] = EVI.[SKU]
    AND EVI.LOCATION = SIV.LOCATION
    AND EVI.WAREHOUSE = SIV.WAREHOUSE
    )
  WHEN MATCHED
    THEN UPDATE
      SET SIV.[SKU_DESCRIPTION] = EVI.[SKU_DESCRIPTION]
         ,SIV.[ON_HAND] = EVI.[ON_HAND]
         ,SIV.[BATCH_ID] = EVI.[BATCH_ID]
         ,SIV.[LAST_UPDATE] = EVI.[LAST_UPDATE]
         ,SIV.[LAST_UPDATE_BY] = EVI.[LAST_UPDATE_BY]
  WHEN NOT MATCHED
    THEN INSERT ([SERIAL_NUMBER]
      , [WAREHOUSE]
      , [LOCATION]
      , [SKU]
      , [SKU_DESCRIPTION]
      , [ON_HAND]
      , [BATCH_ID]
      , [LAST_UPDATE]
      , [LAST_UPDATE_BY]
      , [TXN_ID]
      , [IS_SCANNED]
      , [RELOCATED_DATE])
        VALUES (EVI.[SERIAL_NUMBER], EVI.[WAREHOUSE], EVI.[LOCATION], EVI.[SKU], EVI.[SKU_DESCRIPTION], EVI.[ON_HAND], EVI.[BATCH_ID], EVI.[LAST_UPDATE], EVI.[LAST_UPDATE_BY], EVI.[TXN_ID], EVI.[IS_SCANNED], EVI.[RELOCATED_DATE]);
END


