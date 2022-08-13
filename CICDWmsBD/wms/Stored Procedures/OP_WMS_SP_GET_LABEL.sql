-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-16 @ Team REBORN - Sprint Drache
-- Description:	   Obtiene la informacion de la eituqeta

/*
-- Ejemplo de Ejecucion:
                EXEC [wms].OP_WMS_SP_GET_LABEL @LABEL_ID = 1
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LABEL] (@LABEL_ID INT)
AS
BEGIN
	SET NOCOUNT ON;
  --

	SELECT
		[PL].[LABEL_ID]
		,[PL].[LOGIN_ID]
		,[PL].[LICENSE_ID]
		,[PL].[MATERIAL_ID]
		,[PL].[MATERIAL_NAME]
		,[PL].[QTY]
		,[PL].[CODIGO_POLIZA]
		,[PL].[SOURCE_LOCATION]
		,[PL].[TARGET_LOCATION]
		,[PL].[TRANSIT_LOCATION]
		,[PL].[BATCH]
		,[PL].[VIN]
		,[PL].[TONE]
		,[PL].[CALIBER]
		,[PL].[SERIAL_NUMBER]
		,[PL].[LABEL_STATUS] AS [STATUS]
		,[PL].[WEIGHT]
		,[PL].[WAVE_PICKING_ID]
		,[PL].[TASK_SUBT_YPE]
		,[PL].[WAREHOUSE_TARGET]
		,[PL].[CLIENT_NAME]
		,[PL].[CLIENT_CODE]
		,[PL].[STATE_CODE]
		,[PL].[REGIMEN]
		,[PL].[TRANSFER_REQUEST_ID]
		,GETDATE() [DATE_TIME]
		,[L].[LOGIN_NAME] [LOGIN_NAME]
		,[PDH].[DOC_NUM]
		,[PDH].[DOC_ENTRY]
	FROM
		[wms].[OP_WMS_PICKING_LABELS] [PL]
	LEFT JOIN [wms].[OP_WMS_LOGINS] [L] ON ([L].[LOGIN_ID] = [PL].[LOGIN_ID])
	LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON (
											[PL].[WAVE_PICKING_ID] = [PDH].[WAVE_PICKING_ID]
											AND [PDH].[IS_CONSOLIDATED] = 0
											)
	WHERE
		[PL].[LABEL_ID] = @LABEL_ID;


END;