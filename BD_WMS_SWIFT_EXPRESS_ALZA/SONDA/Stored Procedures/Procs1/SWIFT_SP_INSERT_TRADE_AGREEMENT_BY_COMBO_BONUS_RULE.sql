-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	08-Feb-17 @ A-TEAM Sprint Chatuluka
-- Description:			SP que agrega la regla de bonificacion por combo al acuerdo comercial

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_INSERT_TRADE_AGREEMENT_BY_COMBO_BONUS_RULE]
					@COMBO_ID = 1
					,@BONUS_SUB_TYPE = 'MULTIPLE'
					,@IS_BONUS_BY_LOW_PURCHASE = 0
					,@IS_BONUS_BY_COMBO = 1
					,@LOW_QTY = 15
					,@TRADE_AGREEMENT_ID = 20
				-- 
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BY_COMBO_BONUS_RULE]
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BY_BONUS_RULE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_TRADE_AGREEMENT_BY_COMBO_BONUS_RULE](
	@COMBO_ID INT
	,@BONUS_SUB_TYPE VARCHAR(50)
	,@IS_BONUS_BY_LOW_PURCHASE INT
	,@IS_BONUS_BY_COMBO INT
	,@LOW_QTY INT = 1
	,@TRADE_AGREEMENT_ID INT
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SWIFT_TRADE_AGREEMENT_BY_COMBO_BONUS_RULE]
				(
					[COMBO_ID]
					,[BONUS_SUB_TYPE]
					,[IS_BONUS_BY_LOW_PURCHASE]
					,[IS_BONUS_BY_COMBO]
					,[LOW_QTY]
				)
		VALUES
				(
					@COMBO_ID
					,@BONUS_SUB_TYPE
					,@IS_BONUS_BY_LOW_PURCHASE
					,@IS_BONUS_BY_COMBO
					,@LOW_QTY
				)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		INSERT INTO [SONDA].[SWIFT_TRADE_AGREEMENT_BY_BONUS_RULE]
				(
					[TRADE_AGREEMENT_ID]
					,[TRADE_AGREEMENT_BONUS_RULE_BY_COMBO_ID]
				)
		VALUES
				(
					@TRADE_AGREEMENT_ID
					,@ID
				)
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Ya existe la bonificacion del combo'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
