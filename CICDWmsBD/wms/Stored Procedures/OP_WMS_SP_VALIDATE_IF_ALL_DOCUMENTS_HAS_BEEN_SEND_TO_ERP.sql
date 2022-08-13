-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181121 GForce@Ornitorrinco
-- Description:	        valida si todos los documentos de la tarea han sido enviados al erp

/*
-- Ejemplo de Ejecucion:
         EXEC [wms].[OP_WMS_SP_VALIDATE_IF_ALL_DOCUMENTS_HAS_BEEN_SEND_TO_ERP] @TASK_ID = 101
*/
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_IF_ALL_DOCUMENTS_HAS_BEEN_SEND_TO_ERP] (@TASK_ID INT)
AS
BEGIN
	--
	DECLARE
		@TOTAL_ENVIADOS_ERP INT = 0
		,@TOTAL_DOCUMENTOS INT = 0
		,@RESULT VARCHAR(10)= '1';

	SELECT
		@TOTAL_ENVIADOS_ERP = COUNT(1)
	FROM
		[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
	WHERE
		[TASK_ID] = @TASK_ID
		AND [IS_POSTED_ERP] = 1;

	SELECT
		@TOTAL_DOCUMENTOS = COUNT(1)
	FROM
		[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
	WHERE
		[TASK_ID] = @TASK_ID;

	IF @TOTAL_ENVIADOS_ERP <> @TOTAL_DOCUMENTOS
	BEGIN
		SET @RESULT = '0';
	END;

	SELECT
		1 AS [Resultado]
		,'Proceso Exitoso' AS [Mensaje]
		,1 AS [Codigo]
		,@RESULT AS [DbData];
	
END;