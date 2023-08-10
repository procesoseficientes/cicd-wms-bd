-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	03-11-2015
-- Description:			Obtiene todos los eventos para la ruta

/*
-- Ejemplo de Ejecucion:				
				--
				exec [SONDA].[SWIFT_SP_GET_RULE] @Route = '001'
				--				
*/
-- =============================================

CREATE PROC [SONDA].[SWIFT_SP_GET_RULE]
@Route VARCHAR(150)
AS	
	SELECT E.*, R.CODE, RE.EVENT_ORDER
	FROM [SONDA].[SWIFT_EVENT] E
		INNER JOIN [SONDA].[SWIFT_RULE_X_EVENT] RE ON (RE.EVENT_ID = E.EVENT_ID)
		INNER JOIN [SONDA].[SWIFT_RULE] R ON (R.RULE_ID = RE.RULE_ID)
		INNER JOIN [SONDA].[SWIFT_RULE_X_ROUTE] RR ON (R.RULE_ID = RR.RULE_ID)
	WHERE CODE_ROUTE = @Route
	ORDER BY R.CODE, RE.EVENT_ORDER
