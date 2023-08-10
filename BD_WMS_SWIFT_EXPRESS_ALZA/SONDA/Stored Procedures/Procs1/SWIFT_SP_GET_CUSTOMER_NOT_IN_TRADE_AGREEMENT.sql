/*==================================================

Autor:				diego.as
Fecha de Creacion:	12-09-2016 @ A-TEAM Sprint 1
Descripcion:		Trae todos los clientes que no estan en un acuerdo comercial

Modificado:  hector.gonzalez
Fecha:        2016-09-16 @ A-TEAM Sprint 1
Descripcion:  Se modifico para que trajera todos los clientes y que mostrara si esta asignado a un cliente o no

Modificado:  rudi.garcia
Fecha:        2017-07-15 @ Reborn-TEAM Sprint Bearbeitung
Descripcion:  Se agrego los siguientes parametros  @TRADE_AGREEMENT_ID INT, @CODE_CUSTOMER VARCHAR(50) y tambien se agrego condiciones para esos parametso


Ejemplo de Ejecución:

	EXEC [SONDA].[SWIFT_SP_GET_CUSTOMER_NOT_IN_TRADE_AGREEMENT] @TRADE_AGREEMENT_ID = 30 , @CODE_CUSTOMER = 'V1'

==================================================*/

CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_CUSTOMER_NOT_IN_TRADE_AGREEMENT] (
		@TRADE_AGREEMENT_ID INT
		,@CODE_CUSTOMER VARCHAR(50)
	)
AS
BEGIN
	SELECT
		ROW_NUMBER()	OVER (ORDER BY [VAC].[CUSTOMER] DESC) AS [CUSTOMER]
		,[VAC].[CODE_CUSTOMER]
		,[VAC].[NAME_CUSTOMER]
		,[VAC].[ADRESS_CUSTOMER]
		,[VAC].[CODE_ROUTE]
		,[svas].[SELLER_NAME]
		,[sc].[NAME_CHANNEL]
		,CASE ISNULL([TA].[TRADE_AGREEMENT_ID], 1)
			WHEN 1 THEN 'NO'
			ELSE 'SI'
			END AS [ASOCIADO]
	FROM
		[SONDA].[SWIFT_VIEW_ALL_COSTUMER] AS [VAC]
	LEFT JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] AS [TA] ON ([VAC].[CODE_CUSTOMER] = [TA].[CODE_CUSTOMER])
	LEFT JOIN [SONDA].[SWIFT_SELLER] [svas] ON ([svas].[SELLER_CODE] = [VAC].[SELLER_DEFAULT_CODE])
	LEFT JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [scxc] ON ([VAC].[CODE_CUSTOMER] = [scxc].[CODE_CUSTOMER])
	LEFT JOIN [SONDA].[SWIFT_CHANNEL] [sc] ON (
											[scxc].[CHANNEL_ID] = [sc].[CHANNEL_ID]
											AND [sc].[TYPE_CHANNEL] = 'Comercial'
										)
	WHERE
		[VAC].[NAME_CUSTOMER] LIKE '%' + @CODE_CUSTOMER + '%'
		AND (
			[TA].[TRADE_AGREEMENT_ID] IS NULL
			OR [TA].[TRADE_AGREEMENT_ID] <> @TRADE_AGREEMENT_ID
			);
END;
