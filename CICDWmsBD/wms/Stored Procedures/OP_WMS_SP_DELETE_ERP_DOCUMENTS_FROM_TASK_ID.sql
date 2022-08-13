-- =============================================
-- Autor:				marvin.garcia
-- Fecha de Creacion: 	26-Jun-2018 @ A-TEAM Sprint Elefante  
-- Description:			SP que elimina los documentos de recepcion ERP

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20180801 GForce@FocaMonje
-- Description:			modificación para que tome en cuenta varios documentos por tarea

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_DELETE_ERP_DOCUMENTS_FROM_TASK_ID]
				@TASK_ID = --NUMERIC(18,0)
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_DELETE_ERP_DOCUMENTS_FROM_TASK_ID] @TASK_ID NUMERIC(18,
											0)
AS
BEGIN
	BEGIN TRY

	-- ELIMINANDO DETALLES ERP
		DELETE FROM
			[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL]
		WHERE
			[ERP_RECEPTION_DOCUMENT_HEADER_ID] IN (
			SELECT
				[ERP_RECEPTION_DOCUMENT_HEADER_ID]
			FROM
				[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
			WHERE
				[TASK_ID] = @TASK_ID);

	-- ELIMINANDO ENCABEZADOS ERP
		DELETE FROM
			[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
		WHERE
			[ERP_RECEPTION_DOCUMENT_HEADER_ID] IN (
			SELECT
				[ERP_RECEPTION_DOCUMENT_HEADER_ID]
			FROM
				[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
			WHERE
				[TASK_ID] = @TASK_ID);

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CONVERT(VARCHAR(16), 1) [DbData];

	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;