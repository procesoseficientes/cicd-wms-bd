-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	27-JUN-2018 @ G-FORCE Sprint Elefante
-- Description:			SP que obtiene los equipos.

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_TEAM]
				--
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_TEAM]
AS
BEGIN

  SELECT
    [T].[TEAM_ID]
   ,[T].[NAME_TEAM]
   ,[T].[SUPERVISOR]
   ,[U].[LOGIN]
   ,[U].[NAME_USER]
   ,COUNT([UT].[USER_ID]) [USERS_QUANTITY]
  FROM [SONDA].[SWIFT_TEAM] [T]
  INNER JOIN [SONDA].[USERS] [U]
    ON ([T].[SUPERVISOR] = [U].[CORRELATIVE])
  LEFT JOIN [SONDA].[SWIFT_USER_BY_TEAM] [UT]
    ON ([T].[TEAM_ID] = [UT].[TEAM_ID])
  GROUP BY 
    [T].[TEAM_ID]
   ,[T].[NAME_TEAM]
   ,[T].[SUPERVISOR]
   ,[U].[LOGIN]
   ,[U].[NAME_USER]
END
