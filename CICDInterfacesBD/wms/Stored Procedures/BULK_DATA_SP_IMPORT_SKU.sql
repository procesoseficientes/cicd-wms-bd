
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	29-02-2016
-- Description:			SP que importa SKU

-- Modificacion 17-04-2016
-- alberto.ruiz
-- Se agrego que se actualizara el nombre de la lista de precios por la lista de precios default

-- Modificacion 23-05-2016
-- alberto.ruiz
-- Se Agergo la columna USE_LINE_PICKING

-- Modificacion 27-05-2016
-- alberto.ruiz
-- Se agregaron las columnas VOLUME_CODE_UNIT y VOLUME_NAME_UNIT

-- Modificacion 3/14/2017 @ A-Team Sprint Ebonne
-- rodrigo.gomez
-- Se agregaron las columas OWNER y OWNER_ID

-- Modificacion 8/31/2017 @ Reborn-Team Sprint Collin
-- diego.as
-- Se agregan columnas ART_CODE, VAT_CODE
/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [wms].[BULK_DATA_SP_IMPORT_SKU]
				--
				SELECT * FROM [wms].[SWIFT_ERP_SKU]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_IMPORT_SKU]
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @NAME_PRICE_LIST VARCHAR(250) = ''
         ,@CODEE_PRICE_LIST INT

  -- ------------------------------------------------------------------------------------
  -- Obtiene los productos
  -- ------------------------------------------------------------------------------------
  MERGE [wms].[SWIFT_ERP_SKU] [TRG]
  USING (SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[sonda].[ERP_VIEW_SKU]) AS [SRC]
  ON [TRG].[CODE_SKU] = [SRC].[CODE_SKU] collate database_default
  WHEN MATCHED
    THEN UPDATE
      SET [TRG].[SKU] = [SRC].[SKU]
         ,[TRG].[CODE_SKU] = [SRC].[CODE_SKU]
         ,[TRG].[DESCRIPTION_SKU] = [SRC].[DESCRIPTION_SKU]
         ,[TRG].[BARCODE_SKU] = [SRC].[BARCODE_SKU]
         ,[TRG].[NAME_PROVIDER] = [SRC].[NAME_PROVIDER]
         ,[TRG].[COST] = [SRC].[COST]
         ,[TRG].[LIST_PRICE] = [SRC].[LIST_PRICE]
         ,[TRG].[MEASURE] = [SRC].[MEASURE]
         ,[TRG].[NAME_CLASSIFICATION] = [SRC].[NAME_CLASSIFICATION]
         ,[TRG].[VALUE_TEXT_CLASSIFICATION] = [SRC].[VALUE_TEXT_CLASSIFICATION]
         ,[TRG].[HANDLE_SERIAL_NUMBER] = [SRC].[HANDLE_SERIAL_NUMBER]
         ,[TRG].[HANDLE_BATCH] = [SRC].[HANDLE_BATCH]
         ,[TRG].[FROM_ERP] = [SRC].[FROM_ERP]
         ,[TRG].[PRICE] = [SRC].[PRICE]
         ,[TRG].[LIST_NUM] = [SRC].[LIST_NUM]
         ,[TRG].[CODE_PROVIDER] = [SRC].[CODE_PROVIDER]
         ,[TRG].[LAST_UPDATE] = [SRC].[LAST_UPDATE]
         ,[TRG].[LAST_UPDATE_BY] = [SRC].[LAST_UPDATE_BY]
         ,[TRG].[CODE_FAMILY_SKU] = [SRC].[CODE_FAMILY_SKU]
         ,[TRG].[USE_LINE_PICKING] = ISNULL([SRC].[USE_LINE_PICKING], 0)
         ,[TRG].[VOLUME_SKU] = [SRC].[VOLUME_SKU]
         ,[TRG].[WEIGHT_SKU] = [SRC].[WEIGHT_SKU]
         ,[TRG].[VOLUME_CODE_UNIT] = [SRC].[VOLUME_CODE_UNIT]
         ,[TRG].[VOLUME_NAME_UNIT] = [SRC].[VOLUME_NAME_UNIT]
         ,[TRG].[OWNER] = [SRC].[OWNER]
         ,[TRG].[OWNER_ID] = [SRC].[OWNER_ID]
         ,[TRG].ART_CODE = [SRC].ART_CODE
         ,[TRG].VAT_CODE = [SRC].VAT_CODE
  WHEN NOT MATCHED
    THEN INSERT ([SKU]
      , [CODE_SKU]
      , [DESCRIPTION_SKU]
      , [BARCODE_SKU]
      , [NAME_PROVIDER]
      , [COST]
      , [LIST_PRICE]
      , [MEASURE]
      , [NAME_CLASSIFICATION]
      , [VALUE_TEXT_CLASSIFICATION]
      , [HANDLE_SERIAL_NUMBER]
      , [HANDLE_BATCH]
      , [FROM_ERP]
      , [PRICE]
      , [LIST_NUM]
      , [CODE_PROVIDER]
      , [LAST_UPDATE]
      , [LAST_UPDATE_BY]
      , [CODE_FAMILY_SKU]
      , [USE_LINE_PICKING]
      , [VOLUME_SKU]
      , [WEIGHT_SKU]
      , [VOLUME_CODE_UNIT]
      , [VOLUME_NAME_UNIT]
      , [OWNER]
      , [OWNER_ID]
      , ART_CODE
      , VAT_CODE)
        VALUES ([SRC].[SKU], [SRC].[CODE_SKU], [SRC].[DESCRIPTION_SKU], [SRC].[BARCODE_SKU], [SRC].[NAME_PROVIDER], [SRC].[COST], [SRC].[LIST_PRICE], [SRC].[MEASURE], [SRC].[NAME_CLASSIFICATION], [SRC].[VALUE_TEXT_CLASSIFICATION], [SRC].[HANDLE_SERIAL_NUMBER], [SRC].[HANDLE_BATCH], [SRC].[FROM_ERP], [SRC].[PRICE], [SRC].[LIST_NUM], [SRC].[CODE_PROVIDER], [SRC].[LAST_UPDATE], [SRC].[LAST_UPDATE_BY], [SRC].[CODE_FAMILY_SKU], ISNULL([SRC].[USE_LINE_PICKING], 0), [SRC].[VOLUME_SKU], [SRC].[WEIGHT_SKU], [SRC].[VOLUME_CODE_UNIT], [SRC].[VOLUME_NAME_UNIT], [SRC].[OWNER], [SRC].[OWNER_ID], [SRC].ART_CODE, [SRC].VAT_CODE);

  -- ------------------------------------------------------------------------------------
  -- Obtiene el nombre de la lista de precios
  -- ------------------------------------------------------------------------------------
  SELECT
    @CODEE_PRICE_LIST = SWIFT_EXPRESS.sonda.[SWIFT_FN_GET_PARAMETER]('ERP_HARDCODE_VALUES', 'PRICE_LIST')
  --
  SELECT
    @NAME_PRICE_LIST = epl.NAME_PRICE_LIST
  FROM SWIFT_INTERFACES_ONLINE.sonda.ERP_PRICE_LIST epl

  -- ------------------------------------------------------------------------------------
  -- Obtiene coloca el nombre de la lista de preicos
  -- ------------------------------------------------------------------------------------
  UPDATE wms.SWIFT_ERP_SKU
  SET [VALUE_TEXT_CLASSIFICATION] = @NAME_PRICE_LIST
END


