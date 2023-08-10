CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_VEHICLE_X_USER
(
   @CODE_VEHICLE INT
  ,@LOGIN VARCHAR(50)  
)
  AS
    SET NOCOUNT ON;
BEGIN TRY
            DECLARE @VEHICLE INT ;
            SET @VEHICLE = ( SELECT  TOP(1) VEHICLE FROM [SONDA].SWIFT_VEHICLES WHERE CODE_VEHICLE = @CODE_VEHICLE )
          
            DELETE [SONDA].SWIFT_VEHICLE_X_USER
            WHERE VEHICLE = @VEHICLE  AND 
            [LOGIN] =  @LOGIN

    IF @@error = 0
  BEGIN
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
  END
  ELSE
  BEGIN
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@ERROR Codigo
  END
END TRY
BEGIN CATCH
  SELECT
    -1 AS Resultado
   ,ERROR_MESSAGE() Mensaje
   ,@@ERROR Codigo
END CATCH
