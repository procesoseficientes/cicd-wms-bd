-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	11/23/2017 @ NEXUS-Team Sprint GTA 
-- Description:			Marca como envio exitoso el picking general

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_MARK_AS_SENT_GENERAL_EXIT] 1, 'Proceso Exitoso', '1294123'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_MARK_AS_SENT_GENERAL_EXIT](
	@GENERAL_EXIT_ID INT
	,@POSTED_RESPONSE VARCHAR(250)
	,@ERP_REFERENCE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
			@QUERY NVARCHAR(MAX)
			,@OWNER VARCHAR(50)
			,@INTERFACE_DATA_BASE_NAME VARCHAR(50)
			,@ERP_DATABASE VARCHAR(50)
			,@SCHEMA_NAME VARCHAR(50)
			,@DOC_NUM INT;
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene el owner
		-- ------------------------------------------------------------------------------------
		SELECT @OWNER = [TL].[CLIENT_OWNER]
		FROM [wms].[OP_WMS_TASK_LIST] TL
		INNER JOIN [wms].[OP_WMS_PICKING_ERP_DOCUMENT] PED ON [PED].[WAVE_PICKING_ID] = [TL].[WAVE_PICKING_ID]
		WHERE [PED].[PICKING_ERP_DOCUMENT_ID] = @GENERAL_EXIT_ID;
		-- ------------------------------------------------------------------------------------
		-- Obtiene la fuente del dueño de la recepcion
		-- ------------------------------------------------------------------------------------
		SELECT 
			@INTERFACE_DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
			,@ERP_DATABASE = [C].[ERP_DATABASE]
			,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
		FROM [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
		INNER JOIN [wms].[OP_WMS_COMPANY] [C] ON ([C].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID])
		WHERE [C].[COMPANY_NAME] = @OWNER

		-- ------------------------------------------------------------------------------------
		-- Obtiene el doc num de la entrada 
		-- ------------------------------------------------------------------------------------
		SELECT
			@QUERY = N'EXEC ' + @INTERFACE_DATA_BASE_NAME + '.' + @SCHEMA_NAME +'.[SWIFT_SP_GET_ERP_DOC_NUM_FOR_DOCUMENT_BY_DOC_ENTRY]
					@DATABASE ='+ @ERP_DATABASE + '
					,@TABLE = ''OIGE''
					,@DOC_ENTRY = ' + CAST(@ERP_REFERENCE AS VARCHAR) + '
					,@DOC_NUM = @DOC_NUM OUTPUT';
		--
		PRINT @QUERY;
		--
		EXEC sp_executesql @QUERY,N'@DOC_NUM INT =-1 OUTPUT',@DOC_NUM = @DOC_NUM OUTPUT;

		UPDATE [wms].[OP_WMS_PICKING_ERP_DOCUMENT]
		SET [IS_POSTED_ERP] = 1
			,[POSTED_RESPONSE] = @POSTED_RESPONSE
			,[POSTED_ERP] = GETDATE()
			,[ERP_REFERENCE] = @ERP_REFERENCE
			,[ERP_REFERENCE_DOC_NUM] = @DOC_NUM
			,[LAST_UPDATED] = GETDATE()
			,[LAST_UPDATED_BY] = 'INTERFACES'
		WHERE [PICKING_ERP_DOCUMENT_ID] = @GENERAL_EXIT_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN ''
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END