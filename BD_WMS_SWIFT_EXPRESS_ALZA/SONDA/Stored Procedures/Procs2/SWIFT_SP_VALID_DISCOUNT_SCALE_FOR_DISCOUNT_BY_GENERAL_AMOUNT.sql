-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	7/23/2017 @ Reborn-TEAM Sprint Bearbeitung
-- Description:			SP que valida la escala del descuento por monto general para que no existan colisiones

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_VALID_DISCOUNT_SCALE_FOR_DISCOUNT_BY_GENERAL_AMOUNT]
				@PROMO_ID = 8,
				@LOW_AMOUNT = 1000.000000,
				@HIGH_AMOUNT = 2999.990000
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALID_DISCOUNT_SCALE_FOR_DISCOUNT_BY_GENERAL_AMOUNT](
	@PROMO_ID INT
	,@LOW_AMOUNT NUMERIC(18,6)
	,@HIGH_AMOUNT NUMERIC(18,6)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@MESSAGE VARCHAR(250) = NULL
	--
	SELECT TOP 1 
		@MESSAGE = CASE
			WHEN @LOW_AMOUNT BETWEEN S.LOW_AMOUNT AND S.HIGH_AMOUNT THEN 'Límite inferior del Rango de Venta Mínima y Venta Máxima se encuentra entre rango existente.'
			WHEN @HIGH_AMOUNT BETWEEN S.LOW_AMOUNT AND S.HIGH_AMOUNT THEN 'Límite superior del Rango de Venta Mínima y Venta Máxima se encuentra entre rango existente.'
			WHEN S.LOW_AMOUNT BETWEEN @LOW_AMOUNT AND @HIGH_AMOUNT THEN 'Rango de Venta Mínima y Venta Máxima, absorbe un rango existente.'
			ELSE 'Rangos mal definidos.'
		END
	FROM [SONDA].SWIFT_PROMO_DISCOUNT_BY_GENERAL_AMOUNT AS S
	WHERE S.[PROMO_ID] = @PROMO_ID
		AND (
			(
				@LOW_AMOUNT BETWEEN S.[LOW_AMOUNT] AND S.[HIGH_AMOUNT]
				OR @HIGH_AMOUNT BETWEEN S.[LOW_AMOUNT] AND S.[HIGH_AMOUNT]
			)
			OR
			(
				S.[LOW_AMOUNT] BETWEEN @LOW_AMOUNT AND @HIGH_AMOUNT
				OR S.[HIGH_AMOUNT] BETWEEN @LOW_AMOUNT AND @HIGH_AMOUNT
			)
		)
	--
	IF @MESSAGE IS NOT NULL
	BEGIN
		RAISERROR(@MESSAGE,16,1)
	END
END
