-- =============================================
-- Autor:				Yaqueline Canahui
-- Fecha de Creacion: 	04-07-2018
-- Description:			Devuelve el detalle de metas

-- Modificacion 		8/5/2019 @ G-Force Team Sprint 
-- Autor: 				diego.as
-- Historia/Bug:		Impediment 31075: Ajuste de funcionalidad de metas BO Swift Express
-- Descripcion: 		8/5/2019 - Se modifica SP para que haga un nico join a la tabla USERS
--						y valide unicamente con el campo [GOAL_HEADER_ID]

/*
-- Ejemplo de Ejecucion:
	exec [SONDA].SWIFT_SP_GET_GOAL_DETAIL 
	@GOAL_HEADER_ID = 2024
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_GOAL_DETAIL] (@GOAL_HEADER_ID INT)
AS
BEGIN
    SET NOCOUNT ON;
    --
    SELECT [U].[CORRELATIVE],
           [U].[LOGIN],
           [U].[NAME_USER],
           ISNULL([GD].[GOAL_BY_SELLER], 0) AS [GOAL_BY_SELLER],
           ISNULL([GD].[DAILY_GOAL_BY_SELLER], 0) AS [DAILY_GOAL_BY_SELLER]
    FROM [SONDA].[SWIFT_GOAL_DETAIL] [GD]
        INNER JOIN [SONDA].[USERS] [U]
            ON ([GD].[SELLER_ID] = [U].[CORRELATIVE])
    WHERE [GD].[GOAL_HEADER_ID] = @GOAL_HEADER_ID;
END;
  
