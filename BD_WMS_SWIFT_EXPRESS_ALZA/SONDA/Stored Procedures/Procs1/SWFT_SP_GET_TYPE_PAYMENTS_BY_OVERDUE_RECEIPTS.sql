-- =============================================
-- Autor:				Christian Hernandez 
-- Fecha de Creacion: 	07-13-2018
-- Description:			Selecciona los tipos de pagos por facturas vencidas de sonda pos
--                      
/*
-- Ejemplo de Ejecucion:				
				--exec [SONDA].[SWFT_SP_GET_TYPE_PAYMENTS_BY_RECEIPTS]
							   	@PAYMENT_HEADER_ID = 1 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWFT_SP_GET_TYPE_PAYMENTS_BY_OVERDUE_RECEIPTS]  
	@PAYMENT_HEADER_ID	AS INT
AS
SELECT 
	PT.PAYMENT_TYPE_ID 
	,PT.PAYMENT_HEADER_ID
	,CASE PT.PAYMENT_TYPE 
	  WHEN 'BANK_CHECK' THEN 'Cheque' 
	  WHEN 'BANK_DEPOSIT' THEN 'Deposito'  
	  ELSE 'Efectivo' 
	END as PAYMENT_TYPE 
	,PT.AMOUNT
	,PT.DOCUMENT_NUMBER 
	,PT.BANK_NAME
	,PT.FRONT_IMAGE
	,PT.BACK_IMAGE
FROM SONDA.SONDA_PAYMENT_TYPE_DETAIL_FOR_OVERDUE_INVOICE_PAYMENT PT 
WHERE PT.PAYMENT_HEADER_ID = @PAYMENT_HEADER_ID
