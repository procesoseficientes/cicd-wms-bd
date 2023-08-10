-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		09-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- Description:			    SP para obtener el codigo de sku por cada base de datos de la multiempresa

-- Modificacion 20-Nov-17 @ Nexus Team Sprint GTA
					-- alberto.ruiz
					-- Se agrega tabla intermedia

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[BULK_DATA_SP_IMPORT_MATERIAL_INTERCOMPANY_FOR_OP_WMS]
		--
		SELECT * FROM [OP_WMS_wms].[wms].[OP_WMS_MATERIAL_INTERCOMPANY]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_IMPORT_MATERIAL_INTERCOMPANY_FOR_OP_WMS]
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @MATERIAL_INTERCOMPANY TABLE (
		[MASTER_ID] VARCHAR(50)
		,[ITEM_CODE] VARCHAR(50)
		,[SOURCE] VARCHAR(50)
	)
	--
	INSERT INTO @MATERIAL_INTERCOMPANY
			(
				[MASTER_ID]
				,[ITEM_CODE]
				,[SOURCE]
			)
	SELECT
		[MASTER_ID]
		,[ITEM_CODE]
		,[SOURCE]
	FROM [SWIFT_INTERFACES_ONLINE].[wms].[ERP_VIEW_SKU_SOURCE]
	--
	DELETE FROM [OP_WMS_wms].[wms].[OP_WMS_MATERIAL_INTERCOMPANY]
	--
	INSERT INTO [OP_WMS_wms].[wms].[OP_WMS_MATERIAL_INTERCOMPANY]
			(
				[MASTER_ID]
				,[ITEM_CODE]
				,[SOURCE]
			)
	SELECT
		[MASTER_ID]
		,[ITEM_CODE]
		,[SOURCE]
	FROM @MATERIAL_INTERCOMPANY
END

