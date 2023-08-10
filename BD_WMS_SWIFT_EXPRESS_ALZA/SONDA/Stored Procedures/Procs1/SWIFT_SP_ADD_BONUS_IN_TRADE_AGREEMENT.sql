-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	20-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que inserta las nuevos bonificaciones al acuerdo comercial

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_ADD_BONUS_IN_TRADE_AGREEMENT
					@TRADE_AGREEMENT_ID = 5
					,@CODE_SKU = '100008'
					,@PACK_UNIT = 7
					,@LOW_LIMIT = 1
					,@HIGH_LIMIT = 10
					,@CODE_SKU_BONUS = '100008'
					,@PACK_UNIT_BONUS = 7
					,@BONUS_QTY = 2
				-- 
				SELECT * FROM [SONDA].SWIFT_TRADE_AGREEMENT_BONUS
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_ADD_BONUS_IN_TRADE_AGREEMENT(
	@TRADE_AGREEMENT_ID INT
	,@CODE_SKU VARCHAR(50)
	,@PACK_UNIT INT
	,@LOW_LIMIT INT
	,@HIGH_LIMIT INT
	,@CODE_SKU_BONUS VARCHAR(50)
	,@PACK_UNIT_BONUS INT
	,@BONUS_QTY INT
)
AS
BEGIN
	BEGIN TRY
		EXEC [SONDA].[SWIFT_SP_VALIDATED_BONUS_SCALE]
			@TRADE_AGREEMENT_ID = @TRADE_AGREEMENT_ID
			,@CODE_SKU = @CODE_SKU
			,@PACK_UNIT = @PACK_UNIT
			,@LOW_LIMIT = @LOW_LIMIT
			,@HIGH_LIMIT = @HIGH_LIMIT
			,@CODE_SKU_BONUS = @CODE_SKU_BONUS
			,@PACK_UNIT_BONUS = @PACK_UNIT_BONUS
			,@BONUS_QTY = @BONUS_QTY

		DECLARE @ID INT
		--
		INSERT INTO [SONDA].SWIFT_TRADE_AGREEMENT_BONUS (
			TRADE_AGREEMENT_ID
			,CODE_SKU
			,PACK_UNIT
			,LOW_LIMIT
			,HIGH_LIMIT
			,CODE_SKU_BONUS
			,PACK_UNIT_BONUS
			,BONUS_QTY
		) VALUES (
			@TRADE_AGREEMENT_ID
			,@CODE_SKU
			,@PACK_UNIT
			,@LOW_LIMIT
			,@HIGH_LIMIT
			,@CODE_SKU_BONUS
			,@PACK_UNIT_BONUS
			,@BONUS_QTY
		)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Ya esta la bonificacion relacionada al acuerdo comercial'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
