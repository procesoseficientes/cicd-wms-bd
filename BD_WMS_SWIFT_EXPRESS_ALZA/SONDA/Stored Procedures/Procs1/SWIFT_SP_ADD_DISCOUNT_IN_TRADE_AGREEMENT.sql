-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	13-09-2016 @ A-TEAM Sprint 1
-- Description:			Agrega un sku al acuerdo comercial


-- Modificacion 2/10/2017 @ A-Team Sprint Chatuluka
		-- rodrigo.gomez
		-- Se agrego la validacion con el SP SWIFT_SP_VALIDATED_DISCOUNT_SCALE y se modifico la estructura del insert para las modificaciones a la tabla SWIFT_TRADE_AGREEMENT_DISCOUNT.
/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_ADD_DISCOUNT_IN_TRADE_AGREEMENT
					@TRADE_AGREEMENT_ID  = 21
					,@CODE_SKU  = '100002'
					,@PACK_UNIT = 7
					,@LOW_LIMIT = 1
					,@HIGH_LIMIT = 10
					,@DISCOUNT  = 5

				-- 
				SELECT * FROM [SONDA].SWIFT_TRADE_AGREEMENT_DISCOUNT WHERE TRADE_AGREEMENT_ID = 21
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_ADD_DISCOUNT_IN_TRADE_AGREEMENT(
	@TRADE_AGREEMENT_ID  INT
	,@CODE_SKU  VARCHAR(50)
	,@PACK_UNIT INT
	,@LOW_LIMIT INT
	,@HIGH_LIMIT INT
	,@DISCOUNT NUMERIC(18,6)
)
AS
BEGIN
	BEGIN TRY		
		--
		EXEC [SONDA].[SWIFT_SP_VALIDATED_DISCOUNT_SCALE] 
			@TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID , -- int
			@CODE_SKU = @CODE_SKU , -- varchar(50)
			@PACK_UNIT = @PACK_UNIT , -- int
			@LOW_LIMIT = @LOW_LIMIT , -- int
			@HIGH_LIMIT = @HIGH_LIMIT -- int

		--
		DECLARE @ID INT
		--

		INSERT INTO [SONDA].[SWIFT_TRADE_AGREEMENT_DISCOUNT]
				(
					[TRADE_AGREEMENT_ID]
					,[CODE_SKU]
					,[PACK_UNIT]
					,[LOW_LIMIT]
					,[HIGH_LIMIT]
					,[DISCOUNT]
				)
		VALUES
				(
					@TRADE_AGREEMENT_ID  -- TRADE_AGREEMENT_ID - int
					,@CODE_SKU  -- CODE_SKU - varchar(50)
					,@PACK_UNIT  -- PACK_UNIT - int
					,@LOW_LIMIT  -- LOW_LIMIT - int
					,@HIGH_LIMIT  -- HIGH_LIMIT - int
					,@DISCOUNT  -- DISCOUNT - numeric
				)
				
		
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Ya esta el producto: ' + @CODE_SKU+ ' ya esta asociado al acuerdo comercial.'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
