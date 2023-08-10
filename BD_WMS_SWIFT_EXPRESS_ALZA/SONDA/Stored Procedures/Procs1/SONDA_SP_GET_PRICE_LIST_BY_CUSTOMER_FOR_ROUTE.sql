
-- =====================================================
-- Author:         diego.as
-- Create date:    06-04-2016
-- Description:    Trae las listas de precios de los clientes  
--				   de las tareas asignadas al dia de trabajo
--				   
--
/*
-- EJEMPLO DE EJECUCION: 
		
		EXEC [SONDA].[SONDA_SP_GET_PRICE_LIST_BY_CUSTOMER_FOR_ROUTE]
			@CODE_ROUTE = 'RUDI@SONDA'
		
*/			
-- =====================================================

CREATE PROCEDURE [SONDA].[SONDA_SP_GET_PRICE_LIST_BY_CUSTOMER_FOR_ROUTE]
(
	@CODE_ROUTE VARCHAR(50)
)
AS
BEGIN
	
	SELECT DISTINCT PL.CODE_PRICE_LIST
		,pl.CODE_CUSTOMER 
	FROM [SONDA].[SWIFT_PRICE_LIST_BY_CUSTOMER] AS PL
	INNER JOIN [SONDA].[SONDA_ROUTE_PLAN] AS RP ON(
	RP.RELATED_CLIENT_CODE = PL.CODE_CUSTOMER
	)
	WHERE RP.CODE_ROUTE = @CODE_ROUTE

END
