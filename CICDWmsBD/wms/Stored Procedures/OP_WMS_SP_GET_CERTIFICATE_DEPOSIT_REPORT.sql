-- =============================================
-- Author:         rudi.garcia
-- Create date:    22/May/2018 - @G-Force - Caribu
-- Description:    SP que obtiene el detalle de la certificacion de deposito
/*                    
                
*/
/*
Ejemplo de Ejecucion:
                --
                EXEC [wms].OP_WMS_SP_GET_CERTIFICATE_DEPOSIT_REPORT
                    @ID_DEPOSIT_HEADER = 1
                --    
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_CERTIFICATE_DEPOSIT_REPORT] (
		@ID_DEPOSIT_HEADER INT
	)
AS
BEGIN
	SET NOCOUNT ON;


	SELECT
		MAX([CDD].[CERTIFICATE_DEPOSIT_ID_DETAIL]) AS [CERTIFICATE_DEPOSIT_ID_DETAIL]
		,MAX([CDD].[CERTIFICATE_DEPOSIT_ID_HEADER]) AS [CERTIFICATE_DEPOSIT_ID_HEADER]
		,MAX([CDD].[DOC_ID]) AS [DOC_ID]
		,[IL].[MATERIAL_ID] AS [MATERIAL_CODE]
		,([IL].[MATERIAL_NAME] + '|' + [SML].[STATUS_NAME]) AS [SKU_DESCRIPTION]
		,[L].[CURRENT_LOCATION] AS [LOCATIONS]
		,SUM([IL].[ENTERED_QTY]) AS [BULTOS]
		,SUM([IL].[ENTERED_QTY]) AS [QTY]
		,ISNULL(CAST(([PD].[CUSTOMS_AMOUNT]
						/ SUM([IL].[ENTERED_QTY])) AS NUMERIC(18,
											2)), 0) AS [UNIT_VALUE]
		,ISNULL([PD].[CUSTOMS_AMOUNT], 0) AS [CUSTOMS_AMOUNT]
		,MAX([PH].[POLIZA_ASEGURADA]) AS [POLIZA_ASEGURADA]
		,MAX([ID].[COMPANY_NAME]) AS [COMPANY_NAME]
	FROM
		[wms].[OP_WMS_CERTIFICATE_DEPOSIT_DETAIL] AS [CDD]
	INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH] ON ([CDD].[DOC_ID] = [PH].[DOC_ID])
	INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON ([PH].[CODIGO_POLIZA] = [L].[CODIGO_POLIZA])
	INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON (
											[IL].[LICENSE_ID] = [L].[LICENSE_ID]
											AND [IL].[MATERIAL_ID] = [CDD].[MATERIAL_CODE]
											)
	INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON ([SML].[STATUS_ID] = [IL].[STATUS_ID])
	INNER JOIN [wms].[OP_WMS_VIEW_INSURANCE_DOC] [ID] ON ([ID].[POLIZA_INSURANCE] = [PH].[POLIZA_ASEGURADA])
	LEFT JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PD] ON (
											[PH].[DOC_ID] = [PD].[DOC_ID]
											AND [IL].[MATERIAL_ID] = [PD].[MATERIAL_ID]
											)
	WHERE
		[CDD].[CERTIFICATE_DEPOSIT_ID_HEADER] = 1
	GROUP BY
		[IL].[MATERIAL_ID]
		,[IL].[MATERIAL_NAME]
		,[L].[CURRENT_LOCATION]
		,[SML].[STATUS_NAME]
		,[PD].[CUSTOMS_AMOUNT];          
END;