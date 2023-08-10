
-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 18-08-2016
-- Description:			SP que importa las bonificiaciones

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[BULK_DATA_SP_IMPORT_BONUS]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[BULK_DATA_SP_IMPORT_BONUS]
AS
BEGIN
  SET NOCOUNT ON;
  
  -- ------------------------------------------------------------------------------------
  -- Obtiene las listas de bonificaciones 
  -- ------------------------------------------------------------------------------------
  TRUNCATE TABLE SWIFT_EXPRESS.[SONDA].SWIFT_BONUS_LIST
  --
  INSERT INTO SWIFT_EXPRESS.[SONDA].SWIFT_BONUS_LIST(
    NAME_BONUS_LIST
  )
  SELECT
    R.CODE_ROUTE + '|' + C.CODE_CUSTOMER AS NAME_BONUS_LIST
  FROM SWIFT_INTERFACES_ONLINE.[SONDA].ERP_VIEW_ROUTE R
  INNER JOIN SWIFT_INTERFACES_ONLINE.[SONDA].ERP_VIEW_COSTUMER C ON (
    R.CODE_ROUTE = C.CODE_ROUTE
  )

  -- ------------------------------------------------------------------------------------
  -- Obtiene los clientes para la lista de bonos
  -- ------------------------------------------------------------------------------------
  TRUNCATE TABLE SWIFT_EXPRESS.[SONDA].SWIFT_BONUS_LIST_BY_CUSTOMER
  --
  INSERT INTO SWIFT_EXPRESS.[SONDA].SWIFT_BONUS_LIST_BY_CUSTOMER(
    BONUS_LIST_ID
    , CODE_CUSTOMER
  )
  SELECT
    BL.BONUS_LIST_ID
    ,C.CODE_CUSTOMER
  FROM SWIFT_INTERFACES_ONLINE.[SONDA].ERP_VIEW_ROUTE R
  INNER JOIN SWIFT_INTERFACES_ONLINE.[SONDA].ERP_VIEW_COSTUMER C ON (
    R.CODE_ROUTE = C.CODE_ROUTE
  )
  INNER JOIN SWIFT_EXPRESS.[SONDA].SWIFT_BONUS_LIST BL ON (
    BL.NAME_BONUS_LIST = (R.CODE_ROUTE + '|' + C.CODE_CUSTOMER)
  )
  -- ------------------------------------------------------------------------------------
  -- Obtiene los sku para la lista de bonos
  -- ------------------------------------------------------------------------------------
  TRUNCATE TABLE SWIFT_EXPRESS.[SONDA].SWIFT_BONUS_LIST_BY_SKU
  --
  INSERT INTO SWIFT_EXPRESS.[SONDA].SWIFT_BONUS_LIST_BY_SKU(
    BONUS_LIST_ID
    ,CODE_SKU
    ,CODE_PACK_UNIT
    ,LOW_LIMIT
    ,HIGH_LIMIT
    ,CODE_SKU_BONUS
    ,BONUS_QTY
    ,CODE_PACK_UNIT_BONUES
  )
  SELECT 
    BL.BONUS_LIST_ID
    ,B.SKU
    ,B.SKU_PACK_UNIT
    ,B.LOW_LIMIT
    ,B.HIGT_LIMIT
    ,B.BONUS_SKU
    ,B.BONUS_QTY
    ,B.BONUS_PACK_UNIT
  FROM SWIFT_INTERFACES_ONLINE.[SONDA].ERP_VIEW_BONUS B  
  INNER JOIN SWIFT_EXPRESS.[SONDA].SWIFT_BONUS_LIST BL ON (
    BL.NAME_BONUS_LIST = (B.CODE_ROUTE + '|' + B.CODE_CUSTOMER)
  )

END