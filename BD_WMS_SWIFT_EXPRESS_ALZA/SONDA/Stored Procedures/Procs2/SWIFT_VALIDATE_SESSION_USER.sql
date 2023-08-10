-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	01/17/2018 @ Reborn Team strom  
-- Description:			SP que valida si el usuario tiene una sesion activa.

/*
-- Ejemplo de Ejecucion:
				 EXEC [SONDA].SWIFT_VALIDATE_SESSION_USER 'GERENTE@SONDA','zwtlxyeapvniysfrwqavlkese78fa2db'
					
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_VALIDATE_SESSION_USER (@LOGIN_ID VARCHAR(100)
, @SESSION_USER_ID VARCHAR(80))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @SESSION_ID VARCHAR(88) = NULL;
  DECLARE @SESSION_ITEM_SHORT VARBINARY(7000) = NULL;
  DECLARE @SESSION_ID_AC VARCHAR(88) = NULL;

  BEGIN TRY
    SELECT TOP 1
      @SESSION_ID = [SESSION_ID]
    FROM [SONDA].[USERS]
    WHERE [login] = @LOGIN_ID;

    SELECT TOP 1
      @SESSION_ID_AC = [SessionId]
     ,@SESSION_ITEM_SHORT = [SessionItemShort]
    FROM [ASPState].[dbo].[ASPStateTempSessions]
    WHERE [SessionId] LIKE @SESSION_ID + '%'    

    IF
      @SESSION_USER_ID = @SESSION_ID 
      OR @SESSION_ID_AC IS NULL    
      OR @SESSION_ITEM_SHORT IS NOT NULL
    BEGIN
      SELECT
        1 AS [STATUS]
       ,'Proceso Exitoso' [MESSAGE]
       ,0 [ERROR_CODE];
    END;
    ELSE
    BEGIN

      SELECT
        2 AS [STATUS]
       ,'Proceso Exitoso' [MESSAGE]
       ,0 [ERROR_CODE]
       ,@SESSION_ID [DbData];
    END;


  END TRY
  BEGIN CATCH
    SELECT
      0 AS [STATUS]
     ,ERROR_MESSAGE() [MESSAGE]
     ,@@error [ERROR_CODE];

  END CATCH;
END;
