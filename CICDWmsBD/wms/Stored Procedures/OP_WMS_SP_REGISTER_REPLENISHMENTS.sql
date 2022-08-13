-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		21-Aug-2018 G-Force@Langosta
-- Description:			    Sp que registra el despacho de reubicación.
--PickingProvider.registerReplenishment
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REGISTER_REPLENISHMENTS] (
		@pLOGIN_ID VARCHAR(25)
		,@pCLIENT_OWNER VARCHAR(25)
		,@pMATERIAL_ID VARCHAR(50)
		,@pMATERIAL_BARCODE VARCHAR(25)
		,@pSOURCE_LICENSE NUMERIC(18, 0)
		,@pSOURCE_LOCATION VARCHAR(25)
		,@pQUANTITY_UNITS NUMERIC(18, 4)
		,@pCODIGO_POLIZA VARCHAR(25)
		,@pWAVE_PICKING_ID NUMERIC(18, 0)
		,@pSERIAL_NUMBER NUMERIC(18, 0)
		,@pTipoUbicacion VARCHAR(25)
		,@pMt2 NUMERIC(18, 2)
		,@pRESULT VARCHAR(300) OUTPUT
		,@pTASK_ID NUMERIC(18, 0) = NULL
		,@LICENSE_DISPATCH_ID INT = 0
	)
AS
BEGIN

	SET NOCOUNT ON;

	DECLARE
		@ErrorMessage NVARCHAR(4000)
		,@ErrorSeverity INT
		,@ErrorState INT
		,@ErrorCode INT
		,@pTASK_IS_PAUSED INT
		,@pTASK_IS_CANCELED INT
		,@pSKUQtyPending NUMERIC(18, 0)
		,@pMATERIAL_ID_LOCAL VARCHAR(50)
		,@pCLIENT_ID_LOCAL VARCHAR(50)
		,@CLIENT_NAME VARCHAR(100)
		,@pINV_AVAILABLE NUMERIC(18, 4)
		,@IS_FROM_SONDA INT
		,@BATCH VARCHAR(50)
		,@DATE_EXPIRATION DATETIME
		,@HANDLE_SERIAL INT
		,@IS_MASTER_PACK INT
		,@TERMS_OF_TRADE VARCHAR(50)
		,@LOGIN_NAME VARCHAR(50)
		,@WAREHOUSE_PARENT VARCHAR(50)
		,@SOURCE_TYPE VARCHAR(50)
		,@TRANSFER_REQUEST_ID INT
		,@TRANS_SUBTYPE VARCHAR(50)
		,@QTY_AVAILABLE_NEW_LICENSE NUMERIC(18, 4)
		,@HANDLE_BATCH INT
		,@ALTERNATE_BARCODE VARCHAR(25)
		,@MATERIAL_NAME VARCHAR(200)
		,@UPDATE_LICENSE INT = 0
		,@VIN VARCHAR(40)
		,@TONE VARCHAR(20)
		,@CALIBER VARCHAR(20)
		,@LAST_LOCATION_SPOT_TARGET VARCHAR(50) 
		,@LOCKED_BY_INTERFACES INT;

	DECLARE	@AVAILABLE_PICKING_LICENSE TABLE (
			[LICENSE_ID] INT
			,[MATERIAL_ID] VARCHAR(50)
			,[QTY_AVAILABLE] DECIMAL(38, 4)
			,[TONE] VARCHAR(20)
			,[CALIBER] VARCHAR(20)
			,[SPOT_TYPE] VARCHAR(25)
			,[USED_MT2] NUMERIC(18, 2)
			,[TASK_SUBTYPE] VARCHAR(25)
			,[IS_DISCRETIONARY] INT
			,[QUANTITY_PENDING] NUMERIC(18, 4)
			,[SERIAL_NUMBER_REQUESTS] NUMERIC
		);
	
		BEGIN TRANSACTION;
		BEGIN TRY
		---------------------------------------------------------------------------------
		-- ASIGNA VALORES A VARIABLES 
		---------------------------------------------------------------------------------

			SELECT TOP 1
				@LOGIN_NAME = [D].[LOGIN_NAME]
			FROM
				[wms].[OP_WMS_FUNC_GETLOGIN_NAME](@pLOGIN_ID) [D];


			SELECT TOP 1
				@pCLIENT_ID_LOCAL = [L].[CLIENT_OWNER]
				,@CLIENT_NAME = [C].[CLIENT_NAME]
			FROM
				[wms].[OP_WMS_LICENSES] [L]
			INNER JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C] ON [C].[CLIENT_CODE] = [L].[CLIENT_OWNER]
			WHERE
				[L].[LICENSE_ID] = @pSOURCE_LICENSE;

			SELECT TOP 1
				@pMATERIAL_ID_LOCAL = [MATERIAL_ID]
				,@HANDLE_SERIAL = ISNULL([M].[SERIAL_NUMBER_REQUESTS],
											0)
				,@IS_MASTER_PACK = ISNULL([M].[IS_MASTER_PACK],
											0)
				,@HANDLE_BATCH = ISNULL([M].[BATCH_REQUESTED], 0)
				,@ALTERNATE_BARCODE = [M].[ALTERNATE_BARCODE]
				,@MATERIAL_NAME = [M].[MATERIAL_NAME]
			FROM
				[wms].[OP_WMS_MATERIALS] [M]
			WHERE
				(
					[M].[BARCODE_ID] = @pMATERIAL_BARCODE
					OR [M].[ALTERNATE_BARCODE] = @pMATERIAL_BARCODE
				)
				AND [M].[CLIENT_OWNER] = @pCLIENT_ID_LOCAL;


			SELECT TOP 1
				@pINV_AVAILABLE = [IL].[QTY]
				,@BATCH = [IL].[BATCH]
				,@DATE_EXPIRATION = [IL].[DATE_EXPIRATION]
				,@TERMS_OF_TRADE = [IL].[TERMS_OF_TRADE]
				,@LOCKED_BY_INTERFACES = [IL].[LOCKED_BY_INTERFACES]
				,@VIN = [IL].[VIN]
			FROM
				[wms].[OP_WMS_INV_X_LICENSE] [IL]
			WHERE
				[IL].[LICENSE_ID] = @pSOURCE_LICENSE
				AND [IL].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL;


			SELECT TOP 1
				@WAREHOUSE_PARENT = ISNULL([WAREHOUSE_PARENT],
											'BODEGA_DEF')
			FROM
				[wms].[OP_WMS_SHELF_SPOTS]
			WHERE
				[LOCATION_SPOT] = @pSOURCE_LOCATION;

			SELECT TOP 1
				@pTASK_IS_CANCELED = [T].[IS_CANCELED]
				,@IS_FROM_SONDA = [T].[IS_FROM_SONDA]
				,@TRANSFER_REQUEST_ID = [T].[TRANSFER_REQUEST_ID]
				,@SOURCE_TYPE = [T].[SOURCE_TYPE]
				,@TRANS_SUBTYPE = [T].[TASK_SUBTYPE]
			FROM
				[wms].[OP_WMS_TASK_LIST] [T]
			WHERE
				[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
				AND [T].[SERIAL_NUMBER] = @pSERIAL_NUMBER;

		---------------------------------------------------------------------------------
		-- VALIDACIONES
		---------------------------------------------------------------------------------  

				IF (@pTASK_IS_CANCELED <> 0)
				BEGIN
					SELECT
						@pRESULT = 'ERROR, Tarea ha sido cancelada, verifique.'
						,@ErrorCode = 1202;
					RAISERROR (@pRESULT, 16, 1);
				END;


				IF @pMATERIAL_ID_LOCAL IS NULL
				BEGIN
					SELECT
						@pRESULT = 'ERROR, SKU Invalido: ['
						+ @pMATERIAL_BARCODE + '/'
						+ @pCLIENT_ID_LOCAL + '] verifique.'
						,@ErrorCode = 1203;
					RAISERROR (@pRESULT, 16, 1);
				END;

				IF (@pINV_AVAILABLE < @pQUANTITY_UNITS)
				BEGIN
					SELECT
						@pRESULT = 'ERROR, Inventario insuficiente['
						+ CONVERT(VARCHAR(20), @pINV_AVAILABLE)
						+ '] en licencia origen: ['
						+ CONVERT(VARCHAR(20), @pSOURCE_LICENSE)
						+ '] verifique.'
						,@ErrorCode = 1201;
					RAISERROR (@pRESULT, 16, 1);
				END;

			---------------------------------------------------------------------------------
			-- INSERTA TRANSACCIÓN DE PICKING
			---------------------------------------------------------------------------------  
				IF @HANDLE_SERIAL = 1
				BEGIN
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
								,[MATERIAL_TYPE]
								,[MATERIAL_COST]
								,[SOURCE_LICENSE]
								,[TARGET_LICENSE]
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
								,[WAVE_PICKING_ID]
								,[TASK_ID]
								,[IS_FROM_SONDA]
								,[BATCH]
								,[DATE_EXPIRATION]
								,[SERIAL]
							)
					SELECT
						@TERMS_OF_TRADE
						,GETDATE()
						,@pLOGIN_ID
						,@LOGIN_NAME
						,'DESPACHO_GENERAL'
						,ISNULL((SELECT TOP 1
										[PARAM_CAPTION]
									FROM
										[wms].[OP_WMS_FUNC_GETTRANS_DESC]('DESPACHO_GENERAL')),
								'DESPACHO GENERAL')
						,NULL
						,@pMATERIAL_BARCODE
						,@pMATERIAL_ID_LOCAL
						,(SELECT TOP 1
								*
							FROM
								[wms].[OP_WMS_FUNC_GETMATERIAL_DESC](@pMATERIAL_BARCODE,
													@pCLIENT_ID_LOCAL))
						,NULL
						,[wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL](@pMATERIAL_ID_LOCAL,
													@pCLIENT_ID_LOCAL)
						,@pSOURCE_LICENSE
						,NULL
						,@pSOURCE_LOCATION
						,'PUERTA_1'
						,@pCLIENT_ID_LOCAL
						,(SELECT TOP 1
								*
							FROM
								[wms].[OP_WMS_FUNC_GETCLIENT_NAME](@pCLIENT_ID_LOCAL))
						,-1
						,@WAREHOUSE_PARENT
						,NULL
						,@TRANS_SUBTYPE
						,@pCODIGO_POLIZA
						,@pSOURCE_LICENSE
						,'PROCESSED'
						,@pWAVE_PICKING_ID
						,@pWAVE_PICKING_ID
						,@IS_FROM_SONDA
						,@BATCH
						,@DATE_EXPIRATION
						,[S].[SERIAL]
					FROM
						[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [S]
					INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [T].[WAVE_PICKING_ID] = [S].[WAVE_PICKING_ID]
													AND [S].[LICENSE_ID] = [T].[LICENSE_ID_SOURCE]
													AND [S].[MATERIAL_ID] = [T].[MATERIAL_ID]
													AND [T].[TASK_ASSIGNEDTO] = [S].[ASSIGNED_TO]
					WHERE
						[T].[TASK_ASSIGNEDTO] = @pLOGIN_ID
						AND [S].[STATUS] = 2
						AND [T].[SERIAL_NUMBER] = @pSERIAL_NUMBER;
						PRINT 'BRE 001'
				END;
				ELSE
				BEGIN
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
								,[MATERIAL_TYPE]
								,[MATERIAL_COST]
								,[SOURCE_LICENSE]
								,[TARGET_LICENSE]
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
								,[WAVE_PICKING_ID]
								,[TASK_ID]
								,[IS_FROM_SONDA]
								,[BATCH]
								,[DATE_EXPIRATION]
								,[SOURCE_TYPE]
								,[TRANSFER_REQUEST_ID]
								,[VIN]
							)
					VALUES
							(
								@TERMS_OF_TRADE
								,GETDATE()
								,@pLOGIN_ID
								,@LOGIN_NAME
								,'DESPACHO_GENERAL'
								,ISNULL((SELECT TOP 1
												[PARAM_CAPTION]
											FROM
												[wms].[OP_WMS_FUNC_GETTRANS_DESC]('DESPACHO_GENERAL')),
										'DESPACHO GENERAL')
								,NULL
								,@pMATERIAL_BARCODE
								,@pMATERIAL_ID_LOCAL
								,(SELECT TOP 1
										*
									FROM
										[wms].[OP_WMS_FUNC_GETMATERIAL_DESC](@pMATERIAL_BARCODE,
													@pCLIENT_ID_LOCAL))
								,NULL
								,[wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL](@pMATERIAL_ID_LOCAL,
													@pCLIENT_ID_LOCAL)
								,@pSOURCE_LICENSE
								,NULL
								,@pSOURCE_LOCATION
								,'PUERTA_1'
								,@pCLIENT_ID_LOCAL
								,@CLIENT_NAME
								,(@pQUANTITY_UNITS * -1)
								,@WAREHOUSE_PARENT
								,NULL
								,@TRANS_SUBTYPE
								,@pCODIGO_POLIZA
								,@pSOURCE_LICENSE
								,'PROCESSED'
								,@pWAVE_PICKING_ID
								,@pWAVE_PICKING_ID
								,@IS_FROM_SONDA
								,@BATCH
								,@DATE_EXPIRATION
								,@SOURCE_TYPE
								,@TRANSFER_REQUEST_ID
								,@VIN
							);
							PRINT 'BRE 002'
				END;

				UPDATE
					[wms].[OP_WMS_INV_X_LICENSE]
				SET	
					[QTY] = [QTY] - @pQUANTITY_UNITS
					,[LAST_UPDATED] = GETDATE()
					,[LAST_UPDATED_BY] = @pLOGIN_ID
				WHERE
					[LICENSE_ID] = @pSOURCE_LICENSE
					AND [MATERIAL_ID] = @pMATERIAL_ID_LOCAL;


				UPDATE
					[wms].[OP_WMS_LICENSES]
				SET	
					[LAST_UPDATED] = GETDATE()
					,[LAST_UPDATED_BY] = @pLOGIN_ID
				WHERE
					[LICENSE_ID] = @pSOURCE_LICENSE;

				IF @pTipoUbicacion = 'PISO'
				BEGIN
					UPDATE
						[wms].[OP_WMS_LICENSES]
					SET	
						[USED_MT2] = [USED_MT2] - @pMt2
					WHERE
						[LICENSE_ID] = @pSOURCE_LICENSE;
				END;

				IF @IS_MASTER_PACK = 1
				BEGIN
					EXEC [wms].[OP_WMS_SP_DISPATCH_MASTER_PACK] @MATERIAL_ID = @pMATERIAL_ID_LOCAL,
						@LICENCE_ID = @pSOURCE_LICENSE,
						@QTY_DISPATCH = @pQUANTITY_UNITS;
				END;
				
				print 'bug'
				print @pSERIAL_NUMBER
				PRINT @pMATERIAL_ID_LOCAL
				PRINT @pQUANTITY_UNITS
				UPDATE
					[wms].[OP_WMS_TASK_LIST]
				SET	
					[QUANTITY_PENDING] = [QUANTITY_PENDING]
					- @pQUANTITY_UNITS
				WHERE
					[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
					AND [SERIAL_NUMBER] = @pSERIAL_NUMBER;



				IF EXISTS ( SELECT TOP 1
								1
							FROM
								[wms].[OP_WMS_TASK_LIST] [T]
							WHERE
								[T].[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
								AND [SERIAL_NUMBER] = @pSERIAL_NUMBER
								AND [T].[QUANTITY_PENDING] = 0 )
				BEGIN
					UPDATE
						[wms].[OP_WMS_TASK_LIST]
					SET	
						[IS_COMPLETED] = 1
						,[COMPLETED_DATE] = GETDATE()
					WHERE
						[MATERIAL_ID] = @pMATERIAL_ID_LOCAL
						AND [SERIAL_NUMBER] = @pSERIAL_NUMBER;

				END;

			---------------------------------------------------------------------------------
			-- Validamos si tiene activado el parametro para agregar productos a la licencia
			---------------------------------------------------------------------------------    
				IF EXISTS ( SELECT TOP 1
								1
							FROM
								[wms].[OP_WMS_PARAMETER] [P]
							WHERE
								[P].[GROUP_ID] = 'REPLENISHMENTS'
								AND [P].[PARAMETER_ID] = 'CREATE_LICENSE_IN_REPLENISHMENTS'
								AND [P].[VALUE] = '1' )
				BEGIN

			  ---------------------------------------------------------------------------------
			  -- Validamos si existe una licencia con la ola de picking del usuario
			  ---------------------------------------------------------------------------------    
					IF EXISTS ( SELECT TOP 1
									1
								FROM
									[wms].[OP_WMS_LICENSES] [L]
								WHERE
									[L].[LICENSE_ID] = @LICENSE_DISPATCH_ID
									AND [L].[CURRENT_LOCATION] = @pLOGIN_ID )
					BEGIN

				---------------------------------------------------------------------------------
				-- Declaramos las variables necesarias
				---------------------------------------------------------------------------------    
						DECLARE
							@LOCATION_SPOT_TARGET VARCHAR(25)
							,@VOLUME_FACTOR NUMERIC(18, 4)
							,@BARCODE_ID VARCHAR(25)
							,@STATUS_CODE VARCHAR(50)
							,@STATUS_NAME VARCHAR(100)
							,@BLOCKS_INVENTORY VARCHAR(50)
							,@ALLOW_REALLOC VARCHAR(50)
							,@TARGET_LOCATION VARCHAR(50) = ''
							,@DESCRIPTION VARCHAR(200)
							,@COLOR VARCHAR(50)
							,@STATUS_ID INT
							,@LOCATION_TARGET VARCHAR(50)
							,@LICENSE_DISPATCH_ID_TEMP INT = NULL;

						DECLARE	@STATUS_TB TABLE (
								[RESULTADO] INT
								,[MENSAJE] VARCHAR(15)
								,[CODIGO] INT
								,[STATUS_ID] INT
							);

				---------------------------------------------------------------------------------
				-- Obtenemos los datos para agregar el producto a la licencia
				---------------------------------------------------------------------------------        
				PRINT 'Obtenemos los datos para agregar el producto a la licencia'+ CAST(@LICENSE_DISPATCH_ID AS VARCHAR)
						SELECT TOP 1
							@LOCATION_TARGET = [TL].[LOCATION_SPOT_TARGET]
						FROM
							[wms].[OP_WMS_TASK_LIST] [TL]
						WHERE
							[TL].[SERIAL_NUMBER] = @pSERIAL_NUMBER;

				---------------------------------------------------------------------------------
				-- Validamos si la licencia de despacho tiene la ubicacion destino igual al que estan enviando para el operador.
				---------------------------------------------------------------------------------        
						IF NOT EXISTS ( SELECT TOP 1
											1
										FROM
											[wms].[OP_WMS_LICENSES] [L]
										WHERE
											[L].[LICENSE_ID] = @LICENSE_DISPATCH_ID
											--AND [L].[TARGET_LOCATION_REPLENISHMENT] = @LOCATION_TARGET
											AND [L].[CURRENT_LOCATION] = @pLOGIN_ID )
						BEGIN
				  ---------------------------------------------------------------------------------
				  -- Si no es igual, buscamos si existe una licencia que tenga esa ubicacion destino
				  ---------------------------------------------------------------------------------        
							SELECT TOP 1
								@LICENSE_DISPATCH_ID_TEMP = [L].[LICENSE_ID]
							FROM
								[wms].[OP_WMS_LICENSES] [L]
							WHERE
								[L].[WAVE_PICKING_ID] = @pWAVE_PICKING_ID
								--AND [L].[TARGET_LOCATION_REPLENISHMENT] = @LOCATION_TARGET
								AND [L].[CURRENT_LOCATION] = @pLOGIN_ID;

				  ---------------------------------------------------------------------------------
				  -- Validamos si encontro una licencia con la ubicacion destino.
				  ---------------------------------------------------------------------------------        
							IF @LICENSE_DISPATCH_ID_TEMP IS NULL
							BEGIN
					---------------------------------------------------------------------------------
					-- Validamos si la licencia de despacho no tiene una ubicacion destino
					---------------------------------------------------------------------------------        
								IF EXISTS ( SELECT TOP 1
												1
											FROM
												[wms].[OP_WMS_LICENSES] [L]
											WHERE
												[L].[LICENSE_ID] = @LICENSE_DISPATCH_ID
												AND [L].[CURRENT_LOCATION] = @pLOGIN_ID
												AND (
													[L].[TARGET_LOCATION_REPLENISHMENT] IS NULL
													OR [L].[TARGET_LOCATION_REPLENISHMENT] = ''
													) )
								BEGIN
					  ---------------------------------------------------------------------------------
					  -- Si no la tiene actualizamos la ubicacion destiono para que sea esta.
					  ---------------------------------------------------------------------------------        
									UPDATE
										[wms].[OP_WMS_LICENSES]
									SET	
										[TARGET_LOCATION_REPLENISHMENT] = @LOCATION_TARGET
									WHERE
										[LICENSE_ID] = @LICENSE_DISPATCH_ID;
								END;
								ELSE
								BEGIN
					  ---------------------------------------------------------------------------------
					  -- Retornamos el error para que el operador cree la licenica
					  ---------------------------------------------------------------------------------        
									SELECT
										@ErrorCode = 3050;
									RAISERROR ('No existe una licencia con la ubicación destino enviada, por favor crear otra licencia.', 16, 1);
									RETURN;
								END;
							END;
							ELSE
							BEGIN
					---------------------------------------------------------------------------------
					-- Establecemos la licencia encontrada a la variable que se utiliza en los demas.
					---------------------------------------------------------------------------------      
								-- ------------------------------------------------------------------------------------
								-- Si la licencia que viene como parámetro no tiene inventario no asignamos la licencia encontrada con el algoritmo
								-- ------------------------------------------------------------------------------------  
								IF EXISTS ( SELECT TOP 1
												1
											FROM
												[wms].[OP_WMS_INV_X_LICENSE]
											WHERE
												[LICENSE_ID] = @LICENSE_DISPATCH_ID )
								BEGIN
									SET @LICENSE_DISPATCH_ID = @LICENSE_DISPATCH_ID_TEMP;
								END;
								ELSE
								BEGIN
									-- ------------------------------------------------------------------------------------
									-- la licencia no tiene inventario actualizamos la ubicacion destino si esta en null
									-- ------------------------------------------------------------------------------------
									IF EXISTS ( SELECT TOP 1
													1
												FROM
													[wms].[OP_WMS_LICENSES] [L]
												WHERE
													[L].[LICENSE_ID] = @LICENSE_DISPATCH_ID
													AND [L].[CURRENT_LOCATION] = @pLOGIN_ID
													AND (
													[L].[TARGET_LOCATION_REPLENISHMENT] IS NULL
													OR [L].[TARGET_LOCATION_REPLENISHMENT] = ''
													) )
									BEGIN
					  ---------------------------------------------------------------------------------
					  -- Si no la tiene actualizamos la ubicacion destiono para que sea esta.
					  ---------------------------------------------------------------------------------        
										UPDATE
											[wms].[OP_WMS_LICENSES]
										SET	
											[TARGET_LOCATION_REPLENISHMENT] = @LOCATION_TARGET
										WHERE
											[LICENSE_ID] = @LICENSE_DISPATCH_ID;
									END;
								END;

					---------------------------------------------------------------------------------
					-- Actualizamos la fecha y operado que modifico la licencia.
					---------------------------------------------------------------------------------        
								UPDATE
									[wms].[OP_WMS_LICENSES]
								SET	
									[LAST_UPDATED] = GETDATE()
									,[LAST_UPDATED_BY] = @pLOGIN_ID
								WHERE
									[LICENSE_ID] = @LICENSE_DISPATCH_ID;

							END;
						END;


						SELECT TOP 1
							@LOCATION_SPOT_TARGET = [TL].[LOCATION_SPOT_TARGET]
						FROM
							[wms].[OP_WMS_TASK_LIST] [TL]
						WHERE
							[TL].[SERIAL_NUMBER] = @pSERIAL_NUMBER;
				----
						SELECT TOP 1
							@VOLUME_FACTOR = [M].[VOLUME_FACTOR]
							,@BARCODE_ID = [M].[BARCODE_ID]
						FROM
							[wms].[OP_WMS_MATERIALS] [M]
						WHERE
							[M].[MATERIAL_ID] = @pMATERIAL_ID;
				----
						SELECT
							@TONE = [TCM].[TONE]
							,@CALIBER = [TCM].[CALIBER]
						FROM
							[wms].[OP_WMS_INV_X_LICENSE] [L]
						INNER JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON ([L].[TONE_AND_CALIBER_ID] = [TCM].[TONE_AND_CALIBER_ID])
						WHERE
							[L].[LICENSE_ID] = @pSOURCE_LICENSE
							AND [L].[MATERIAL_ID] = @pMATERIAL_ID;
				----
						SELECT TOP 1
							@STATUS_CODE = [PARAM_NAME]
							,@STATUS_NAME = [PARAM_CAPTION]
							,@BLOCKS_INVENTORY = CASE [SPARE1]
													WHEN 'SI' THEN 1
													WHEN '1' THEN 1
													ELSE 0
													END
							,@ALLOW_REALLOC = CASE [SPARE2]
												WHEN 'SI' THEN 1
												WHEN '1' THEN 1
												ELSE 0
												END
							,@TARGET_LOCATION = [SPARE3]
							,@DESCRIPTION = [TEXT_VALUE]
							,@COLOR = [COLOR]
						FROM
							[wms].[OP_WMS_CONFIGURATIONS]
						WHERE
							[PARAM_TYPE] = 'ESTADO'
							AND [PARAM_GROUP] = 'ESTADOS'
							AND [NUMERIC_VALUE] = 1;

				---------------------------------------------------------------------------------
				-- Validamos si la licencia con el producto ya fue ingresada
				---------------------------------------------------------------------------------    
						IF EXISTS ( SELECT TOP 1
										1
									FROM
										[wms].[OP_WMS_INV_X_LICENSE] [IL]
									WHERE
										[IL].[LICENSE_ID] = @LICENSE_DISPATCH_ID
										AND [IL].[MATERIAL_ID] = @pMATERIAL_ID )
						BEGIN


							IF @TRANSFER_REQUEST_ID IS NOT NULL
							BEGIN
					---------------------------------------------------------------------------------
					-- Validamos si el producto maneja lote y si ya fue ingresado el producto a la licencia
					---------------------------------------------------------------------------------    
								IF EXISTS ( SELECT TOP 1
												1
											FROM
												[wms].[OP_WMS_INV_X_LICENSE] [IL]
											INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([IL].[MATERIAL_ID] = [M].[MATERIAL_ID])
											WHERE
												[IL].[LICENSE_ID] = @LICENSE_DISPATCH_ID
												AND [IL].[MATERIAL_ID] = @pMATERIAL_ID
												AND (
													[IL].[DATE_EXPIRATION] <> @DATE_EXPIRATION
													OR [IL].[BATCH] <> @BATCH
													)
												AND [M].[BATCH_REQUESTED] = 1 )
								BEGIN
									SELECT
										@ErrorCode = 3001;
									RAISERROR ('Ya existe un producto con ese lote, debe de crear otra licencia.', 16, 1);
									RETURN;
								END;

					---------------------------------------------------------------------------------
					-- Validamos si el producto maneja tono o calibre y si ya fue ingresado el producto a la licencia
					---------------------------------------------------------------------------------    
								IF EXISTS ( SELECT TOP 1
												1
											FROM
												[wms].[OP_WMS_INV_X_LICENSE] [IL]
											INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([IL].[MATERIAL_ID] = [M].[MATERIAL_ID])
											INNER JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON ([IL].[TONE_AND_CALIBER_ID] = [TCM].[TONE_AND_CALIBER_ID])
											WHERE
												[IL].[LICENSE_ID] = @LICENSE_DISPATCH_ID
												AND [IL].[MATERIAL_ID] = @pMATERIAL_ID
												AND (
													[M].[HANDLE_TONE] = 1
													OR [M].[HANDLE_CALIBER] = 1
													)
												AND (
													[TCM].[TONE] <> @TONE
													OR [TCM].[CALIBER] <> @CALIBER
													) )
								BEGIN
									SELECT
										@ErrorCode = 3002;
									RAISERROR ('Ya existe un producto con ese tono o calibre, debe de crear otra licencia.', 16, 1);
									RETURN;
								END;
							END;

					-----------------------------------------------------------------------------------------------------------------------------
					-- Validamos que el location spot target del material registrado sea el mismo que los materiales ya registrados en la licencia
					----------------------------------------------------------------------------------------------------------------------------- 
					
					SELECT TOP 1 @LAST_LOCATION_SPOT_TARGET = LOCATION_SPOT_TARGET FROM wms.OP_WMS_VIEW_TASK WHERE WAVE_PICKING_ID = @pWAVE_PICKING_ID AND MATERIAL_ID = (
							SELECT TOP 1 MATERIAL_ID FROM wms.OP_WMS_INV_X_LICENSE WHERE LICENSE_ID = @LICENSE_DISPATCH_ID)

							PRINT @LAST_LOCATION_SPOT_TARGET
							PRINT @LOCATION_SPOT_TARGET
							IF(@LAST_LOCATION_SPOT_TARGET IS NOT NULL AND @LAST_LOCATION_SPOT_TARGET <> @LOCATION_SPOT_TARGET)
							BEGIN
								SELECT
										@ErrorCode = 5008;
									RAISERROR ('La última ubicación de destino y la actual no coinciden, por favor cree otra licencia', 16, 1);
									RETURN;
							END

				  ---------------------------------------------------------------------------------
				  -- Actualizamos el producto ya verificado antes que todos los campos sean iguales
				  ---------------------------------------------------------------------------------    
							UPDATE
								[wms].[OP_WMS_INV_X_LICENSE]
							SET	
								[QTY] = [QTY] + @pQUANTITY_UNITS
							WHERE
								[LICENSE_ID] = @LICENSE_DISPATCH_ID
								AND [MATERIAL_ID] = @pMATERIAL_ID;
						END;
						ELSE
						BEGIN
				  ---------------------------------------------------------------------------------
				  -- Insertamos el nuevo estado para el nuevo producto.
				  ---------------------------------------------------------------------------------

							INSERT	[wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE]
									(
										[STATUS_CODE]
										,[STATUS_NAME]
										,[BLOCKS_INVENTORY]
										,[ALLOW_REALLOC]
										,[TARGET_LOCATION]
										,[DESCRIPTION]
										,[COLOR]
										,[LICENSE_ID]
									)
							VALUES
									(
										@STATUS_CODE
										,@STATUS_NAME
										,@BLOCKS_INVENTORY
										,@ALLOW_REALLOC
										,@TARGET_LOCATION
										,@DESCRIPTION
										,@COLOR
										,@LICENSE_DISPATCH_ID
									);
							PRINT 'BRE 003'
							SET @STATUS_ID = SCOPE_IDENTITY();

							--select top 100 * from wms.OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE where STATUS_ID = @STATUS_ID
				  ---------------------------------------------------------------------------------
				  -- Declaramos las variables necesarias
				  ---------------------------------------------------------------------------------    
							DECLARE	@TONE_AND_CALIBER_ID INT = NULL;

				  ---------------------------------------------------------------------------------
				  -- Validamos si el producto manje tono o calibre
				  ---------------------------------------------------------------------------------    
							IF EXISTS ( SELECT TOP 1
											1
										FROM
											[wms].[OP_WMS_MATERIALS] [M]
										WHERE
											[M].[MATERIAL_ID] = @pMATERIAL_ID
											AND (
													[M].[HANDLE_TONE] = 1
													OR [M].[HANDLE_CALIBER] = 1
												) )
							BEGIN

					---------------------------------------------------------------------------------
					-- Obtenemos el id si existe el tono y calibre con ese producto
					---------------------------------------------------------------------------------    
								SELECT
									@TONE_AND_CALIBER_ID = [TCM].[TONE_AND_CALIBER_ID]
								FROM
									[wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM]
								WHERE
									[TCM].[MATERIAL_ID] = @pMATERIAL_ID
									AND [TCM].[TONE] = @TONE
									AND [TCM].[CALIBER] = @CALIBER;
							END;

				  ---------------------------------------------------------------------------------
				  -- Insertamos el inventario para la licencia de despacho
				  print 'hola'

							INSERT	INTO [wms].[OP_WMS_INV_X_LICENSE]
									(
										[LICENSE_ID]
										,[MATERIAL_ID]
										,[MATERIAL_NAME]
										,[QTY]
										,[VOLUME_FACTOR]
										,[WEIGTH]
										,[SERIAL_NUMBER]
										,[COMMENTS]
										,[LAST_UPDATED]
										,[LAST_UPDATED_BY]
										,[BARCODE_ID]
										,[TERMS_OF_TRADE]
										,[STATUS]
										,[CREATED_DATE]
										,[DATE_EXPIRATION]
										,[BATCH]
										,[ENTERED_QTY]
										,[VIN]
										,[HANDLE_SERIAL]
										,[IS_EXTERNAL_INVENTORY]
										,[IS_BLOCKED]
										,[BLOCKED_STATUS]
										,[STATUS_ID]
										,[TONE_AND_CALIBER_ID]
										,[LOCKED_BY_INTERFACES]
									)
							VALUES
									(
										@LICENSE_DISPATCH_ID
										,@pMATERIAL_ID
										,@MATERIAL_NAME
										,@pQUANTITY_UNITS
										,@VOLUME_FACTOR
										,0
										,'N/A'
										,'N/A'
										,GETDATE()
										,@pLOGIN_ID
										,@BARCODE_ID
										,@TERMS_OF_TRADE
										,''
										,GETDATE()
										,@DATE_EXPIRATION
										,@BATCH
										,@pQUANTITY_UNITS
										,@VIN
										,@HANDLE_SERIAL
										,0
										,0
										,NULL
										,@STATUS_ID
										,@TONE_AND_CALIBER_ID
										,@LOCKED_BY_INTERFACES
									);
									--select * from wms.OP_WMS_INV_X_LICENSE where LICENSE_ID = @LICENSE_DISPATCH_ID
									PRINT 'BRE 004'
						END;

				---------------------------------------------------------------------------------
				-- Validamos si el producto maneja master pack
				---------------------------------------------------------------------------------    
						IF EXISTS ( SELECT TOP 1
										1
									FROM
										[wms].[OP_WMS_MATERIALS] [M]
									WHERE
										[M].[MATERIAL_ID] = @pMATERIAL_ID
										AND [M].[IS_MASTER_PACK] = 1 )
						BEGIN
				  ---------------------------------------------------------------------------------
				  -- Declaramos las vaaribles necesarias
				  ---------------------------------------------------------------------------------    
							DECLARE
								@MASTER_PACK_HEADER_ID_SOURCE INT
								,@MASTER_PACK_HEADER_ID INT;

							PRINT 'Licencia';
							PRINT @pSOURCE_LICENSE;
							SELECT TOP 1
								@MASTER_PACK_HEADER_ID_SOURCE = [MPH].[MASTER_PACK_HEADER_ID]
							FROM
								[wms].[OP_WMS_MASTER_PACK_HEADER] [MPH]
							WHERE
								[MPH].[LICENSE_ID] = @pSOURCE_LICENSE AND [MPH].MATERIAL_ID = @pMATERIAL_ID; ;
				  ---------------------------------------------------------------------------------
				  -- Validamos si el ya se ingreso el master pack herdader 
				  ---------------------------------------------------------------------------------    
							IF EXISTS ( SELECT TOP 1
											1
										FROM
											[wms].[OP_WMS_MASTER_PACK_HEADER] [MPH]
										WHERE
											[MPH].[LICENSE_ID] = @LICENSE_DISPATCH_ID )
							BEGIN
					---------------------------------------------------------------------------------
					-- Actualizamos la cantidad del master pack
					---------------------------------------------------------------------------------    
								UPDATE
									[MPH]
								SET	
									[MPH].[QTY] = [MPH].[QTY]
									+ @pQUANTITY_UNITS
								FROM
									[wms].[OP_WMS_MASTER_PACK_HEADER] [MPH]
								WHERE
									[MPH].[LICENSE_ID] = @LICENSE_DISPATCH_ID;
							END;
							ELSE
							BEGIN
					---------------------------------------------------------------------------------
					-- Insertamos el master pack header
					---------------------------------------------------------------------------------    
								INSERT	[wms].[OP_WMS_MASTER_PACK_HEADER]
										(
											[LICENSE_ID]
											,[MATERIAL_ID]
											,[POLICY_HEADER_ID]
											,[LAST_UPDATED]
											,[LAST_UPDATE_BY]
											,[EXPLODED]
											,[EXPLODED_DATE]
											,[RECEPTION_DATE]
											,[IS_AUTHORIZED]
											,[ATTEMPTED_WITH_ERROR]
											,[IS_POSTED_ERP]
											,[POSTED_ERP]
											,[POSTED_RESPONSE]
											,[ERP_REFERENCE]
											,[ERP_REFERENCE_DOC_NUM]
											,[QTY]
											,[IS_IMPLOSION]
										)
								SELECT TOP 1
									@LICENSE_DISPATCH_ID
									,[MPH].[MATERIAL_ID]
									,[MPH].[POLICY_HEADER_ID]
									,GETDATE()
									,@pLOGIN_ID
									,[MPH].[EXPLODED]
									,[MPH].[EXPLODED_DATE]
									,GETDATE()
									,[MPH].[IS_AUTHORIZED]
									,[MPH].[ATTEMPTED_WITH_ERROR]
									,[MPH].[IS_POSTED_ERP]
									,[MPH].[POSTED_ERP]
									,[MPH].[POSTED_RESPONSE]
									,[MPH].[ERP_REFERENCE]
									,[MPH].[ERP_REFERENCE_DOC_NUM]
									,@pQUANTITY_UNITS
									,[MPH].[IS_IMPLOSION]
								FROM
									[wms].[OP_WMS_MASTER_PACK_HEADER] [MPH]
								WHERE
									[MPH].[LICENSE_ID] = @pSOURCE_LICENSE AND [MPH].MATERIAL_ID = @pMATERIAL_ID;
									PRINT 'BRE 005'
									print  @pSOURCE_LICENSE
									print ' @pSOURCE_LICENSE'

									--select * from [wms].[OP_WMS_MASTER_PACK_HEADER] where LICENSE_ID = @LICENSE_DISPATCH_ID
					---------------------------------------------------------------------------------
					-- Obtenemos el master pack header generado
					---------------------------------------------------------------------------------    
								SELECT
									@MASTER_PACK_HEADER_ID = SCOPE_IDENTITY();


								INSERT	INTO [wms].[OP_WMS_MASTER_PACK_DETAIL]
										(
											[MASTER_PACK_HEADER_ID]
											,[MATERIAL_ID]
											,[QTY]
											,[BATCH]
											,[DATE_EXPIRATION]
										)
								SELECT
									@MASTER_PACK_HEADER_ID
									,[MPDSS].[MATERIAL_ID]
									,[MPDSS].[QTY]
									,[MPDSS].[BATCH]
									,[MPDSS].[DATE_EXPIRATION]
								FROM
									[wms].[OP_WMS_MASTER_PACK_DETAIL] [MPDSS]
								WHERE
									[MPDSS].[MASTER_PACK_HEADER_ID] = @MASTER_PACK_HEADER_ID_SOURCE;
							PRINT 'BRE 006'
							END;
						END;
					END;
				END;

				EXEC [wms].[OP_WMS_SP_PICKING_HAS_BEEN_COMPLETED] @WAVE_PICKING_ID = @pWAVE_PICKING_ID, -- int
					@LOGIN = @pLOGIN_ID; -- varchar(50)
		
				---------------------------------------------------------------------------------
				-- Se validad si en la ubicación se permi
				--------------------------------------------------------------------------------- 
				print @IS_MASTER_PACK
				IF EXISTS(SELECT TOP 1 1 FROM [wms].[OP_WMS_SHELF_SPOTS] [SSPOTS] INNER JOIN [OP_WMS_ALZA].[wms].[OP_WMS_ZONE] [ZW] ON SSPOTS.[ZONE] = ZW.[ZONE] 
					WHERE ZW.RECEIVE_EXPLODED_MATERIALS = 1 AND LOCATION_SPOT = @LOCATION_SPOT_TARGET)
				BEGIN
				PRINT @LICENSE_DISPATCH_ID
					PRINT @pMATERIAL_ID
					PRINT @pLOGIN_ID
					PRINT 'BRE 006.5'
					--EXEC [wms].[OP_WMS_EXPLODE_MASTER_PACK] @LICENSE_ID = @LICENSE_DISPATCH_ID, 
					--										@MATERIAL_ID = @pMATERIAL_ID, 
					--										@LAST_UPDATE_BY = @pLOGIN_ID
					PRINT 'BRE 007'
					
				END

				--------------------------------------------------------------------------------- 
				--------------------------------------------------------------------------------- 
				COMMIT TRANSACTION;	
				SELECT
					@pRESULT = 'OK';

				SELECT
				1 AS [Resultado]
				,'Proceso Exitoso' [Mensaje]
				,0 [Codigo]
				,CAST(@LICENSE_DISPATCH_ID AS VARCHAR) [DbData];	
			
		END TRY
		BEGIN CATCH
	PRINT ERROR_MESSAGE()		
	IF(@@ERROR <> 0) ROLLBACK TRANSACTION;
			SELECT
				@ErrorCode = IIF(@@ERROR <> 0, @@ERROR, @ErrorCode);
			SELECT
				-1 AS [Resultado]
				,ERROR_MESSAGE() AS [Mensaje]
				,@ErrorCode AS [Codigo]
				,'' AS [DbData];

			SELECT
				@pRESULT = ERROR_MESSAGE();

		END CATCH;
	
END;