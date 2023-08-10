-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	7/23/2017 @ Reborn-TEAM Sprint Bearbeitung
-- Description:			SP que agrega una nueva promocion de DMG

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_ADD_DISCOUNT_BY_GENERAL_AMOUNT_TO_PROMOTION_OF_DISCOUNT_BY_GENERAL_AMOUNT]
				@PROMO_ID = 8,
				@LOW_AMOUNT = 50000.000000,
				@HIGH_AMOUNT = 60000.990000,
				@DISCOUNT = 3.000000
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_DISCOUNT_BY_GENERAL_AMOUNT_TO_PROMOTION_OF_DISCOUNT_BY_GENERAL_AMOUNT](
	@PROMO_ID INT,
	@LOW_AMOUNT DECIMAL(18,6),
	@HIGH_AMOUNT DECIMAL(18,6),
	@DISCOUNT DECIMAL(18,6)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE @ID INT
		-- ----------------------------------------------------------------------------------------------------------
		-- Se valida el rango de venta para el descuento por monto general
		-- ----------------------------------------------------------------------------------------------------------
		EXEC [SONDA].[SWIFT_SP_VALID_DISCOUNT_SCALE_FOR_DISCOUNT_BY_GENERAL_AMOUNT] @PROMO_ID,@LOW_AMOUNT,@HIGH_AMOUNT;
		
		-- -----------------------------------------------------------------------------------------------------------
		-- Si no hay conflicto con el rango de descuento, éste se agrega a la promoción de Descuento por Monto General
		-- -----------------------------------------------------------------------------------------------------------
		INSERT INTO [SONDA].[SWIFT_PROMO_DISCOUNT_BY_GENERAL_AMOUNT]
				(
					[PROMO_ID]
					,[LOW_AMOUNT]
					,[HIGH_AMOUNT]
					,[DISCOUNT]
				)
		VALUES
				(
					@PROMO_ID  -- PROMO_ID - int
					,@LOW_AMOUNT  -- LOW_AMOUNT - numeric(18, 6)
					,@HIGH_AMOUNT  -- HIGH_AMOUNT - numeric(18, 6)
					,@DISCOUNT -- DISCOUNT - numeric(18, 6)
				)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Ya existe un registro del mismo tipo.'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
	
END
