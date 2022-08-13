
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	29-02-2016
-- Description:			SP que importa lista de precios por cliente

-- Modificacion 25-Apr-17 @ A-Team Sprint Hondo
-- alberto.ruiz
-- Se agrego el campo owner

/*
-- Ejemplo de Ejecucion:
				-- TIME 0:40:45:617
				EXEC [wms].[BULK_DATA_SP_IMPORT_PRICE_LIST_BY_CUSTOMER]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_IMPORT_PRICE_LIST_BY_CUSTOMER]
AS
BEGIN
  SET NOCOUNT ON;
  --
  ------------------------------------------------------------------------------------
  -- Merge para [SWIFT_PRICE_LIST_BY_CUSTOMER] con SAP
  -- ------------------------------------------------------------------------------------

  MERGE [SWIFT_EXPRESS].[wms].[SWIFT_PRICE_LIST_BY_CUSTOMER] [TGR]
  USING (SELECT
      *
    FROM [SWIFT_INTERFACES_ONLINE].[wms].[ERP_PRICE_LIST_BY_CUSTOMER]) [SRC]
  ON [TGR].[CODE_CUSTOMER] = [SRC].[CODE_CUSTOMER]
  WHEN MATCHED
    THEN UPDATE
      SET [TGR].[CODE_PRICE_LIST] = [SRC].[CODE_PRICE_LIST]
         ,[TGR].[OWNER] = [SRC].[OWNER]

  WHEN NOT MATCHED
    THEN INSERT ([CODE_PRICE_LIST]
      , [CODE_CUSTOMER]
      , [OWNER])
        VALUES ([SRC].[CODE_PRICE_LIST], [SRC].[CODE_CUSTOMER], [SRC].[OWNER]);

END


