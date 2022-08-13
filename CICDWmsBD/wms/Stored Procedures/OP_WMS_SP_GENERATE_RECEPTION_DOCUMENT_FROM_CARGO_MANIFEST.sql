-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/30/2017 @ NEXUS-Team Sprint CommandAndConquer 
-- Description:			Genera la tarea de recepcion desde el documento de manifiesto de carga

-- Modificacion 13-Dec-17 @ Nexus Team Sprint HeyYouPikachu!
					-- alberto.ruiz
					-- Se cambio para que administre el proceso de generar tareas por manifiesto de carga

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GENERATE_RECEPTION_DOCUMENT_FROM_CARGO_MANIFEST]
					@MANIFEST_ID = 1045
					,@LOGIN = 'ACAMACHO'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GENERATE_RECEPTION_DOCUMENT_FROM_CARGO_MANIFEST] (
	@MANIFEST_ID INT
	,@LOGIN VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Valida si es de una solicitud de transferencia
		-- ------------------------------------------------------------------------------------
		IF EXISTS (SELECT TOP 1 1 FROM [wms].[OP_WMS_MANIFEST_HEADER] WHERE [MANIFEST_HEADER_ID] = @MANIFEST_ID AND [TRANSFER_REQUEST_ID] IS NOT NULL)
		BEGIN
			EXEC [wms].[OP_WMS_SP_GENERATE_RECEPTION_DOCUMENT_FROM_CARGO_MANIFEST_BY_TRANSFER_REQUEST]
				@MANIFEST_ID = @MANIFEST_ID
				,@LOGIN = @LOGIN
		END
		ELSE
		BEGIN
			EXEC [wms].[OP_WMS_SP_GENERATE_RECEPTION_DOCUMENT_FROM_CARGO_MANIFEST_BY_SALE]
				@MANIFEST_ID = @MANIFEST_ID
				,@LOGIN = @LOGIN
		END
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]
			,'' [DbData];
	END CATCH;
END;