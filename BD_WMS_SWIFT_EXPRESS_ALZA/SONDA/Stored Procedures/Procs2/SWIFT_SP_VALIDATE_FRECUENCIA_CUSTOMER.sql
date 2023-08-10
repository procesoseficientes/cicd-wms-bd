-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	01-09-2016 @ Sprint θ
-- Description:			Validad si el cliente tiene una frecuencia y agregarlo si no.


/*
-- Ejemplo de Ejecucion:
          EXEC [SONDA].SWIFT_SP_VALIDATE_FRECUENCIA_CUSTOMER
            @CODE_CUSTOMER = 'B0-2013'
        	  ,@POLYGON_ID = 3102
            ,@LAST_UPDATED_BY = 'gerente@SONDA'
            ,@REFERENCE_SOURCE 'BD'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_VALIDATE_FRECUENCIA_CUSTOMER
	@CODE_CUSTOMER VARCHAR(50)
	,@POLYGON_ID INT 
  ,@LAST_UPDATED_BY VARCHAR(25)
  ,@REFERENCE_SOURCE VARCHAR(150)
AS
BEGIN TRY
	SET NOCOUNT ON;
	--
  -- ------------------------------------------------------------
	-- Valida si el cliente tiene una frecuencia
	-- ------------------------------------------------------------	
  IF 1 = (SELECT 1
          FROM [SONDA].SWIFT_CUSTOMER_FREQUENCY F
          WHERE F.CODE_CUSTOMER = @CODE_CUSTOMER) 
  BEGIN
    DECLARE 
      @SUNDAY INT
      ,@MONDAY INT 
      ,@TUESDAY INT 
      ,@WEDNESDAY INT
      ,@THURSDAY INT
      ,@FRIDAY INT
      ,@SATURDAY INT 
      ,@FREQUENCY_WEEKS INT
      ,@LAST_DATE_VISITED DATE      
    
    -- ------------------------------------------------------------
	  -- Obtenemos la frecuencia del cliente
	  -- ------------------------------------------------------------	
    SELECT 
      @SUNDAY = F.SUNDAY
      ,@MONDAY = F.MONDAY
      ,@TUESDAY = F.TUESDAY
      ,@WEDNESDAY = F.WEDNESDAY
      ,@THURSDAY = F.THURSDAY
      ,@FRIDAY = F.FRIDAY
      ,@SATURDAY = F.SATURDAY
      ,@FREQUENCY_WEEKS = F.FREQUENCY_WEEKS
      ,@LAST_DATE_VISITED = F.LAST_DATE_VISITED      
    FROM [SONDA].SWIFT_CUSTOMER_FREQUENCY F
    WHERE F.CODE_CUSTOMER = @CODE_CUSTOMER
    
    -- ------------------------------------------------------------
	  -- Asociamos el cliente a la frecuencia
	  -- ------------------------------------------------------------	
    EXEC [SONDA].[SWIFT_SP_ASOSOCIATE_CUSTOMER_FREQUENCY]
      @FREQUENCY_WEEKS = @FREQUENCY_WEEKS
      ,@SUNDAY = @SUNDAY
      ,@MONDAY = @MONDAY
      ,@TUESDAY = @TUESDAY
      ,@WEDNESDAY = @WEDNESDAY
      ,@THURSDAY = @THURSDAY
      ,@FRIDAY  = @FRIDAY
      ,@SATURDAY  = @SATURDAY
      ,@LAST_DATE_VISITED = @LAST_DATE_VISITED
      ,@LAST_UPDATED_BY = @LAST_UPDATED_BY
      ,@POLYGON_ID = @POLYGON_ID
      ,@REFERENCE_SOURCE = @REFERENCE_SOURCE
      ,@CODE_CUSTOMER = @CODE_CUSTOMER   
  
  END  
	
	IF @@error = 0 BEGIN		
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END		
	ELSE BEGIN
		
		SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo
	END

END TRY
BEGIN CATCH     
	 SELECT  -1 as Resultado , ERROR_MESSAGE() Mensaje ,  @@ERROR Codigo 
END CATCH
