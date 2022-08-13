-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	07-Nov-16 @ A-TEAM Sprint 4 
-- Description:			SP que obtiene el detalle de la licencia

-- Modificacion 6/27/2017 
-- rodrigo.gomez
-- Se modifico el join a la tabla de numeros de serie por materiales.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_LICENSE_DETAIL]
					@LICENSE_ID = 307820
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LICENSE_DETAIL] (@LICENSE_ID NUMERIC)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[IL].[PK_LINE]
		,[IL].[LICENSE_ID]
		,[IL].[MATERIAL_ID]
		,[IL].[MATERIAL_NAME]
		,CASE [IL].[HANDLE_SERIAL]
			WHEN 1 THEN 1
			ELSE [IL].[QTY]
			END [QTY]
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
		,CASE [IL].[HANDLE_SERIAL]
			WHEN 1 THEN [MSN].[DATE_EXPIRATION]
			ELSE [IL].[DATE_EXPIRATION]
			END [DATE_EXPIRATION]
		,CASE [IL].[HANDLE_SERIAL]
			WHEN 1 THEN [MSN].[BATCH]
			ELSE [IL].[BATCH]
			END [BATCH]
		,[IL].[ENTERED_QTY]
		,[IL].[VIN]
		,[IL].[HANDLE_SERIAL]
		,ISNULL([MSN].[SERIAL], 0) [SERIAL]
	FROM
		[wms].[OP_WMS_INV_X_LICENSE] [IL]
	LEFT JOIN [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [MSN] ON (
											[IL].[LICENSE_ID] = [MSN].[LICENSE_ID]
											AND [MSN].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											AND [MSN].[STATUS] > 0
											)
	WHERE
		[IL].[LICENSE_ID] = @LICENSE_ID;
 
END;