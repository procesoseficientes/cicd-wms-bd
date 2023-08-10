-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	22-Nov-16 @ A-TEAM Sprint 5 
-- Description:			SP que obtiene las series por sku en una bodega

-- Modificacion 31-Jan-17 @ A-Team Sprint Bankole
					-- alberto.ruiz
					-- Se cambio validacion para muestre las series de ordenes canceladas

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_SERIE_BY_SKU_AND_WAREHOUSE]
					@CODE_WAREHOUSE = 'C001'
					,@CODE_SKU = '100003'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SERIE_BY_SKU_AND_WAREHOUSE](
	@CODE_WAREHOUSE VARCHAR(50)
	,@CODE_SKU VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[I].[INVENTORY]
		,[I].[SERIAL_NUMBER]
		,[I].[WAREHOUSE]
		,[I].[LOCATION]
		,[I].[SKU]
		,[I].[SKU_DESCRIPTION]
		,[I].[ON_HAND]
		,[I].[BATCH_ID]
		,[I].[LAST_UPDATE]
		,[I].[LAST_UPDATE_BY]
		,[I].[TXN_ID]
		,[I].[IS_SCANNED]
		,[I].[RELOCATED_DATE]
		,[I].[PALLET_ID]
	FROM [SONDA].[SWIFT_INVENTORY] [I]
	LEFT JOIN [SONDA].[SWIFT_TRANSFER_DETAIL] [TD] ON (
		[TD].[SKU_CODE] = [I].[SKU]
		AND ISNULL([I].[SERIAL_NUMBER],'NA') = ISNULL([TD].[SERIE],'NA')
		--AND [TD].[STATUS] = 'CANCELADO'
	)
	LEFT JOIN [SONDA].[SWIFT_TRANSFER_HEADER] [TH] ON (
		[TH].[TRANSFER_ID] = [TD].[TRANSFER_ID]
	)
	WHERE [I].[WAREHOUSE] = @CODE_WAREHOUSE
		AND [I].[SKU] = @CODE_SKU
		AND [I].[ON_HAND] > 0
		AND [I].[SERIAL_NUMBER] IS NOT NULL
		AND ([TH].[STATUS] = 'CANCELADO' OR [TH].[STATUS] IS NULL)
		--AND [TD].[TRANSFER_ID] IS NULL
END
