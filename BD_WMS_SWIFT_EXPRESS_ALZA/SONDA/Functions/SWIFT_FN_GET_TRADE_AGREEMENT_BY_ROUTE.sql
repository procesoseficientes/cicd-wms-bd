-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		12-Jan-17 @ A-Team Sprint Adeben
-- Description:			    Funcion que obtiene el acuerdo comercial asignado a la ruta

/*
-- Ejemplo de Ejecucion:
        SELECT [SONDA].[SWIFT_FN_GET_TRADE_AGREEMENT_BY_ROUTE]('001')
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_FN_GET_TRADE_AGREEMENT_BY_ROUTE]
(
	@CODE_ROUTE VARCHAR(50)
)
RETURNS INT
AS
BEGIN
	DECLARE @TRADE_AGREEMENT_ID INT
	--
	SELECT TOP 1 @TRADE_AGREEMENT_ID = [R].[TRADE_AGREEMENT_ID]
	FROM [SONDA].[SWIFT_ROUTES] [R]
	WHERE [R].[CODE_ROUTE] = @CODE_ROUTE
	--
	RETURN @TRADE_AGREEMENT_ID
END
