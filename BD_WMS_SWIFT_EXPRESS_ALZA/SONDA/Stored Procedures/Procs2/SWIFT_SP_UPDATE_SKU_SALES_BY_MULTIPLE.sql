-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	08-Dec-16 @ A-TEAM Sprint Chatoluka 
-- Description:			SP que actualiza una venta por multiplo del acuerdo comercial

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_SKU_SALES_BY_MULTIPLE]
					@TRADE_AGREEMENT_ID = 21
					,@CODE_SKU = '100002'
					,@PACK_UNIT = 8
					,@MULTIPLE = 4
				-- 
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_SKU_SALES_BY_MULTIPLE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_SKU_SALES_BY_MULTIPLE](
	@TRADE_AGREEMENT_ID INT
	,@CODE_SKU VARCHAR(50)
	,@PACK_UNIT INT
	,@MULTIPLE INT
)
AS
BEGIN
	BEGIN TRY
		UPDATE [SONDA].[SWIFT_TRADE_AGREEMENT_SKU_SALES_BY_MULTIPLE]
		SET	
			[MULTIPLE] = @MULTIPLE
		WHERE [TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID
			AND [CODE_SKU] = @CODE_SKU
			AND [PACK_UNIT] = @PACK_UNIT
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Ya existe una venta minima para el producto y unidad de medida seleccionado'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
