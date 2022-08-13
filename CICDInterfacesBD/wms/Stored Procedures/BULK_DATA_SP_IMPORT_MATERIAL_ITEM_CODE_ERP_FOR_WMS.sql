-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		09-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- Description:			    SP para obtener el codigo de sku por cada base de datos de la multiempresa

-- Modificacion 20-Nov-17 @ Nexus Team Sprint GTA
					-- alberto.ruiz
					-- Se agrega tabla intermedia

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[BULK_DATA_SP_IMPORT_MATERIAL_ITEM_CODE_ERP_FOR_WMS] 
		--
		SELECT * FROM [wms].[OP_WMS_MATERIAL_INTERCOMPANY]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_IMPORT_MATERIAL_ITEM_CODE_ERP_FOR_WMS] 
AS
BEGIN
	SET NOCOUNT ON;
	update [OP_WMS_ALZA].wms.[OP_WMS_MATERIALS] 
		SET
			ITEM_CODE_ERP = [INV].CVE_ART
	FROM 
	 SAE70EMPRESA01.dbo.INVE01  [INV]
		INNER JOIN [OP_WMS_ALZA].wms.[OP_WMS_MATERIALS] [M] ON [INV].CVE_ART = [M].BARCODE_ID collate DATABASE_DEFAULT
		
END

