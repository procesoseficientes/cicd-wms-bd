-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/14/2017 @ A-TEAM Sprint Jibade
-- Description:			Inserta un registro en la tabla SWIFT_PROMO_BY_BONUS_RULE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_ADD_PROMO_BY_BONUS_RULE]
					@PROMO_ID = 6
					, @PROMO_RULE_BY_COMBO_ID = 33
				-- 
				SELECT * FROM [SONDA].[SWIFT_PROMO_BY_BONUS_RULE] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_PROMO_BY_BONUS_RULE](
	@PROMO_ID INT
	, @PROMO_RULE_BY_COMBO_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SWIFT_PROMO_BY_BONUS_RULE]
				(
					[PROMO_ID]
					,[PROMO_RULE_BY_COMBO_ID]
				)
		VALUES
				(
					@PROMO_ID  -- PROMO_ID - int
					,@PROMO_RULE_BY_COMBO_ID  -- PROMO_RULE_BY_COMBO_ID - int
				)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Error al insertar un registro.'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
