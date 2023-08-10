-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		7/26/2017 @ Sprint Bearbeitung
-- Description:			    Devuelve 0/1 dependiendo si la promo esta asociada a un acuerdo comercial.

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].SWIFT_FN_PROMO_IS_IN_TRADE_AGREEEMENT @PROMO_ID = 9
		--
        EXEC [SONDA].SWIFT_FN_PROMO_IS_IN_TRADE_AGREEEMENT @PROMO_ID = 1
*/
-- =============================================

CREATE FUNCTION [SONDA].SWIFT_FN_PROMO_IS_IN_TRADE_AGREEEMENT
    (@PROMO_ID AS INT)
RETURNS INT
AS
BEGIN
    DECLARE @EXISTE INT = 0
	--
	SELECT TOP 1
		@EXISTE = 1
	FROM
		[SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO]
	WHERE
		@PROMO_ID = [PROMO_ID];
	--
	RETURN @EXISTE
END
