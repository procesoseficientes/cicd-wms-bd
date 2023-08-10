-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	12-Jul-2018 @ G-FORCE Sprint Faisan
-- Description:			SP que obtiene las estadisticas de la meta.

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_STATISTIC_BY_GOAL =1
				--
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_STATISTIC_BY_GOAL (@GOAL_HEADER_ID INT)
AS
BEGIN

  SELECT
    [SGS].[STATISTICS_GOAL_BY_SALE_ID]
   ,[SGS].[GOAL_HEADER_ID]
   ,[SGS].[TEAM_ID]
   ,[SGS].[USER_ID]
   ,[SGS].[SELLER_CODE]
   ,[SGS].[SELLER_NAME]
   ,[SGS].[CODE_ROUTE]
   ,[SGS].[NAME_ROUTE]
   ,[SGS].[RANKING]
   ,[SGS].[DAILY_GOAL]
   ,[SGS].[ACCUMULATED_BY_PERIOD]
   ,[SGS].[PERCENTAGE_GOAL_DAILY]
   ,[SGS].[DAYS_OF_SALE]
   ,[SGS].[REMAINING_DAYS]
   ,[SGS].[PERCENTAGE_OF_DAYS]
   ,[SGS].[GENERAL_GOAL]
   ,[SGS].[DIFFERENCE_FROM_THE_GOAL]
   ,[SGS].[NEXT_SALE_GOAL]
   ,[SGS].[PERCENTAGE_OF_GENERAL_GOAL]
   ,[SGS].[SALE_OF_THE_DAY]
   ,[SGS].[SALES_DATE]
   ,[SGS].[CREATED_DATE]
   ,[SGS].[LAST_CREATED]
   ,[SGS].[SALE_TYPE]
  FROM [SONDA].[SWIFT_STATISTICS_GOALS_BY_SALES] [SGS]
  WHERE [SGS].[GOAL_HEADER_ID] = @GOAL_HEADER_ID
  AND [SGS].[LAST_CREATED] = 1

END
