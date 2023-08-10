-- =============================================
-- Autor:				christian.hernandez
-- Fecha de Creacion: 	11/14/2018 @Mamut
-- Description:			SP que agrega la promo precio especial por sku

/*
-- Ejemplo de Ejecucion:
		EXEC [SONDA].[SWIFT_SP_ADD_PROMO_SPECIAL_PRICE_LIST_BY_SCALE]
		@PROMO_ID = 3512
		,@CODE_SKU = '100001'
		,@PACK_UNIT = 1
		,@LOW_LIMIT = 1
		,@HIGH_LIMIT = 1
		,@PRICE = 1.000000
		,@INCLUDE_DISCOUNT = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_PROMO_SPECIAL_PRICE_LIST_BY_SCALE](
@PROMO_ID INT
	, @CODE_SKU VARCHAR(50)
	, @PACK_UNIT INT
	, @LOW_LIMIT INT
	, @HIGH_LIMIT INT
	, @PRICE NUMERIC(18,6)
	, @INCLUDE_DISCOUNT INT 
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
		, @DISCOUNT_TYPE = 'MONETARY';
		
		--
		DECLARE @ID INT;
		--

		IF (
				SELECT COUNT(D.CODE_SKU) FROM 
					(SELECT
						*
					FROM
						[SONDA].[SWIFT_PROMO_SPECIAL_PRICE_LIST_BY_SCALE]
					WHERE
						CODE_SKU = @CODE_SKU and PROMO_ID = @PROMO_ID) AS D WHERE (@LOW_LIMIT BETWEEN  D.LOW_LIMIT AND D.HIGH_LIMIT) OR (@HIGH_LIMIT BETWEEN  D.LOW_LIMIT AND D.HIGH_LIMIT) 

			) > 0
	BEGIN 
		SELECT  -1 as Resultado
		,
		' tiene traslape de rangos, intente con otro.'
		 Mensaje  
		,@@ERROR Codigo 
	END;		
ELSE 
	BEGIN 
		INSERT INTO SONDA.[SWIFT_PROMO_SPECIAL_PRICE_LIST_BY_SCALE]
			(
				[PROMO_ID]
				,[CODE_SKU]
				,[PACK_UNIT]
				,[LOW_LIMIT]
				,[HIGH_LIMIT]
				,[PRICE]
				,[LAST_UPDATE]
				,[INCLUDE_DISCOUNT]
			)
		VALUES
				(
					@PROMO_ID  -- PROMO_ID - int
					,@CODE_SKU  -- CODE_SKU - varchar(50)
					,@PACK_UNIT  -- PACK_UNIT - int
					,@LOW_LIMIT  -- LOW_LIMIT - int
					,@HIGH_LIMIT  -- HIGH_LIMIT - int
					,@PRICE  -- DISCOUNT - numeric(18, 6)
					,GETDATE()
					,@INCLUDE_DISCOUNT -- INCLUDE_DISCOUNT - int 
				)
		--
		SET @ID = SCOPE_IDENTITY();
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData;
	END;
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
