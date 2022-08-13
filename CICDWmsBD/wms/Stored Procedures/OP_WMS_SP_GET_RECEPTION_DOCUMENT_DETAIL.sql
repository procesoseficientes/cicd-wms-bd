-- =============================================
-- Autor:               brandon.sicay
-- Fecha de Creacion:   2022/04/12
-- Description:         SP que obtiene todos los materiales que se deben recepcionar para la tarea

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[OP_WMS_SP_GET_RECEPTION_DOCUMENT_DETAIL]
          @SERIAL_NUMBER = 809152;

*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_GET_RECEPTION_DOCUMENT_DETAIL] (@SERIAL_NUMBER INT)
AS
SELECT
	[RDD].[MATERIAL_ID]
	,[M].[BARCODE_ID]
	,[M].[MATERIAL_NAME]
	,[RDD].[QTY]
	,[RDD].[STATUS_CODE]
FROM
	[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RDD]
INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH] ON [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [RDD].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [T].[SERIAL_NUMBER] = [RDH].[TASK_ID]
INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [RDD].[MATERIAL_ID]
											AND [M].[CLIENT_OWNER] = [T].[CLIENT_OWNER]
WHERE
	[T].[SERIAL_NUMBER] = @SERIAL_NUMBER AND RDD.QTY > 0