-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	10/11/2017 @ NEXUS-Team Sprint ewms 
-- Description:			Marca una recepcion de devolucion de factura como enviada a ERP

-- Modificacion 11/29/2017 @ NEXUS-Team Sprint GTA
					-- rodrigo.gomez
					-- Se valida el parametro de explosion por bodegas de los materiales

-- Modificacion 1/29/2018 @ REBORN-Team Sprint Trotzdem
					-- rodrigo.gomez
					-- Se agrega el parametro @TABLE_NAME para que dependiendo de este vaya a traer el docnum a la tabla especificada
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_MARK_CREDIT_MEMO_AS_SEND_TO_ERP]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_MARK_CREDIT_MEMO_AS_SEND_TO_ERP](
	@RECEPTION_HEADER_ID INT,
	@POSTED_RESPONSE VARCHAR(500),
	@ERP_REFERENCE VARCHAR(50),
	@OWNER VARCHAR(50),
	@TABLE_NAME VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@DOC_NUM INT
		,@QUERY NVARCHAR(MAX)
		,@LICENSE_ID DECIMAL
		,@INTERFACE_DATA_BASE_NAME VARCHAR(50)
		,@ERP_DATABASE VARCHAR(50)
		,@SCHEMA_NAME VARCHAR(50)
		,@TASK_ID INT
		,@CODIGO_POLIZA VARCHAR(50)
		,@IS_FROM_ERP INT = 0
		,@MATERIAL_ID VARCHAR(50)
		,@LOGIN VARCHAR(50)
		,@EXPLOSION_TYPE VARCHAR(200);
	BEGIN TRY
		SELECT TOP 1 @EXPLOSION_TYPE = [C].[TEXT_VALUE]
		FROM [wms].[OP_WMS_CONFIGURATIONS] [C]
		WHERE [C].[PARAM_TYPE] = 'SISTEMA'
			AND [C].[PARAM_GROUP] = 'MASTER_PACK_SETTINGS'
			AND [C].[PARAM_NAME] = 'TIPO_EXPLOSION_RECEPCION'
		-- ------------------------------------------------------------------------------------
		-- Obtiene la fuente del dueño de la recepcion
		-- ------------------------------------------------------------------------------------
		SELECT 
			@INTERFACE_DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
			,@ERP_DATABASE = [C].[ERP_DATABASE]
			,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
		FROM [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
		INNER JOIN [wms].[OP_WMS_COMPANY] [C] ON ([C].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID])
		WHERE [C].[CLIENT_CODE] = @OWNER
			AND [ES].[READ_ERP] = 1
		-- ------------------------------------------------------------------------------------
		-- Obtiene el doc num del ERP
		-- ------------------------------------------------------------------------------------
		SELECT
			@QUERY = N'EXEC ' + @INTERFACE_DATA_BASE_NAME + '.' + @SCHEMA_NAME +'.[SWIFT_SP_GET_ERP_DOC_NUM_FOR_DOCUMENT_BY_DOC_ENTRY]
					@DATABASE ='+ @ERP_DATABASE + '
					,@TABLE = ' + @TABLE_NAME + '
					,@DOC_ENTRY = ' + @ERP_REFERENCE + '
					,@DOC_NUM = @DOC_NUM OUTPUT';
		PRINT @QUERY;
		--
		EXEC sp_executesql @QUERY,N'@DOC_NUM INT =-1 OUTPUT',@DOC_NUM = @DOC_NUM OUTPUT;
		-- ------------------------------------------------------------------------------------
		-- Actualiza el detalle de la recepcion
		-- ------------------------------------------------------------------------------------
        UPDATE [RDD]
        SET
            [RDD].[IS_POSTED_ERP] = 1
          , [RDD].[POSTED_ERP] = GETDATE()
          , [RDD].[POSTED_RESPONSE] = REPLACE(@POSTED_RESPONSE, @ERP_REFERENCE, @DOC_NUM)
          , [RDD].[ERP_REFERENCE] = @ERP_REFERENCE
          , [RDD].[ERP_REFERENCE_DOC_NUM] = @DOC_NUM
        FROM
            [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RDD]
        INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [RDD].[MATERIAL_ID]
        WHERE
            [RDD].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER_ID
            AND [M].[CLIENT_OWNER] = @OWNER
            AND [RDD].[ERP_RECEPTION_DOCUMENT_DETAIL_ID] > 0;

		-- ------------------------------------------------------------------------------------
		-- Verifica que todo el detalle este marcado como 1 y marca el encabezado como posteado
		-- ------------------------------------------------------------------------------------
		IF NOT EXISTS (SELECT * FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] WHERE [IS_POSTED_ERP] <> 1 AND [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER_ID)
		BEGIN
			
			UPDATE [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
			SET	
				[LAST_UPDATE] = GETDATE()
				,[LAST_UPDATE_BY] = 'INTERFACE'
				,[IS_POSTED_ERP] = 1
				,[POSTED_ERP] = GETDATE()
				,[POSTED_RESPONSE] = REPLACE(@POSTED_RESPONSE, @ERP_REFERENCE, @DOC_NUM)
				,[ERP_REFERENCE] = @ERP_REFERENCE
				,[ERP_REFERENCE_DOC_NUM] = @DOC_NUM
			WHERE [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER_ID;

			-- ------------------------------------------------------------------------------------
			-- Obtiene la tarea para desbloquear el inventario
			-- ------------------------------------------------------------------------------------
			SELECT @TASK_ID = [TASK_ID]
			FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
			WHERE [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER_ID;
			-- ------------------------------------------------------------------------------------
			-- Obtiene el codigo de poliza de la tarea
			-- ------------------------------------------------------------------------------------
			SELECT @CODIGO_POLIZA = [CODIGO_POLIZA_SOURCE] 
			FROM [wms].[OP_WMS_TASK_LIST] 
			WHERE [SERIAL_NUMBER] = @TASK_ID
			-- ------------------------------------------------------------------------------------
			-- Obtiene el ID de la licencia
			-- ------------------------------------------------------------------------------------
			SELECT [LICENSE_ID]
			INTO [#LICENSES]
			FROM [wms].[OP_WMS_LICENSES] 
			WHERE [CODIGO_POLIZA] = @CODIGO_POLIZA
			-- ------------------------------------------------------------------------------------
			-- Desbloquea el inventario por licencia
			-- ------------------------------------------------------------------------------------
			UPDATE [IXL]
			SET [IS_BLOCKED] = 0
				,[IXL].[LOCKED_BY_INTERFACES] = 0 
			FROM [wms].[OP_WMS_INV_X_LICENSE] [IXL]
				INNER JOIN [#LICENSES] [L] ON [L].[LICENSE_ID] = [IXL].[LICENSE_ID]
			WHERE [IXL].[PK_LINE] > 0
		END
		-- ------------------------------------------------------------------------------------
		-- Obtiene los master packs que explotan en recepcion
		-- ------------------------------------------------------------------------------------
		SELECT DISTINCT
			[MPH].[MATERIAL_ID]
			,[MPH].[LICENSE_ID]
			,[T].[TASK_ASSIGNEDTO]
		INTO [#MASTERPACK_TO_EXPLODE]
		FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
		INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D] ON [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
		INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [H].[TASK_ID] = [T].[SERIAL_NUMBER]
		INNER JOIN [wms].[OP_WMS_MASTER_PACK_HEADER] [MPH] ON [MPH].[POLICY_HEADER_ID] = [T].[DOC_ID_SOURCE]
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [MPH].[MATERIAL_ID] = [M].[MATERIAL_ID]
		LEFT JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON [H].[ERP_WAREHOUSE_CODE] = [W].[ERP_WAREHOUSE]
		INNER JOIN [wms].[OP_WMS_MATERIAL_PROPERTY_BY_WAREHOUSE] [MW] ON [M].[MATERIAL_ID] = [MW].[MATERIAL_ID] AND [MW].[WAREHOUSE_ID] = (ISNULL([D].[WAREHOUSE_CODE], [W].[WAREHOUSE_ID]))
		INNER JOIN [wms].[OP_WMS_MATERIAL_PROPERTY] [MP] ON [MP].[MATERIAL_PROPERTY_ID] = [MW].[MATERIAL_PROPERTY_ID] AND [MP].[NAME] = 'EXPLODE_IN_RECEPTION'
		WHERE [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER_ID
			AND [M].[EXPLODE_IN_RECEPTION] = 1
			AND [M].[IS_MASTER_PACK] = 1
			AND	[MW].[VALUE] = '1';

		-- ------------------------------------------------------------------------------------
		-- Ciclo para explotar cada master pack
		-- ------------------------------------------------------------------------------------
		WHILE EXISTS ( SELECT TOP 1 1 FROM [#MASTERPACK_TO_EXPLODE] )
		BEGIN
			SELECT TOP 1
				@MATERIAL_ID = [M].[MATERIAL_ID]
				,@LICENSE_ID = [M].[LICENSE_ID]
				,@LOGIN = [M].[TASK_ASSIGNEDTO]
			FROM [#MASTERPACK_TO_EXPLODE] [M];

			-- ---------------------------------------------------------------------------------
			-- validar si explotara en cascada o directo al ultimo nivel 
			-- ---------------------------------------------------------------------------------  
			IF @EXPLOSION_TYPE = 'EXPLOSION_CASCADA'
			BEGIN
				EXEC [wms].[OP_WMS_SP_EXPLODE_CASCADE_IN_RECEPTION] @LICENSE_ID = @LICENSE_ID,
					@LOGIN_ID = @LOGIN,
					@MATERIAL_ID = @MATERIAL_ID;
			END;
			ELSE
			BEGIN
				EXEC [wms].[OP_WMS_EXPLODE_MASTER_PACK] @LICENSE_ID = @LICENSE_ID,
					@MATERIAL_ID = @MATERIAL_ID,
					@LAST_UPDATE_BY = @LOGIN,
					@MANUAL_EXPLOTION = 0;
			END;
			--
			DELETE [#MASTERPACK_TO_EXPLODE]
			WHERE [MATERIAL_ID] = @MATERIAL_ID
				AND [LICENSE_ID] = @LICENSE_ID
				AND [TASK_ASSIGNEDTO] = @LOGIN;
		END;


		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado final
		-- ------------------------------------------------------------------------------------
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'0' [DbData];
	END TRY
	BEGIN CATCH
		SELECT 1
	END CATCH
END