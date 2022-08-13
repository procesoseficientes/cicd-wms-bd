
-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-06-16 @ Team ERGON - Sprint ERGON 
-- Description:	        sp que devuelve los campos de la vista [OP_WMS_VIEW_INVENTORY_GENERAL_BY_MATERIALS] que trae el inventario en picking y el commited

-- Modificacion 28-Nov-2017 @ NEXUS-Team Sprint CommandAndConquer
					-- rudi.garcia
					-- Se agregaron los campos [TONE] ,[CALIBER] ,[CURRENT_LOCATION]

-- Modificacion:		henry.rodriguez
-- Fecha:				24-Julio-2019 G-Force@Dublin
-- Descripcion:			Se agrego filtro para que excluya licencias asociadas a proyectos
/*
-- Ejemplo de Ejecucion:
    exec [wms].OP_WMS_SP_GET_INVENTORY_BY_SKU @MATERIAL_ID='wms/SKUPRUEBAHEC'
                                                ,@CURRENT_WAREHOUSE='CE'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INVENTORY_BY_SKU] (
		@MATERIAL_ID VARCHAR(50)
		,@CURRENT_WAREHOUSE VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --

	SELECT
		[IBM].[LICENSE_ID]
		,[IBM].[MATERIAL_ID]
		,[IBM].[MATERIAL_NAME]
		,[IBM].[CLIENT_OWNER]
		,[IBM].[ALTERNATE_BARCODE]
		,[IBM].[BARCODE_ID]
		,[IBM].[TERMS_OF_TRADE]
		,[IBM].[CLIENT_NAME]
		,CASE [IBM].[HANDLE_SERIAL]
			WHEN 1 THEN 1
			ELSE [IBM].[QTY]
			END [QTY]
		,[IBM].[ON_PICKING]
		,CASE [IBM].[HANDLE_SERIAL]
			WHEN 1 THEN 1
			ELSE [IBM].[AVAILABLE]
			END [AVAILABLE]
		,[IBM].[BATCH]
		,[IBM].[DATE_EXPIRATION]
		,[IBM].[VIN]
		,[IBM].[CURRENT_WAREHOUSE]
		,[IBM].[HANDLE_SERIAL]
		,[IBM].[SERIAL]
		,[MS].[WAVE_PICKING_ID]
		,[IBM].[TONE]
		,[IBM].[CALIBER]
		,[IBM].[CURRENT_LOCATION]
		,[SML].[STATUS_CODE]
	FROM
		[wms].[OP_WMS_VIEW_INVENTORY_GENERAL_BY_MATERIALS] [IBM]
	LEFT JOIN [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [MS] ON (
											[IBM].[LICENSE_ID] = [MS].[LICENSE_ID]
											AND [IBM].[MATERIAL_ID] = [MS].[MATERIAL_ID]
											AND [IBM].[SERIAL] = [MS].[SERIAL]
											AND [MS].[STATUS] = 1
											AND [MS].[WAVE_PICKING_ID] IS NULL
											)
	INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IXL] ON (
											[IBM].[LICENSE_ID] = [IXL].[LICENSE_ID]
											AND [IBM].[MATERIAL_ID] = [IXL].[MATERIAL_ID]
											)
	LEFT JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON (
											[IXL].[LICENSE_ID] = [SML].[LICENSE_ID]
											AND [IXL].[STATUS_ID] = [SML].[STATUS_ID]
											)
	WHERE
		[IBM].[MATERIAL_ID] = @MATERIAL_ID
		AND [IBM].[CURRENT_WAREHOUSE] = @CURRENT_WAREHOUSE
		AND [IXL].[PROJECT_ID] IS NULL
	ORDER BY
		[IBM].[DATE_EXPIRATION];
END;