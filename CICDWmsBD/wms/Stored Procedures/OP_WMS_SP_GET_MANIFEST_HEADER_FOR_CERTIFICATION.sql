-- =============================================
-- Autor:            rudi.garcia
-- Fecha de Creacion:     2017-10-21 @ Team REBORN - Sprint Drache
-- Description:            Sp que obtiene la informacion del manifiesto encabezado
/*
-- Ejemplo de Ejecucion:
            EXEC [wms].OP_WMS_SP_GET_MANIFEST_HEADER_FOR_CERTIFICATION 1119
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MANIFEST_HEADER_FOR_CERTIFICATION] (
		@MANIFEST_HEADER_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	SELECT
		[MH].[MANIFEST_HEADER_ID]
		,[MH].[DRIVER]
		,[MH].[VEHICLE]
		,[MH].[DISTRIBUTION_CENTER]
		,[MH].[CREATED_DATE]
		,[MH].[STATUS]
		,[MH].[LAST_UPDATE]
		,[MH].[LAST_UPDATE_BY]
		,[MH].[MANIFEST_TYPE]
		,[MH].[TRANSFER_REQUEST_ID]
		,[CH].[CERTIFICATION_HEADER_ID]
		,[CH].[STATUS] AS [STATUS_CERTIFICATION]
	FROM
		[wms].[OP_WMS_MANIFEST_HEADER] [MH]
	LEFT JOIN [wms].[OP_WMS_CERTIFICATION_HEADER] [CH] ON ([CH].[MANIFEST_HEADER_ID] = [MH].[MANIFEST_HEADER_ID])
	WHERE
		[MH].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
		AND (
				[MH].[STATUS] = 'CREATED'
				OR [MH].[STATUS] = 'CERTIFIED'
				OR [MH].[STATUS] = 'CERTIFYING'
			);
END;