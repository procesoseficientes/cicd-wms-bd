-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-17 @ Team REBORN - Sprint Drache
-- Description:	        SP que trae los vehiculos con menor o igual peso al parametro y que tengan un piloto asignado

-- Modificacion 11/6/2017 @ NEXUS-Team Sprint F-Zero
					-- rodrigo.gomez
					-- Se agrega rating, is_active, fill_rate, vehicle_axles e insurance_doc_id

/*
-- Ejemplo de Ejecucion:
		SELECT * FROM [wms].OP_WMS_VEHICLE
		--
		EXEC [wms].OP_WMS_SP_GET_VEHICLE_BY_WEIGHT @WEIGHT = 12
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_VEHICLE_BY_WEIGHT
    (
     @WEIGHT NUMERIC(18, 6) = NULL
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
		,[V].[WEIGHT]
		,[V].[HIGH]
		,[V].[WIDTH]
		,[V].[DEPTH]
		,[V].[VOLUME_FACTOR]
		,[V].[LAST_UPDATE]
		,[V].[LAST_UPDATE_BY]
		,[V].[PILOT_CODE]
		,[P].[NAME] [PILOT_NAME]
		,[V].[RATING]
		,[V].[IS_ACTIVE]
		,[V].[STATUS]
		,[V].[FILL_RATE]
		,[V].[VEHICLE_AXLES]
		,[V].[INSURANCE_DOC_ID]
    FROM [wms].[OP_WMS_VEHICLE] [V]
    INNER JOIN [wms].[OP_WMS_PILOT] [P] ON [V].[PILOT_CODE] = [P].[PILOT_CODE]
    WHERE
        (
         [V].[WEIGHT] >= @WEIGHT
         OR @WEIGHT IS NULL
        )
        AND [V].[VEHICLE_CODE] > 0
		AND [V].[IS_ACTIVE] = 1;
END;