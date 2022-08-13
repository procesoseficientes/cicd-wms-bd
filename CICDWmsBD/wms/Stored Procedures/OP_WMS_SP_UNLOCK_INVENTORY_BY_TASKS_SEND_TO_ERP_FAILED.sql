-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181121 GForce@Ornitorrinco
-- Description:	        valida si todos los documentos de la tarea han sido enviados al erp

/*
-- Ejemplo de Ejecucion:
         EXEC [wms].[OP_WMS_SP_UNLOCK_INVENTORY_BY_TASKS_SEND_TO_ERP_FAILED] @TASK_ID = 101
*/
CREATE PROCEDURE [wms].[OP_WMS_SP_UNLOCK_INVENTORY_BY_TASKS_SEND_TO_ERP_FAILED] (
		@TASK_ID INT
		,@REFERENCE VARCHAR(30)
		,@REASON VARCHAR(200)
		,@LOGIN VARCHAR(100)
	)
AS
BEGIN
	--
	DECLARE	@LICENSE_ID_ITERATE INT;
	BEGIN TRAN;
	BEGIN TRY

		DECLARE
			@MATERIAL_ID VARCHAR(50)
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
		


		SELECT
		
		DISTINCT
			[TR].[LICENSE_ID]
		INTO
			[#LICENSES_BY_TASK]
		FROM
			[wms].[OP_WMS_TRANS] [TR]
		WHERE
			[TR].[TASK_ID] = @TASK_ID
			AND [TR].[STATUS] = 'PROCESSED'
			AND [TR].[TRANS_TYPE] = 'INGRESO_GENERAL';

	-- ------------------------------------------------------------------------------------
	-- RECORREMOS LAS LICENCIAS ASOCIADAS A LA TAREA PARA DESBLOQUEAR EL INVENTARIO
	-- ------------------------------------------------------------------------------------
		WHILE (EXISTS ( SELECT TOP 1
							1
						FROM
							[#LICENSES_BY_TASK] ))
		BEGIN
			SELECT TOP 1
				@LICENSE_ID_ITERATE = [LICENSE_ID]
			FROM
				[#LICENSES_BY_TASK];
		-- ------------------------------------------------------------------------------------
		--DESBLOQUEAMOS EL INVENTARIO
		-- ------------------------------------------------------------------------------------
			UPDATE
				[wms].[OP_WMS_INV_X_LICENSE]
			SET	
				[LOCKED_BY_INTERFACES] = 0
				,[LAST_UPDATED] = GETDATE()
				,[LAST_UPDATED_BY] = @LOGIN
			WHERE
				[LICENSE_ID] = @LICENSE_ID_ITERATE;

		-- ------------------------------------------------------------------------------------
		-- ACTUALIZO EL ENCABEZADO DE LA LICENCIA
		-- ------------------------------------------------------------------------------------
			UPDATE
				[wms].[OP_WMS_LICENSES]
			SET	
				[LAST_UPDATED] = GETDATE()
				,[LAST_UPDATED_BY] = @LOGIN
			WHERE
				[LICENSE_ID] = @LICENSE_ID_ITERATE;

		-- ------------------------------------------------------------------------------------
		-- ELIMINO LA LICENCIA ITERADA DEL ARRAY
		-- ------------------------------------------------------------------------------------
			DELETE FROM
				[#LICENSES_BY_TASK]
			WHERE
				[LICENSE_ID] = @LICENSE_ID_ITERATE;

		END;

	-- ------------------------------------------------------------------------------------
	-- actualizo los documentos asociados a la tarea de la cual liberamos el inventario
	-- ------------------------------------------------------------------------------------
		UPDATE
			[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
		SET	
			[IS_POSTED_ERP] = 1
			,[POSTED_RESPONSE] = @REASON
			,[ERP_REFERENCE] = @REFERENCE
			,[LAST_UPDATE] = GETDATE()
			,[LAST_UPDATE_BY] = @LOGIN
			,[ERP_REFERENCE_DOC_NUM] = @REFERENCE
		WHERE
			[TASK_ID] = @TASK_ID
			AND [IS_POSTED_ERP] != 1;


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
			[H].[TASK_ID] = @TASK_ID
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
			DELETE
				[#MASTERPACK_TO_EXPLODE]
			WHERE
				[MATERIAL_ID] = @MATERIAL_ID
				AND [LICENSE_ID] = @LICENSE_ID
				AND [TASK_ASSIGNEDTO] = @LOGIN;
		END;


		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' AS [Mensaje]
			,1 AS [Codigo]
			,'' AS [DbData];

		COMMIT;	

	END TRY
	BEGIN CATCH
		-- ------------------------------------------------------------------------------------
		-- Despliega el error
		-- ------------------------------------------------------------------------------------
		ROLLBACK;
		--
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH;
	
END;


