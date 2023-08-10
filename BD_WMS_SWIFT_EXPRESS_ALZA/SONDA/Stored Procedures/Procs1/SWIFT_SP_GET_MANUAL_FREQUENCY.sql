-- =============================================
-- Autor:				Christian Hernandez 
-- Fecha de Creacion: 	07-18-2018
-- Description:			Seleciona todoas las frecuencias que han sido insertadas manualmente 
--                      
/*
-- Ejemplo de Ejecucion:				
				--exec [SONDA].[SWIFT_SP_GET_MANUAL_FRECUENCY]  
*/
-- =============================================
CREATE PROCEDURE SONDA.SWIFT_SP_GET_MANUAL_FREQUENCY
AS
	BEGIN
		SELECT
			[VAC].[CODE_CUSTOMER]
			,[VAC].[NAME_CUSTOMER]
		INTO
			[#CUSTOMERS]
		FROM
			[SONDA].[SWIFT_VIEW_ALL_COSTUMER] AS [VAC];

		SELECT
			[SF].[ID_FREQUENCY]
			,[US].[CODE_ROUTE] AS [SELLER_CODE]
			,[US].[NAME_ROUTE] AS [SELLER_NAME]
			,[US].[CODE_ROUTE]
			,[SF].[CODE_FREQUENCY]
			,[VAC].[CODE_CUSTOMER]
			,[VAC].[NAME_CUSTOMER]
			,[SF].[TYPE_TASK]
			,[SF].[MONDAY]
			,[SF].[TUESDAY]
			,[SF].[WEDNESDAY]
			,[SF].[THURSDAY]
			,[SF].[FRIDAY]
			,[SF].[SATURDAY]
			,[SF].[SUNDAY]
			,[SF].[FREQUENCY_WEEKS]
			,[FXC].[PRIORITY]
			,[FXC].[LAST_WEEK_VISITED]
		FROM
			[SONDA].[SWIFT_FREQUENCY] [SF]
		INNER JOIN [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] [FXC]
		ON	[SF].[ID_FREQUENCY] = [FXC].[ID_FREQUENCY]
		INNER JOIN [#CUSTOMERS] [VAC]
		ON	[VAC].[CODE_CUSTOMER] = [FXC].[CODE_CUSTOMER]
		INNER JOIN [SONDA].[SWIFT_ROUTES] [US]
		ON	[US].[CODE_ROUTE] = [SF].[CODE_ROUTE]
		WHERE
			[SF].[IS_BY_POLIGON] = 0
		ORDER BY
			[FXC].[ID_FREQUENCY]
			,[US].[CODE_ROUTE]
			,[FXC].[PRIORITY];
	END;

