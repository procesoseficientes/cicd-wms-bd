-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		22-Nov-16 @ A-Team Sprint 5
-- Description:			    Se agrego el campo si maneja serie

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].[SWIFT_VIEW_INVENTORY_BY_WAREHOUSE]
*/
-- =============================================
CREATE VIEW [SONDA].[SWIFT_VIEW_INVENTORY_BY_WAREHOUSE]
AS (
	SELECT
		[I].[WAREHOUSE]
		,[I].[SKU]
		,MAX([S].[HANDLE_SERIAL_NUMBER]) [HANDLE_SERIAL_NUMBER]
		,MAX([I].[SKU_DESCRIPTION]) [DESCRIPTION_SKU]
		,MAX([S].[BARCODE_SKU]) [BARCODE]
		,SUM([I].[ON_HAND]) [ON_HAND]
	FROM [SONDA].[SWIFT_INVENTORY] [I]
	LEFT OUTER JOIN [SONDA].[SWIFT_VIEW_SKU] [S] ON (
		[I].[SKU] = [S].[CODE_SKU]
	)
	GROUP BY
		[I].[WAREHOUSE]
		,[I].[SKU]
)
