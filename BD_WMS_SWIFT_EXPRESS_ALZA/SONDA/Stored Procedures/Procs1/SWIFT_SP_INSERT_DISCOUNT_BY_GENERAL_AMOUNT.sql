-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	2/15/2017 @ A-TEAM Sprint Chatuluka
-- Description:			SP que inserta un nuevo registro de Descuento por Monto General Al Acuerdo Comercial

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_INSERT_DISCOUNT_BY_GENERAL_AMOUNT]
				@TRADE_AGREEMENT_ID = 21
				,@LOW_AMOUNT = '100'
				,@HIGH_AMOUNT = '500'
				,@DISCOUNT = 25
				-- 
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_DISCOUNT_BY_GENERAL_AMOUNT] 
				WHERE TRADE_AGREEMENT_ID = 21
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_DISCOUNT_BY_GENERAL_AMOUNT](
	@TRADE_AGREEMENT_ID INT
	,@LOW_AMOUNT NUMERIC(18, 6)
	,@HIGH_AMOUNT NUMERIC(18, 6)
	,@DISCOUNT NUMERIC(18, 6)
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		EXEC [SONDA].[SWIFT_SP_VALIDATED_DISCOUNT_SCALE_FOR_GENERAL_AMOUNT] @TRADE_AGREEMENT_ID, @LOW_AMOUNT,@HIGH_AMOUNT
		--
		INSERT INTO [SONDA].[SWIFT_TRADE_AGREEMENT_DISCOUNT_BY_GENERAL_AMOUNT] (
			TRADE_AGREEMENT_ID
			,LOW_AMOUNT
			,HIGH_AMOUNT
			,DISCOUNT
		)
		VALUES (
			@TRADE_AGREEMENT_ID
			,@LOW_AMOUNT
			,@HIGH_AMOUNT
			,@DISCOUNT
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
