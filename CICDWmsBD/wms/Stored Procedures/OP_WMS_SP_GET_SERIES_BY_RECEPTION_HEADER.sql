-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-19 @ Team ERGON - Sprint ERGON 1
-- Description:	 Obtener las series de un documento de recepción




/*
-- Ejemplo de Ejecucion:
			 EXEC [wms].[OP_WMS_SP_GET_SERIES_BY_RECEPTION_HEADER] @RECEPTION_HEADER = '2005'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_SERIES_BY_RECEPTION_HEADER]
	@RECEPTION_HEADER VARCHAR(50)
AS
SET NOCOUNT ON;

SELECT
	@RECEPTION_HEADER AS [DocEntry]
	,[S].[MATERIAL_ID] AS [ItemCode]
	,[S].[SERIAL] AS [TxnSerie]
	,'AVAILABLE' [STATUS]
FROM
	[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [H].[TASK_ID] = [T].[SERIAL_NUMBER]
INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[CODIGO_POLIZA] = [T].[CODIGO_POLIZA_SOURCE]
INNER JOIN [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [S] ON [S].[LICENSE_ID] = [L].[LICENSE_ID]
											AND [S].[STATUS] > 0
WHERE
	[H].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER;