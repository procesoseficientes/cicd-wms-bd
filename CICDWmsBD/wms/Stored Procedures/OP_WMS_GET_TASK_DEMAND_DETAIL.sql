-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	5/21/2018 @ GForce-Team Sprint Capibara???
-- Description:			Obtiene las demandas que pertenecen a una ola de picking

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_GET_TASK_DEMAND_DETAIL]
					@WAVE_PICKING_ID = 339
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_TASK_DEMAND_DETAIL] (@WAVE_PICKING_ID INT)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@MAX_ATTEMPTS INT = 5;
	-- ------------------------------------------------------------------------------------
	-- Obtiene intentos maximos
	-- ------------------------------------------------------------------------------------
	SELECT
		@MAX_ATTEMPTS = [C].[NUMERIC_VALUE]
	FROM
		[wms].[OP_WMS_CONFIGURATIONS] [C]
	WHERE
		[C].[PARAM_TYPE] = 'SISTEMA'
		AND [C].[PARAM_GROUP] = 'MAX_NUMBER_OF_ATTEMPTS'
		AND [C].[PARAM_NAME] = 'MAX_NUMBER_OF_SENDING_ATTEMPTS_TO_ERP';
	--
	SELECT DISTINCT
		CAST(ISNULL([PDH].[DOC_NUM], [PD].[WAVE_PICKING_ID]) AS VARCHAR) [NO_DOC]
		,[PDH].[PICKING_DEMAND_HEADER_ID]
		,ISNULL([PDH].[PICKING_DEMAND_HEADER_ID],
				[PD].[PICKING_ERP_DOCUMENT_ID]) [WMS_DOCUMENT_HEADER_ID]
		,ISNULL([PDH].[DOC_NUM], [PD].[WAVE_PICKING_ID]) [DOC_ID]
		,ISNULL([PDH].[ATTEMPTED_WITH_ERROR],
				[PD].[ATTEMPTED_WITH_ERROR]) [ATTEMPTED_WITH_ERROR]
		,ISNULL([PDH].[IS_POSTED_ERP], [PD].[IS_POSTED_ERP]) [IS_POSTED_ERP]
		,CASE	WHEN COALESCE([PDH].[IS_POSTED_ERP],
								[PD].[IS_POSTED_ERP], 0) = -1
				THEN 'Fallido'
				WHEN COALESCE([PDH].[IS_POSTED_ERP],
								[PD].[IS_POSTED_ERP], 0) = 0
						AND ISNULL([PDH].[IS_AUTHORIZED], 0) = 1
				THEN 'Autorizada'
				WHEN COALESCE([PDH].[IS_POSTED_ERP],
								[PD].[IS_POSTED_ERP], 0) = 0
						AND COALESCE([PDH].[IS_AUTHORIZED],
										[PD].[IS_AUTHORIZED],
										0) = 0
				THEN 'Pendiente de Autorización'
				WHEN COALESCE([PDH].[IS_POSTED_ERP],
								[PD].[IS_POSTED_ERP], 0) = 1
				THEN 'Enviado'
			END [STATUS_POSTED_ERP]
		,ISNULL([PDH].[POSTED_ERP], [PD].[POSTED_ERP]) [POSTED_ERP]
		,ISNULL([PDH].[POSTED_RESPONSE],
				[PD].[POSTED_RESPONSE]) [POSTED_RESPONSE]
		,CAST(ISNULL([PDH].[ERP_REFERENCE_DOC_NUM],
						[PD].[ERP_REFERENCE_DOC_NUM]) AS VARCHAR) [ERP_REFERENCE]
		,COALESCE([PDH].[IS_AUTHORIZED],
					[PD].[IS_AUTHORIZED], 0) [IS_AUTHORIZED]
		,@MAX_ATTEMPTS [MAX_ATTEMPTS]
		,[PDH].[CODE_ROUTE]
		,CASE	WHEN (
						[W].[USE_PICKING_LINE] = 1
						AND (
								[PDH].[IS_FROM_ERP] = 1
								OR [PDH].[IS_FROM_SONDA] = 1
							)
						) THEN 1
				ELSE 0
			END AS [USE_PICKING_LINE]
	FROM
		[wms].[OP_WMS_TASK_LIST] [TL]
	INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON [TL].[WAREHOUSE_SOURCE] = [W].[WAREHOUSE_ID]
	LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON [PDH].[WAVE_PICKING_ID] = [TL].[WAVE_PICKING_ID]
	LEFT JOIN [wms].[OP_WMS_PICKING_ERP_DOCUMENT] [PD] ON [PD].[WAVE_PICKING_ID] = [TL].[WAVE_PICKING_ID]
	WHERE
		[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;
END;