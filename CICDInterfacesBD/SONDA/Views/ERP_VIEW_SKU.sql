
-- =============================================
-- Autor:				hector.gonzalez
-- Fecha de Creacion: 	04-05-2016
-- Description:			SP que importa SKU

-- Modificacion 23-05-2016
					-- alberto.ruiz
					-- Se agrego la columna USE_LINE_PICKING

-- Modificacion 27-05-2016
					-- alberto.ruiz
					-- Se agregaron las columnas VOLUME_CODE_UNIT y VOLUME_NAME_UNIT

-- Modificacion 3/14/2017 @ A-Team Sprint Ebonne
					-- rodrigo.gomez
					-- Se agregaron las columnas OWNER y [OWNER_ID]

-- Modificacion 8/31/2017 @ Reborn-Team Sprint Collin
					-- diego.as
					-- Se agregan columnas ART_CODE, VAT_CODE
/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].[ERP_VIEW_SKU]
*/
-- =============================================

CREATE VIEW [SONDA].[ERP_VIEW_SKU]
AS
	SELECT
		[SKU]
		,[CODE_SKU]
		,[DESCRIPTION_SKU]
		,[BARCODE_SKU]
		,[NAME_PROVIDER]
		,[COST]
		,[LIST_PRICE]
		,[UNIT_MEASURE_SKU]
		,[WEIGHT_SKU]
		,[VOLUME_SKU]
		,[LONG_SKU]
		,[WIDTH_SKU]
		,[HIGH_SKU]
		,[MEASURE]
		,[NAME_CLASSIFICATION]
		,[VALUE_TEXT_CLASSIFICATION]
		,[HANDLE_SERIAL_NUMBER]
		,[HANDLE_BATCH]
		,[FROM_ERP]
		,[PRICE]
		,[LIST_NUM]
		,[CODE_PROVIDER]
		,[LAST_UPDATE]
		,[LAST_UPDATE_BY]
		,[CODE_FAMILY_SKU]
		,[USE_LINE_PICKING]
		,[VOLUME_CODE_UNIT]
		,[VOLUME_NAME_UNIT]
		,[OWNER]
		,[OWNER_ID]
		,[ART_CODE]
		,[VAT_CODE]
	FROM [SONDA].[SWIFT_ERP_SKU]