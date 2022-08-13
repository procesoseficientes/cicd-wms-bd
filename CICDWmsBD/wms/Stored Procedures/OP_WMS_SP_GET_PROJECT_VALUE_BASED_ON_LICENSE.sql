-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	18-Apr-18 @ G-FORCE Team Sprint buho 
-- Description:			SP que obtiene el proyecto y el codigo de cliente de venta en base a una licencia
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_GET_PROJET_VALUE_BASED_ON_LICENSE] @LICENSE_ID = 22732
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_PROJECT_VALUE_BASED_ON_LICENSE] (@LICENSE_ID INT)
AS
BEGIN
	SET NOCOUNT ON;
	--	
	SELECT
		CASE	WHEN [IL].[PICKING_DEMAND_HEADER_ID] IS NULL
				THEN [IL].[REGIMEN]
				WHEN [PDH].[PROJECT] IS NULL
				THEN [PDH].[CLIENT_CODE]
				WHEN LEN(ISNULL([PDH].[PROJECT], '')) = 0
				THEN [PDH].[CLIENT_CODE]
				ELSE [PDH].[PROJECT]
		END AS [PROJECT]
	FROM
		[wms].[OP_WMS_LICENSES] [IL]
	LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON [IL].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
	WHERE
		[IL].[LICENSE_ID] = @LICENSE_ID;

END;