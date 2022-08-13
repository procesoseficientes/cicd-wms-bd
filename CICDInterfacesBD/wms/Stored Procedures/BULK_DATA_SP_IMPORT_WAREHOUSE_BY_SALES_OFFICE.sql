
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	04-Apr-17 @ A-Team Sprint Garai
-- Description:			SP que importa las bodegas por oficina de venta

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [wms].[BULK_DATA_SP_IMPORT_WAREHOUSE_BY_SALES_OFFICE]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_IMPORT_WAREHOUSE_BY_SALES_OFFICE]
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [O].[SALES_OFFICE_ID]
   ,[O].[NAME_SALES_OFFICE]
   ,[WSO].[WAREHOUSE] [CODE_WAREHOUSE] INTO #WAREHOUSE_BY_SALES_OFFICE
  FROM [SWIFT_EXPRESS].[wms].[SWIFT_SALES_OFFICE] [O]
  INNER JOIN [SWIFT_INTERFACES_ONLINE].[wms].[ERP_VIEW_WAREHOUSE_BY_SALES_OFFICE] [WSO]
    ON (
      [O].[NAME_SALES_OFFICE] = [WSO].[NAME_SALES_OFFICE]
      )
  --
  UPDATE [W]
  SET [W].[SALES_OFFICE_ID] = [WSO].[SALES_OFFICE_ID]
  FROM [SWIFT_EXPRESS].[wms].[SWIFT_WAREHOUSES] [W]
  INNER JOIN [#WAREHOUSE_BY_SALES_OFFICE] [WSO]
    ON (
    [W].[CODE_WAREHOUSE] = [WSO].[CODE_WAREHOUSE]
    )
END


