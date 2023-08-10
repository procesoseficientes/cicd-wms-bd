-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	26-JUN-2018 @ G-FORCE Sprint Elefante
-- Description:			Sp que elimina los usuario del equipo.

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_DELETE_USER_BY_TEAM]
					  @TEAM_ID = 1          
				-- 
				SELECT * FROM [SONDA].[SWIFT_TEAM]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_USER_BY_TEAM] (@TEAM_ID INT, @USER_ID INT = NULL)
AS
BEGIN
  BEGIN TRY
    --

    DELETE FROM [SONDA].[SWIFT_USER_BY_TEAM]
    WHERE [TEAM_ID] = @TEAM_ID
      AND (@USER_ID IS NULL
      OR [USER_ID] = @USER_ID)

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
