
-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	2017-10-11
-- Description:			SP que importa MATERIALES con su Familia (categoria)

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [wms].[BULK_DATA_SP_IMPORT_MATERIALS_WITH_CATEGORY]
				--
				SELECT * FROM [OP_WMS_wms].[wms].[OP_WMS_MATERIALS_WITH_CATEGORY]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_IMPORT_MATERIALS_WITH_CATEGORY]
AS
BEGIN
  SET NOCOUNT ON;
  --

  -- ------------------------------------------------------------------------------------
  -- Obtiene los productos
  -- ------------------------------------------------------------------------------------
  MERGE [OP_WMS_wms].[wms].[OP_WMS_MATERIALS_WITH_CATEGORY] [TRG]
  USING (SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[wms].[ERP_VIEW_MATERIALS_WITH_CATEGORY]) AS [SRC]
  ON [TRG].[ITEM_CODE] = [SRC].[ITEM_CODE] COLLATE DATABASE_DEFAULT
  WHEN MATCHED
    THEN UPDATE
      SET [TRG].[ITEM_CODE] = [SRC].[ITEM_CODE]
         ,TRG.ITEM_CODE_ERP = [SRC].ITEM_CODE_ERP
         ,[TRG].ITEM_NAME = [SRC].ITEM_NAME
         ,[TRG].CATEGORY_CODE = [SRC].CATEGORY_CODE
         ,[TRG].CATEGORY_NAME = [SRC].CATEGORY_NAME

  WHEN NOT MATCHED
    THEN INSERT ([ITEM_CODE]
      , ITEM_CODE_ERP
      , ITEM_NAME
      , CATEGORY_CODE
      , CATEGORY_NAME)
        VALUES ([SRC].[ITEM_CODE], [SRC].ITEM_CODE_ERP, [SRC].ITEM_NAME, [SRC].CATEGORY_CODE, [SRC].CATEGORY_NAME);


END


