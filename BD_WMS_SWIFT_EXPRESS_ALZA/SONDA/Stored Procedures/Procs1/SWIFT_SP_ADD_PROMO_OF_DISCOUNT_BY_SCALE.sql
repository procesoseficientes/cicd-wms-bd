-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	6/29/2017 @ A-TEAM Sprint Anpassung 
-- Description:			SP que agrega la promo de descuento

/*
-- Ejemplo de Ejecucion:
		EXEC [SONDA].[SWIFT_SP_ADD_PROMO_OF_DISCOUNT_BY_SCALE]
		@PROMO_ID = 2114
		,@CODE_SKU = '100001'
		,@PACK_UNIT = 1
		,@LOW_LIMIT = 1
		,@HIGH_LIMIT = 20
		,@DISCOUNT = 5.000000
		,@DISCOUNT_TYPE = 'PERCENTAGE'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_PROMO_OF_DISCOUNT_BY_SCALE](
@PROMO_ID INT
	, @CODE_SKU VARCHAR(50)
	, @PACK_UNIT INT
	, @LOW_LIMIT INT
	, @HIGH_LIMIT INT
	, @DISCOUNT NUMERIC(18,6)
	, @DISCOUNT_TYPE VARCHAR(50)
	, @IS_UNIQUE INT 
)
AS
BEGIN
	BEGIN TRY
		-- --------------------------------------------------------------------------
		-- Se valida el rango de la promocion que se desea agregar
		-- --------------------------------------------------------------------------
		EXEC [SONDA].[SWIFT_SP_VALIDATE_DISCOUNT_SCALE_FOR_PROMO]
		@PROMO_ID = @PROMO_ID
		, @CODE_SKU = @CODE_SKU
		, @PACK_UNIT = @PACK_UNIT
		, @LOW_LIMIT = @LOW_LIMIT
		, @HIGH_LIMIT = @HIGH_LIMIT
		, @DISCOUNT_TYPE = @DISCOUNT_TYPE;
		
		--
		DECLARE @ID INT;
		--
		INSERT INTO SONDA.[SWIFT_PROMO_DISCOUNT_BY_SCALE]
			(
				[PROMO_ID]
				,[CODE_SKU]
				,[PACK_UNIT]
				,[LOW_LIMIT]
				,[HIGH_LIMIT]
				,[DISCOUNT]
				,[DISCOUNT_TYPE]
				,[IS_UNIQUE]
			)
		VALUES
				(
					@PROMO_ID  -- PROMO_ID - int
					,@CODE_SKU  -- CODE_SKU - varchar(50)
					,@PACK_UNIT  -- PACK_UNIT - int
					,@LOW_LIMIT  -- LOW_LIMIT - int
					,@HIGH_LIMIT  -- HIGH_LIMIT - int
					,@DISCOUNT  -- DISCOUNT - numeric(18, 6)
					,@DISCOUNT_TYPE  -- DISCOUNT_TYPE - varchar(50)
					,@IS_UNIQUE -- IS_UNIQUE - int 
				)
		--
		SET @ID = SCOPE_IDENTITY();
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData;
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Error al insertar el descuento por escala.'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
