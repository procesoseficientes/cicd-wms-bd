-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	12-4-2015
-- Description:			Obtine las Ordens de Venta que son DRAFT dependiendo de la ruta que se envie como parametro

/*
-- Ejemplo de Ejecucion:
				exec [SONDA].[SONDA_SP_GET_INVOICE_DRAFT]  @CODE_ROUTE = 'RUDI@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_INVOICE_DRAFT]
	@CODE_ROUTE VARCHAR(50)

AS
BEGIN

	SET NOCOUNT ON;


  UPDATE [SONDA].[SONDA_POS_INVOICE_HEADER]
    SET IS_ACTIVE_ROUTE = 1    
    WHERE POS_TERMINAL = @CODE_ROUTE 
      AND IS_DRAFT = 1
      

	SELECT 
  	H.[INVOICE_ID]
  	,H.[TERMS]
  	,H.[POSTED_DATETIME]
  	,H.[CLIENT_ID]
  	,H.[POS_TERMINAL]
  	,H.[GPS_URL]
  	,H.[TOTAL_AMOUNT]
  	,H.[STATUS]
  	,H.[POSTED_BY]
  	,H.[IMAGE_1]
  	,H.[IMAGE_2]
  	,H.[IMAGE_3]
  	,H.[IS_POSTED_OFFLINE]
  	,H.[INVOICED_DATETIME]
  	,H.[DEVICE_BATTERY_FACTOR]
  	,H.[CDF_INVOICENUM]
  	,H.[CDF_DOCENTRY]
  	,H.[CDF_SERIE]
  	,H.[CDF_NIT]
  	,H.[CDF_NOMBRECLIENTE]
  	,H.[CDF_RESOLUCION]
  	,H.[CDF_POSTED_ERP]
  	,H.[IS_CREDIT_NOTE]
  	,H.[VOID_DATETIME]
  	,H.[CDF_PRINTED_COUNT]
  	,H.[VOID_REASON]
  	,H.[VOID_NOTES]
  	,H.[VOIDED_INVOICE]
  	,H.[CLOSED_ROUTE_DATETIME]
  	,H.[CLEARING_DATETIME]
  	,H.[IS_ACTIVE_ROUTE]
  	,H.[SOURCE_CODE]
  	,H.[GPS_EXPECTED]
  	,H.[ATTEMPTED_WITH_ERROR]
  	,H.[IS_POSTED_ERP]
  	,H.[POSTED_ERP]
  	,H.[POSTED_RESPONSE]
  	,H.[IS_DRAFT]
	FROM [SONDA].[SONDA_POS_INVOICE_HEADER] H
	WHERE H.POS_TERMINAL = @CODE_ROUTE 
    AND H.IS_DRAFT = 1
    

END
