-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		30-Jan-17 @ A-Team Sprint Bankole
-- Description:			    Funcion que obtiene los datos de la primera linea de la tarea de picking general

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-04-21 Team ERGON - Sprint EPONA
-- Description:	 Se modifica la forma en que va a obtener la información y lo ordena por ubicación. 

-- Modificacion 9/14/2017 @ Reborn - Team Sprint Collin
					-- diego.as
					-- Se agregan los campos TONE y CALIBER

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM  [wms].[OP_WMS_FUNC_GET_MY_FIRST_PICKING]('ACAMACHO',4373,'RD141216','LEC-FAT-IRISH')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FUNC_GET_MY_FIRST_PICKING]
	(
		@pLOGIN_ID VARCHAR(25)
		,@pWAVE_ID NUMERIC(18 ,0)
		,@pCODIGO_POLIZA_SOURCE VARCHAR(50)
		,@pBARCODE_ID VARCHAR(50)
	)
RETURNS TABLE
AS

  RETURN
	(
		SELECT TOP 1
			[T].[WAVE_PICKING_ID]
			,[T].[SERIAL_NUMBER]
			,[T].[CODIGO_POLIZA_SOURCE]
			,[T].[CODIGO_POLIZA_TARGET]
			,[T].[BARCODE_ID]
			,[T].[MATERIAL_NAME]
			,[T].[MATERIAL_SHORT_NAME]
			,[L].[CURRENT_LOCATION] [LOCATION_SPOT_SOURCE]
			,[T].[LICENSE_ID_SOURCE]
			,[T].[QUANTITY_ASSIGNED]
			,[T].[QUANTITY_PENDING]
			,[T].[QUANTITY_PENDING] [QTY_AVAILABLE]
			,[M].[BATCH_REQUESTED]
			,[M].[CLIENT_OWNER]
			,(CASE WHEN [T].[TONE] IS NULL THEN '' ELSE [T].[TONE] END) AS TONE
			,(CASE WHEN [T].[CALIBER] IS NULL THEN '' ELSE [T].[CALIBER] END) AS CALIBER
			,[M].[MATERIAL_ID]
		FROM
			[wms].[OP_WMS_TASK_LIST] [T]
		INNER JOIN [wms].[OP_WMS_LICENSES] [L]
		ON	[L].[LICENSE_ID] = [T].[LICENSE_ID_SOURCE]
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
		ON	[M].[MATERIAL_ID] = [T].[MATERIAL_ID]
		WHERE
			[T].[WAVE_PICKING_ID] = @pWAVE_ID
			AND [T].[CODIGO_POLIZA_SOURCE] = @pCODIGO_POLIZA_SOURCE
			AND [T].[BARCODE_ID] = @pBARCODE_ID
			AND [T].[QUANTITY_PENDING] > 0
		ORDER BY
			[L].[CURRENT_LOCATION] ASC
	);