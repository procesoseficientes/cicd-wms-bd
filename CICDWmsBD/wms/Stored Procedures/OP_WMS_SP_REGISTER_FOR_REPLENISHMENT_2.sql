-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	09-Oct-2018 G-Force@Langosta
-- Description:			Sp que registra la transaccion y la ubica la licencia de un reabastecimiento

-- Autor:	        marvin.solares
-- Fecha de Creacion: 	20181030 GForce@Mamba
-- Description:		Se corrige escenario cuando la ubicacion es fast picking y no existen licencias en dicha ubicacion y se libera actualiza locked_by_interfaces a 0

-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_REGISTER_FOR_REPLENISHMENT_2] (
		@LOGIN VARCHAR(50)
		,@LICENSE_ID INT
		,@LOCATION_ID VARCHAR(25)
	)
AS
BEGIN
	BEGIN TRY
		BEGIN TRANSACTION;

		DECLARE
			@ErrorCode INT
			,@CLIENT_OWNER VARCHAR(50);
		-- ------------------------------------------------------------------------------------
		-- validamos que la licencia no haya sido ubicada
		-- ------------------------------------------------------------------------------------
		--IF EXISTS ( SELECT TOP 1
		--				1
		--			FROM
		--				[wms].[OP_WMS_LICENSES]
		--			WHERE
		--				[LICENSE_ID] = @LICENSE_ID
		--				AND [CURRENT_LOCATION] <> @LOGIN
		--				OR [CURRENT_LOCATION] <> NULL )
		--BEGIN
		--	SELECT
		--		@ErrorCode = 3051;
		--	RAISERROR ('La licencia de despacho ya fue ubicada.', 16, 1);
		--	RETURN;
		--END;

    -- -----------------------------------
    -- Declaramos las variables necesarias.
    -- -----------------------------------
		DECLARE
			@FAST_PICKING INT = 0
			,@WAREHOUSE_CODE VARCHAR(25)
			,@TASK_ID INT
			,@WAVE_PICKING_ID INT
			,@MATERIAL_ID VARCHAR(50)
			,@QTY NUMERIC(18, 4)
			,@EXPLOSION_TYPE VARCHAR(50);

    -- -----------------------------------
    -- Obtenemos los registros necesarios.
    -- -----------------------------------
		SELECT TOP 1
			@FAST_PICKING = [SS].[ALLOW_FAST_PICKING]
			,@WAREHOUSE_CODE = [SS].[WAREHOUSE_PARENT]
		FROM
			[wms].[OP_WMS_SHELF_SPOTS] [SS]
		WHERE
			[SS].[LOCATION_SPOT] = @LOCATION_ID;

		SELECT TOP 1
			@TASK_ID = [TL].[SERIAL_NUMBER]
			,@WAVE_PICKING_ID = [TL].[WAVE_PICKING_ID]
		FROM
			[wms].[OP_WMS_TASK_LIST] [TL]
		INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON ([L].[WAVE_PICKING_ID] = [L].[WAVE_PICKING_ID])
		WHERE
			[L].[LICENSE_ID] = @LICENSE_ID;

    -- -----------------------------------
    -- Creamos las variables de tabla.
    -- -----------------------------------
		DECLARE	@INV_X_LICENSE TABLE (
				[MATERIAL_ID] VARCHAR(50)
				,[QTY] NUMERIC(18, 4)
			);


    -- -----------------------------------
    -- Validamos si la zona de la ubicación hace explocion de los master pack
    -- -----------------------------------

		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_SHELF_SPOTS] [SS]
					INNER JOIN [wms].[OP_WMS_ZONE] [Z] ON ([SS].[ZONE] = [Z].[ZONE])
					WHERE
						[SS].[LOCATION_SPOT] = @LOCATION_ID
						AND [Z].[RECEIVE_EXPLODED_MATERIALS] = 1 )
		BEGIN
      -- -----------------------------------
      -- Obtenemos el tipo de explocion
      -- -----------------------------------
			SELECT TOP 1
				@EXPLOSION_TYPE = [C].[TEXT_VALUE]
			FROM
				[wms].[OP_WMS_CONFIGURATIONS] [C]
			WHERE
				[C].[PARAM_TYPE] = 'SISTEMA'
				AND [C].[PARAM_GROUP] = 'MASTER_PACK_SETTINGS'
				AND [C].[PARAM_NAME] = 'TIPO_EXPLOSION_RECEPCION';

      -- -----------------------------------
      -- Obtenemos los materiales de tipo explocion
      -- -----------------------------------
			INSERT	INTO @INV_X_LICENSE
					(
						[MATERIAL_ID]
						,[QTY]
					)
			SELECT
				[IL].[MATERIAL_ID]
				,[IL].[QTY]
			FROM
				[wms].[OP_WMS_INV_X_LICENSE] [IL]
			INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([IL].[MATERIAL_ID] = [M].[MATERIAL_ID])
			WHERE
				[IL].[LICENSE_ID] = @LICENSE_ID
				AND [M].[IS_MASTER_PACK] = 1;

      -- -----------------------------------
      -- Recorremos los materiales
      -- -----------------------------------
			WHILE EXISTS ( SELECT TOP 1
								1
							FROM
								@INV_X_LICENSE )
			BEGIN
        -- -----------------------------------
        -- Obtenemos el primer material de la licencia.
        -- -----------------------------------
				SELECT TOP 1
					@MATERIAL_ID = [MATERIAL_ID]
					,@QTY = [QTY]
				FROM
					@INV_X_LICENSE;

        -- -----------------------------------
        -- Validamos el tipo de explocion configurado
        -- -----------------------------------
				IF @EXPLOSION_TYPE = 'EXPLOSION_CASCADA'
				BEGIN
          -- -----------------------------------
          -- Se realiza una explocion en cascada
          -- -----------------------------------
		  PRINT @LICENSE_ID
		  PRINT @MATERIAL_ID
		    RAISERROR ('La licencia de despacho ya fue.', 16, 1);
		  RETURN;
					EXEC [wms].[OP_WMS_SP_EXPLODE_CASCADE_IN_RECEPTION] @LICENSE_ID = @LICENSE_ID,
						@LOGIN_ID = @LOGIN,
						@MATERIAL_ID = @MATERIAL_ID;
				END;
				ELSE
				BEGIN
          -- -----------------------------------
          -- Se realiza una explocion normal
          -- -----------------------------------
		  PRINT ('EXPLODE MASTERPACK')
		  PRINT @LICENSE_ID
		  PRINT @MATERIAL_ID
		  PRINT @LOGIN
		  RAISERROR ('La licencia de despacho ya fue.', 16, 1);
		  RETURN;
					--EXEC [wms].[OP_WMS_EXPLODE_MASTER_PACK] @LICENSE_ID = @LICENSE_ID,
					--	@MATERIAL_ID = @MATERIAL_ID,
					--	@LAST_UPDATE_BY = @LOGIN,
					--	@MANUAL_EXPLOTION = 0;
				END;
	
        -- -----------------------------------
        -- Borramos el materrial
        -- -----------------------------------
				DELETE FROM
					@INV_X_LICENSE
				WHERE
					[MATERIAL_ID] = @MATERIAL_ID;
			END;
		END;

		SELECT TOP 1
			@CLIENT_OWNER = [L].[CLIENT_OWNER]
		FROM
			[wms].[OP_WMS_LICENSES] [L]
		WHERE
			[L].[LICENSE_ID] = @LICENSE_ID; 

    -- -----------------------------------
    -- Validamos si es de picking rapido
    -- -----------------------------------
		IF @FAST_PICKING = 1
		BEGIN

      -- -----------------------------------
      -- Obtenemos los materiales y cantidades de la licencia.
      -- -----------------------------------
			INSERT	INTO @INV_X_LICENSE
					(
						[MATERIAL_ID]
						,[QTY]
					)
			SELECT
				[IL].[MATERIAL_ID]
				,[IL].[QTY]
			FROM
				[wms].[OP_WMS_INV_X_LICENSE] [IL]
			WHERE
				[IL].[LICENSE_ID] = @LICENSE_ID;

      -- -----------------------------------
      -- Recorremos uno por uno todos los materiales de la licencia.
      -- -----------------------------------
			WHILE EXISTS ( SELECT TOP 1
								1
							FROM
								@INV_X_LICENSE )
			BEGIN
        -- -----------------------------------
        -- Obtenemos el primer material de la licencia.
        -- -----------------------------------
				SELECT TOP 1
					@MATERIAL_ID = [MATERIAL_ID]
					,@QTY = [QTY]
				FROM
					@INV_X_LICENSE;
				
        -- -----------------------------------
        -- Reutilizamos el sp de reubicacion de picking rapido para reubicar. antes validamos que exista al menos una licencia en la ubicacion
        -- -----------------------------------
				IF EXISTS ( SELECT TOP 1
								1
							FROM
								[wms].[OP_WMS_LICENSES] [L]
							INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [INVL] ON [L].[LICENSE_ID] = [INVL].[LICENSE_ID]
							WHERE
								[L].[CURRENT_LOCATION] = @LOCATION_ID
								AND [L].[STATUS] = 'ALLOCATED'
								AND [L].[LICENSE_ID] <> @LICENSE_ID --EXCLUIMOS DEL SELECT LA LICENCIA CREADA EN LA RECEPCION
								AND [L].[CLIENT_OWNER] = @CLIENT_OWNER )
				BEGIN
					EXEC [wms].[OP_WMS_SP_UPDATE_PARTIAL_LICENSE_FAST_PICKING] @LOGIN_ID = @LOGIN,
						@LICENSE_ID = @LICENSE_ID,
						@LOCATION_ID = @LOCATION_ID,
						@TRANS_TYPE = 'REABASTECIMIENTO',
						@MATERIAL_ID_REALLOC = @MATERIAL_ID,
						@QTY_REALLOC = @QTY;
				END;
				ELSE
				BEGIN
					UPDATE
						[wms].[OP_WMS_LICENSES]
					SET	
						[CURRENT_WAREHOUSE] = @WAREHOUSE_CODE
						,[CURRENT_LOCATION] = @LOCATION_ID
						,[LAST_UPDATED] = GETDATE()
						,[LAST_UPDATED_BY] = @LOGIN
						,[STATUS] = 'ALLOCATED'
					WHERE
						[LICENSE_ID] = @LICENSE_ID;

					UPDATE
						[wms].[OP_WMS_INV_X_LICENSE]
					SET	
						[LOCKED_BY_INTERFACES] = 0
					WHERE
						[LICENSE_ID] = @LICENSE_ID;

				END;
        -- -----------------------------------
        -- Borramos el material
        -- -----------------------------------
				DELETE FROM
					@INV_X_LICENSE
				WHERE
					[MATERIAL_ID] = @MATERIAL_ID;
			END;
		END;
		ELSE
		BEGIN
      -- -----------------------------------
      -- Actualizamos nada mas la ubicacion a la licencia.
      -- -----------------------------------
			UPDATE
				[wms].[OP_WMS_LICENSES]
			SET	
				[CURRENT_WAREHOUSE] = @WAREHOUSE_CODE
				,[CURRENT_LOCATION] = @LOCATION_ID
				,[LAST_UPDATED] = GETDATE()
				,[LAST_UPDATED_BY] = @LOGIN
				,[STATUS] = 'ALLOCATED'
			WHERE
				[LICENSE_ID] = @LICENSE_ID;

			UPDATE
				[wms].[OP_WMS_INV_X_LICENSE]
			SET	
				[LOCKED_BY_INTERFACES] = 0
			WHERE
				[LICENSE_ID] = @LICENSE_ID;
		END;

    -- -----------------------------------
    -- Declaramos las variables necesarias.
    -- -----------------------------------
		DECLARE
			@LOGIN_NAME VARCHAR(50)
			,@CLIENT_NAME VARCHAR(150);

    -- -----------------------------------
    -- Obtenemos los registros necesarios
    -- -----------------------------------
		SELECT TOP 1
			@LOGIN_NAME = [L].[LOGIN_NAME]
		FROM
			[wms].[OP_WMS_LOGINS] [L]
		WHERE
			[L].[LOGIN_ID] = @LOGIN;

    -- -----------------------------------
    -- Insertamos las transacciones de la reubicacion
    -- -----------------------------------
		INSERT	INTO [wms].[OP_WMS_TRANS]
				(
					[TERMS_OF_TRADE]
					,[TRANS_DATE]
					,[LOGIN_ID]
					,[LOGIN_NAME]
					,[TRANS_TYPE]
					,[TRANS_DESCRIPTION]
					,[TRANS_EXTRA_COMMENTS]
					,[MATERIAL_BARCODE]
					,[MATERIAL_CODE]
					,[MATERIAL_DESCRIPTION]
					,[SOURCE_LICENSE]
					,[SOURCE_LOCATION]
					,[TARGET_LOCATION]
					,[CLIENT_OWNER]
					,[CLIENT_NAME]
					,[QUANTITY_UNITS]
					,[SOURCE_WAREHOUSE]
					,[TARGET_WAREHOUSE]
					,[TRANS_SUBTYPE]
					,[CODIGO_POLIZA]
					,[LICENSE_ID]
					,[STATUS]
					,[TRANS_MT2]
					,[WAVE_PICKING_ID]
					,[TASK_ID]
					,[SERIAL]
					,[BATCH]
					,[DATE_EXPIRATION]
					,[TONE]
					,[CALIBER]
					,[ORIGINAL_LICENSE]
				)
		SELECT
			[IL].[TERMS_OF_TRADE]
			,GETDATE()
			,@LOGIN
			,@LOGIN_NAME
			,'REABASTECIMIENTO'
			,'REABASTECIMIENTO'
			,'N/A'
			,[M].[BARCODE_ID]
			,[M].[MATERIAL_ID]
			,[M].[MATERIAL_NAME]
			,@LICENSE_ID
			,[L].[CURRENT_LOCATION]
			,@LOCATION_ID
			,[L].[CLIENT_OWNER]
			,[VC].[CLIENT_NAME]
			,[IL].[QTY]
			,[L].[CURRENT_WAREHOUSE]
			,@WAREHOUSE_CODE
			,'N/A'
			,[L].[CODIGO_POLIZA]
			,[L].[LICENSE_ID]
			,'COMPLETED'
			,0
			,@WAVE_PICKING_ID
			,@TASK_ID
			,[MSN].[SERIAL]
			,[IL].[BATCH]
			,[IL].[DATE_EXPIRATION]
			,[TCM].[TONE]
			,[TCM].[CALIBER]
			,[L].[LICENSE_ID]
		FROM
			[wms].[OP_WMS_INV_X_LICENSE] [IL]
		INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON ([IL].[LICENSE_ID] = [L].[LICENSE_ID])
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([IL].[MATERIAL_ID] = [M].[MATERIAL_ID])
		INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [VC] ON ([L].[CLIENT_OWNER] = [VC].[CLIENT_CODE])
		LEFT JOIN [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [MSN] ON (
											[IL].[LICENSE_ID] = [MSN].[LICENSE_ID]
											AND [IL].[MATERIAL_ID] = [MSN].[MATERIAL_ID]
											AND [MSN].[STATUS] > 0
											)
		LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON ([IL].[TONE_AND_CALIBER_ID] = [TCM].[TONE_AND_CALIBER_ID])
		WHERE
			[L].[LICENSE_ID] = @LICENSE_ID;

		COMMIT TRANSACTION;

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST('1' AS VARCHAR) [DbData];

	END TRY
	BEGIN CATCH

		PRINT ERROR_MESSAGE();
		IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;
		SELECT
			@ErrorCode = IIF(@@ERROR <> 0, @@ERROR, @ErrorCode);

		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]
			,CAST('' AS VARCHAR) [DbData];
	END CATCH;
END;