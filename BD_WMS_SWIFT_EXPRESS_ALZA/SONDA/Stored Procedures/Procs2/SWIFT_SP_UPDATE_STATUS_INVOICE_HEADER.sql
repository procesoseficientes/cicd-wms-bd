-- =============================================
-- Author:		rudi.garcia
-- Create date: 30-01-2016
-- Description:	Actualiza el estado de la factura

-- Modificacion 3/7/2017 @ A-Team Sprint Ebonne
					-- rodrigo.gomez
					-- Valida si la factura se puede anular antes de actualizarla

--Ejemplo de Ejecucion:

/*
	EXECUTE  [SONDA].[SWIFT_SP_UPDATE_STATUS_INVOICE_HEADER] 
					   @INVOICE_ID = 195
					  ,@CDF_SERIE = 'Seria Prueba hector'  
					  ,@CDF_RESOLUCION = 'Prueba hector numero'
					  ,@STATUS = 0
					  ,@VOID_REASON = 'FACTURA EN MAL ESTADO PRUEBA'
					  			 
*/	

-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_STATUS_INVOICE_HEADER]
	@INVOICE_ID INT
	,@CDF_SERIE VARCHAR(50)
	,@CDF_RESOLUCION VARCHAR(50)
	,@STATUS INT
	,@VOID_REASON VARCHAR(250)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE @RESULT INT = [SONDA].[SONDA_FN_CAN_VOID_INVOICE](@CDF_SERIE, @CDF_RESOLUCION, @INVOICE_ID)
    IF @RESULT = 1
	BEGIN
		UPDATE [SONDA].[SONDA_POS_INVOICE_HEADER] SET
		[STATUS] = @STATUS,
		[VOIDED_INVOICE] = 1,
		[VOID_DATETIME] = GETDATE(),
		[VOID_REASON] = @VOID_REASON	
		WHERE [INVOICE_ID] = @INVOICE_ID
		AND [CDF_SERIE] = @CDF_SERIE
		AND [CDF_RESOLUCION] = @CDF_RESOLUCION

		SELECT 0 ERROR, 'Factura anulada exitosamente.' as ERRMESSAGE
	END
	ELSE
	BEGIN
		SELECT 1 ERROR, 'La Factura ya se encuentra procesada, no es posible Anularla' as ERRMESSAGE
	END
	
END
