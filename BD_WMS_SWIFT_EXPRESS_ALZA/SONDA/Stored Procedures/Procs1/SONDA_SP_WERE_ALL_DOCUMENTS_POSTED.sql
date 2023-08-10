-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	06/07/2017    TeamOmikron@Qalisar
-- Description:			

/*

*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_WERE_ALL_DOCUMENTS_POSTED (@QUANTITY INT, @ROUTE_ID VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @COUNT_SALES_ORDER INT;
  DECLARE @COUNT_INVOICES INT; 
  DECLARE @COUNT INT;
 

  SET @COUNT_SALES_ORDER=0;
  SET @COUNT_INVOICES =0;
  SET @COUNT =0;
  
  SELECT @COUNT_SALES_ORDER= COUNT(1) FROM [SONDA].SONDA_SALES_ORDER_HEADER ssoh
    WHERE
    ssoh.POS_TERMINAL = @ROUTE_ID 
    AND ssoh.IS_ACTIVE_ROUTE =1 
    AND ssoh.IS_READY_TO_SEND =1    

     

  SELECT @COUNT_INVOICES =  COUNT(1) FROM [SONDA].SONDA_POS_INVOICE_HEADER spih
    WHERE spih.IS_ACTIVE_ROUTE =1
    AND spih.IS_READY_TO_SEND =1  
    AND spih.POS_TERMINAL = @ROUTE_ID
    
  SET @COUNT = @COUNT_INVOICES + @COUNT_SALES_ORDER;  
  IF @COUNT = @QUANTITY 
    SELECT 1 AS status , 'Every things are ok' AS message    
  ELSE
    SELECT 0 AS status , 'there are inconsistencies  between  the server with ' + CAST(@COUNT AS VARCHAR) + ' documents and client with  '  + CAST(@QUANTITY AS VARCHAR)  AS message
  
  

END
