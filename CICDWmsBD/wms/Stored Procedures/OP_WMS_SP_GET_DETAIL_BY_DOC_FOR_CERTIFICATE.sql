-- =============================================
-- Author:		rudi.garcia
-- Create date: 15-02-2016
-- Description:	Obtiene el detalle del documento para el certificado para regimen fiscal
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_DETAIL_BY_DOC_FOR_CERTIFICATE] @DOC_ID INT
AS
BEGIN	
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT DISTINCT
		[PT].[MATERIAL_CODE]
		,[PT].[SKU_DESCRIPTION]
		,[wms].[OP_WMS_FUNC_GET_CONCATENATE_LOCATION_BY_SKU]([PH].[DOC_ID],
											[PT].[MATERIAL_CODE]) AS [LOCATIONS]
		,[PT].[BULTOS_POLIZA] AS [BULTOS]
		,[PD].[QTY]
		,[PD].[CUSTOMS_AMOUNT]
		,[PH].[DOC_ID]
		--,PD.LINE_NUMBER
		,CASE	WHEN [CH].[STATUS] = 'ANULAR'
				THEN 'DISPONIBLE'
				WHEN [CD].[CERTIFICATE_DEPOSIT_ID_DETAIL] IS NULL
				THEN 'DISPONIBLE'
				ELSE 'ASOCIADO'
			END AS [STATUS]
		,ISNULL([PD].[UNITARY_PRICE], 1) AS [UNIT_VALUE]
	FROM
		[wms].[OP_WMS3PL_POLIZA_TRANS_MATCH] [PT]
	INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH] ON ([PT].[CODIGO_POLIZA] = [PH].[CODIGO_POLIZA])
	INNER JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PD] ON (
											[PH].[DOC_ID] = [PD].[DOC_ID]
											AND [PD].[LINE_NUMBER] = [PT].[LINENO_POLIZA]
											)
	LEFT JOIN [wms].[OP_WMS_CERTIFICATE_DEPOSIT_DETAIL] [CD] ON (
											[PH].[DOC_ID] = [CD].[DOC_ID]
											AND [PT].[MATERIAL_CODE] = [CD].[MATERIAL_CODE]
											)
	LEFT JOIN [wms].[OP_WMS_CERTIFICATE_DEPOSIT_HEADER] [CH] ON ([CD].[CERTIFICATE_DEPOSIT_ID_HEADER] = [CH].[CERTIFICATE_DEPOSIT_ID_HEADER])
	WHERE
		[PH].[DOC_ID] = @DOC_ID;
END;