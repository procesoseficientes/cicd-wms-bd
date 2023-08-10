-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	8/5/2019 @ G-Force - TEAM Sprint 
-- Historia/Bug:		Impediment 31075: Ajuste de funcionalidad de metas BO Swift Express
-- Descripcion: 		8/5/2019 - SP que obtiene los operadores para el detalle de la meta en el proceso de creacion

/*
-- Ejemplo de Ejecucion:
	EXEC [SONDA].[SWIFT_SP_GET_USERS_BY_TEAM_FOR_NEW_GOAL]
	@TEAM_ID = 2,
	@SALE_TYPE = 'PRE'
  
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_USERS_BY_TEAM_FOR_NEW_GOAL]
(
    @TEAM_ID INT,
    @SALE_TYPE VARCHAR(50)
)
AS
BEGIN
    SET NOCOUNT ON;
    --
    SELECT [U].[CORRELATIVE],
           [U].[LOGIN],
           [U].[NAME_USER],
           CAST(0 AS DECIMAL(18, 6)) AS [GOAL_BY_SELLER],
           CAST(0 AS DECIMAL(18, 6)) AS [DAILY_GOAL_BY_SELLER]
    FROM [SONDA].[SWIFT_USER_BY_TEAM] [UT]
        INNER JOIN [SONDA].[USERS] [U]
            ON ([UT].[USER_ID] = [U].[CORRELATIVE])
    WHERE [UT].[TEAM_ID] = @TEAM_ID
          AND [U].[USER_TYPE] = @SALE_TYPE;
END;