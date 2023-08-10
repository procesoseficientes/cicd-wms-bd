-- =============================================
-- Author:		rudi.garcia
-- Create date: 22-02-2015
-- Description:	Obtiene las facturas activas de erp por cliente


/*
-- Ejemplo de Ejecucion:      
        
        EXEC [SONDA].SONDA_SP_GET_INVOICE_ACTIVE_BY_COSTUMER @COSTUMER = 'C001'
        
*/

-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_INVOICE_ACTIVE_BY_COSTUMER @CODE_COSTUMER AS VARCHAR(50)
AS
BEGIN

  SET NOCOUNT ON;

  DECLARE @SQL VARCHAR(8000)

  CREATE TABLE #INVOICE (
    DOC_TOTAL FLOAT
   ,PAID_TO_DATE FLOAT
   ,DOC_DUE_DATE DATETIME
   ,CARD_CODE VARCHAR(50)
   ,DOC_DATE DATETIME
  );

	  SELECT
		@SQL = ' INSERT INTO #INVOICE 
		SELECT		
			DOC_TOTAL 
			,PAID_TO_DATE 
			,DOC_DUE_DATE 
			,CARD_CODE
			,DOC_DATE
		FROM openquery ([ERPSERVER],''
		SELECT
		  IV.DocTotal AS DOC_TOTAL
		 ,IV.PaidToDate AS PAID_TO_DATE
		 ,IV.DocDueDate AS DOC_DUE_DATE
		 ,IV.CardCode AS CARD_CODE
		 ,IV.DocDate AS DOC_DATE
		FROM PRUEBA.dbo.OINV IV
		WHERE IV.DocStatus = ''''O''''
		AND (IV.CardCode = ''''' + @CODE_COSTUMER + ''''')

		'')'

	  PRINT '@SQL: ' + @SQL
	  EXEC (@SQL);

  SELECT
    *
  FROM #INVOICE i;

END
