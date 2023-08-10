-- =====================================================
-- Author:         diego.as
-- Create date:    06-05-2016
-- Description:    Trae las Etiquetas por Cliente en base a los clientes de la Ruta que recibe como parametro.
--				   

/*
-- EJEMPLO DE EJECUCION: 
		
		EXEC [SONDA].[SWIFT_SP_GET_TAG_X_CUSTUMER_FOR_SCOUTING]
		@CODE_ROUTE = 'RUDI@SONDA'
			

*/
-- =====================================================
CREATE PROC [SONDA].[SWIFT_SP_GET_TAG_X_CUSTUMER_FOR_SCOUTING]
	@CODE_ROUTE varchar(50)	
AS	
	SELECT TC.*
	FROM [SONDA].[SWIFT_TAG_X_CUSTOMER] TC
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] VC ON TC.CUSTOMER = VC.CODE_CUSTOMER
	WHERE VC.SCOUTING_ROUTE = @CODE_ROUTE
