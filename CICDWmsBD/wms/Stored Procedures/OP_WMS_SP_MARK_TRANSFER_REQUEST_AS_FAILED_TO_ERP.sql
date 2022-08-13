-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/31/2017 @ NEXUS-Team Sprint CommandAndConquer 
-- Description:			Marca una recepcion de solicitud de traslado como fallida a ERP

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_MARK_TRANSFER_REQUEST_AS_FAILED_TO_ERP]
					@RECEPTION_DOCUMENT_ID = 40790
					,@POSTED_RESPONSE = 'SAP ERROR'
					,@OWNER = 'autovanguard'
				-- 
				SELECT * FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
				WHERE [ERP_RECEPTION_DOCUMENT_HEADER_ID] = 4079;		

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_MARK_TRANSFER_REQUEST_AS_FAILED_TO_ERP] (
	@RECEPTION_DOCUMENT_ID INT
	,@POSTED_RESPONSE VARCHAR(500)
	,@OWNER VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE @IS_FROM_ERP INT = 0
		--
		SELECT @IS_FROM_ERP = [RDH].[IS_FROM_ERP]
		FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
		WHERE [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID
		-- ------------------------------------------------------------------------------------
		-- Actualiza el encabezado
		-- ------------------------------------------------------------------------------------
		UPDATE
			[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
		SET	
			[LAST_UPDATE] = GETDATE()
			,[LAST_UPDATE_BY] = 'INTERFACE'
			,[ATTEMPTED_WITH_ERROR] = [ATTEMPTED_WITH_ERROR] + 1
			,[IS_POSTED_ERP] = -1
			,[POSTED_ERP] = GETDATE()
			,[POSTED_RESPONSE] = @POSTED_RESPONSE
		WHERE
			[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID;		
		-- ------------------------------------------------------------------------------------
		-- Actualiza el detalle
		-- ------------------------------------------------------------------------------------
		UPDATE [RDD]
		SET	
			[ATTEMPTED_WITH_ERROR] = [ATTEMPTED_WITH_ERROR] + 1
			,[IS_POSTED_ERP] = -1
			,[POSTED_ERP] = GETDATE()
			,[POSTED_RESPONSE] = @POSTED_RESPONSE
		FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RDD]
			INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [RDD].[MATERIAL_ID]
		WHERE [RDD].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID AND
			([M].[CLIENT_OWNER] = @OWNER OR @IS_FROM_ERP = 1);
		-- ------------------------------------------------------------------------------------
		-- Muestra resultado final
		-- ------------------------------------------------------------------------------------
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'' [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,CASE CAST(@@ERROR AS VARCHAR)
				WHEN '2627' THEN ''
				ELSE ERROR_MESSAGE()
				END [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH;
END;