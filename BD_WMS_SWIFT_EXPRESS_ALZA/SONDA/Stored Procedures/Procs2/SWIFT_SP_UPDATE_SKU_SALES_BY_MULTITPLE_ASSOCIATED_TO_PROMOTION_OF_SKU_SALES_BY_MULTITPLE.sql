-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	7/26/2017 @Reborn-TEAM Sprint Bearbeitung
-- Description:			SP que actualiza un registro de la tabla SWIFT_PROMO_SKU_SALES_BY_MULTIPLE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_SKU_SALES_BY_MULTITPLE_ASSOCIATED_TO_PROMOTION_OF_SKU_SALES_BY_MULTITPLE]
					@SKU_SALE_BY_MULTITPLE_ID = 2
					, @MULTIPLE = 10
				-- 
				SELECT * FROM [SONDA].[SWIFT_PROMO_SKU_SALES_BY_MULTIPLE]
					WHERE PROMO_ID = 9 AND CODE_SKU = '100011' AND PACK_UNIT = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_SKU_SALES_BY_MULTITPLE_ASSOCIATED_TO_PROMOTION_OF_SKU_SALES_BY_MULTITPLE](
	@SKU_SALE_BY_MULTITPLE_ID INT
	,@MULTIPLE INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		--
		UPDATE [SONDA].[SWIFT_PROMO_SKU_SALES_BY_MULTIPLE]
		SET	[MULTIPLE] = @MULTIPLE
		WHERE [SWIFT_PROMO_SKU_SALES_BY_MULTIPLE_ID] = @SKU_SALE_BY_MULTITPLE_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
