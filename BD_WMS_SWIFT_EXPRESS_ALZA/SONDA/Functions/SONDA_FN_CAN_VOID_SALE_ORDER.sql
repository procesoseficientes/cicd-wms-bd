-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		07-Mar-17 @ A-Team Sprint Ebonne 
-- Description:			    Funcion para saber si se puede anular una orden de venta

/*
-- Ejemplo de Ejecucion:
        SELECT [SONDA].[SONDA_FN_CAN_VOID_SALE_ORDER]('C',505)
		--
		SELECT [SONDA].[SONDA_FN_CAN_VOID_SALE_ORDER]('B',17)
		--
		SELECT [SONDA].[SONDA_FN_CAN_VOID_SALE_ORDER]('SGERENT',60)
*/
-- =============================================
CREATE FUNCTION [SONDA].SONDA_FN_CAN_VOID_SALE_ORDER
(
	@DOC_SERIE VARCHAR(50)
	,@DOC_NUM INT
)
RETURNS INT
AS
BEGIN
	DECLARE @RESULT INT = 0
	--
	SELECT TOP 1
		@RESULT = 1
	FROM [SONDA].[SONDA_SALES_ORDER_HEADER] [S]
	WHERE [S].[SALES_ORDER_ID] > 0
		AND [S].[DOC_SERIE] = @DOC_SERIE
		AND [S].[DOC_NUM] = @DOC_NUM
		AND ISNULL([S].[IS_POSTED_ERP],0) = 0
		AND [S].[HAVE_PICKING] = 0
    AND [S].IS_READY_TO_SEND=1
	--
	RETURN @RESULT
END
