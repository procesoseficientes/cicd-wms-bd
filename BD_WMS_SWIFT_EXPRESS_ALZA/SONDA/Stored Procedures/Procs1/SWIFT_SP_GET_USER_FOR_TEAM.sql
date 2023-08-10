-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	26-JUN-2018 @ G-FORCE Sprint Elefante
-- Description:			Sp que agrega el encabezado del equipo

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_USER_FOR_TEAM] @TEAM_ID = 1
				--
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_USER_FOR_TEAM] (@TEAM_ID INT)
AS
BEGIN

  SELECT
    [UT].[TEAM_ID]
   ,[U].[CORRELATIVE]
   ,[U].[LOGIN]
   ,[U].[NAME_USER]
  FROM [SONDA].[USERS] [U]
  INNER JOIN [SONDA].[SWIFT_USER_BY_TEAM] [UT] ON (
    [UT].[USER_ID] = [U].[CORRELATIVE]    
  )
  WHERE [UT].[TEAM_ID] = @TEAM_ID
END
