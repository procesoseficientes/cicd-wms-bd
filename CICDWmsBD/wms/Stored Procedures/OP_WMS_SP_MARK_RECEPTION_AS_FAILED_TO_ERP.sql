
-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-16 @ Team ERGON - Sprint ERGON 
-- Description:	        Sp que marca una recepcion fallida 

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_MARK_RECEPTION_AS_FAILED_TO_ERP]
          @RECEPTION_DOCUMENT_ID = 3
          ,@POSTED_RESPONSE = 'Error de sap'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_MARK_RECEPTION_AS_FAILED_TO_ERP] (
		@RECEPTION_DOCUMENT_ID INT
		,@POSTED_RESPONSE VARCHAR(500)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --

	BEGIN TRY

		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
					WHERE
						[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID
						AND [IS_POSTED_ERP] <> 1 )
		BEGIN

			UPDATE
				[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
			SET	
				[LAST_UPDATE] = GETDATE()
				,[LAST_UPDATE_BY] = 'INTERFACE'
				,[ATTEMPTED_WITH_ERROR] = [ATTEMPTED_WITH_ERROR]
				+ 1
				,[IS_POSTED_ERP] = -1
				,[POSTED_ERP] = GETDATE()
				,[POSTED_RESPONSE] = @POSTED_RESPONSE
				,[IS_SENDING] = 0
			WHERE
				[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID;

		END;
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'0' [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;