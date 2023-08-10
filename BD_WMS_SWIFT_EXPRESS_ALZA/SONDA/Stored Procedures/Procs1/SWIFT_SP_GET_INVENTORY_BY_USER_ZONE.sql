-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	14-Dec-16 @ A-TEAM Sprint 6 
-- Description:			SP que obtiene el inventario de una zona asociada a un login 

-- Modificacion 20-Jun-17 @ A-Team Sprint Khalid
					-- alberto.ruiz
					-- Se cambia para que consuma la tabla [SONDA_INVENTORY_ONLINE]

/*
-- Ejemplo de Ejecucion:
				EXEC  [SONDA].[SWIFT_SP_GET_INVENTORY_BY_USER_ZONE] @CODE_ROUTE = '44'
                                                    ,@CODE_SKU = '100002'
				--
			SELECT * FROM [SONDA].[SONDA_INVENTORY_ONLINE] [s]

*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_INVENTORY_BY_USER_ZONE] (
	@CODE_ROUTE VARCHAR(50)
	,@CODE_SKU VARCHAR(50)
) AS
BEGIN
  SET NOCOUNT ON;
  --
	SELECT
		[SI].[CODE_SKU] [SKU]--@CODE_SKU [SKU]
		,SUM([SI].[ON_HAND]) [ON_HAND]
		,[SI].[CODE_WAREHOUSE] [WAREHOUSE]
		,MAX(S.[DESCRIPTION_SKU]) [DESCRIPTION_SKU]
	FROM [SWIFT_INTERFACES_ONLINE].[SONDA].[ERP_VIEW_INVENTORY_ONLINE] [SI]
	INNER JOIN [SONDA].[SWIFT_WAREHOUSES] [W] ON ([SI].[CODE_WAREHOUSE] = [W].[CODE_WAREHOUSE] COLLATE DATABASE_DEFAULT)
	INNER JOIN [SONDA].[SWIFT_WAREHOUSE_X_ZONE] [WZ] ON ([W].[CODE_WAREHOUSE] = [WZ].[CODE_WAREHOUSE])
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S] ON ([S].[CODE_SKU] = [SI].[CODE_SKU] COLLATE DATABASE_DEFAULT)
	INNER JOIN [SONDA].[USERS] [U] ON ([U].[ZONE_ID] = [WZ].[ID_ZONE])
	WHERE [SI].[CODE_SKU] = @CODE_SKU
		AND [U].[SELLER_ROUTE] = @CODE_ROUTE
	GROUP BY [SI].[CODE_WAREHOUSE], [SI].[CODE_SKU];
END

