-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	26-JUN-2018 @ G-FORCE Sprint Elefante
-- Description:			Sp que actualiza el encabezado del equipo

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_TEAM]
					  @TEAM_ID = 1
          , @NAME_TEAM = 'RD'
          , @SUPERVISOR = 1
          , @LOGIN_ID = 'GERENTE@SONDA'
				-- 
				SELECT * FROM [SONDA].[SWIFT_TEAM]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_TEAM] (@TEAM_ID INT
, @NAME_TEAM VARCHAR(100)
, @SUPERVISOR INT
, @LOGIN_ID VARCHAR(50))
AS
BEGIN
  BEGIN TRY
    --
    UPDATE [SONDA].[SWIFT_TEAM]
    SET [NAME_TEAM] = @NAME_TEAM
       ,[SUPERVISOR] = @SUPERVISOR
       ,[LAST_UPDATE] = GETDATE()
       ,[LAST_UPDATE_BY] = @LOGIN_ID
    WHERE [TEAM_ID] = @TEAM_ID;

    --
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CAST(@TEAM_ID AS VARCHAR) DbData
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
