-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	03-03-2016
-- Description:			obtiene los detalles de facturas y pedidos 

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_GET_SKU_BY_ORDER]
			@DOC_TYPE = 'SALES_ORDER'
			,@DOC_RESOLUTION = 'NA'
			,@DOC_SERIE = 'C'
			,@DOC_ID = '38'
		--
		EXEC [SONDA].[SWIFT_SP_GET_SKU_BY_ORDER]
			@DOC_TYPE = 'INVOICE'
			,@DOC_RESOLUTION = 'Oper17@arium'
			,@DOC_SERIE = 'Oper17@arium'
			,@DOC_ID = '2'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SKU_BY_ORDER] (
	@DOC_TYPE VARCHAR(20)
	,@DOC_RESOLUTION VARCHAR(50)
	,@DOC_SERIE VARCHAR(100)
	,@DOC_ID VARCHAR(50)
)
AS
BEGIN
	SELECT 
		D.DOC_ID
		,D.SKU_ID
		,D.SKU_DESCRIPTION
		,D.QTY
		,D.SKU_PRICE
		,D.TOTAL_LINE
		,D.INVOICE_RESOLUTION
	FROM [SONDA].SWIFT_VIEW_DOCUMENTS_DETAIL D
	WHERE
		D.DOC_TYPE = @DOC_TYPE
		AND D.INVOICE_RESOLUTION = @DOC_RESOLUTION
		AND D.DOC_SERIE = @DOC_SERIE
		AND DOC_ID = @DOC_ID	
END
