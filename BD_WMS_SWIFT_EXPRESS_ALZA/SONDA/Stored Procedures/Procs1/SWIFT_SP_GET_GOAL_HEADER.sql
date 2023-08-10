-- =============================================

-- Modificacion 		8/5/2019 @ G-Force Team Sprint Groenlandia
-- Autor: 				diego.as
-- Historia/Bug:		Impediment 31075: Ajuste de funcionalidad de metas BO Swift Express
-- Descripcion: 		8/5/2019 - Se modifica SP para que devuelva la nueva columna PERIOD_DAYS en lugar de calcularlos
--						Se formatea codigo

/*
-- Ejemplo de Ejecucion:
	EXEC [SONDA].[SWIFT_SP_GET_GOAL_HEADER] @STATUS = 'CREATED'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_GOAL_HEADER] @STATUS AS VARCHAR(25)
AS
BEGIN
    SET NOCOUNT ON;
    --
    SELECT [GH].[GOAL_HEADER_ID],
           [GH].[GOAL_NAME],
           [GH].[TEAM_ID],
           [GH].[SUPERVISOR_ID],
           [GH].[GOAL_AMOUNT],
           CONVERT(DATE, [GOAL_DATE_FROM]) AS [GOAL_DATE_FROM],
           CONVERT(DATE, [GOAL_DATE_TO]) AS [GOAL_DATE_TO],
           [GH].[GOAL_CLOSE_DATE],
           [GH].[STATUS],
           CASE [GH].[STATUS]
               WHEN 'CREATED' THEN
                   'Creado'
               WHEN 'IN_PROGRESS' THEN
                   'En Progreso'
               WHEN 'CANCELED' THEN
                   'Cancelado'
               WHEN 'FINISHED' THEN
                   'Finalizado'
               ELSE
                   [GH].[STATUS]
           END [STATUS_DESCRIPTION],
           [GH].[STATUS],
           [GH].[INCLUDE_SATURDAY],
           [GH].[LAST_UPDATE],
           [GH].[LAST_UPDATE_BY],
           [GH].[CLOSED_BY],
           [GH].[PERIOD_DAYS],
           [B].[NAME_TEAM],
           [GH].[SALE_TYPE]
    FROM [SONDA].[SWIFT_GOAL_HEADER] [GH]
        INNER JOIN [SONDA].[SWIFT_TEAM] [B]
            ON [GH].[TEAM_ID] = [B].[TEAM_ID]
    WHERE [GH].[STATUS] = @STATUS
    ORDER BY [GH].[GOAL_HEADER_ID] DESC;
END;

  
