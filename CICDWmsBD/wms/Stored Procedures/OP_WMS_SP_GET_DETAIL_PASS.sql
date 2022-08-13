-- =============================================
-- Autor:	rudi.garcia
-- Fecha de Creacion: 	26-Nov-2017 @ Team Reborn - Sprint Nach
-- Description:	 Sp que obtiene 

/*
-- Ejemplo de Ejecucion:
EXEC [wms].[OP_WMS_SP_GET_DEMAND_DETAIL_FOR_PASS] @PICKING_DEMAND_HEADER_ID = '1041'
                                     

			SELECT * FROM [wms].[OP_WMS_TASK]
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_GET_DETAIL_PASS] (@PASS_HEADER_ID INT)
AS
BEGIN
	SET NOCOUNT ON;
  --
	SELECT
		[PD].[PASS_DETAIL_ID]
		,[PD].[PASS_HEADER_ID]
		,[PD].[CLIENT_CODE]
		,[PD].[CLIENT_NAME]
		,[PD].[PICKING_DEMAND_HEADER_ID]
		,CAST(ISNULL([TRH].[DOC_NUM], [PD].[DOC_NUM]) as varchar(50)) [DOC_NUM]
		,[PD].[MATERIAL_ID]
		,[PD].[MATERIAL_NAME]
		,[PD].[QTY]
		,[PD].[DOC_NUM_POLIZA]
		,[PD].[CODIGO_POLIZA]
		,[PD].[NUMERO_ORDEN_POLIZA]
		,[PD].[WAVE_PICKING_ID]
		,[PD].[CREATED_DATE]
		,[PD].[CODE_WAREHOUSE]
		,[PD].[TYPE_DEMAND_CODE]
		,[PD].[TYPE_DEMAND_NAME]
		,ISNULL([PD].[LINE_NUM], 0) AS [LINE_NUM]
	FROM
		[wms].[OP_WMS_PASS_DETAIL] [PD]
	LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON [PDH].[PICKING_DEMAND_HEADER_ID] = [PD].[PICKING_DEMAND_HEADER_ID]
	LEFT JOIN [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [TRH] ON [TRH].[TRANSFER_REQUEST_ID] = [PDH].[TRANSFER_REQUEST_ID]
	WHERE
		[PASS_HEADER_ID] = @PASS_HEADER_ID;


END;
