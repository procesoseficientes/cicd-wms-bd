-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	21-Nov-16 @ A-TEAM Sprint 5
-- Description:			SP que inserta una bonificacion por multiplo

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_ADD_BONUS_MULTIPLE_IN_TRADE_AGREEMENT]
					@TRADE_AGREEMENT_ID = 20
					,@CODE_SKU = '100002'
					,@PACK_UNIT = 7
					,@MULTIPLE = 5
					,@CODE_SKU_BONUS = '100002'
					,@PACK_UNIT_BONUS = 7
					,@BONUS_QTY = 1
				-- 
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BONUS_BY_MULTIPLE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_BONUS_MULTIPLE_IN_TRADE_AGREEMENT](
	@TRADE_AGREEMENT_ID INT
	,@CODE_SKU VARCHAR(50)
	,@PACK_UNIT INT
	,@MULTIPLE NUMERIC(18,0)
	,@CODE_SKU_BONUS VARCHAR(50)
	,@PACK_UNIT_BONUS INT
	,@BONUS_QTY NUMERIC(18,0)
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SWIFT_TRADE_AGREEMENT_BONUS_BY_MULTIPLE]
				(
					[TRADE_AGREEMENT_ID]
					,[CODE_SKU]
					,[PACK_UNIT]
					,[MULTIPLE]
					,[CODE_SKU_BONUS]
					,[PACK_UNIT_BONUS]
					,[BONUS_QTY]
				)
		VALUES
				(
					@TRADE_AGREEMENT_ID  -- TRADE_AGREEMENT_ID - int
					,@CODE_SKU  -- CODE_SKU - varchar(50)
					,@PACK_UNIT  -- PACK_UNIT - int
					,@MULTIPLE -- MULTIPLE - numeric
					,@CODE_SKU_BONUS  -- CODE_SKU_BONUS - varchar(50)
					,@PACK_UNIT_BONUS  -- PACK_UNIT_BONUS - int
					,@BONUS_QTY -- BONUS_QTY - numeric
				)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Error: Ya existe la bonificacion por multiplo'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
