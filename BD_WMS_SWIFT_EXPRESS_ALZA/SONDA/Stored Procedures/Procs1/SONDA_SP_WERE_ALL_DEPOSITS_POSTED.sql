-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	06/07/2017    TeamOmikron@Qalisar
-- Description:			

/*

*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_WERE_ALL_DEPOSITS_POSTED (@QUANTITY INT, @ROUTE_ID VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON; 
  DECLARE @COUNT INT;
 


  SET @COUNT =0;
  
  SELECT @COUNT= COUNT(1) FROM [SONDA].SONDA_DEPOSITS sd
    WHERE    
    sd.POS_TERMINAL = @ROUTE_ID 
    AND sd.LIQUIDATION_ID is null 
    AND sd.IS_READY_TO_SEND =1        

  
  IF @COUNT = @QUANTITY 
    SELECT 1 AS status , 'Every things are ok' AS message    
  ELSE
    SELECT 0 AS status , 'there are inconsistencies  between  the server with ' + CAST(@COUNT AS VARCHAR) + ' deposits and client with  '  + CAST(@QUANTITY AS VARCHAR)  AS message
  
  

END
