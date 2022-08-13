-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		14-Dec-16 @ A-Team Sprint 6
-- Description:			    Se agrego el convert a la condicion poliza asegurada con doc id
-- =============================================

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [wms].OP_WMS_VIEW_INSURANCE_DOC
*/
-- =============================================


CREATE VIEW [wms].[OP_WMS_VIEW_POLIZAS]
AS
SELECT
	[PH].[DOC_ID]
	,[NUMERO_ORDEN]
	,[CODIGO_POLIZA]
	,[PH].[CLIENT_CODE]
	,[SP].[CLIENT_NAME] [CardName]
	,[TH].[ACUERDO_COMERCIAL_NOMBRE]
	,[ID].[POLIZA_INSURANCE]
	,[PH].[TIPO]
	,[PH].[WAREHOUSE_REGIMEN]
	,[PH].[FECHA_DOCUMENTO]
	,[PH].[LAST_UPDATED]
	,CASE [PH].[PENDIENTE_RECTIFICACION]
		WHEN 1 THEN 'SI'
		WHEN 2 THEN 'Rectificada'
		ELSE 'NO'
		END AS [PENDIENTE_RECTIFICACION_DESCRIPCION]
	,[PH].[PENDIENTE_RECTIFICACION]
	,[PH].[CODIGO_POLIZA_RECTIFICACION]
	,[PH].[COMENTARIO_RECTIFICACION]
	,[PH].[CLASE_POLIZA_RECTIFICACION]
	,[PH].[COMENTARIO_RECTIFICADO]
	,[PH].[DOC_ID_RECTIFICACION]
FROM
	[wms].[OP_WMS_POLIZA_HEADER] [PH]
INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [SP] ON ([PH].[CLIENT_CODE] = [SP].[CLIENT_CODE] COLLATE DATABASE_DEFAULT)
LEFT JOIN [wms].[OP_WMS_TARIFICADOR_HEADER] [TH] ON ((CASE
											WHEN [PH].[ACUERDO_COMERCIAL] = ''
											THEN 0
											ELSE [PH].[ACUERDO_COMERCIAL]
											END) = [TH].[ACUERDO_COMERCIAL_ID])
LEFT JOIN [wms].[OP_WMS_VIEW_INSURANCE_DOC] [ID] ON ([PH].[POLIZA_ASEGURADA] = (CASE
											WHEN [ID].[DOC_ID] = 0
											THEN [ID].[POLIZA_INSURANCE]
											ELSE CONVERT(VARCHAR(50), [ID].[DOC_ID])
											END));