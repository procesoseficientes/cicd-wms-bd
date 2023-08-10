-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/14/2017 @ A-TEAM Sprint Jibade
-- Description:			Inserta un registro en la tabla SWIFT_PROMO_SKU_BY_PROMO_RULE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_ADD_PROMO_SKU_BY_PROMO_RULE]
					@PROMO_RULE_BY_COMBO_ID   = 34
					,@CODE_SKU  = 'UP0000683'
					,@PACK_UNIT  = 1
					,@QTY  = 5
					,@IS_MULTIPLE  = 0
				-- 
				SELECT * FROM [SONDA].[SWIFT_PROMO_SKU_BY_PROMO_RULE] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_PROMO_SKU_BY_PROMO_RULE](
	@PROMO_RULE_BY_COMBO_ID   int
	,@CODE_SKU  varchar(50)
	,@PACK_UNIT  int
	,@QTY  int
	,@IS_MULTIPLE  int
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SWIFT_PROMO_SKU_BY_PROMO_RULE]
				(
					[PROMO_RULE_BY_COMBO_ID]
					,[CODE_SKU]
					,[PACK_UNIT]
					,[QTY]
					,[IS_MULTIPLE]
				)
		VALUES
				(
					@PROMO_RULE_BY_COMBO_ID  -- PROMO_RULE_BY_COMBO_ID - int
					,@CODE_SKU  -- CODE_SKU - varchar(50)
					,@PACK_UNIT  -- PACK_UNIT - int
					,@QTY  -- QTY - int
					,@IS_MULTIPLE  -- IS_MULTIPLE - int
				)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Error al insertar un sku para la bonificacion por combo.'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
