
-- =======================================================
-- Autor:				diego.as
-- Fecha de Creacion:	16-02-2017 TEAM-A @ Sprint Chatuluka
-- Descripcion:		Valida si los datos de porcentaje de descuento que se envian como parametros, no colisionan con algun registro ya existente.

/*
-- Ejemplo de Ejecucion:
	EXEC [SONDA].[SWIFT_SP_VALIDATED_DISCOUNT_SCALE_FOR_GENERAL_AMOUNT]
		@TRADE_AGREEMENT_ID = 21
		,@LOW_LIMIT = 100
		,@HIGH_LIMIT = 450
		------------------------------
		SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_DISCOUNT_BY_GENERAL_AMOUNT]
*/
-- =======================================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATED_DISCOUNT_SCALE_FOR_GENERAL_AMOUNT] (
	@TRADE_AGREEMENT_ID INT
	,@LOW_LIMIT NUMERIC(18,6)
	,@HIGH_LIMIT NUMERIC(18,6)
) AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @MESSAGE VARCHAR(250) = NULL

	--
	SELECT TOP 1 
		@MESSAGE = CASE
			WHEN @LOW_LIMIT BETWEEN S.LOW_AMOUNT AND S.HIGH_AMOUNT THEN 'Limite inferior del Rango de Venta Minima y Venta Maxima entre rango existente'
			WHEN @HIGH_LIMIT BETWEEN S.LOW_AMOUNT AND S.HIGH_AMOUNT THEN 'Limite superior del Rango de Venta Minima y Venta Maxima entre rango existente'
			WHEN S.LOW_AMOUNT BETWEEN @LOW_LIMIT AND @HIGH_LIMIT THEN 'Rango de Venta Minima y Venta Maxima, absorve un rango ya existente'
			WHEN @LOW_LIMIT > @HIGH_LIMIT THEN 'Rango de Venta Minima y Venta Maxima, mal configurado. Venta Minima no puede ser mayor a Venta Maxima.'
			ELSE 'Rangos mal definidos'
		END
	FROM [SONDA].[SWIFT_TRADE_AGREEMENT_DISCOUNT_BY_GENERAL_AMOUNT] AS S
	WHERE S.TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID
		AND (
			(
				@LOW_LIMIT BETWEEN S.LOW_AMOUNT AND S.HIGH_AMOUNT
				OR @HIGH_LIMIT BETWEEN S.LOW_AMOUNT AND S.HIGH_AMOUNT
			)
			OR
			(
				S.LOW_AMOUNT BETWEEN @LOW_LIMIT AND @HIGH_LIMIT
				OR S.LOW_AMOUNT BETWEEN @LOW_LIMIT AND @HIGH_LIMIT
			)
			OR
			(
				@LOW_LIMIT > @HIGH_LIMIT
			)
		)
	--
	IF @MESSAGE IS NOT NULL
	BEGIN
		RAISERROR(@MESSAGE,16,1)
	END
END
