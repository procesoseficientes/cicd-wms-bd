-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	08-Dec-16 @ A-TEAM Sprint Chatuluka 
-- Description:			SP que borra una venta por multiplo del acuerdo comercial

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_SKU_SALES_BY_MULTIPLE]
				--
				EXEC [SONDA].[SWIFT_SP_DELETE_SKU_SALES_BY_MULTIPLE]
					@TRADE_AGREEMENT_ID = 21
					,@CODE_SKU = '10002'
					,@PACK_UNIT = 7
				-- 
				SELECT * FROM [SONDA].[SWIFT_TRADE_AGREEMENT_SKU_SALES_BY_MULTIPLE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_SKU_SALES_BY_MULTIPLE](
	@TRADE_AGREEMENT_ID INT
	,@CODE_SKU VARCHAR(50)
	,@PACK_UNIT INT
)
AS
BEGIN
	BEGIN TRY
		DELETE FROM [SONDA].[SWIFT_TRADE_AGREEMENT_SKU_SALES_BY_MULTIPLE]
		WHERE [TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID
			AND [CODE_SKU] = @CODE_SKU
			AND [PACK_UNIT] = @PACK_UNIT
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
