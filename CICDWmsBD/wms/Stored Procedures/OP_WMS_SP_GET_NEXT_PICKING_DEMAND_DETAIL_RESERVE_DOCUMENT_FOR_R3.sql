-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181012 GForce@Langosta
-- Description:	        Sp que trae el detalle de un Picking wms para enviarlo a R3

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181114 GForce@Narwhal
-- Description:	        Modificación para que separe la obtención de series en otro sp

/*
-- Ejemplo de Ejecucion:
			select * from [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
			--
			EXEC [wms].[OP_WMS_SP_GET_NEXT_PICKING_DEMAND_DETAIL_RESERVE_DOCUMENT_FOR_R3]
				@PICKING_DEMAND_HEADER_ID = 28
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_NEXT_PICKING_DEMAND_DETAIL_RESERVE_DOCUMENT_FOR_R3] (
		@PICKING_DEMAND_HEADER_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;
  --

	SELECT TOP 1
		[T].[WAVE_PICKING_ID]
		,[T].[TASK_OWNER]
		,ISNULL([T].[DISPATCH_LICENSE_EXIT_BY],
				[T].[TASK_ASSIGNEDTO]) [DISPATCH_LICENSE_EXIT_BY]
	INTO
		[#TASK]
	FROM
		[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
	INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [PDH].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID]
	WHERE
		[PDH].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;

	SELECT
		'RS' [INPUT_TYPE]
		,'Asigna: ' + CAST([T].[TASK_OWNER] AS VARCHAR) [XBLNR]
		,'Opera: ' + [T].[DISPATCH_LICENSE_EXIT_BY] [BKTXT]
		,'Ola: ' + CAST([T].[WAVE_PICKING_ID] AS VARCHAR) [FRBNR]
		,[R].[RSNUM]
		,[R].[RSPOS]
		,GETDATE() [BDTER]
		,[M].[ITEM_CODE_ERP] [MATNR]
		,[R].[WERKS]
		,CASE	WHEN ISNULL([R].[LGORT], '') = ''
				THEN '0001'
				ELSE [R].[LGORT]
			END [LGORT]
		,[PDD].[STATUS_CODE] [CHARG]
		,[PDD].[QTY] [BDMNG]
		,[R].[MEINS] [MEINS]
		,[R].[MSEHL]
		,[R].[ENWRT]
		,'' [SERIE]
		,ROW_NUMBER() OVER (ORDER BY [PDD].[LINE_NUM] ASC) AS [ROW_NUMBER]
		,ISNULL([R].[BWART], '') [BWART]
		,ISNULL([R].[RSSTA], '') [RSSTA]
		,ISNULL([R].[XLOEK], '') [XLOEK]
	INTO
		[#PICKING_RS]
	FROM
		[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD]
	INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON [PDH].[PICKING_DEMAND_HEADER_ID] = [PDD].[PICKING_DEMAND_HEADER_ID]
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [PDD].[MATERIAL_ID]
	INNER JOIN [SWIFT_R3_INTER].[dbo].[RFC_RESERVED] [R] ON [PDH].[DOC_ENTRY] = [R].[RSNUM]
											AND [R].[RSPOS] = [PDD].[LINE_NUM]
	INNER JOIN [#TASK] [T] ON [T].[WAVE_PICKING_ID] = [PDH].[WAVE_PICKING_ID]
	WHERE
		[PDD].[QTY] > 0
		AND [PDH].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
		AND [PDH].[TYPE_DEMAND_CODE] = 1
	ORDER BY
		[PDD].[LINE_NUM] ASC;

	SELECT
		*
	FROM
		[#PICKING_RS]
	ORDER BY
		[ROW_NUMBER] ASC;

END;