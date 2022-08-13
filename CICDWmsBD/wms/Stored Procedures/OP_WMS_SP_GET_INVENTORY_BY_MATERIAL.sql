-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	3/20/2018 @ GTEAM-Team Sprint Anemona 
-- Description:			obtiene el inventario por material id completo

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181121 GForce@Ornitorrinco
-- Description:	        Se agrega el estado del material por licencia en la consulta

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20190626 GForce@Cancun
-- Description:	        Se agrega filtro de bodegas y filtro de usuario

-- Modificacion:		henry.rodriguez
-- Fecha de Creacion: 	26-Julio-2019 GForce@Dublin
-- Description:	        Se agrega ShortName del proyecto en la consulta.

-- Modificacion:		kevin.guerra
-- Fecha de Creacion: 	13-Diciembre-2019 GForce@Magadasgar-SWIFT
-- Description:	        Se agrega Régimen en la consulta.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_INVENTORY_BY_MATERIAL]
					@MATERIAL_ID = 'viscosa/VCA1030',@LOGIN_ID = 'MARVIN'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INVENTORY_BY_MATERIAL] (
		@MATERIAL_ID VARCHAR(25)
		,@LOGIN_ID VARCHAR(100)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--

	SELECT
		[WAREHOUSE_ID]
	INTO
		[#WAREHOUSES_BY_USER]
	FROM
		[wms].[OP_WMS_WAREHOUSE_BY_USER]
	WHERE
		[LOGIN_ID] = @LOGIN_ID;
	
	SELECT
		[L].[LICENSE_ID]
		,[L].[CURRENT_LOCATION]
		,[L].[CODIGO_POLIZA]
		,[L].[CLIENT_OWNER]
		,[L].REGIMEN
		,[IL].[MATERIAL_ID]
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
	INNER JOIN [#WAREHOUSES_BY_USER] [WU] ON [WU].[WAREHOUSE_ID] = [L].[CURRENT_WAREHOUSE]
	INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
	INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON [SML].[STATUS_ID] = [IL].[STATUS_ID]
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
	LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TC] ON [TC].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID]
	LEFT JOIN [wms].[OP_WMS_INVENTORY_RESERVED_BY_PROJECT] [IRP] ON (
											[IL].[PK_LINE] = [IRP].[PK_LINE]
											AND [IL].[PROJECT_ID] = [IRP].[PROJECT_ID]
											)
	LEFT JOIN [wms].[OP_WMS_PROJECT] [P] ON ([IRP].[PROJECT_ID] = [P].[ID])
	WHERE
		[IL].[MATERIAL_ID] = @MATERIAL_ID
		AND [IL].[QTY] > 0
	GROUP BY
		[L].[LICENSE_ID]
		,[L].[CURRENT_LOCATION]
		,[L].[CODIGO_POLIZA]
		,[L].[CLIENT_OWNER]
		,[L].REGIMEN
		,[IL].[MATERIAL_ID]
		,[IL].[QTY]
		,[IL].[VIN]
		,[IL].[BATCH]
		,[IL].[DATE_EXPIRATION]
		,[TC].[TONE]
		,[TC].[CALIBER]
		,[M].[SERIAL_NUMBER_REQUESTS]
		,[SML].[STATUS_NAME]
		,[P].[SHORT_NAME]
	ORDER BY
		[IL].[QTY];


END;