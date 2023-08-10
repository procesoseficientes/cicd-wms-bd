-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	7/20/2018 @ A-TEAM Sprint G-Force@Gato  
-- Description:			SP que obtiene los registros del detalle de un documento de pago

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_PAYMENT_DETAIL]
				@PAYMENT_HEADER_ID = 20
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_PAYMENT_DETAIL]
	(
		@PAYMENT_HEADER_ID INT
	)
AS
	BEGIN
		SET NOCOUNT ON;
	--
		SELECT
			[OIPD].[ID]
			,[OIPD].[PAYMENT_HEADER_ID]
			,[OIPD].[INVOICE_ID]
			,[OIPD].[DOC_ENTRY]
			,[OIPD].[DOC_SERIE]
			,[OIPD].[DOC_NUM]
			,[OIPD].[PAYED_AMOUNT]
			,NULL AS [DOC_NUM_ERP]
		FROM
			[SONDA].[SONDA_OVERDUE_INVOICE_PAYMENT_DETAIL] AS [OIPD]
		WHERE
			[OIPD].[PAYMENT_HEADER_ID] = @PAYMENT_HEADER_ID;
	END;
