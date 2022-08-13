-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	11/20/2017 @ NEXUS-Team Sprint GTA 
-- Description:			Obtiene los primeras 5 ediciones a la nota de entrega.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_TOP_5_UPDATES_DELIVERY_NOTE] @owner = 'me_llega'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TOP_5_UPDATES_DELIVERY_NOTE](
	@OWNER VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@MAX_ATTEMPTS INT = 5;
	--
	SELECT
		@MAX_ATTEMPTS = [OWC].[NUMERIC_VALUE]
	FROM
		[wms].[OP_WMS_CONFIGURATIONS] [OWC]
	WHERE
		[OWC].[PARAM_TYPE] = 'SISTEMA'
		AND [OWC].[PARAM_GROUP] = 'MAX_NUMBER_OF_ATTEMPTS'
		AND [OWC].[PARAM_NAME] = 'MAX_NUMBER_OF_SENDING_ATTEMPTS_TO_ERP';
	--
	SELECT DISTINCT TOP 5
		[pdh].[PICKING_DEMAND_HEADER_ID]
	   ,[v].[PLATE_NUMBER]
	   ,[pdh].[ERP_REFERENCE]
	   ,[pdh].[ERP_REFERENCE_DOC_NUM]
	FROM
		[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] pdh
	INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] md ON [md].[PICKING_DEMAND_HEADER_ID] = [pdh].[PICKING_DEMAND_HEADER_ID]
	INNER JOIN [wms].[OP_WMS_MANIFEST_HEADER] mh ON [mh].[MANIFEST_HEADER_ID] = [md].[MANIFEST_HEADER_ID]
	INNER JOIN [wms].[OP_WMS_VEHICLE] v ON [v].[VEHICLE_CODE] = [mh].[VEHICLE]
	WHERE
		[mh].[STATUS] IN ('ASSIGNED', 'COMPLETED')
		AND [pdh].[UPDATED_VEHICLE] <> 1
		AND [pdh].[UPDATED_VEHICLE_ATTEMPTED_WITH_ERROR] < @MAX_ATTEMPTS
		AND [pdh].[OWNER] = @OWNER
		AND [pdh].[IS_POSTED_ERP] = 1
END