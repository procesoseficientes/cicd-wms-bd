
-- =============================================
-- Autor:				Jose Roberto
-- Fecha de Creacion: 	13-11-2015
-- Description:			ELIMINA LA FRECUENCIA POR CLIENTE

-- Modificacion 29-08-2016 @ Sprint θ
-- rudi.garcia
-- Se agrego que el parametro "@ID_FREQUENCY" pueda venir null.

-- Modificacion 20-09-2016 @ Sprint 1 A-TEAM
-- pablo.aguilar
-- Se agrego el parametro "@ID_POLYGON" que permite null para realizar la eliminación de la tabla [SWIFT_POLYGON_X_CUSTOMER].

/*
-- Ejemplo de Ejecucion:
				exec [SONDA].[SWIFT_SP_ELIMINAR_FRECUENCIA_POR_CLIENTE] @CODE_CUSTOMER = "0001011110001", @ID_FREQUENCY = 1
        exec [SONDA].[SWIFT_SP_ELIMINAR_FRECUENCIA_POR_CLIENTE] @CODE_CUSTOMER = "0001011110001"
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_FREQUENCY_X_CUSTOMER @CODE_CUSTOMER VARCHAR(50),
@ID_FREQUENCY INT = NULL
  , @ID_POLYGON INT = NULL 
AS
BEGIN TRY
  SET NOCOUNT ON;
  --
  DECLARE @CODE_FREQUENCY VARCHAR(50)

  SELECT
    @CODE_FREQUENCY = CODE_FREQUENCY
  FROM [SONDA].SWIFT_FREQUENCY
  WHERE ID_FREQUENCY = @ID_FREQUENCY
  
  DELETE FROM [SONDA].[SWIFT_POLYGON_X_CUSTOMER] 
     WHERE POLYGON_ID = @ID_POLYGON
        AND CODE_CUSTOMER = @CODE_CUSTOMER

  DELETE FROM [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER]
  WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER
    AND (@ID_FREQUENCY IS NULL
    OR ID_FREQUENCY = @ID_FREQUENCY)

--  EXEC [SONDA].[SONDA_SP_GENERATE_ROUTE_PLAN] @CODE_FREQUENCY
--                                             ,@CODE_FREQUENCY
  IF @@error = 0
  BEGIN
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'0' DbData
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
