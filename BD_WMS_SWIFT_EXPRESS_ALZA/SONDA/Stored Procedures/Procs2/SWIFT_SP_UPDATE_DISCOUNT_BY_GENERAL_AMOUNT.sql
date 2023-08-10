-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	15-Feb-17 @ A-TEAM Sprint Chatuluka
-- Description:			SP que actualiza un registro de Descuento Por Monto General en el Acuerdo Comercial

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_DISCOUNT_BY_GENERAL_AMOUNT]
				WHERE TRADE_AGREEMENT_ID = 21
				--
				EXEC [SONDA].[SWIFT_SP_UPDATE_DISCOUNT_BY_GENERAL_AMOUNT]
				@TRADE_AGREEMENT_ID = 21
				,@LOW_AMOUNT = 50
				,@HIGH_AMOUNT = 100
				,@DISCOUNT = 15
				-- 
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_DISCOUNT_BY_GENERAL_AMOUNT]
				WHERE TRADE_AGREEMENT_ID = 21
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_DISCOUNT_BY_GENERAL_AMOUNT](
	@TRADE_AGREEMENT_ID INT
	,@LOW_AMOUNT NUMERIC(18, 6)
	,@HIGH_AMOUNT NUMERIC(18, 6)
	,@DISCOUNT NUMERIC(18, 6)
)
AS
BEGIN
	BEGIN TRY
		--
		UPDATE [SONDA].[SWIFT_TRADE_AGREEMENT_DISCOUNT_BY_GENERAL_AMOUNT]
		SET	
			DISCOUNT = @DISCOUNT
		WHERE 
			TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID
			AND [LOW_AMOUNT] = @LOW_AMOUNT
			AND [HIGH_AMOUNT] = @HIGH_AMOUNT
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Registros ya existe.'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
