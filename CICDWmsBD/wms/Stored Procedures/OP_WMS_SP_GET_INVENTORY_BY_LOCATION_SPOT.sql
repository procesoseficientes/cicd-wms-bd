-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	3/21/2018 @ GTEAM-Team Sprint Anemona
-- Description:			obtiene el inventario por ubicacion completo

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181121 GForce@Ornitorrinco
-- Description:	        Se agrega el estado del material por licencia en la consulta

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	20190318 GForce@Ualabi
-- Description:	        Se agrego el campo MATERIAL_NAME por Location-Info

-- Modificacion:		henry.rodriguez
-- Fecha de Creacion: 	26-Julio-2019 GForce@Dublin
-- Description:	        Se agrega ShortName de proyecto en consulta.

-- Modificacion:		kevin.guerra
-- Fecha de Creacion: 	13-Diciembre-2019 GForce@Madagascar-SWIFT
-- Description:	        Se agrega Regimen en la consulta.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_INVENTORY_BY_LOCATION_SPOT]
					@LOCATION_SPOT = 'B01-R01-C07-ND'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INVENTORY_BY_LOCATION_SPOT] (
		@LOCATION_SPOT VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[L].[LICENSE_ID]
		,[L].[CURRENT_LOCATION]
		,[L].[CODIGO_POLIZA]
		,[L].[CLIENT_OWNER]
		,[L].REGIMEN
		,[IL].[MATERIAL_ID]
		,[IL].[MATERIAL_NAME]
		,[IL].[QTY]
		,[IL].[VIN]
		,[IL].[BATCH]
		,[IL].[DATE_EXPIRATION]
		,[TC].[TONE]
		,[TC].[CALIBER]
		,[M].[SERIAL_NUMBER_REQUESTS]
		,[SML].[STATUS_NAME]
		,[P].[SHORT_NAME]
	FROM
		[wms].[OP_WMS_LICENSES] [L]
	INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
	INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON [SML].[STATUS_ID] = [IL].[STATUS_ID]
	LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TC] ON [TC].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID]
	LEFT JOIN [wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT] [IRP] ON (
											[IL].[PK_LINE] = [IRP].[PK_LINE]
											AND [IL].[PROJECT_ID] = [IRP].[PROJECT_ID]
											)
	LEFT JOIN [wms].[OP_WMS_PROJECT] [P] ON ([IRP].[PROJECT_ID] = [P].[ID])
	WHERE
		[L].[CURRENT_LOCATION] = @LOCATION_SPOT
		AND [IL].[QTY] > 0;
END;