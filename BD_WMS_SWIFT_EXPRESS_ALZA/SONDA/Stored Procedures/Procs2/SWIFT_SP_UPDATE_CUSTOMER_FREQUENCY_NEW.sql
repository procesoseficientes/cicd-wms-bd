-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	14-10-2016 @ A-TEAM Sprint 3
-- Description:			Actualiza la frecuencia del scouting
/*
-- Ejemplo de Ejecucion:				
    EXEC [SONDA].SWIFT_SP_UPDATE_CUSTOMER_FREQUENCY_NEW
        @CODE_FREQUENCY = 1027
      , @SUNDAY = '0'
      , @MONDAY = '0'
      , @TUESDAY = '0'
      , @WEDNESDAY = '1'
      , @THURSDAY = '0'
      , @FRIDAY = '1'
      , @SATURDAY = '1'
      , @FREQUENCY_WEEKS = '2'
      , @LAST_UPDATED_BY = 'gerente@SONDA'

*/
-- =============================================

CREATE PROCEDURE [SONDA].SWIFT_SP_UPDATE_CUSTOMER_FREQUENCY_NEW (@CODE_FREQUENCY INT
, @SUNDAY VARCHAR(10)
, @MONDAY VARCHAR(10)
, @TUESDAY VARCHAR(10)
, @WEDNESDAY VARCHAR(10)
, @THURSDAY VARCHAR(10)
, @FRIDAY VARCHAR(10)
, @SATURDAY VARCHAR(10)
, @FREQUENCY_WEEKS VARCHAR(10)
, @LAST_UPDATED_BY VARCHAR(50))
AS
BEGIN TRY
  SET NOCOUNT ON;

  UPDATE [SONDA].SWIFT_CUSTOMER_FREQUENCY_NEW
  SET SUNDAY = @SUNDAY
     ,MONDAY = @MONDAY
     ,TUESDAY = @TUESDAY
     ,WEDNESDAY = @WEDNESDAY
     ,THURSDAY = @THURSDAY
     ,FRIDAY = @FRIDAY
     ,SATURDAY = @SATURDAY
     ,FREQUENCY_WEEKS = @FREQUENCY_WEEKS
     ,LAST_UPDATED_BY = @LAST_UPDATED_BY
     ,LAST_UPDATED = GETDATE()
  WHERE CODE_FREQUENCY = @CODE_FREQUENCY

  SELECT
    1 AS [RESULTADO]
    ,'Proceso Exitoso' [MENSAJE]
    ,0 [CODIGO]
--
END TRY
BEGIN CATCH
  SELECT
    -1 AS Resultado
   ,ERROR_MESSAGE() Mensaje
   ,@@ERROR Codigo
END CATCH
