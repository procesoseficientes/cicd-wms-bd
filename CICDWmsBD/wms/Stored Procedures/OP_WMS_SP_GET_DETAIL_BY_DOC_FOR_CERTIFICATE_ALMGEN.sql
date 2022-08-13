-- =============================================
-- Author:        rudi.garcia
-- Create date: 15-02-2016
-- Description:    Obtiene el detalle del documento para el certificado
-- Modificacion: 23-Mar-2018 @ G-Force-Team Sprint@Anemona

-- Autor:        rudi.garcia
-- Description:  Se cambio el sp para que consultara la tabla de transacciones en vez de inventario por licencia.
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_DETAIL_BY_DOC_FOR_CERTIFICATE_ALMGEN] @DOC_ID INT
AS
BEGIN
	SET NOCOUNT ON;
	SELECT
		SUM([T].[QUANTITY_UNITS]) AS [BULTOS]
		,[T].[MATERIAL_DESCRIPTION] AS [SKU_DESCRIPTION]
		,[T].[TARGET_WAREHOUSE] AS [LOCATIONS]
		,SUM([T].[QUANTITY_UNITS]) AS [QTY]
		,MIN(ISNULL([PD].[CUSTOMS_AMOUNT], 0)) [CUSTOMS_AMOUNT]
		,[T].[MATERIAL_CODE] AS [MATERIAL_CODE]
		,[PH].[DOC_ID]
		,CASE	WHEN [CH].[STATUS] = 'ANULAR'
				THEN 'DISPONIBLE'
				WHEN [CD].[CERTIFICATE_DEPOSIT_ID_DETAIL] IS NULL
				THEN 'DISPONIBLE'
				ELSE 'ASOCIADO'
			END AS [STATUS]
	FROM
		[wms].[OP_WMS_TRANS] [T]
	INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH] ON ([T].[CODIGO_POLIZA] = [PH].[CODIGO_POLIZA])
	LEFT JOIN [wms].[OP_WMS_POLIZA_DETAIL] [PD] ON (
											[PD].[DOC_ID] = [PH].[DOC_ID]
											AND [PD].[MATERIAL_ID] = [T].[MATERIAL_CODE]
											)
	LEFT JOIN [wms].[OP_WMS_CERTIFICATE_DEPOSIT_DETAIL] [CD] ON (
											[PH].[DOC_ID] = [CD].[DOC_ID]
											AND [T].[MATERIAL_CODE] = [CD].[MATERIAL_CODE]
											)
	LEFT JOIN [wms].[OP_WMS_CERTIFICATE_DEPOSIT_HEADER] [CH] ON ([CD].[CERTIFICATE_DEPOSIT_ID_HEADER] = [CH].[CERTIFICATE_DEPOSIT_ID_HEADER])
	WHERE
		[PH].[WAREHOUSE_REGIMEN] = 'GENERAL'
		AND [PH].[TIPO] = 'INGRESO'
		AND [T].[STATUS] = 'PROCESSED'
		AND [T].[TRANS_TYPE] = 'INGRESO_GENERAL'
		AND [PH].[DOC_ID] = @DOC_ID
	GROUP BY
		[T].[MATERIAL_DESCRIPTION]
		,[T].[TARGET_WAREHOUSE]
		,[PH].[DOC_ID]
		,[T].[MATERIAL_CODE]
		,[CD].[CERTIFICATE_DEPOSIT_ID_DETAIL]
		,[CH].[STATUS];
END;