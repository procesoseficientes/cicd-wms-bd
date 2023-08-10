-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	26-01-2016
-- Description:			Obtiene todos los proveedores que esten en el inventario sin serie o solo uno que este en el inventario sin serie

/*
-- Ejemplo de Ejecucion:
				--
				EXEC [SONDA].[SWIFT_SP_GET_PROVIDER_INVENTORY_WITHOUT_SERIE]
				--
				EXEC [SONDA].[SWIFT_SP_GET_PROVIDER_INVENTORY_WITHOUT_SERIE] @CODE_PROVIDER = 'P0001'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_PROVIDER_INVENTORY_WITHOUT_SERIE]
	@CODE_PROVIDER varchar(100) = NULL
AS
BEGIN
	SELECT
		P.[CODE_PROVIDER]
		,P.[NAME_PROVIDER]
		,P.[CODE_SKU]
		,P.[DESCRIPTION_SKU]
		,P.[BATCH_ID]
		,P.[BATCH_SUPPLIER_EXPIRATION_DATE]
		,P.[PALLET_ID]
		,P.[ON_HAND]
	FROM [SONDA].[SWIFT_VIEW_PROVIDER_INVENTORY_WITHOUT_SERIE] P
	WHERE @CODE_PROVIDER IS NULL OR P.CODE_PROVIDER = @CODE_PROVIDER
END
