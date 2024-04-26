﻿-- =============================================
-- Autor:				Christian Hernandez 
-- Fecha de Creacion: 	07-13-2018
-- Description:			Selecciona el detalle de pagos hechos en facturas 
--                      
/*
-- Ejemplo de Ejecucion:				
				--exec [SONDA].SWIFT_SP_GET_INVOICE_OVERDUE_BY_RECEIPTS 
							  4
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_INVOICE_OVERDUE_BY_RECEIPTS 
	@PAYMENT_HEADER_ID	AS INT
AS

SELECT 
	SPD.INVOICE_ID
	,SPH.POSTED_DATE
	,sph.CREATED_DATE
	,OIC.TOTAL_AMOUNT
	,OIC.TOTAL_AMOUNT - OIC.PENDING_TO_PAID AS AMOUNT_PAYED
	,OIC.PENDING_TO_PAID
 FROM SONDA.[SONDA_OVERDUE_INVOICE_PAYMENT_HEADER] SPH 
 INNER JOIN SONDA.[SONDA_OVERDUE_INVOICE_PAYMENT_DETAIL] SPD ON SPH.ID = SPD.PAYMENT_HEADER_ID
 INNER JOIN SONDA.[SWIFT_OVERDUE_INVOICE_BY_CUSTOMER] OIC ON OIC.INVOICE_ID = SPD.INVOICE_ID
WHERE SPD.PAYMENT_HEADER_ID = @PAYMENT_HEADER_ID