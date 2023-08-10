-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	10/21/2017 @ Reborn - TEAM Sprint Drache
-- Description:			SP que genera las tareas de entrega para Sonda SD

-- Modificacion 11/7/2017 @ Reborn - Team Sprint Eberhard
					-- diego.as
					-- Se agrega funcionalidad de generacion de tareas para multiples manifiestos

-- Modificacion 12/8/2017 @ Reborn-Team Sprint Pannen
					-- diego.as
					-- Se modifica ordenamiento de tareas para que tome como punto gps el del ultimo cliente procesado

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GENERATE_DELIVERY_PLAN_FROM_MANIFEST_3PL] @MANIFEST_HADER_ID = 2145, @LOGIN_ID = 'ADOLFO@SONDA', @CURRENT_GPS_USER = '14.64986000,-90.53980000'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GENERATE_DELIVERY_PLAN_FROM_MANIFEST_3PL]
	(
		@MANIFEST_HADER_ID INT
		,@LOGIN_ID VARCHAR(25)
		,@CURRENT_GPS_USER VARCHAR(50)
	) WITH RECOMPILE
AS 
	BEGIN
		--
		SET NOCOUNT ON;
		
		--
		DECLARE
			@DATABASE_NAME VARCHAR(MAX)
			,@SCHEMA_NAME VARCHAR(MAX)
			,@QUERY VARCHAR(MAX)
			,@CLIENT_CODE VARCHAR(50)
			,@TASK_ID INT
			,@TASK_STATUS VARCHAR(50)
			,@GPS_WAREHOUSE VARCHAR(50)
			,@GPS_TEMP VARCHAR(50)
			,@QTY_COMPLETED_TASKS INT = 0
			,@LAST_TASK_SEQ INT = 1;
		
		--
		CREATE TABLE [#CLIENTS_IN_MANIFEST]
			(
				[ID] INT IDENTITY(1 ,1)
				,[TASK_ID] INT
				,[CLIENT_CODE] VARCHAR(50)
				,[CLIENT_NAME] VARCHAR(250)
				,[ADDRESS_CUSTOMER] VARCHAR(250)
				,[TASK_STATUS] VARCHAR(50)
				,PRIMARY KEY ([CLIENT_CODE])
			);
		--
		CREATE TABLE [#CLIENTS_IN_TASKS]
			(
				[ID] INT IDENTITY(1 ,1)
				,[TASK_ID] INT
				,[CLIENT_CODE] VARCHAR(50)
				,[CLIENT_NAME] VARCHAR(250)
				,[ADDRESS_CUSTOMER] VARCHAR(250)
				,[TASK_STATUS] VARCHAR(50)
				,PRIMARY KEY ([CLIENT_CODE])
			);

		--
		CREATE TABLE [#CLIENTS_FILTERED]
			(
				[ID] INT IDENTITY(1 ,1)
				,[TASK_ID] INT DEFAULT 0
				,[CLIENT_CODE] VARCHAR(50)
				,[CLIENT_NAME] VARCHAR(250)
				,[ADDRESS_CUSTOMER] VARCHAR(250)
				,[TASK_STATUS] VARCHAR(50)
				,PRIMARY KEY ([CLIENT_CODE])
			);
		--
		CREATE TABLE [#CLIENTS_FOR_OPTIMIZATION]
			(
				[CLIENT_CODE] VARCHAR(50)
				,GPS VARCHAR(MAX)
				,DISTANCE NUMERIC(18,6)
				,TASK_ID INT
			);
		
		--
		CREATE NONCLUSTERED INDEX [IDX_TEMP_CODE_CUSTOMER]
		ON [#CLIENTS_IN_TASKS]([CLIENT_CODE])
		INCLUDE(
			[TASK_ID]
			,[CLIENT_NAME]
			,[ADDRESS_CUSTOMER]
			,[TASK_STATUS]
		);

		--
		CREATE NONCLUSTERED INDEX [IDX_TEMP_CODE_CUSTOMER]
		ON [#CLIENTS_IN_MANIFEST]([CLIENT_CODE])
		INCLUDE(
			[TASK_ID]
			,[CLIENT_NAME]
			,[ADDRESS_CUSTOMER]
			,[TASK_STATUS]
		);
		
		--
		BEGIN TRANSACTION [INSERT_TASK];
		--
		BEGIN TRY
		
		-- ---------------------------------------------------------------------------------------------------------
		-- Se obtiene el GPS inicial de la ruta, si el vendedor no tiene uno asociado, entiendase ('', null, '0,0'),
		-- entonces se toma el del centro de distribucion al que pertenece su bodega de venta
		-- ---------------------------------------------------------------------------------------------------------
		SELECT 
			@GPS_WAREHOUSE = CASE 
				WHEN SS.[GPS] IS NULL THEN (CONVERT(VARCHAR,DC.[LATITUDE]) + ',' + CONVERT(VARCHAR, DC.[LONGITUDE]))
				WHEN SS.GPS = '' THEN (CONVERT(VARCHAR, DC.[LATITUDE]) + ',' + CONVERT(VARCHAR,DC.[LONGITUDE]))
				WHEN SS.[GPS] = '0,0' THEN (CONVERT(VARCHAR,DC.[LATITUDE]) + ',' + CONVERT(VARCHAR,DC.[LONGITUDE]))
				ELSE SS.GPS
			END
		FROM [SONDA].[SWIFT_SELLER] AS SS
		INNER JOIN [SONDA].[USERS] AS U
		ON (U.[RELATED_SELLER] = SS.[SELLER_CODE])
		INNER JOIN [SONDA].[SWIFT_DISTRIBUTION_CENTER] AS DC
		ON (U.[DISTRIBUTION_CENTER_ID] = DC.[DISTRIBUTION_CENTER_ID])
		INNER JOIN [SONDA].[SWIFT_WAREHOUSE_X_DISTRIBUTION_CENTER] AS WXD
		ON ([WXD].[DISTRIBUTION_CENTER_ID] = DC.[DISTRIBUTION_CENTER_ID] AND WXD.[CODE_WAREHOUSE] = U.[DEFAULT_WAREHOUSE])
		WHERE U.[LOGIN] = @LOGIN_ID

		-- -----------------------------------------------------------------------------------------------------------------
		-- Se valida si hay alguna tarea completada
		-- -----------------------------------------------------------------------------------------------------------------
		SELECT 
			@QTY_COMPLETED_TASKS = COUNT(TASK_ID)
			,@LAST_TASK_SEQ = MAX([TASK_SEQ])
		FROM [SONDA].[SWIFT_TASKS] 
		WHERE [TASK_TYPE] = 'DELIVERY_SD' 
			AND [TASK_DATE] = CONVERT(DATE,GETDATE()) 
			AND [TASK_STATUS] ='COMPLETED' 
			AND [ASSIGEND_TO] = @LOGIN_ID
		
		--
		IF (@QTY_COMPLETED_TASKS > 0 ) BEGIN
			IF(@CURRENT_GPS_USER IS NOT NULL AND @CURRENT_GPS_USER <> '0,0') BEGIN
				SET @GPS_WAREHOUSE = @CURRENT_GPS_USER
			END
		END
		ELSE BEGIN
			SET @LAST_TASK_SEQ = 1;
		END


		-- -----------------------------------------------------------------------
		-- Se obtiene el nombre de la BD y el Esquema de la implementacion de 3PL
		-- -----------------------------------------------------------------------
			SELECT
				@DATABASE_NAME = [S].[DATABASE_NAME]
				,@SCHEMA_NAME = [S].[SCHEMA_NAME]
			FROM
				[SONDA].[SWIFT_SETUP_EXTERNAL_SOURCE] AS [S]
			WHERE
				[S].[EXTERNAL_SOURCE_ID] > 0;

		-- ---------------------------------------------------------------------------------
		-- Se obtienen los distintos clientes para generar las tareas de entrega de Sonda SD
		-- ---------------------------------------------------------------------------------
			SELECT
				@QUERY = '	
		SELECT DISTINCT NULL, CLIENT_CODE, CLIENT_NAME, ADDRESS_CUSTOMER, NULL
		FROM ' + @DATABASE_NAME + '.' + @SCHEMA_NAME + '.OP_WMS_MANIFEST_DETAIL 
		WHERE MANIFEST_HEADER_ID = ' + CAST(@MANIFEST_HADER_ID AS VARCHAR) + '
		';
		
		--
			INSERT	INTO [#CLIENTS_IN_MANIFEST]
					EXEC (
							@QUERY
						);
		--
			INSERT	INTO [#CLIENTS_IN_TASKS]
					(
						[TASK_ID]
						,[CLIENT_CODE]
						,[CLIENT_NAME]
						,[ADDRESS_CUSTOMER]
						,[TASK_STATUS]
					)
			SELECT
				[TASK_ID]
				,[COSTUMER_CODE]
				,[COSTUMER_NAME]
				,[TASK_ADDRESS]
				,[TASK_STATUS]
			FROM
				[SONDA].[SWIFT_TASKS]
			WHERE
				[ASSIGEND_TO] = @LOGIN_ID
				AND [TASK_DATE] = CONVERT(DATE ,GETDATE())
				AND [TASK_TYPE] = 'DELIVERY_SD';
		--
		
			INSERT	INTO [#CLIENTS_FILTERED]
					(
						[TASK_ID]
						,[CLIENT_CODE]
						,[CLIENT_NAME]
						,[ADDRESS_CUSTOMER]
						,[TASK_STATUS]
					)
			SELECT
				[TASK_ID]
				,[CLIENT_CODE]
				,[CLIENT_NAME]
				,[ADDRESS_CUSTOMER]
				,[TASK_STATUS]
			FROM
				[#CLIENTS_IN_TASKS] AS [TIC]
			WHERE
				[TIC].[CLIENT_CODE] IN (SELECT
											[CLIENT_CODE]
										FROM
											[#CLIENTS_IN_MANIFEST]);

		--

			INSERT	INTO [#CLIENTS_FILTERED]
					(
						[TASK_ID]
						,[CLIENT_CODE]
						,[CLIENT_NAME]
						,[ADDRESS_CUSTOMER]
						,[TASK_STATUS]
					)
			SELECT
				[TASK_ID]
				,[CLIENT_CODE]
				,[CLIENT_NAME]
				,[ADDRESS_CUSTOMER]
				,[TASK_STATUS]
			FROM
				[#CLIENTS_IN_TASKS] AS [TIC]
			WHERE
				[TIC].[CLIENT_CODE] NOT IN (SELECT
												[CLIENT_CODE]
											FROM
												[#CLIENTS_IN_MANIFEST])
			AND [TIC].[TASK_STATUS] <> 'COMPLETED';

		--

			INSERT	INTO [#CLIENTS_FILTERED]
					(
						[CLIENT_CODE]
						,[CLIENT_NAME]
						,[ADDRESS_CUSTOMER]
					)
			SELECT
				[CLIENT_CODE]
				,[CLIENT_NAME]
				,[ADDRESS_CUSTOMER]
			FROM
				[#CLIENTS_IN_MANIFEST] AS [TIC]
			WHERE
				[TIC].[CLIENT_CODE] NOT IN (SELECT
												[CLIENT_CODE]
											FROM
												[#CLIENTS_IN_TASKS]);


		INSERT INTO [#CLIENTS_FOR_OPTIMIZATION]
				([CLIENT_CODE]
				,[GPS]
				,[DISTANCE]
				)
		SELECT 
			VAC.[CODE_CUSTOMER]
			,VAC.[GPS]
			,DBO.[SONDA_FN_CALCULATE_DISTANCE](@GPS_WAREHOUSE,VAC.[GPS])
		FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] AS VAC
		INNER JOIN [#CLIENTS_FILTERED] AS CF
		ON (CF.[CLIENT_CODE] = VAC.[CODE_CUSTOMER])

		-- ---------------------------------------------------------------------------------
		-- Se borran las tareas generadas para el dia actual
		-- ---------------------------------------------------------------------------------
			DELETE FROM
				[SONDA].[SWIFT_TASKS]
			WHERE
				[ASSIGEND_TO] = @LOGIN_ID
				AND [TASK_DATE] = CONVERT(DATE ,GETDATE())
				AND [TASK_STATUS] <> 'COMPLETED'
				AND TASK_ID > 0;
			--
			WHILE EXISTS ( SELECT TOP 1
								1
							FROM
								[#CLIENTS_FILTERED] )
			BEGIN
			--
				SELECT TOP 1
					@CLIENT_CODE = [CLIENT_CODE]
					,@TASK_ID = [TASK_ID]
					,@TASK_STATUS = [TASK_STATUS]
				FROM
					[#CLIENTS_FILTERED]; 

				-- ----------------------------------------------------------------------
				-- Si el cliente no tiene tarea se le crea una
				-- ----------------------------------------------------------------------
				IF (@TASK_ID = 0)
				BEGIN
					INSERT	INTO [SONDA].[SWIFT_TASKS]
							(
								[TASK_TYPE]
								,[TASK_DATE]
								,[SCHEDULE_FOR]
								,[CREATED_STAMP]
								,[ASSIGEND_TO]
								,[ASSIGNED_BY]
								,[ASSIGNED_STAMP]
								,[EXPECTED_GPS]
								,[TASK_STATUS]
								,[TASK_COMMENTS]
								,[TASK_SEQ]
								,[COSTUMER_CODE]
								,[COSTUMER_NAME]
								,[CUSTOMER_PHONE]
								,[TASK_ADDRESS]
								,[IN_PLAN_ROUTE]
								,[CREATE_BY]
								,[ALLOW_STORAGE_ON_DIFF]
							)
					SELECT
						'DELIVERY_SD'
						,GETDATE()
						,GETDATE()
						,GETDATE()
						,@LOGIN_ID
						,'Escaneo de manifiesto'
						,GETDATE()
						,COALESCE([VC].[GPS] ,'0,0')
						,'ASSIGNED'
						,'Tarea de entrega para Sonda SD'
						,[T].[ID]
						,[T].[CLIENT_CODE]
						,ISNULL([T].[CLIENT_NAME] ,'...')
						,COALESCE([VC].[PHONE_CUSTOMER] ,'No tiene telefono') [PHONE_CUSTOMER]
						,COALESCE([T].[ADDRESS_CUSTOMER] ,'No tiene direccion') [ADRESS_CUSTOMER]
						,1
						,'BY_MANIFEST_3PL'
						,0
					FROM
						[#CLIENTS_FILTERED] [T]
					INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [VC]
					ON	[VC].[CODE_CUSTOMER] = [T].[CLIENT_CODE]
					WHERE
						[T].[CLIENT_CODE] = @CLIENT_CODE;
					--
					UPDATE [#CLIENTS_FOR_OPTIMIZATION] SET [TASK_ID] = SCOPE_IDENTITY() WHERE [CLIENT_CODE] = @CLIENT_CODE
				END;
				ELSE
				BEGIN
						-- ----------------------------------------------------
						-- Si la tarea ya estaba completada la volvemos a abrir
						-- ----------------------------------------------------
					IF (@TASK_STATUS = 'COMPLETED')
					BEGIN
						UPDATE
							[SONDA].[SWIFT_TASKS]
						SET	
							[TASK_STATUS] = 'ASSIGNED'
						WHERE
							[TASK_ID] = @TASK_ID;
						--
						UPDATE [#CLIENTS_FOR_OPTIMIZATION] SET [TASK_ID] = @TASK_ID WHERE [CLIENT_CODE] = @CLIENT_CODE
					END;
					ELSE
					BEGIN
						INSERT	INTO [SONDA].[SWIFT_TASKS]
								(
									[TASK_TYPE]
									,[TASK_DATE]
									,[SCHEDULE_FOR]
									,[CREATED_STAMP]
									,[ASSIGEND_TO]
									,[ASSIGNED_BY]
									,[ASSIGNED_STAMP]
									,[EXPECTED_GPS]
									,[TASK_STATUS]
									,[TASK_COMMENTS]
									,[TASK_SEQ]
									,[COSTUMER_CODE]
									,[COSTUMER_NAME]
									,[CUSTOMER_PHONE]
									,[TASK_ADDRESS]
									,[IN_PLAN_ROUTE]
									,[CREATE_BY]
									,[ALLOW_STORAGE_ON_DIFF]
								)
						SELECT
							'DELIVERY_SD'
							,GETDATE()
							,GETDATE()
							,GETDATE()
							,@LOGIN_ID
							,'Escaneo de manifiesto'
							,GETDATE()
							,COALESCE([VC].[GPS] ,'0,0')
							,'ASSIGNED'
							,'Tarea de entrega para Sonda SD'
							,[T].[ID]
							,[T].[CLIENT_CODE]
							,ISNULL([T].[CLIENT_NAME] ,'...')
							,COALESCE([VC].[PHONE_CUSTOMER] ,'No tiene telefono') [PHONE_CUSTOMER]
							,COALESCE([T].[ADDRESS_CUSTOMER] ,
										'No tiene direccion') [ADRESS_CUSTOMER]
							,1
							,'BY_MANIFEST_3PL'
							,0
						FROM
							[#CLIENTS_FILTERED] [T]
						INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [VC]
						ON	[VC].[CODE_CUSTOMER] = [T].[CLIENT_CODE]
						WHERE
							[T].[CLIENT_CODE] = @CLIENT_CODE;
						--
						UPDATE [#CLIENTS_FOR_OPTIMIZATION] SET [TASK_ID] = SCOPE_IDENTITY() WHERE [CLIENT_CODE] = @CLIENT_CODE
					END;
				END;

			--
				
		--
				DELETE FROM
					[#CLIENTS_FILTERED]
				WHERE
					[CLIENT_CODE] = @CLIENT_CODE;
		--
			END;
		--
			-- ----------------------------------------------------------------------------------------------------------------------
			-- Se ordenan las tareas por proximidad del cliente al vendedor o al centro de distribucion
			-- ----------------------------------------------------------------------------------------------------------------------
			DECLARE @TASK_SEQUENCE INT
					,@TASK_ID_FOR_OPTIMIZATION INT
					,@CURRENT_GPS VARCHAR(50)
					,@LAST_GPS VARCHAR(50);
		
			--
			SET @CURRENT_GPS = @GPS_WAREHOUSE;
			SET @TASK_SEQUENCE = @LAST_TASK_SEQ;

			WHILE EXISTS(SELECT TOP 1 1 FROM [#CLIENTS_FOR_OPTIMIZATION]) BEGIN
				--
				SELECT TOP 1 
					@TASK_ID_FOR_OPTIMIZATION = T.TASK_ID 
					,@LAST_GPS = T.[GPS]
				FROM [#CLIENTS_FOR_OPTIMIZATION] AS T 
				ORDER BY [T].[DISTANCE] ASC

				--
				UPDATE [SONDA].[SWIFT_TASKS] SET [TASK_SEQ] = @TASK_SEQUENCE WHERE [TASK_ID] = @TASK_ID_FOR_OPTIMIZATION

				--
				SET @TASK_SEQUENCE = (@TASK_SEQUENCE + 1);
				SET @CURRENT_GPS = @LAST_GPS;

				--
				DELETE FROM [#CLIENTS_FOR_OPTIMIZATION] WHERE [TASK_ID] = @TASK_ID_FOR_OPTIMIZATION

				--
				UPDATE T 
					SET T.[DISTANCE] = DBO.[SONDA_FN_CALCULATE_DISTANCE](@CURRENT_GPS,T.[GPS])
				FROM [#CLIENTS_FOR_OPTIMIZATION] AS T

			END

		--
			COMMIT TRANSACTION [INSERT_TASK];
		--
		END TRY
		BEGIN CATCH
			--
			ROLLBACK TRANSACTION [INSERT_TASK];
			--
			DECLARE	@ERROR_MESSAGE VARCHAR(MAX) = 'Error al generar las tareas de entrega debido a: '
				+ ERROR_MESSAGE();
			--
			RAISERROR( @ERROR_MESSAGE,16,1);
		END CATCH;
	END;
