
/*==================================================

Autor:				diego.as
Fecha de Creacion:	12-09-2016 @ A-TEAM Sprint 1
Descripcion:		Trae todos los clientes del acuerdo comercial que recibe como parametro

Ejemplo de Ejecución:

	EXEC [SONDA].[SWIFT_SP_GET_CUSTOMER_IN_TRADE_AGREEMENT]
		@TRADE_AGREEMENT_ID = 1

==================================================*/

CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_CUSTOMER_IN_TRADE_AGREEMENT]
(
	@TRADE_AGREEMENT_ID INT
) AS
BEGIN
	SELECT
		TA.TRADE_AGREEMENT_ID
		,TA.CODE_CUSTOMER
		,VAC.NAME_CUSTOMER
		,VAC.ADRESS_CUSTOMER
	FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] AS TA
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] AS VAC ON(
		TA.CODE_CUSTOMER = VAC.CODE_CUSTOMER
	)
	WHERE TA.TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID
END
