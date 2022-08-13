-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-Oct-17 @ Nexus Team Sprint ewms 
-- Description:			SP que limpia las licencias con cero
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_CLEAN_INV_X_LICENSE]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CLEAN_INV_X_LICENSE]
AS
BEGIN
	SET NOCOUNT ON;
	
	-- ------------------------------------------------------------------------------------
	-- Pasa al historico
	-- ------------------------------------------------------------------------------------
	INSERT INTO [wms].[OP_WMS_INV_X_LICENSE_HISTORY]
			(
				[PK_LINE]
				,[LICENSE_ID]
				,[MATERIAL_ID]
				,[MATERIAL_NAME]
				,[QTY]
				,[VOLUME_FACTOR]
				,[WEIGTH]
				,[SERIAL_NUMBER]
				,[COMMENTS]
				,[LAST_UPDATED]
				,[LAST_UPDATED_BY]
				,[BARCODE_ID]
				,[TERMS_OF_TRADE]
				,[STATUS]
				,[CREATED_DATE]
				,[DATE_EXPIRATION]
				,[BATCH]
				,[ENTERED_QTY]
				,[VIN]
				,[HANDLE_SERIAL]
				,[IS_EXTERNAL_INVENTORY]
				,[IS_BLOCKED]
				,[BLOCKED_STATUS]
				,[STATUS_ID]
				,[TONE_AND_CALIBER_ID]
				,[LOCKED_BY_INTERFACES]
			)
	SELECT
		[IL].[PK_LINE]
		,[IL].[LICENSE_ID]
		,[IL].[MATERIAL_ID]
		,[IL].[MATERIAL_NAME]
		,[IL].[QTY]
		,[IL].[VOLUME_FACTOR]
		,[IL].[WEIGTH]
		,[IL].[SERIAL_NUMBER]
		,[IL].[COMMENTS]
		,[IL].[LAST_UPDATED]
		,[IL].[LAST_UPDATED_BY]
		,[IL].[BARCODE_ID]
		,[IL].[TERMS_OF_TRADE]
		,[IL].[STATUS]
		,[IL].[CREATED_DATE]
		,[IL].[DATE_EXPIRATION]
		,[IL].[BATCH]
		,[IL].[ENTERED_QTY]
		,[IL].[VIN]
		,[IL].[HANDLE_SERIAL]
		,[IL].[IS_EXTERNAL_INVENTORY]
		,[IL].[IS_BLOCKED]
		,[IL].[BLOCKED_STATUS]
		,[IL].[STATUS_ID]
		,[IL].[TONE_AND_CALIBER_ID]
		,[IL].[LOCKED_BY_INTERFACES]
	FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
	WHERE [IL].[PK_LINE] > 0
		AND [IL].[QTY] = 0
	
	-- ------------------------------------------------------------------------------------
	-- Elimina las lineas con cero
	-- ------------------------------------------------------------------------------------
	DELETE FROM [wms].[OP_WMS_INV_X_LICENSE]
	WHERE [PK_LINE] > 0
		AND [QTY] = 0
	-- ------------------------------------------------------------------------------------
	-- Inserta al historico
	-- ------------------------------------------------------------------------------------
	INSERT INTO [wms].[OP_WMS_LICENSES_HISTORY]
	        (
	          [LICENSE_ID]
	        , [CLIENT_OWNER]
	        , [CODIGO_POLIZA]
	        , [CURRENT_WAREHOUSE]
	        , [CURRENT_LOCATION]
	        , [LAST_LOCATION]
	        , [LAST_UPDATED]
	        , [LAST_UPDATED_BY]
	        , [STATUS]
	        , [REGIMEN]
	        , [CREATED_DATE]
	        , [USED_MT2]
	        , [CODIGO_POLIZA_RECTIFICACION]
	        )
	SELECT [L].[LICENSE_ID]
         , [L].[CLIENT_OWNER]
         , [L].[CODIGO_POLIZA]
         , [L].[CURRENT_WAREHOUSE]
         , [L].[CURRENT_LOCATION]
         , [L].[LAST_LOCATION]
         , [L].[LAST_UPDATED]
         , [L].[LAST_UPDATED_BY]
         , [L].[STATUS]
         , [L].[REGIMEN]
         , [L].[CREATED_DATE]
         , [L].[USED_MT2]
         , [L].[CODIGO_POLIZA_RECTIFICACION] 
	FROM [wms].[OP_WMS_LICENSES] [L]
		LEFT JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID])
	WHERE [L].[LICENSE_ID] > 0
		AND [IL].[PK_LINE] IS NULL
	-- ------------------------------------------------------------------------------------
	-- Elimina las licencias sin materiales
	-- ------------------------------------------------------------------------------------
	DELETE [L]
	FROM [wms].[OP_WMS_LICENSES] [L]
	LEFT JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID])
	WHERE [L].[LICENSE_ID] > 0
		AND [IL].[PK_LINE] IS NULL
END