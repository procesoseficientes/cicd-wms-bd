-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	11-Jul-2019 G-FORCE@Dublin
-- Historia:    Product Backlog Item 30119: Catalogo de proyectos - asignacion de inventario
-- Description:			Sp que obtiene los materiales

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_MATERIALS]						
					
   */
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MATERIALS]
AS
BEGIN
	SELECT
		[CLIENT_OWNER]
		,[MATERIAL_ID]
		,[BARCODE_ID]
		,[ALTERNATE_BARCODE]
		,[MATERIAL_NAME]
		,[SHORT_NAME]
		,[VOLUME_FACTOR]
		,[MATERIAL_CLASS]
		,[HIGH]
		,[LENGTH]
		,[WIDTH]
		,[MAX_X_BIN]
		,[SCAN_BY_ONE]
		,[REQUIRES_LOGISTICS_INFO]
		,[WEIGTH]
		,[IMAGE_1]
		,[IMAGE_2]
		,[IMAGE_3]
		,[LAST_UPDATED]
		,[LAST_UPDATED_BY]
		,[IS_CAR]
		,[MT3]
		,[BATCH_REQUESTED]
		,[SERIAL_NUMBER_REQUESTS]
		,[IS_MASTER_PACK]
		,[ERP_AVERAGE_PRICE]
		,[WEIGHT_MEASUREMENT]
		,[EXPLODE_IN_RECEPTION]
		,[HANDLE_TONE]
		,[HANDLE_CALIBER]
		,[USE_PICKING_LINE]
		,[QUALITY_CONTROL]
		,[ITEM_CODE_ERP]
		,[NON_STORAGE]
		,[ALLOW_DECIMAL_VALUE]
		,[PREFIX_CORRELATIVE_SERIALS]
		,[HANDLE_CORRELATIVE_SERIALS]
		,[BASE_MEASUREMENT_UNIT]
		,[LEAD_TIME]
		,[SUPPLIER]
		,[NAME_SUPPLIER]
		,[UPDATE_PROPERTIES_BY_HH]
	FROM
		[wms].[OP_WMS_MATERIALS];

END;