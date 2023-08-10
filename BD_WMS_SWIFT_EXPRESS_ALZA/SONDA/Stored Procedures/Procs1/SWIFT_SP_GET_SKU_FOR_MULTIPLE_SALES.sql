-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Feb-17 @ A-TEAM Sprint Chatuluka
-- Description:			SP que obtiene los productos con venta minima del acuerdo comercial

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_SKU_FOR_MULTIPLE_SALES]
					@TRADE_AGREEMENT_ID = 21
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SKU_FOR_MULTIPLE_SALES](
	@TRADE_AGREEMENT_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		ROW_NUMBER() OVER (ORDER BY [TAS].[TRADE_AGREEMENT_ID],[S].[CODE_SKU],[PU].[PACK_UNIT]) [ID]
		,[TAS].[TRADE_AGREEMENT_ID]
		,[TAS].[CODE_SKU]
		,[S].[DESCRIPTION_SKU]
		,[TAS].[PACK_UNIT]
		,[PU].[CODE_PACK_UNIT]
		,[PU].[DESCRIPTION_PACK_UNIT]
		,[FS].[FAMILY_SKU]
		,[FS].[CODE_FAMILY_SKU]
		,[FS].[DESCRIPTION_FAMILY_SKU]
		,[TAS].[MULTIPLE]
	FROM [SONDA].[SWIFT_TRADE_AGREEMENT_SKU_SALES_BY_MULTIPLE] [TAS]	
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S] ON (
		[TAS].[CODE_SKU] = [S].[CODE_SKU]
	)
	LEFT JOIN [SONDA].[SWIFT_FAMILY_SKU] [FS] ON (
		[FS].[CODE_FAMILY_SKU] = [S].[CODE_FAMILY_SKU]
	)
	INNER JOIN [SONDA].[SONDA_PACK_UNIT] [PU] ON (
		[TAS].[PACK_UNIT] = [PU].[PACK_UNIT]
	)
	WHERE [TAS].[TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID
	ORDER BY
		[S].[CODE_SKU]
		,[PU].[PACK_UNIT]
END
