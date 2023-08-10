
-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	12-4-2015
-- Description:			    Obtiene los detalles de una consignacion

/*
-- Ejemplo de Ejecucion:
				exec [SONDA].SONDA_SP_GET_CONSIGNMENTS_DETAILS_BY_ROUTE  @CONSIGNMENT_ID = 1455
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_GET_CONSIGNMENTS_DETAILS_BY_ROUTE @CONSIGNMENT_ID INT

AS
BEGIN
  SET NOCOUNT ON;

  SELECT
    D.CONSIGNMENT_ID
   ,D.SKU
   ,D.LINE_NUM
   ,D.QTY
   ,D.PRICE
   ,D.DISCOUNT
   ,D.TOTAL_LINE
   ,D.POSTED_DATETIME
   ,D.PAYMENT_ID
   ,D.HANDLE_SERIAL
   , CASE [D].[HANDLE_SERIAL]
     	WHEN 0 THEN 'N/A'
     	WHEN 1 THEN SERIAL_NUMBER
     END AS SERIAL_NUMBER
  FROM [SONDA].SWIFT_CONSIGNMENT_DETAIL D
  WHERE D.CONSIGNMENT_ID = @CONSIGNMENT_ID

END
