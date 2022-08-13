-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-04-12 @ Team ERGON - Sprint ERGON EPONA
-- Description:	 

-- Modificacion:					rudi.garcia
-- Fecha de Creacion: 		2017-05-02 @ TeamErgon Sprint Ganondorf
-- Description:			    Se agrego el parametro @TASK_TYPE

-- Modificacion 24-Nov-17 @ Nexus Team Sprint GTA
					-- pablo.aguilar
					-- Se modifica para que agrupe por ubicación de salida, debido a las tareas de reabastecimiento.

/*
-- Ejemplo de Ejecucion:
	 EXEC [wms].[OP_WMS_SP_GET_MY_PICKING_LIST_DETAIL] @LOGIN_ID		 = 'ACAMACHO'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MY_PICKING_LIST_DETAIL] (
		@LOGIN_ID VARCHAR(25)
		,@TASK_TYPE VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	SELECT
		[T].[WAVE_PICKING_ID] [WAVE_PICKING_ID]
		,MAX([SERIAL_NUMBER]) AS [SERIAL_NUMBER]
		,[T].[BARCODE_ID]
		,MAX([T].[CODIGO_POLIZA_SOURCE]) [CODIGO_POLIZA_SOURCE]
		,MAX([T].[CODIGO_POLIZA_TARGET]) [CODIGO_POLIZA_TARGET]
		,[T].[MATERIAL_SHORT_NAME] [MATERIAL_NAME]
		,SUM([T].[QUANTITY_PENDING]) [QUANTITY_PENDING]
		,[T].[LOCATION_SPOT_TARGET]
		,[T].[MATERIAL_ID]
		,[T].[TASK_SUBTYPE]
		,[M].[MATERIAL_CLASS]
	FROM
		[wms].[OP_WMS_TASK_LIST] [T]
	LEFT JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [T].[MATERIAL_ID]
	WHERE
		[T].[TASK_ASSIGNEDTO] = @LOGIN_ID
		AND [T].[TASK_TYPE] = @TASK_TYPE
		AND [T].[IS_COMPLETED] <> 1
		AND [T].[IS_CANCELED] = 0
		AND [T].[IS_PAUSED] = 0
		AND [T].[QUANTITY_PENDING] > 0
	GROUP BY
		[T].[WAVE_PICKING_ID]
		,[M].[MATERIAL_CLASS]
		,[T].[MATERIAL_ID]
		,[T].[BARCODE_ID]
		,[T].[MATERIAL_SHORT_NAME]
		,[T].[TASK_SUBTYPE]
		,[T].[LOCATION_SPOT_TARGET];

END;