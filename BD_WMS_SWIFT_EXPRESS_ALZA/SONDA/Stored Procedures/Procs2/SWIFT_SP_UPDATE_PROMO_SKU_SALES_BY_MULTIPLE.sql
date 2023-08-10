-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	7/26/2017 @ Sprint Bearbeitung
-- Description:			SP que actualiza un registro de la tabla SWIFT_PROMO_SKU_SALES_BY_MULTIPLE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_PROMO_SKU_SALES_BY_MULTIPLE]
					@PROMO_ID = 9
					, @CODE_SKU = '100011'
					, @PACK_UNIT = 1
					, @MULTIPLE = 8
				-- 
				SELECT * FROM [SONDA].[SWIFT_PROMO_SKU_SALES_BY_MULTIPLE]
					WHERE PROMO_ID = 9 AND CODE_SKU = '100011' AND PACK_UNIT = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_PROMO_SKU_SALES_BY_MULTIPLE](
	@PROMO_ID INT,
	@CODE_SKU VARCHAR(50),
	@PACK_UNIT INT,
	@MULTIPLE INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		UPDATE [SONDA].[SWIFT_PROMO_SKU_SALES_BY_MULTIPLE]
		SET	
			[MULTIPLE] = @MULTIPLE
		WHERE [CODE_SKU] = @CODE_SKU
			AND [PACK_UNIT] = @PACK_UNIT
			AND [PROMO_ID] = @PROMO_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN ''
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
