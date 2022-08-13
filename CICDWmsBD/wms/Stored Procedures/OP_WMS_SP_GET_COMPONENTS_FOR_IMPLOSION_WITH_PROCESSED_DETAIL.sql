-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/18/2017 @ NEXUS-Team Sprint DuckHunt 
-- Description:			Devuelve el inventario que hace falta y lo que ya lleva procesado.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_COMPONENTS_FOR_IMPLOSION_WITH_PROCESSED_DETAIL]
					@LICENSE_ID = 378274,
					@MATERIAL_ID = 'autovanguard/VAD1001',
					@QTY = 10

					SELECT * FROM [wms].[OP_WMS_MASTER_PACK_HEADER]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_COMPONENTS_FOR_IMPLOSION_WITH_PROCESSED_DETAIL](
	@LICENSE_ID INT,
	@MATERIAL_ID VARCHAR(50),
	@QTY DECIMAL
)
AS
BEGIN
	SET NOCOUNT ON;
	--

	SELECT @MATERIAL_ID [MASTER_PACK_ID]
		,[D].[MATERIAL_ID]
		, MAX([D].[QTY]) * MAX([H].[QTY]) [QTY]
		,SUM(ISNULL([TL].[QUANTITY_ASSIGNED],0)) [QTY_PROCESSED] 
	FROM  [wms].[OP_WMS_MASTER_PACK_HEADER] [H]
	INNER JOIN [wms].[OP_WMS_MASTER_PACK_DETAIL] [D] ON [D].[MASTER_PACK_HEADER_ID] = [H].[MASTER_PACK_HEADER_ID]
		LEFT JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON [TL].[MATERIAL_ID] = [D].[MATERIAL_ID]
													AND [TL].[LICENSE_ID_TARGET] = @LICENSE_ID
													AND [TL].[TASK_TYPE] = 'IMPLOSION_INVENTARIO'
	WHERE [H].[MATERIAL_ID] = @MATERIAL_ID
	AND [H].[LICENSE_ID] = @LICENSE_ID
	AND [H].[IS_IMPLOSION] = 1 
	GROUP BY 
            [D].[MATERIAL_ID]
END