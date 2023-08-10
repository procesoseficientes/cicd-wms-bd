-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	08-Feb-17 @ A-TEAM Sprint Chatuluca
-- Description:			SP que agrega un producto al combo

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_INSERT_SKU_BY_COMBO]
					@COMBO_ID = 5
					,@CODE_SKU = '100002'
					,@PACK_UNIT = 8
					,@QTY = 2
				-- 
				SELECT * FROM [SONDA].[SWIFT_SKU_BY_COMBO]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_SKU_BY_COMBO](
	@COMBO_ID INT
	,@CODE_SKU VARCHAR(50)
	,@PACK_UNIT INT
	,@QTY INT
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SWIFT_SKU_BY_COMBO]
				(
					[COMBO_ID]
					,[CODE_SKU]
					,[PACK_UNIT]
					,[QTY]
				)
		VALUES
				(
					@COMBO_ID
					,@CODE_SKU
					,@PACK_UNIT
					,@QTY
				)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Ya esta asociado el producto con la unidad de medida al combo'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
