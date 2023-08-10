-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	09-Feb-17 @ A-TEAM Sprint Chatuluka
-- Description:			SP que inserta la bonificacion del combo

-- Modificacion 27-Mar-17 @ A-Team Sprint Fenyang
					-- alberto.ruiz
					-- Se Agrego campo IS_MULTIPLE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_INSERT_TRADE_AGREEMENT_SKU_BY_BONUS_RULE]
					@TRADE_AGREEMENT_BONUS_RULE_BY_COMBO_ID = 64
					,@CODE_SKU = '10003'
					,@PACK_UNIT = 8
					,@QTY = 2
					,@IS_MULTIPLE = 0
				-- 
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_SKU_BY_BONUS_RULE] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_TRADE_AGREEMENT_SKU_BY_BONUS_RULE](
	@TRADE_AGREEMENT_BONUS_RULE_BY_COMBO_ID INT
	,@CODE_SKU VARCHAR(50)
	,@PACK_UNIT INT
	,@QTY INT
	,@IS_MULTIPLE INT = 0
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SWIFT_TRADE_AGREEMENT_SKU_BY_BONUS_RULE]
				(
					[TRADE_AGREEMENT_BONUS_RULE_BY_COMBO_ID]
					,[CODE_SKU]
					,[PACK_UNIT]
					,[QTY]
					,[IS_MULTIPLE]
				)
		VALUES
				(
					@TRADE_AGREEMENT_BONUS_RULE_BY_COMBO_ID
					,@CODE_SKU
					,@PACK_UNIT
					,@QTY
					,@IS_MULTIPLE
				)
		--
		SET @ID = SCOPE_IDENTITY()
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
