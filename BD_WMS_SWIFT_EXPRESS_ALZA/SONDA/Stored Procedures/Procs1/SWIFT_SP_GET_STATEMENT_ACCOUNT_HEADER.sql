-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	06-Dec-16 @ A-TEAM Sprint 6 
-- Description:			SP que obtiene el estado de cuenta del cliente

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_STATEMENT_ACCOUNT_HEADER]
					@CODE_CUSTOMER = '11'
				--
				EXEC [SONDA].[SWIFT_SP_GET_STATEMENT_ACCOUNT_HEADER]
					@CODE_CUSTOMER = '2120'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_STATEMENT_ACCOUNT_HEADER](
	@CODE_CUSTOMER VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @INVOICE TABLE(
		[DOC_NUM] INT    
		,[DOC_TOTAL] FLOAT
		,[PAID_TO_DATE] FLOAT
		,[DOC_DUE_DATE] DATETIME
		,[CODE_CUSTOMER] VARCHAR(50)
		,[DOC_DATE] DATETIME
		,[OVERDUE_DAYS] INT
	)
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene las facturas del cliente
	-- ------------------------------------------------------------------------------------
	INSERT INTO @INVOICE
	EXEC [SONDA].[SONDA_SP_GET_ACTIVE_OVERDUE_INVOICE_BY_COSTUMER] 
		@CODE_CUSTOMER = @CODE_CUSTOMER
	
	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	SELECT
		[C].[CODE_CUSTOMER]
		,MAX([C].[NAME_CUSTOMER]) [NAME_CUSTOMER]
		,MAX([C].[CREDIT_LIMIT]) [CREDIT_LIMIT]
		,MAX([C].[EXTRA_DAYS]) [EXTRA_DAYS]
    ,SUM([I].[DOC_TOTAL])  [TOTAL]
    ,SUM([I].[PAID_TO_DATE]) [PAID_TO_DATE]
    ,ISNULL( SUM([I].[DOC_TOTAL]), 0)  -  ISNULL( SUM([I].[PAID_TO_DATE]),0) [TOTAL_CREDIT]
    ,MAX([C].[CREDIT_LIMIT] ) - (ISNULL( SUM([I].[DOC_TOTAL]), 0)  -  ISNULL( SUM([I].[PAID_TO_DATE]),0)) [AVAILABLE_CREDIT]
		,ISNULL(COUNT(I.[CODE_CUSTOMER]),0) [QTY_OVERDUE_INVOICE]
	FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
	LEFT JOIN @INVOICE [I] ON (
		[I].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER]
	)
	WHERE [C].[CODE_CUSTOMER] = @CODE_CUSTOMER
	GROUP BY [C].[CODE_CUSTOMER]
END
