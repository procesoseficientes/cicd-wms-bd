-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	01-15-2016
-- Description:			Obtiene el detalle de una facutar

-- Modificado Fecha
		-- anonymous
		-- sin motivo

/*
-- Ejemplo de Ejecucion:
          USE SWIFT_EXPRESS
          GO
          
          DECLARE @RC int
          DECLARE @INVOICE_ID int
          
          SET @INVOICE_ID = 4 
          
          EXECUTE @RC = [SONDA].SWIFT_SP_GET_INVOICE_DETAIL @INVOICE_ID				
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_INVOICE_DETAIL
    @INVOICE_ID INT,
    @CDF_SERIE VARCHAR(50),
    @CDF_RESOLUCION NVARCHAR(50)  
AS

  DECLARE @TAX_ID VARCHAR(50);

  SELECT @TAX_ID= sp.VALUE FROM [SONDA].SWIFT_PARAMETER sp WHERE sp.GROUP_ID='ERP_HARDCODE_VALUES' AND  sp.PARAMETER_ID='TAX_ID';

SELECT 
  spid.INVOICE_ID
 ,spid.INVOICE_SERIAL
 ,spid.SKU
 ,spid.LINE_SEQ
 ,spid.QTY
 ,spid.PRICE
 ,spid.DISCOUNT
 ,spid.TOTAL_LINE
 ,spid.POSTED_DATETIME
 ,spid.SERIE
 ,spid.SERIE_2
 ,spid.REQUERIES_SERIE
 ,spid.COMBO_REFERENCE
 ,spid.INVOICE_RESOLUTION
 ,spid.PARENT_SEQ
 ,spid.IS_ACTIVE_ROUTE 
 , @TAX_ID TAX_ID 
	FROM  [SONDA].[SONDA_POS_INVOICE_DETAIL] spid 
	WHERE  spid.INVOICE_ID = @INVOICE_ID
  AND spid.INVOICE_SERIAL = @CDF_SERIE
  AND spid.INVOICE_RESOLUTION= @CDF_RESOLUCION
