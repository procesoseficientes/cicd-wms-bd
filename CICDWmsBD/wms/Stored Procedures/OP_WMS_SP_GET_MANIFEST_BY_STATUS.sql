-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-18 @ Team REBORN - Sprint Drache
-- Description:	        SP que trae los manifiestos de carga por fecha y estado

-- Modificacion 10-Nov-17 @ Nexus Team Sprint F-Zero
					-- alberto.ruiz
					-- Se agrega un case al texto del status

-- Modificacion 10-Jan-18 @ Nexus Team Sprint Ramsey
					-- alberto.ruiz
					-- Se agrega que filtre por el centro de distribucion del cliente


-- Modificacion 18-Apr-18 @ G-FORCE Team Sprint Buho
					-- pablo.aguilar
					-- Se agrega campos de bodega destino y orgine cuando es transferencia.

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_MANIFEST_BY_STATUS] 
				@START_DATE = '2017-12-01' 
				,@END_DATE = '2018-10-11'
				,@STATUS_MANIFEST = null
				,@LOGIN = 'BETO'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MANIFEST_BY_STATUS] (
		@START_DATE DATETIME
		,@END_DATE DATETIME
		,@STATUS_MANIFEST VARCHAR(25) = NULL
		,@LOGIN VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@DISTRIBUTION_CENTER_ID VARCHAR(50) =  '';
	--
	SELECT TOP 1
		@DISTRIBUTION_CENTER_ID = [L].[DISTRIBUTION_CENTER_ID]
	FROM
		[wms].[OP_WMS_LOGINS] [L]
	WHERE
		[L].[LOGIN_ID] = @LOGIN;
	--
	SELECT
		[MH].[MANIFEST_HEADER_ID]
		,[MH].[DRIVER]
		,[MH].[VEHICLE]
		,[MH].[DISTRIBUTION_CENTER]
		,[MH].[CREATED_DATE]
		,CASE [MH].[STATUS]
			WHEN 'CREATED' THEN 'Creado'
			WHEN 'ASSIGNED' THEN 'Asignado'
			WHEN 'CANCELED' THEN 'Cancelado'
			WHEN 'CERTIFIED' THEN 'Certificado'
			WHEN 'COMPLETED' THEN 'Completado'
			WHEN 'IN_PICKING' THEN 'En Picking'
			ELSE [MH].[STATUS]
			END AS [STATUS]
		,[MH].[LAST_UPDATE]
		,[MH].[LAST_UPDATE_BY]
		,CASE [MH].[MANIFEST_TYPE]
			WHEN 'SALES_ORDER' THEN 'Orden De Venta'
			WHEN 'TRANSFER_REQUEST' THEN 'Traslado'
			ELSE [MH].[MANIFEST_TYPE]
			END AS [MANIFEST_TYPE]
		,[MH].[TRANSFER_REQUEST_ID]
		,[MH].[PLATE_NUMBER]
		,[P].[NAME] [PILOT_NAME]
		,[T].[WAREHOUSE_FROM]
		,[T].[WAREHOUSE_TO]
	FROM
		[wms].[OP_WMS_MANIFEST_HEADER] [MH]
	LEFT JOIN [wms].[OP_WMS_VEHICLE] [V] ON [MH].[VEHICLE] = [V].[VEHICLE_CODE]
	LEFT JOIN [wms].[OP_WMS_PILOT] [P] ON [V].[PILOT_CODE] = [P].[PILOT_CODE]
	LEFT JOIN [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [T] ON [T].[TRANSFER_REQUEST_ID] = [MH].[TRANSFER_REQUEST_ID]
	WHERE
		[MH].[MANIFEST_HEADER_ID] > 0
		AND (
				[MH].[STATUS] = @STATUS_MANIFEST
				OR @STATUS_MANIFEST IS NULL
			)
		AND [MH].[CREATED_DATE] BETWEEN @START_DATE
								AND		@END_DATE
		AND [MH].[DISTRIBUTION_CENTER] = @DISTRIBUTION_CENTER_ID;
END;