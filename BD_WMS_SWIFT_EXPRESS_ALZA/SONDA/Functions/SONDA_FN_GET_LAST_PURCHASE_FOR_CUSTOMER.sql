-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		4/20/2017 @ A-Team Sprint Hondo
-- Description:			    Funcion que obtiene el monto de los pedidos realizados en la ultima fecha de compra

/*
-- Ejemplo de Ejecucion:
        SELECT [SONDA].[SONDA_FN_GET_LAST_PURCHASE_FOR_CUSTOMER] ('928') AS LAST_PURCHASE
*/
-- =============================================

CREATE FUNCTION [SONDA].[SONDA_FN_GET_LAST_PURCHASE_FOR_CUSTOMER](
	@CODE_CUSTOMER VARCHAR(250)
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	DECLARE @LAST_PURCHASE NUMERIC(18,6)

	SELECT TOP 1
		@LAST_PURCHASE = SUM([TOTAL_AMOUNT])
	FROM [SONDA].[SONDA_SALES_ORDER_HEADER] 
	WHERE [CLIENT_ID] = @CODE_CUSTOMER
	GROUP BY CAST([POSTED_DATETIME] AS DATE)
	ORDER BY CAST([POSTED_DATETIME] AS DATE) DESC

	RETURN ISNULL(@LAST_PURCHASE, 0)
END;
