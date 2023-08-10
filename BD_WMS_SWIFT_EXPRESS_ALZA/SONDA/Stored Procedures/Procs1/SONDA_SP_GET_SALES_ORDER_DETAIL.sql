-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	12-4-2015
-- Description:			Obtine las detalles de Ordenes de venta dependiendo del SALES_ORDER_ID

/*
-- Ejemplo de Ejecucion:
				exec [SONDA].[SONDA_SP_GET_SALES_ORDER_DETAIL]  @SALES_ORDER_ID = 4021
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_SALES_ORDER_DETAIL
	@SALES_ORDER_ID INT

AS
BEGIN
	SET NOCOUNT ON;

  UPDATE [SONDA].[SONDA_SALES_ORDER_DETAIL]
    SET IS_ACTIVE_ROUTE = 1
    WHERE SALES_ORDER_ID = @SALES_ORDER_ID
      
	SELECT 
		D.[SALES_ORDER_ID]
		,D.[SKU]
		,D.[LINE_SEQ]
		,D.[QTY]
		,D.[PRICE]
		,D.[DISCOUNT]
		,D.[TOTAL_LINE]
		,D.[POSTED_DATETIME]
		,D.[SERIE]
		,D.[SERIE_2]
		,D.[REQUERIES_SERIE]
		,D.[COMBO_REFERENCE]
		,D.[PARENT_SEQ]
		,D.[IS_ACTIVE_ROUTE]
    ,D.[CODE_PACK_UNIT]  
	FROM [SONDA].[SONDA_SALES_ORDER_DETAIL] D
	WHERE D.SALES_ORDER_ID = @SALES_ORDER_ID

END
