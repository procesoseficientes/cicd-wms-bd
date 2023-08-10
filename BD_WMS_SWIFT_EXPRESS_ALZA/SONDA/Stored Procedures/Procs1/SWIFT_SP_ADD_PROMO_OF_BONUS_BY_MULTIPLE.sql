-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/13/2017 @ A-TEAM Sprint Jibade
-- Description:			Agrega registo en la tabla SWIFT_PROMO_BONUS_BY_MULTIPLE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_ADD_PROMO_OF_BONUS_BY_MULTIPLE]
					@PROMO_ID = 5, -- int
					@CODE_SKU = 'UP0000703', -- varchar(50)
					@PACK_UNIT = 1, -- int
					@MULTIPLE = 2, -- int
					@CODE_SKU_BONUS = 'UP0100683', -- varchar(50)
					@PACK_UNIT_BONUS = 1, -- int
					@BONUS_QTY = 2 -- int
				-- 
				SELECT * FROM [SONDA].[SWIFT_PROMO_BONUS_BY_MULTIPLE] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ADD_PROMO_OF_BONUS_BY_MULTIPLE](
	@PROMO_ID INT
	,@CODE_SKU VARCHAR(50)
	,@PACK_UNIT INT 
	,@MULTIPLE INT
	,@CODE_SKU_BONUS VARCHAR(50)
	,@PACK_UNIT_BONUS INT
	,@BONUS_QTY INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SWIFT_PROMO_BONUS_BY_MULTIPLE]
				(
					[PROMO_ID]
					,[CODE_SKU]
					,[PACK_UNIT]
					,[MULTIPLE]
					,[CODE_SKU_BONUS]
					,[PACK_UNIT_BONUS]
					,[BONUS_QTY]
				)
		VALUES
				(
					@PROMO_ID  -- PROMO_ID - int
					,@CODE_SKU  -- CODE_SKU - varchar(50)
					,@PACK_UNIT  -- PACK_UNIT - int
					,@MULTIPLE  -- MULTIPLE - numeric
					,@CODE_SKU_BONUS  -- CODE_SKU_BONUS - varchar(50)
					,@PACK_UNIT_BONUS  -- PACK_UNIT_BONUS - int
					,@BONUS_QTY  -- BONUS_QTY - numeric
				)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Error al ingresar bonificacion por multiplo.'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
