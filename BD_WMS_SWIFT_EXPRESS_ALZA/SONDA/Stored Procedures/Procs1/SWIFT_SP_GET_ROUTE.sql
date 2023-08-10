-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	1/12/2017 @ A-TEAM Sprint Adeben 
-- Description:			Obtiene todas las rutas, y adicionalmente lleva una columna que indica si esta está asignada a un acuerdo comercial con un Si/No.

-- Modificacion:				rudi.garcia
-- Fecha de Creacion: 	07/25/2017 @ A-TEAM Sprint Adeben 
-- Description:			se agrego la condicion de [TRADE_AGREEMENT_ID]  y que se ordene por [Asignada] 

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_ROUTE]
					@TRADE_AGREEMENT_ID = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ROUTE] (
		@TRADE_AGREEMENT_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[ROUTE]
		,[CODE_ROUTE]
		,[NAME_ROUTE]
		,[GEOREFERENCE_ROUTE]
		,[COMMENT_ROUTE]
		,[LAST_UPDATE]
		,[LAST_UPDATE_BY]
		,[IS_ACTIVE_ROUTE]
		,[CODE_COUNTRY]
		,[NAME_COUNTRY]
		,[SELLER_CODE]
		,[TRADE_AGREEMENT_ID]
		,CASE	WHEN [TRADE_AGREEMENT_ID] IS NULL THEN 'No'
				ELSE 'Si'
			END AS [ASSIGNED]
	FROM
		[SONDA].[SWIFT_ROUTES]
	WHERE
		(
			[TRADE_AGREEMENT_ID] IS NULL
			OR [TRADE_AGREEMENT_ID] <> @TRADE_AGREEMENT_ID
		)
	ORDER BY
		[ASSIGNED];
END;
