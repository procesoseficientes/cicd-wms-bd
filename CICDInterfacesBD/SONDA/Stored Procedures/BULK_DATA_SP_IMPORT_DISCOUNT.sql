
-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 18-08-2016
-- Description:			SP que importa los descuentos

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC SWIFT_INTERFACES.[SONDA].[BULK_DATA_SP_IMPORT_DISCOUNT]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[BULK_DATA_SP_IMPORT_DISCOUNT]
AS
BEGIN
  SET NOCOUNT ON;
  
  -- ------------------------------------------------------------------------------------
  -- Obtiene las listas descuento 
  -- ------------------------------------------------------------------------------------
  TRUNCATE TABLE SWIFT_EXPRESS.[SONDA].SWIFT_DISCOUNT_LIST
  --
  INSERT INTO SWIFT_EXPRESS.[SONDA].SWIFT_DISCOUNT_LIST(
    NAME_DISCOUNT_LIST
  )
  SELECT
    R.CODE_ROUTE + '|' + C.CODE_CUSTOMER AS NAME_BONUS_LIST
  FROM SWIFT_INTERFACES_ONLINE.[SONDA].ERP_VIEW_ROUTE R
  INNER JOIN SWIFT_INTERFACES_ONLINE.[SONDA].ERP_VIEW_COSTUMER C ON (
    R.CODE_ROUTE = C.CODE_ROUTE
  )
  

  -- ------------------------------------------------------------------------------------
  -- Obtiene los clientes para la lista descuento
  -- ------------------------------------------------------------------------------------
  TRUNCATE TABLE SWIFT_EXPRESS.[SONDA].SWIFT_DISCOUNT_LIST_BY_CUSTOMER
  --
  INSERT INTO SWIFT_EXPRESS.[SONDA].SWIFT_DISCOUNT_LIST_BY_CUSTOMER(
    DISCOUNT_LIST_ID
    ,CODE_CUSTOMER
  )
  SELECT
    DL.DISCOUNT_LIST_ID
    ,C.CODE_CUSTOMER
  FROM SWIFT_INTERFACES_ONLINE.[SONDA].ERP_VIEW_ROUTE R
  INNER JOIN SWIFT_INTERFACES_ONLINE.[SONDA].ERP_VIEW_COSTUMER C ON (
    R.CODE_ROUTE = C.CODE_ROUTE
  )
  INNER JOIN SWIFT_EXPRESS.[SONDA].SWIFT_DISCOUNT_LIST DL ON (
    DL.NAME_DISCOUNT_LIST = (R.CODE_ROUTE + '|' + C.CODE_CUSTOMER)
  )

  -- ------------------------------------------------------------------------------------
  -- Obtiene los sku para la lista descuento
  -- ------------------------------------------------------------------------------------
  TRUNCATE TABLE SWIFT_EXPRESS.[SONDA].SWIFT_DISCOUNT_LIST_BY_SKU
  --
  INSERT INTO SWIFT_EXPRESS.[SONDA].SWIFT_DISCOUNT_LIST_BY_SKU(
    DISCOUNT_LIST_ID
    ,CODE_SKU
    ,DISCOUNT
  )
  SELECT     
    DL.DISCOUNT_LIST_ID
    ,DLS.SKU
    ,DLS.DISCOUNT
  FROM SWIFT_INTERFACES_ONLINE.[SONDA].ERP_VIEW_DISCOUNT DLS  
  INNER JOIN SWIFT_EXPRESS.[SONDA].SWIFT_DISCOUNT_LIST DL ON (
    DL.NAME_DISCOUNT_LIST = (DLS.CODE_ROUTE + '|' + DLS.CODE_CUSTOMER)
  )


END