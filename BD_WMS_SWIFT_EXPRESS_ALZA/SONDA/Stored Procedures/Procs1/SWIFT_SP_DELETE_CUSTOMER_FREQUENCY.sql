﻿CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_CUSTOMER_FREQUENCY (
   @CODE_FREQUENCY INT   
)
AS
  SET NOCOUNT ON;

  BEGIN TRY
    
    DELETE FROM [SONDA].SWIFT_CUSTOMER_FREQUENCY
    WHERE CODE_FREQUENCY = @CODE_FREQUENCY    

    IF @@error = 0
    BEGIN
      SELECT 1 AS Resultado, 'Proceso Exitoso' Mensaje
    END
    ELSE
    BEGIN
      SELECT -1 AS Resultado, ERROR_MESSAGE() Mensaje, @@ERROR Codigo
    END
  END TRY
  BEGIN CATCH
    SELECT -1 AS Resultado, ERROR_MESSAGE() Mensaje, @@ERROR Codigo
  END CATCH
