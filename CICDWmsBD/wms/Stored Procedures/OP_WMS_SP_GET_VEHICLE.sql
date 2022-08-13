
-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-12 @ Team REBORN - Sprint Drache
-- Description:	        SP que trae 1 o todos los vehiculos

-- Modificacion 11/6/2017 @ NEXUS-Team Sprint F-Zero
-- rodrigo.gomez
-- Se agrega rating, is_active, fill_rate, vehicle_axles, insurance_doc_id y poliza_insurance

-- Modificacion 26-Nov-2017 @ Reborn-Team Sprint Nach
-- rudi.garcia
-- Se agrego el campo de [LICENSE_NUMBER]

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].OP_WMS_SP_GET_VEHICLE @VEHICLE_CODE = NULL
			--
			EXEC  [wms].OP_WMS_SP_GET_VEHICLE @VEHICLE_CODE = 18
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_VEHICLE] (
		@VEHICLE_CODE INT = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;
  --

	SELECT
		[V].[VEHICLE_CODE]
		,[V].[BRAND]
		,[V].[LINE]
		,[V].[MODEL]
		,[V].[COLOR]
		,[V].[CHASSIS_NUMBER]
		,[V].[ENGINE_NUMBER]
		,[V].[VIN_NUMBER]
		,[V].[PLATE_NUMBER]
		,[V].[TRANSPORT_COMPANY_CODE]
		,[TC].[NAME] AS [TRANSPORT_COMPANY_NAME]
		,[V].[WEIGHT]
		,[V].[HIGH]
		,[V].[WIDTH]
		,[V].[DEPTH]
		,[V].[VOLUME_FACTOR]
		,[V].[LAST_UPDATE]
		,[V].[LAST_UPDATE_BY]
		,[V].[PILOT_CODE]
		,[P].[NAME] AS [PILOT_NAME]
		,[V].[RATING]
		,[V].[STATUS]
		,[V].[IS_ACTIVE]
		,[V].[FILL_RATE]
		,[V].[VEHICLE_AXLES]
		,[V].[INSURANCE_DOC_ID]
		,[I].[POLIZA_INSURANCE]
		,[P].[LICENSE_NUMBER]
		,[V].[AVERAGE_COST_PER_KILOMETER]
	FROM
		[wms].[OP_WMS_VEHICLE] [V]
	LEFT JOIN [wms].[OP_WMS_TRANSPORT_COMPANY] AS [TC] ON ([V].[TRANSPORT_COMPANY_CODE] = [TC].[TRANSPORT_COMPANY_CODE])
	LEFT JOIN [wms].[OP_WMS_PILOT] AS [P] ON ([V].[PILOT_CODE] = [P].[PILOT_CODE])
	LEFT JOIN [wms].[OP_WMS_INSURANCE_DOCS] [I] ON ([I].[DOC_ID] = [V].[INSURANCE_DOC_ID])
	WHERE
		(
			@VEHICLE_CODE IS NULL
			OR [V].[VEHICLE_CODE] = @VEHICLE_CODE
		)
		AND [V].[VEHICLE_CODE] > 0;


END;

