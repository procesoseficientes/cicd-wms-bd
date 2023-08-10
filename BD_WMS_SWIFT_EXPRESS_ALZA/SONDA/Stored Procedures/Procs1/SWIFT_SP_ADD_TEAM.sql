-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	26-JUN-2018 @ G-FORCE Sprint Elefante
-- Description:			Sp que agrega el encabezado del equipo

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_ADD_TEAM]
					 @NAME_TEAM = 'RD'
          , @SUPERVISOR = 1
          , @LOGIN_ID = 'GERENTE@SONDA'
				-- 
				SELECT * FROM [SONDA].[SWIFT_TEAM]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_TEAM] (@NAME_TEAM VARCHAR(100)
, @SUPERVISOR INT
, @LOGIN_ID VARCHAR(50))
AS
BEGIN
  BEGIN TRY
    DECLARE @ID INT
    --
    INSERT INTO [SONDA].[SWIFT_TEAM] ([NAME_TEAM]
    , [SUPERVISOR]
    , [CREATE_BY])
      VALUES (@NAME_TEAM, @SUPERVISOR, @LOGIN_ID)
    --
    SET @ID = SCOPE_IDENTITY()
    --
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CAST(@ID AS VARCHAR) DbData
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,CASE CAST(@@ERROR AS VARCHAR)
        WHEN '2627' THEN 'Error: Ya existe el equipo'
        ELSE ERROR_MESSAGE()
      END Mensaje
     ,@@ERROR Codigo
  END CATCH
END
