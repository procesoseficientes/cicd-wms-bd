-- =============================================
-- Author:     	rudi.garcia
-- Create date: 2016-02-25 17:08:26
-- Description: Obtien el detalle de la factura

/*
Ejemplo de Ejecucion:          
	EXEC [SONDA].SONDA_SP_GET_INVOICE_ACTIVE_DETAIL @DOC_ENTRY = 12229
*/
-- =============================================

CREATE PROCEDURE [SONDA].SONDA_SP_GET_INVOICE_ACTIVE_DETAIL 
  @DOC_ENTRY AS INT
AS
BEGIN
  --    
  DECLARE @SQL VARCHAR(8000)

  SELECT
    @SQL = '
		SELECT
			DOC_NUM
			,LINE_NUM
			,ITEM_CODE
			,ITEM_DSCRIPTION
			,QUANTITY
			,PRICE
			,LINE_TOTAL
		FROM openquery ([ERPSERVER],''
		  SELECT			
			  IV.DocNum AS DOC_NUM
		   ,IND.LineNum AS LINE_NUM
		   ,IND.ItemCode AS ITEM_CODE
		   ,IND.Dscription AS ITEM_DSCRIPTION
		   ,IND.Quantity AS QUANTITY
		   ,IND.LineTotal AS LINE_TOTAL
		   ,IND.Price AS PRICE
		  FROM [Prueba].dbo.OINV IV
		  INNER JOIN [Prueba].dbo.INV1 IND ON (IV.DocEntry = IND.DocEntry)
		  WHERE IV.DocStatus = ''''O''''
		  AND IV.DocEntry = ' + CONVERT(VARCHAR(18), @DOC_ENTRY) + '
		  ORDER BY IND.LineNum
		'')'
  PRINT '@SQL: ' + @SQL
  EXEC (@SQL)

END
