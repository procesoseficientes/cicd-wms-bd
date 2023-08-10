
-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		4/20/2017 @ A-Team Sprint Hondo
-- Description:			    Funcion que obtiene el Balance de la cuenta del Cliente

/*
-- Ejemplo de Ejecucion:
        SELECT [SONDA].[SONDA_FUNC_GET_PREVIUS_BALANCE_FOR_CUSTOMER] ('928') AS PREVIUES_BALANCE
*/
-- =============================================
CREATE FUNCTION [SONDA].[SONDA_FUNC_GET_PREVIUS_BALANCE_FOR_CUSTOMER](
@CODE_CUSTOMER VARCHAR(250)
)
RETURNS DECIMAL(18,6)
AS
BEGIN
	DECLARE @SQL VARCHAR(8000)
			,@PREVIUS_BALANCE DECIMAL(18,6) = 0;

	DECLARE @INVOICE TABLE(
		DOC_TOTAL FLOAT
	   ,PAID_TO_DATE FLOAT
	   ,DOC_DUE_DATE DATETIME
	   ,CARD_CODE VARCHAR(50)
	   ,DOC_DATE DATETIME
	  );
	--
	 INSERT INTO @INVOICE
	 SELECT		
			DOC_TOTAL 
			,PAID_TO_DATE 
			,DOC_DUE_DATE 
			,CARD_CODE
			,DOC_DATE
		FROM openquery ([ERP_SERVER],'
		SELECT
		  IV.DocTotal AS DOC_TOTAL
		 ,IV.PaidToDate AS PAID_TO_DATE
		 ,IV.DocDueDate AS DOC_DUE_DATE
		 ,IV.CardCode AS CARD_CODE
		 ,IV.DocDate AS DOC_DATE
		FROM [PRUEBA].[dbo].[OINV] IV
		WHERE IV.DocStatus = ''O''
		');
		--
	SELECT @PREVIUS_BALANCE = SUM(ISNULL(DOC_TOTAL, 0)) 
	FROM @INVOICE 
	WHERE [CARD_CODE] = @CODE_CUSTOMER;
	--
	RETURN ISNULL(@PREVIUS_BALANCE,0);
 END;
