-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		7/19/2017 @ A-Team Sprint Barbeitung
-- Description:			    SP que valida el rango del descuento que se le envia

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_VALIDATE_DISCOUNT_SCALE_FOR_PROMO]
		@PROMO_ID = 2114
		, @CODE_SKU = '100001'
		, @PACK_UNIT = 1
		, @LOW_LIMIT = 1
		, @HIGH_LIMIT = 20
		, @DISCOUNT_TYPE = 'PERCENTAGE'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_DISCOUNT_SCALE_FOR_PROMO](
	@PROMO_ID INT
	, @CODE_SKU VARCHAR(50)
	, @PACK_UNIT INT
	, @LOW_LIMIT INT
	, @HIGH_LIMIT INT
	, @DISCOUNT_TYPE VARCHAR(50)
)
WITH RECOMPILE
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@MESSAGE VARCHAR(250) = NULL
	--
	SELECT TOP 1 
		@MESSAGE = CASE
			WHEN @LOW_LIMIT BETWEEN S.LOW_LIMIT AND S.HIGH_LIMIT THEN 'Limite inferior del SKU: '+CAST(@CODE_SKU AS VARCHAR) +' entre rango existente'
			WHEN @HIGH_LIMIT BETWEEN S.LOW_LIMIT AND S.HIGH_LIMIT THEN 'Limite superior del SKU: '+CAST(@CODE_SKU AS VARCHAR) +' entre rango existente'
			WHEN S.LOW_LIMIT BETWEEN @LOW_LIMIT AND @HIGH_LIMIT THEN 'Rango del SKU: '+CAST(@CODE_SKU AS VARCHAR) +' absorbe un rango ya existente'
			WHEN S.HIGH_LIMIT BETWEEN @LOW_LIMIT AND @HIGH_LIMIT THEN 'Rango del SKU: '+CAST(@CODE_SKU AS VARCHAR) +' absorbe un rango ya existente'
			ELSE 'Rangos mal definidos'
		END
	FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_SCALE] AS S
	WHERE S.CODE_SKU = @CODE_SKU
		AND S.PACK_UNIT = @PACK_UNIT
		AND (
			(
				@LOW_LIMIT BETWEEN S.LOW_LIMIT AND S.HIGH_LIMIT
				OR @HIGH_LIMIT BETWEEN S.LOW_LIMIT AND S.HIGH_LIMIT
			)
			OR
			(
				S.LOW_LIMIT BETWEEN @LOW_LIMIT AND @HIGH_LIMIT
				OR S.HIGH_LIMIT BETWEEN @LOW_LIMIT AND @HIGH_LIMIT
			)
		)
		AND S.[PROMO_ID] = @PROMO_ID
		
	
	--
	IF @MESSAGE IS NOT NULL
	BEGIN
		RAISERROR(@MESSAGE,16,1)
	END
END
