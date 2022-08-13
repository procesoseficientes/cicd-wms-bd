-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/7/2018 @ GFORCE-Team Sprint Dinosaurio@l3w 
-- Description:			obtiene inventario por licencia

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_INV_X_LIC]
					@LICENSE_ID = 44570
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_INV_X_LIC (
		@LICENSE_ID INT
		,@LOGIN VARCHAR(50) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT DISTINCT
		[A].[PK_LINE]
		,[A].[LICENSE_ID]
		,[A].[MATERIAL_ID]
		,[A].[MATERIAL_NAME]
		,[A].[QTY]
		,[A].[VOLUME_FACTOR]
		,[A].[WEIGTH]
		,[A].[SERIAL_NUMBER]
		,[A].[COMMENTS]
		,[A].[LAST_UPDATED]
		,[A].[LAST_UPDATED_BY]
		,[A].[BARCODE_ID]
		,[A].[TERMS_OF_TRADE]
		,[A].[STATUS]
		,[A].[CREATED_DATE]
		,[A].[DATE_EXPIRATION]
		, CASE WHEN [t].[TONE_AND_CALIBER_ID] IS NOT NULL THEN 'T: ' + ISNULL( t.[TONE] ,'')+ '  C: ' + ISNULL(t.[CALIBER], '')
		ELSE [A].[BATCH] END [BATCH]
		 
		,[A].[ENTERED_QTY]
		,[A].[VIN]
		,[A].[HANDLE_SERIAL]
		,[A].[IS_EXTERNAL_INVENTORY]
		,[A].[IS_BLOCKED]
		,[A].[BLOCKED_STATUS]
		,[A].[STATUS_ID]
		,[A].[TONE_AND_CALIBER_ID]
		,[A].[LOCKED_BY_INTERFACES]
		,[B].[CODIGO_POLIZA]
		,[B].[CURRENT_LOCATION]
		,[B].[CODIGO_POLIZA]
		,[B].[REGIMEN]
		,([wms].[OP_WMS_FN_SPLIT_COLUMNS]([A].[MATERIAL_ID],
											2, '/') + ' '
			+ [A].[MATERIAL_NAME]) AS [MATERIAL_NAME_EXTENDED]
		,CASE [A].[HANDLE_SERIAL]
			WHEN 1 THEN 'Maneja Serie: SI'
			ELSE 'Maneja Serie: NO'
			END AS [HANDLE_SERIAL_DESCRIPTION]
		,CASE [M].[IS_MASTER_PACK]
			WHEN 1 THEN 'Es Master Pack.'
			ELSE ''
			END AS [IS_MASTER_PACK]
		,[B].[USED_MT2]
		,ISNULL([A].[DATE_EXPIRATION],
				CAST('2099/01/01' AS DATETIME))
	FROM
		[wms].[OP_WMS_INV_X_LICENSE] [A]
	INNER JOIN [wms].[OP_WMS_LICENSES] [B] ON ([B].[LICENSE_ID] = [A].[LICENSE_ID])
	LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [t] ON [t].[TONE_AND_CALIBER_ID] = [A].[TONE_AND_CALIBER_ID]
	LEFT JOIN [wms].[OP_WMS_SHELF_SPOTS] [S] ON [S].[LOCATION_SPOT] = [B].[CURRENT_LOCATION]
	LEFT JOIN [wms].[OP_WMS_WAREHOUSE_BY_USER] [W] ON [W].[WAREHOUSE_ID] = [S].[WAREHOUSE_PARENT]
											AND @LOGIN = [W].[LOGIN_ID]
	LEFT JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([M].[MATERIAL_ID] = [A].[MATERIAL_ID])
	WHERE
		[A].[LICENSE_ID] = @LICENSE_ID
		AND [A].[QTY] > 0
	ORDER BY
		ISNULL([A].[DATE_EXPIRATION],
				CAST('2099/01/01' AS DATETIME)) ASC;
END;