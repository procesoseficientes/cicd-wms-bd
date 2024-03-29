﻿
/* =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	04-07-2016 Sprint ζ 
-- Description:			Obtiene el Detalle de un Cliente de Scouting

-- Ejemplo de Ejecucion:
		exec [SONDA].[SWIFT_SP_GET_SCOUTING_DETAIL]
			@CODE_CUSTOMER = 3145
-- =============================================*/
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SCOUTING_DETAIL]
(
	@CODE_CUSTOMER INT
) AS
BEGIN
	--
	SELECT [CND].[CUSTOMER]
		,[CND].[SALE_ROUTE]
		,[CND].[REFERENCE_CBC]
		,[CND].[VISIT_DAY]
		,[CND].[VISIT_FRECUENCY]
		,[CND].[TIME_DELIVER_DAYS]
		,[CND].[BRANCH]
		,[CND].[SERVICE_WINDOW]
		,[CND].[SALE_POINT_COMPLEMENT_DIRECTION]
		,[CND].[INVOICE_ADRESS_COMPLEMENT]
		,[CND].[MUNICIPALITY]
		,[CND].[DEPARTMENT]
		,[CND].[CREDIT_LIMIT]
		,[CND].[CODE_BUSINESS_GYRE]
		,[CND].[BUSINESS_GYRE_DENOMINATION]
		,[CND].[CREDIT_CONTROL_AREA]
		,[CND].[FORM_PAY_AUTHORIZATION]
		,[CND].[CURRENCY]
		,[CND].[ASSOCIATED_ACCOUNTANT_CREDIT_COUNT]
		,[CND].[PAY_CONDITION]
		,[CND].[CREDIT_BLOCKADE]
		,[VAC].[COMMENTS]
		,[VAC].[LAST_UPDATE]
	FROM [SONDA].[SWIFT_CUSTOMER_NEW_DETAIL] AS CND
	INNER JOIN [SONDA].[SWIFT_CUSTOMERS_NEW] AS VAC ON(
		[VAC].[CUSTOMER] = [CND].[CUSTOMER]
	)
	WHERE [CND].[CUSTOMER] = @CODE_CUSTOMER
	--
END
