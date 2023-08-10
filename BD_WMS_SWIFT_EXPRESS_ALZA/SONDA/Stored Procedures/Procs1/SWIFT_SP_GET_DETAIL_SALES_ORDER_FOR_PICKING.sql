-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	1-Ene-2017 @ A-TEAM Sprint Balder
-- Description:			Obtiene el detalle de las orden de venta
/*
-- Ejemplo de Ejecucion:
        USE SWIFT_EXPRESS
        GO
        --
        EXEC [SONDA].SWIFT_SP_GET_DETAIL_SALES_ORDER_FOR_PICKING			    
			    @SALES_ORDERS_IDS = '33698|33699'
			    
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_DETAIL_SALES_ORDER_FOR_PICKING(
  @SALES_ORDERS_IDS VARCHAR(MAX)
)
AS
BEGIN
  DECLARE @DELIMITER CHAR(1)  

  -- ------------------------------------------------------------------------------------
  -- Obtiene el delimitador
  -- ------------------------------------------------------------------------------------
  SELECT
    @DELIMITER = P.VALUE
  FROM [SONDA].SWIFT_PARAMETER P
  WHERE P.GROUP_ID = 'DELIMITER'
  AND P.PARAMETER_ID = 'DEFAULT_DELIMITER'

  -- ------------------------------------------------------------------------------------
  -- Obtiene las ordenes de venta
  -- ------------------------------------------------------------------------------------
  SELECT
    S.Id
   ,S.VALUE SALES_ORDER_ID 
  INTO #SALES_ORDER
  FROM [SONDA].[SWIFT_FN_SPLIT](@SALES_ORDERS_IDS, @DELIMITER) S

  -- ------------------------------------------------------------------------------------
  -- Obtiene el detalle de las ordenes de venta
  -- ------------------------------------------------------------------------------------

  SELECT
    SOD.SALES_ORDER_ID
   ,SO.DOC_SERIE
   ,SO.DOC_NUM
   ,VC.CODE_CUSTOMER
   ,VC.NAME_CUSTOMER
   ,SO.POS_TERMINAL
   ,SO.POSTED_DATETIME
   ,SOD.SKU
   ,VS.DESCRIPTION_SKU
   ,SOD.LINE_SEQ
   ,SOD.QTY
   ,SOD.PRICE
   ,SOD.DISCOUNT
   ,SOD.TOTAL_LINE
   ,SOD.POSTED_DATETIME
   ,SOD.SERIE
   ,SOD.SERIE_2
   ,SOD.REQUERIES_SERIE
   ,SOD.COMBO_REFERENCE
   ,SOD.PARENT_SEQ
   ,SOD.IS_ACTIVE_ROUTE
   ,SOD.CODE_PACK_UNIT
   ,SOD.IS_BONUS
   ,SOD.LONG
   ,SO.WAREHOUSE AS CODE_WAREHOUSE
   ,U.RELATED_SELLER AS CODE_SELLER
  FROM [SONDA].SONDA_SALES_ORDER_DETAIL SOD
  INNER JOIN #SALES_ORDER SOT ON (
    SOT.SALES_ORDER_ID = SOD.SALES_ORDER_ID
  )
  INNER JOIN [SONDA].SONDA_SALES_ORDER_HEADER SO ON(
    SO.SALES_ORDER_ID = SOT.SALES_ORDER_ID
  )
  INNER JOIN [SONDA].SWIFT_VIEW_ALL_SKU VS ON (
    VS.CODE_SKU = SOD.SKU
  )
  INNER JOIN [SONDA].SWIFT_VIEW_ALL_COSTUMER VC ON(
    VC.CODE_CUSTOMER = SO.CLIENT_ID
  )
  INNER JOIN [SONDA].USERS U ON(
    U.LOGIN = SO.POSTED_BY
  )
  WHERE SO.IS_READY_TO_SEND=1
END
