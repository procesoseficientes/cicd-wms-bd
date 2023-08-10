-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	12-4-2015
-- Description:			Obtine los detalles de las facturas, parametros: resolucion, serie e idfactura

/*
-- Ejemplo de Ejecucion:
				exec [SONDA].[SONDA_SP_GET_INVOICE_DETAIL]  
				@RESOLUCION = '001'
				,@SERIE = '0'
				,@INVOICE_ID =35

*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_INVOICE_DETAIL]
	@RESOLUCION VARCHAR(50)
	,@SERIE VARCHAR(50)
	,@INVOICE_ID INT
AS
BEGIN
	SET NOCOUNT ON;


  UPDATE [SONDA].[SONDA_POS_INVOICE_DETAIL]
    SET IS_ACTIVE_ROUTE = 1
    WHERE INVOICE_RESOLUTION = @RESOLUCION 
      AND SERIE = @SERIE 
      AND INVOICE_ID = @INVOICE_ID

	SELECT 
		D.[INVOICE_ID]
		,D.[INVOICE_SERIAL]
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
		,D.[INVOICE_RESOLUTION]
		,D.[PARENT_SEQ]
		,D.[IS_ACTIVE_ROUTE]
	FROM [SONDA].[SONDA_POS_INVOICE_DETAIL] D
	WHERE D.INVOICE_RESOLUTION = @RESOLUCION 
    AND D.INVOICE_SERIAL = @SERIE 
    AND D.INVOICE_ID = @INVOICE_ID

END
