-- =============================================
-- Author:		diego.as
-- Create date: 06-12-2016 @TEM-A S
-- Description:	Obtiene las facturas vencidas de erp por cliente

/*
-- Ejemplo de Ejecucion:      
				EXEC [SONDA].[SONDA_SP_GET_ACTIVE_OVERDUE_INVOICE_BY_COSTUMER]
					@CODE_COSTUMER = '11'
				--
				EXEC [SONDA].[SONDA_SP_GET_ACTIVE_OVERDUE_INVOICE_BY_COSTUMER]
					@CODE_COSTUMER = '2120'

*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_ACTIVE_OVERDUE_INVOICE_BY_COSTUMER 
	@CODE_CUSTOMER AS VARCHAR(50)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @SQL VARCHAR(8000)
  --
  CREATE TABLE #INVOICE(
	[DOC_NUM] INT    
	,[DOC_TOTAL] FLOAT
	,[PAID_TO_DATE] FLOAT
	,[DOC_DUE_DATE] DATETIME
	,[CODE_CUSTOMER] VARCHAR(50)
	,[DOC_DATE] DATETIME
	,[OVERDUE_DAYS] INT
  )
  --
	SELECT
	@SQL = ' INSERT INTO #INVOICE 
	SELECT
		DOC_NUM
		,DOC_TOTAL 
		,PAID_TO_DATE 
		,DOC_DUE_DATE 
		,CARD_CODE
		,DOC_DATE
		,DATEDIFF(DAY,[DOC_DUE_DATE],GETDATE()) [OVERDUE_DAYS]
	FROM openquery ([ERPSERVER],''
	SELECT
		IV.DocNum AS DOC_NUM
		,IV.DocTotal AS DOC_TOTAL
		,IV.PaidToDate AS PAID_TO_DATE
		,IV.DocDueDate AS DOC_DUE_DATE
		,IV.CardCode AS CARD_CODE
		,IV.DocDate AS DOC_DATE
	FROM PRUEBA.dbo.OINV IV
	WHERE IV.DocStatus = ''''O''''
	AND IV.DocNum < GETDATE()
	AND (IV.CardCode = ''''' + @CODE_CUSTOMER + ''''')
	'')'
	--
	PRINT '@SQL: ' + @SQL
	--
	EXEC (@SQL);
	---
	SELECT
		[I].[DOC_NUM]
		,[I].[DOC_TOTAL]
		,[I].[PAID_TO_DATE]
		,[I].[DOC_DUE_DATE]
		,[I].[CODE_CUSTOMER]
		,[I].[DOC_DATE]
		,[I].[OVERDUE_DAYS]
	FROM [#INVOICE] [I]
END
