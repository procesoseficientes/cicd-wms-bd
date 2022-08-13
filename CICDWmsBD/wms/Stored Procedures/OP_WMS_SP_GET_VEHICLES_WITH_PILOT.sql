-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-24 @ Team REBORN - Sprint 
-- Description:	        SP que obtiene los vehiculos con pilotos asociados

-- Modificacion 11/6/2017 @ NEXUS-Team Sprint F-Zero
					-- rodrigo.gomez
					-- Se agrega rating, is_active, fill_rate, vehicle_axles e insurance_doc_id

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].OP_WMS_SP_GET_VEHICLES_WITH_PILOT 
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_VEHICLES_WITH_PILOT
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
       ,[TC].[NAME] [TRANSPORT_COMPANY_NAME]
       ,[V].[WEIGHT]
       ,[V].[HIGH]
       ,[V].[WIDTH]
       ,[V].[DEPTH]
       ,[V].[VOLUME_FACTOR]
       ,[V].[PILOT_CODE]
       ,[P].[NAME] [PILOT_NAME]
       ,[P].[LAST_NAME]
       ,[P].[IDENTIFICATION_DOCUMENT_NUMBER]
       ,[P].[LICENSE_NUMBER]
       ,[P].[LICESE_TYPE]
       ,[P].[LICENSE_EXPIRATION_DATE]
       ,[P].[ADDRESS]
       ,[P].[TELEPHONE]
       ,[P].[MAIL]
       ,[P].[COMMENT]
	   ,[V].[RATING]
	   ,[V].[STATUS]
	   ,[V].[IS_ACTIVE]
	   ,[V].[FILL_RATE]
	   ,[V].[VEHICLE_AXLES]
	   ,[V].[INSURANCE_DOC_ID]
    FROM
        [wms].[OP_WMS_VEHICLE] [V]
    INNER JOIN [wms].[OP_WMS_PILOT] [P] ON [V].[PILOT_CODE] = [P].[PILOT_CODE]
    INNER JOIN [wms].[OP_WMS_TRANSPORT_COMPANY] [TC] ON [V].[TRANSPORT_COMPANY_CODE] = [TC].[TRANSPORT_COMPANY_CODE]
	WHERE [V].[VEHICLE_CODE] > 0

END;