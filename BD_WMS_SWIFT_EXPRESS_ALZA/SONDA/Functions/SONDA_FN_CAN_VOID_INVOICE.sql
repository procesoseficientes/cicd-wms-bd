-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		3/7/2017 @ A-Team Sprint Ebonne
-- Description:			    Valida si se puede anular la factura
-- =============================================
/*
-- Ejemplo de Ejecucion:
        SELECT [SONDA].[SONDA_FN_CAN_VOID_INVOICE]('Seria Prueba hector','Prueba hector numero','195')
*/
-- =============================================
CREATE FUNCTION [SONDA].[SONDA_FN_CAN_VOID_INVOICE]
(	
	@CDF_SERIE VARCHAR(50),
	@CDF_RESOLUTION VARCHAR(50),
	@INVOICE_ID INT
)
RETURNS INT
	AS
BEGIN
	DECLARE @RESULT INT = 1
	--
	SELECT TOP 1 @RESULT = 0  
	FROM [SONDA].[SONDA_POS_INVOICE_HEADER] [IH]
	WHERE [IH].[CDF_SERIE] = @CDF_SERIE
		AND [IH].[CDF_RESOLUCION] = @CDF_RESOLUTION
		AND [IH].[INVOICE_ID] = @INVOICE_ID
		AND [IH].[IS_POSTED_ERP] = 1
		AND [IH].[POSTED_RESPONSE] = 'Proceso Exitoso'
	--
	RETURN @RESULT
 END;
