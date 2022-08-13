-- =============================================
-- Autor:	rudi.garcia
-- Fecha de Creacion: 	07-fEB-2019 @ Team G-Force - Sprint Suricata
-- Description:	 Sp que obtiene 

-- Autor:				rudi.garcia
-- Fecha de Creacion: 	26-Jul-2019 @ G-Force-Team Sprint Dublin
-- Description:			se agrega el campo de referencia

/*
-- Ejemplo de Ejecucion:
EXEC [wms].OP_WMS_SP_GET_WAVE_PIKING_GENERATED_BY_DEMAND_DISPACHT @DATE = GETDATE()
                                     

	
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_GET_WAVE_PIKING_GENERATED_BY_DEMAND_DISPACHT] (@DATE DATE)
AS
BEGIN
	SET NOCOUNT ON;


	DECLARE	@PICKING_TABLE AS TABLE (
			[WAVE_PICKING_ID] INT
			,[ASSIGNED_DATE] DATETIME
			,[STATUS_TASK] VARCHAR(25)
			,[COMPLETED_DATE] DATETIME
			,[TASK_OWNER] VARCHAR(25)
			,[ORDER_NUMBER] VARCHAR(25)
		);

	INSERT	INTO @PICKING_TABLE
			(
				[WAVE_PICKING_ID]
				,[ASSIGNED_DATE]
				,[STATUS_TASK]
				,[COMPLETED_DATE]
				,[TASK_OWNER]
				,[ORDER_NUMBER]
			)
	SELECT
		[TL].[WAVE_PICKING_ID]
		,MIN([TL].[ASSIGNED_DATE])
		,CASE MIN([TL].[IS_COMPLETED])
			WHEN 0 THEN CASE MAX([TL].[IS_ACCEPTED])
							WHEN 0 THEN 'INCOMPLETA'
							WHEN 1 THEN 'ACEPTADA'
							ELSE 'INCOMPLETA'
						END
			ELSE 'COMPLETA'
			END
		,MAX([TL].[COMPLETED_DATE])
		,MAX([TASK_OWNER])
		,MAX([ORDER_NUMBER])
	FROM
		[wms].[OP_WMS_TASK_LIST] [TL]
	WHERE
		CAST([TL].[ASSIGNED_DATE] AS DATE) = @DATE
		AND [TL].[IS_FROM_ERP] = 1
	GROUP BY
		[TL].[WAVE_PICKING_ID];

  --
	SELECT
		[PT].[WAVE_PICKING_ID]
		,[PT].[ASSIGNED_DATE]
		,[PT].[STATUS_TASK]
		,[PT].[COMPLETED_DATE]
		,[PT].[TASK_OWNER]
		,[PDH].[DOC_NUM]
		,CASE	WHEN ISNULL([PDH].[IS_POSTED_ERP], 0) = -1
				THEN 'Fallido'
				WHEN ISNULL([PDH].[IS_POSTED_ERP], 0) = 0
						AND ISNULL([PDH].[IS_AUTHORIZED], 0) = 1
				THEN 'Autorizada'
				WHEN ISNULL([PDH].[IS_POSTED_ERP], 0) = 0
						AND ISNULL([PDH].[IS_AUTHORIZED], 0) = 0
				THEN 'Pendiente de Autorización'
				WHEN ISNULL([PDH].[IS_POSTED_ERP], 0) = 1
				THEN 'Enviado'
			END [STATUS_POSTED_ERP]
		,[PDH].[POSTED_ERP]
		,[PDH].[POSTED_RESPONSE]
		,[PDH].[ERP_REFERENCE]
		,[PT].[ORDER_NUMBER]
	FROM
		[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
	INNER JOIN @PICKING_TABLE [PT] ON ([PDH].[WAVE_PICKING_ID] = [PT].[WAVE_PICKING_ID])
	ORDER BY
		[PT].[WAVE_PICKING_ID] DESC;

END;