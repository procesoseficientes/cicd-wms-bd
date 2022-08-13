-- =============================================
-- Autor:	              marvin.solares
-- Fecha de Creacion: 	20180830 GForce@Ibice
-- Description:	        Sp que marca una recepcion como mandada a ERP R3

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_MARK_RECEPTION_AS_SEND_TO_ERP]
				@RECEPTION_DOCUMENT_ID = 4045
				,@POSTED_RESPONSE = 'Exito al guardar en sap'
				,@ERP_REFERENCE = '3088'
				--
			select
				*
			from
				[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
			where
				[ERP_RECEPTION_DOCUMENT_HEADER_ID] = 4045
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_MARK_RECEPTION_AS_SEND_TO_ERP_R3] (
		@RECEPTION_DOCUMENT_ID INT
		,@POSTED_RESPONSE VARCHAR(500)
		,@ERP_REFERENCE VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE
			@MATERIAL_ID VARCHAR(50)
			,@LOGIN VARCHAR(50)
			,@LICENSE_ID DECIMAL
			,@EXPLOSION_TYPE VARCHAR(200)
			,@WAREHOUSE_CODE_PARAMETER VARCHAR(25) = NULL
			,@WAREHOUSE_CODE VARCHAR(25) = NULL;
		
		-- ------------------------------------------------------------------------------------
		-- Obtiene la bodega de las configuraciones
		-- ------------------------------------------------------------------------------------
		SELECT
			@WAREHOUSE_CODE_PARAMETER = [C].[TEXT_VALUE]
		FROM
			[wms].[OP_WMS_CONFIGURATIONS] AS [C]
		WHERE
			[C].[PARAM_NAME] = 'ERP_WAREHOUSE_PURCHASE_ORDER';
		--
		SELECT TOP 1
			@WAREHOUSE_CODE = [W].[WAREHOUSE_ID]
		FROM
			[wms].[OP_WMS_WAREHOUSES] [W]
		WHERE
			[W].[ERP_WAREHOUSE] = @WAREHOUSE_CODE_PARAMETER;

		-- ------------------------------------------------------------------------------------
		-- Obtiene el tipo de explosion
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@EXPLOSION_TYPE = [C].[TEXT_VALUE]
		FROM
			[wms].[OP_WMS_CONFIGURATIONS] [C]
		WHERE
			[C].[PARAM_TYPE] = 'SISTEMA'
			AND [C].[PARAM_GROUP] = 'MASTER_PACK_SETTINGS'
			AND [C].[PARAM_NAME] = 'TIPO_EXPLOSION_RECEPCION';
		

		-- ------------------------------------------------------------------------------------
		-- Actualiza la recepcion
		-- ------------------------------------------------------------------------------------
		UPDATE
			[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
		SET	
			[LAST_UPDATE] = GETDATE()
			,[LAST_UPDATE_BY] = 'INTERFACE'
			,[IS_POSTED_ERP] = 1
			,[POSTED_ERP] = GETDATE()
			,[POSTED_RESPONSE] = @POSTED_RESPONSE
			,[ERP_REFERENCE] = @ERP_REFERENCE
			,[ERP_REFERENCE_DOC_NUM] = @ERP_REFERENCE
			,[LOCKED_BY_INTERFACES] = 0
		WHERE
			[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID;

    -- ------------------------------------------------------------------------------------
		-- Desbloquea el inventario
		-- ------------------------------------------------------------------------------------
		EXEC [wms].[OP_WMS_UNLOCK_INVENTORY_LOCKED_BY_INTERFACES] @RECEPTION_DOCUMENT_ID = @RECEPTION_DOCUMENT_ID;
		-- ------------------------------------------------------------------------------------
		-- Obtiene los master packs que explotan en recepcion
		-- ------------------------------------------------------------------------------------
		SELECT DISTINCT
			[MPH].[MATERIAL_ID]
			,[MPH].[LICENSE_ID]
			,[T].[TASK_ASSIGNEDTO]
		INTO
			[#MASTERPACK_TO_EXPLODE]
		FROM
			[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
		INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D] ON [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
		INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [H].[TASK_ID] = [T].[SERIAL_NUMBER]
		INNER JOIN [wms].[OP_WMS_MASTER_PACK_HEADER] [MPH] ON [MPH].[POLICY_HEADER_ID] = [T].[DOC_ID_SOURCE]
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [MPH].[MATERIAL_ID] = [M].[MATERIAL_ID]
		LEFT JOIN [wms].[OP_WMS_WAREHOUSES] [WH] ON [H].[ERP_WAREHOUSE_CODE] = [WH].[ERP_WAREHOUSE]
		LEFT JOIN [wms].[OP_WMS_MATERIAL_PROPERTY_BY_WAREHOUSE] [MW] ON (
											[M].[MATERIAL_ID] = [MW].[MATERIAL_ID]
											AND [MW].[WAREHOUSE_ID] = COALESCE([D].[WAREHOUSE_CODE],
											[WH].[WAREHOUSE_ID],
											@WAREHOUSE_CODE)
											)
		LEFT JOIN [wms].[OP_WMS_MATERIAL_PROPERTY] [MP] ON [MP].[MATERIAL_PROPERTY_ID] = [MW].[MATERIAL_PROPERTY_ID]
											AND [MP].[NAME] = 'EXPLODE_IN_RECEPTION'
		WHERE
			[H].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_DOCUMENT_ID
			AND [M].[IS_MASTER_PACK] = 1
			AND (
					(
						[MW].[VALUE] IS NULL
						AND [M].[EXPLODE_IN_RECEPTION] = 1
					)
					OR [MW].[VALUE] = '1'
				);

		-- ------------------------------------------------------------------------------------
		-- Ciclo para explotar cada master pack
		-- ------------------------------------------------------------------------------------
		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							[#MASTERPACK_TO_EXPLODE] )
		BEGIN
			SELECT TOP 1
				@MATERIAL_ID = [M].[MATERIAL_ID]
				,@LICENSE_ID = [M].[LICENSE_ID]
				,@LOGIN = [M].[TASK_ASSIGNEDTO]
			FROM
				[#MASTERPACK_TO_EXPLODE] [M];
			PRINT @MATERIAL_ID

			-- ---------------------------------------------------------------------------------
			-- validar si explotara en cascada o directo al ultimo nivel 
			-- ---------------------------------------------------------------------------------  
			IF @EXPLOSION_TYPE = 'EXPLOSION_CASCADA'
			BEGIN
			PRINT 'EXPLOSION_CASCADA'
				EXEC [wms].[OP_WMS_SP_EXPLODE_CASCADE_IN_RECEPTION] @LICENSE_ID = @LICENSE_ID,
					@LOGIN_ID = @LOGIN,
					@MATERIAL_ID = @MATERIAL_ID;
			END;
			ELSE
			BEGIN
			PRINT 'NO: EXPLOSION_CASCADA'
				EXEC [wms].[OP_WMS_EXPLODE_MASTER_PACK] @LICENSE_ID = @LICENSE_ID,
					@MATERIAL_ID = @MATERIAL_ID,
					@LAST_UPDATE_BY = @LOGIN,
					@MANUAL_EXPLOTION = 0;
			END;
			--
			DELETE
				[#MASTERPACK_TO_EXPLODE]
			WHERE
				[MATERIAL_ID] = @MATERIAL_ID
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
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;