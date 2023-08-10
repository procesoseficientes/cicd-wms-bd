-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	09-May-17 @ A-TEAM Sprint Issa 
-- Description:			SP para obtner los productos por centro de distribucion

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_SKU_WITH_INVETORY_BY_DISTRIBUTION_CENTER]
					@LOGIN = 'ALBERTO@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SKU_WITH_INVETORY_BY_DISTRIBUTION_CENTER](
	@LOGIN VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @WAREHOSE TABLE (
		[CODE_WAREHOUSE] VARCHAR(50)
		,[CODE_SKU] VARCHAR(50)
		,[ON_HAND] FLOAT
	)
	--
	DECLARE @DISTRIBUTION_CENTER_ID INT
	--
	SELECT @DISTRIBUTION_CENTER_ID = [SONDA].[SWIFT_FN_GET_DISTRIBUTION_CENTER_BY_LOGIN](@LOGIN)

	-- ------------------------------------------------------------------------------------
	-- Obtiene las bodegas del centro de distribucion con la cantidad de productos
	-- ------------------------------------------------------------------------------------
	INSERT INTO @WAREHOSE
	(
		[CODE_SKU]
		,[ON_HAND]
	)
	SELECT 
		[I].[SKU]
		,SUM([I].[ON_HAND])
	FROM [SONDA].[SWIFT_INVENTORY] [I]
	INNER JOIN [SONDA].[SWIFT_WAREHOUSE_X_DISTRIBUTION_CENTER] [WDC] ON ([I].[WAREHOUSE] = [WDC].[CODE_WAREHOUSE])
	WHERE [WDC].[DISTRIBUTION_CENTER_ID] = @DISTRIBUTION_CENTER_ID
	GROUP BY
		[I].[SKU]

	-- ------------------------------------------------------------------------------------
	-- Muestra los skus
	-- ------------------------------------------------------------------------------------
	SELECT 
		[S].[SKU]
		,[S].[CODE_SKU]
		,[S].[DESCRIPTION_SKU]
		,[S].[VALUE_TEXT_CLASSIFICATION]
		,[S].[BARCODE_SKU]
		,[S].[CODE_PROVIDER]
		,[S].[LIST_PRICE]
		,[S].[COST]
		,[S].[MEASURE]
		,[S].[LAST_UPDATE]
		,[S].[LAST_UPDATE_BY]
		,[S].[HANDLE_SERIAL_NUMBER]
		,[S].[HANDLE_BATCH]
		,[S].[FROM_ERP]
		,[S].[CODE_FAMILY_SKU]
		,[S].[CODE_PACK_UNIT]
		,[S].[DESCRIPTION_PACK_UNIT]
		,[S].[USE_LINE_PICKING]
		,[S].[VOLUME_SKU]
		,[S].[WEIGHT_SKU]
		,[S].[VOLUME_CODE_UNIT]
		,[S].[VOLUME_NAME_UNIT]
		,[S].[HANDLE_DIMENSION]
		,[S].[OWNER]
		,[S].[OWNER_ID]
		,ISNULL([W].[ON_HAND],0.00) [ON_HAND]
		,[PR].[NAME_PROVIDER]
		,[EVS].[HIGH_SKU]
		,[EVS].[UNIT_MEASURE_SKU]
		,[EVS].[LONG_SKU]
		,[EVS].[WIDTH_SKU]
	FROM [SONDA].[SWIFT_VIEW_ALL_SKU] [S]
	INNER JOIN [SWIFT_INTERFACES].[SONDA].[ERP_VIEW_SKU] [EVS] ON [EVS].[CODE_SKU] = [S].[CODE_SKU]
	LEFT JOIN [SONDA].[SWIFT_PROVIDERS] [PR] ON [S].[CODE_PROVIDER] = [PR].[CODE_PROVIDER] 
	LEFT JOIN @WAREHOSE [W] ON ([W].[CODE_SKU] = [S].[CODE_SKU])
END
