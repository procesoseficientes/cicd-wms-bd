-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	20-Jun-17 @ A-TEAM Sprint Khalid 
-- Description:			SP para importar el inventario en linea para la consulta de inventario por zonas

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[BULK_DATA_SP_IMPORT_INVENTORY_ONLINE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[BULK_DATA_SP_IMPORT_INVENTORY_ONLINE]
AS
BEGIN
	SET NOCOUNT ON;
	--
	TRUNCATE TABLE [SWIFT_EXPRESS].[SONDA].[SONDA_INVENTORY_ONLINE]
	--
	INSERT INTO [SWIFT_EXPRESS].[SONDA].[SONDA_INVENTORY_ONLINE]
			(
				[CENTER]
				,[CODE_WAREHOUSE]
				,[CODE_SKU]
				,[ON_HAND]
				,[CODE_PACK_UNIT]
			)
	SELECT
		[I].[CENTER]
		,[I].[CODE_WAREHOUSE]
		,[I].[CODE_SKU]
		,[I].[ON_HAND]
		,[I].[CODE_PACK_UNIT]
	FROM [SWIFT_INTERFACES_ONLINE].[SONDA].[ERP_VIEW_INVENTORY_ONLINE] [I]
	WHERE [I].[CODE_WAREHOUSE] != ''
END