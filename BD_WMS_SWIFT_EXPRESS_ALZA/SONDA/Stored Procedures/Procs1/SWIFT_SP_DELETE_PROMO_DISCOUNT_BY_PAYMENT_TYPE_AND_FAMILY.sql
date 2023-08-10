-- =============================================
-- Autor:                Marvin.Garcia - Cristian.Hernandez
-- Fecha de Creacion:     04-05-2018 @ A-TEAM Sprint Caribú
-- Description:            SP que elimina promociones por familia y tipo de pago
/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_DELETE_PROMO_DISCOUNT_BY_PAYMENT_TYPE_AND_FAMILY]
        @PROMO_ID = 2114
*/
-- =============================================

CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_PROMO_DISCOUNT_BY_PAYMENT_TYPE_AND_FAMILY
	@PROMO_ID INT
AS
BEGIN TRY
	-- ---------------------------------------------------
	-- se eliminan los descuentos por familia especificada
	-- ---------------------------------------------------
	DELETE FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_PAYMENT_TYPE_AND_FAMILY]
	WHERE PROMO_ID = @PROMO_ID


  UPDATE [SONDA].[SWIFT_PROMO]
    SET [LAST_UPDATE] = GETDATE()
    WHERE [PROMO_ID] = @PROMO_ID;
	-- -------------------------
	-- mensaje resultado exitoso
	-- -------------------------
	SELECT
		1 AS Resultado
		,'Proceso Exitoso' AS Mensaje
		,0 AS Codigo
END TRY
BEGIN CATCH
	-- ----------------
	-- mensaje de error
	-- ----------------
	SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo
END CATCH
