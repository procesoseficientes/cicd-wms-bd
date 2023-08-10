-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		7/25/2018 @ A-Team Sprint G-Force@Gato
-- Description:			    SP que actualiza la informacion de secuencias manuales
-- =============================================

CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_MANUAL_FREQUENCY_INFO]
	(
		@XML XML
		,@LOGIN_ID VARCHAR(250)
		,@REFERENCE_SOURCE VARCHAR(250)
	)
AS
	BEGIN
  -- ------------------------------------------------------------------
  -- Inicia proceso
  -- ------------------------------------------------------------------
		BEGIN TRY

    -- -------------------------------------------------------------------------------
    -- Tabla para mostrar el resultado de procesos
    -- -------------------------------------------------------------------------------
			DECLARE	@TABLE_RESULT TABLE
				(
					[Resultado] INT
					,[Mensaje] VARCHAR(250)
					,[Codigo] INT
					,[DbData] VARCHAR(MAX)
				);

    -- -------------------------------------------------------------------------------
    -- Tabla que almacena la informacion proporcionada por el documento de EXCEL
    -- -------------------------------------------------------------------------------
			DECLARE	@FREQUENCY_UPDATED TABLE
				(
					[ID] INT IDENTITY(1 ,1)
								PRIMARY KEY
					,[ID_FREQUENCY] INT
					,[CODE_FREQUENCY] VARCHAR(50)
					,[SELLER_CODE] VARCHAR(50)
					,[SELLER_NAME] VARCHAR(50)
					,[CODE_CUSTOMER] VARCHAR(50)
					,[TYPE_TASK] VARCHAR(50)
					,[MONDAY] INT
					,[TUESDAY] INT
					,[WEDNESDAY] INT
					,[THURSDAY] INT
					,[FRIDAY] INT
					,[SATURDAY] INT
					,[SUNDAY] INT
					,[FREQUENCY_WEEKS] INT
					,[LAST_WEEK] DATE
					,[LAST_UPDATE] DATETIME
					,[LAST_UPDATE_BY] VARCHAR(50)
					,[PRIORITY] INT
					,[IS_BY_POLIGON] INT
					,[CODE_ROUTE] VARCHAR(50)
				);

    -- -------------------------------------------------------------------------------
    -- Obtenemos los datos que se enviaron desde el BO
    -- -------------------------------------------------------------------------------
			DECLARE	@FREQUENCY_TO_PROCESS TABLE
				(
					[ID] INT IDENTITY(1 ,1)
								PRIMARY KEY
					,[ID_FREQUENCY] INT
					,[CODE_FREQUENCY] VARCHAR(MAX)
					,[CODE_FREQUENCY_NEW] VARCHAR(MAX)
					,[CODE_CUSTOMER] VARCHAR(250)
					,[FREQUENCY_UPDATED_ID] INT
				);

    -- -------------------------------------------------------------------------------
    -- Obtenemos los datos que se enviaron desde el BO
    -- -------------------------------------------------------------------------------
			DECLARE	@FREQUENCY_UNCHANGED TABLE
				(
					[ID] INT IDENTITY(1 ,1)
								PRIMARY KEY
					,[ID_FREQUENCY] INT
					,[CODE_FREQUENCY] VARCHAR(MAX)
					,[FREQUENCY_UPDATED_ID] INT
				);

    -- -------------------------------------------------------------------------------
    -- Obtenemos los datos que se enviaron desde el BO
    -- -------------------------------------------------------------------------------
			DECLARE	@FREQUENCY_TO_INSERT TABLE
				(
					[ID] INT IDENTITY(1 ,1)
								PRIMARY KEY
					,[ID_FREQUENCY] INT
					,[CODE_FREQUENCY] VARCHAR(MAX)
					,[ID_FREQUENCY_NEW] INT
					,[FREQUENCY_UPDATED_ID] INT
				);


			PRINT ('OBTIENE VALORES DESDE XML ' + CAST(GETDATE() AS VARCHAR));
    -- -------------------------------------------------------------------------------
    -- Obtenemos los datos que se enviaron desde el BO
    -- -------------------------------------------------------------------------------
			INSERT	INTO @FREQUENCY_UPDATED
					(
						[ID_FREQUENCY]
						,[CODE_FREQUENCY]
						,[SELLER_CODE]
						,[SELLER_NAME]
						,[CODE_CUSTOMER]
						,[TYPE_TASK]
						,[MONDAY]
						,[TUESDAY]
						,[WEDNESDAY]
						,[THURSDAY]
						,[FRIDAY]
						,[SATURDAY]
						,[SUNDAY]
						,[FREQUENCY_WEEKS]
						,[LAST_WEEK]
						,[PRIORITY]
						,[IS_BY_POLIGON]
						,[CODE_ROUTE]
					)
			SELECT
				[x].[Rec].[query]('./ID_FREQUENCY').[value]('.' ,'int')
				,[x].[Rec].[query]('./CODE_FREQUENCY').[value]('.' ,
																'varchar(50)')
				,[x].[Rec].[query]('./SELLER_CODE').[value]('.' ,'varchar(50)')
				,[x].[Rec].[query]('./SELLER_NAME').[value]('.' ,'varchar(50)')
				,[x].[Rec].[query]('./CODE_CUSTOMER').[value]('.' ,'varchar(50)')
				,[x].[Rec].[query]('./TYPE_TASK').[value]('.' ,'varchar(50)')
				,[x].[Rec].[query]('./MONDAY').[value]('.' ,'int')
				,[x].[Rec].[query]('./TUESDAY').[value]('.' ,'int')
				,[x].[Rec].[query]('./WEDNESDAY').[value]('.' ,'int')
				,[x].[Rec].[query]('./THURSDAY').[value]('.' ,'int')
				,[x].[Rec].[query]('./FRIDAY').[value]('.' ,'int')
				,[x].[Rec].[query]('./SATURDAY').[value]('.' ,'int')
				,[x].[Rec].[query]('./SUNDAY').[value]('.' ,'int')
				,[x].[Rec].[query]('./FREQUENCY_WEEKS').[value]('.' ,'int')
				,[x].[Rec].[query]('./LAST_WEEK_VISITED').[value]('.' ,'date')
				,[x].[Rec].[query]('./PRIORITY').[value]('.' ,'int')
				,[x].[Rec].[query]('./IS_BY_POLIGON').[value]('.' ,'int')
				,[x].[Rec].[query]('./CODE_ROUTE').[value]('.' ,'varchar(MAX)')
			FROM
				@XML.[nodes]('ArrayOfFrecuencia/Frecuencia') AS [x] ([Rec]);


			PRINT ('OBTIENE VALORES DESDE FREQUENCY_UPDATED '
					+ CAST(GETDATE() AS VARCHAR));
    -- -------------------------------------------------------------------------------
    -- Obtenemos los datos que se enviaron desde el BO
    -- -------------------------------------------------------------------------------
			INSERT	INTO @FREQUENCY_TO_PROCESS
					(
						[ID_FREQUENCY]
						,[CODE_FREQUENCY]
						,[CODE_FREQUENCY_NEW]
						,[CODE_CUSTOMER]
						,[FREQUENCY_UPDATED_ID]
					)
			SELECT
				[FU].[ID_FREQUENCY]
				,[FU].[CODE_FREQUENCY]
				,([FU].[TYPE_TASK] + [FU].[CODE_ROUTE]
					+ CAST([FU].[SUNDAY] AS VARCHAR(1))
					+ CAST([FU].[MONDAY] AS VARCHAR(1))
					+ CAST([FU].[TUESDAY] AS VARCHAR(1))
					+ CAST([FU].[WEDNESDAY] AS VARCHAR(1))
					+ CAST([FU].[THURSDAY] AS VARCHAR(1))
					+ CAST([FU].[FRIDAY] AS VARCHAR(1))
					+ CAST([FU].[SATURDAY] AS VARCHAR(1))
					+ CAST([FU].[FREQUENCY_WEEKS] AS VARCHAR(1)))
				,[FU].[CODE_CUSTOMER]
				,[FU].[ID]
			FROM
				@FREQUENCY_UPDATED AS [FU];

			PRINT ('OBTIENE FRECUENCIAS QUE NO CAMBIARON '
					+ CAST(GETDATE() AS VARCHAR));
    -- -------------------------------------------------------------------------------
    -- Obtenemos los datos que se enviaron desde el BO
    -- -------------------------------------------------------------------------------
			INSERT	INTO @FREQUENCY_UNCHANGED
					(
						[ID_FREQUENCY]
						,[CODE_FREQUENCY]
						,[FREQUENCY_UPDATED_ID]
					)
			SELECT
				[FTP].[ID_FREQUENCY]
				,[FTP].[CODE_FREQUENCY_NEW]
				,[FTP].[FREQUENCY_UPDATED_ID]
			FROM
				@FREQUENCY_TO_PROCESS AS [FTP]
			WHERE
				[FTP].[CODE_FREQUENCY] = [FTP].[CODE_FREQUENCY_NEW]
				AND [FTP].[ID] > 0;


			PRINT ('OBTIENE FRECUENCIAS A INSERTAR, AQUELLAS QUE CAMBIARON '
					+ CAST(GETDATE() AS VARCHAR));
    -- -------------------------------------------------------------------------------
    -- Obtenemos los datos que se enviaron desde el BO
    -- -------------------------------------------------------------------------------
			INSERT	INTO @FREQUENCY_TO_INSERT
					(
						[ID_FREQUENCY]
						,[CODE_FREQUENCY]
						,[FREQUENCY_UPDATED_ID]
					)
			SELECT
				[FTP].[ID_FREQUENCY]
				,[FTP].[CODE_FREQUENCY_NEW]
				,[FTP].[FREQUENCY_UPDATED_ID]
			FROM
				@FREQUENCY_TO_PROCESS AS [FTP]
			WHERE
				[FTP].[CODE_FREQUENCY] != [FTP].[CODE_FREQUENCY_NEW]
				AND [FTP].[ID] > 0;

			IF (
				SELECT
					COUNT(*)
				FROM
					@FREQUENCY_TO_INSERT
				) > 0
			BEGIN
			
				PRINT ('ELIMINAMOS LOS CLIENTES DE LAS FRECUENCIAS QUE CAMBIARON '
						+ CAST(GETDATE() AS VARCHAR));
				DELETE
					[FC]
				FROM
					[SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] AS [FC]
				INNER JOIN @FREQUENCY_TO_PROCESS AS [FTP]
				ON	[FC].[ID_FREQUENCY] = [FTP].[ID_FREQUENCY]
					AND [FC].[CODE_CUSTOMER] = [FTP].[CODE_CUSTOMER]
				INNER JOIN @FREQUENCY_TO_INSERT AS [FTI]
				ON	[FTP].[ID_FREQUENCY] = [FTI].[ID_FREQUENCY]
				WHERE
					[FTI].[ID] > 0;


				PRINT ('CREAMOS LAS NUEVAS FRECUENCIAS EN BASE A LAS QUE CAMBIARON '
						+ CAST(GETDATE() AS VARCHAR));
				DECLARE
					@ID_FREQUENCY INT
					,@CODE_REQUENCY VARCHAR(MAX)
					,@ID_FREQUENCY_NEW INT
					,@FREQUENCY_UPDATED_ID INT;


				WHILE EXISTS ( SELECT TOP 1
									1
								FROM
									@FREQUENCY_TO_INSERT AS [FTI]
								WHERE
									[FTI].[ID_FREQUENCY_NEW] IS NULL )
				BEGIN
					PRINT ('OBTENEMOS LOS DATOS DE LA FRECUENCIA A INSERTAR '
							+ CAST(GETDATE() AS VARCHAR));
					SELECT TOP 1
						@ID_FREQUENCY = [ID_FREQUENCY]
						,@CODE_REQUENCY = [CODE_FREQUENCY]
						,@FREQUENCY_UPDATED_ID = [FREQUENCY_UPDATED_ID]
					FROM
						@FREQUENCY_TO_INSERT
					WHERE
						[ID] > 0 AND [ID_FREQUENCY_NEW] IS NULL;

					IF (
						SELECT
							COUNT(*)
						FROM
							[SONDA].[SWIFT_FREQUENCY] AS [F]
						WHERE
							[F].[CODE_FREQUENCY] = @CODE_REQUENCY
						) > 0
					BEGIN

						PRINT ('ACTUALIZAMOS LA FRECUENCIA '
								+ CAST(GETDATE() AS VARCHAR) + ' '
								+ @CODE_REQUENCY
								+ ' ID: ' + CAST(@FREQUENCY_UPDATED_ID AS VARCHAR));
						UPDATE
							@FREQUENCY_TO_INSERT
						SET	
							[ID_FREQUENCY_NEW] = (
													SELECT TOP 1
														[F].[ID_FREQUENCY]
													FROM
														[SONDA].[SWIFT_FREQUENCY]
														AS [F]
													WHERE
														[F].[CODE_FREQUENCY] = @CODE_REQUENCY
												)
						WHERE
							[FREQUENCY_UPDATED_ID] = @FREQUENCY_UPDATED_ID
							AND [ID] > 0;
					END;
					ELSE
					BEGIN 
						
						PRINT ('INSERTAMOS LA NUEVA FRECUENCIA '
								+ CAST(GETDATE() AS VARCHAR) + ' '
								+ @CODE_REQUENCY
								+ ' ID: ' + CAST(@FREQUENCY_UPDATED_ID AS VARCHAR));

						INSERT	INTO [SONDA].[SWIFT_FREQUENCY]
								(
									[CODE_FREQUENCY]
									,[SUNDAY]
									,[MONDAY]
									,[TUESDAY]
									,[WEDNESDAY]
									,[THURSDAY]
									,[FRIDAY]
									,[SATURDAY]
									,[FREQUENCY_WEEKS]
									,[LAST_WEEK_VISITED]
									,[LAST_UPDATED]
									,[LAST_UPDATED_BY]
									,[CODE_ROUTE]
									,[TYPE_TASK]
									,[REFERENCE_SOURCE]
									,[IS_BY_POLIGON]
								)
						SELECT
							@CODE_REQUENCY
							,[FU].[SUNDAY]
							,[FU].[MONDAY]
							,[FU].[TUESDAY]
							,[FU].[WEDNESDAY]
							,[FU].[THURSDAY]
							,[FU].[FRIDAY]
							,[FU].[SATURDAY]
							,[FU].[FREQUENCY_WEEKS]
							,[FU].[LAST_WEEK]
							,GETDATE()
							,@LOGIN_ID
							,[FU].[CODE_ROUTE]
							,[FU].[TYPE_TASK]
							,@REFERENCE_SOURCE
							,0
						FROM
							@FREQUENCY_UPDATED AS [FU]
						INNER JOIN @FREQUENCY_TO_PROCESS AS [FTP]
						ON	[FTP].[CODE_FREQUENCY] = [FU].[CODE_FREQUENCY] AND FU.ID = FTP.[FREQUENCY_UPDATED_ID]
						WHERE
							[FTP].[CODE_FREQUENCY_NEW] = @CODE_REQUENCY
							AND [FTP].[FREQUENCY_UPDATED_ID] = @FREQUENCY_UPDATED_ID;

						SELECT
							@ID_FREQUENCY_NEW = SCOPE_IDENTITY();

						UPDATE
							@FREQUENCY_TO_INSERT
						SET	
							@ID_FREQUENCY_NEW = @ID_FREQUENCY_NEW
						WHERE
							[FREQUENCY_UPDATED_ID] = @FREQUENCY_UPDATED_ID
							AND [ID] > 0;

					END;
				END;

				PRINT ('ASOCIAMOS LOS CLIENTES A LA NUEVA FRECUENCIA '
						+ CAST(GETDATE() AS VARCHAR));
				INSERT	INTO [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER]
						(
							[ID_FREQUENCY]
							,[CODE_CUSTOMER]
							,[PRIORITY]
						)
				SELECT
					[FTI].[ID_FREQUENCY_NEW]
					,[FU].[CODE_CUSTOMER]
					,[FU].[PRIORITY]
				FROM
					@FREQUENCY_UPDATED [FU]
				INNER JOIN @FREQUENCY_TO_INSERT [FTI]
				ON	[FU].[ID_FREQUENCY] = [FTI].[ID_FREQUENCY] AND FU.ID = FTI.[FREQUENCY_UPDATED_ID]
				WHERE
					[FTI].[ID] > 0;

			END;


			IF (
				SELECT
					COUNT(*)
				FROM
					@FREQUENCY_UNCHANGED
				) > 0
			BEGIN
				PRINT ('ACTUALIZAMOS LOS DATOS DE LA PRIORIDAD DE LOS CLIENTES QUE SE ENCUENTRAN EN FRECUENCIAS QUE NO CAMBIARON '
						+ CAST(GETDATE() AS VARCHAR));
				UPDATE
					[FC]
				SET	
					[FC].[PRIORITY] = [FU].[PRIORITY]
				FROM
					[SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] AS [FC]
				INNER JOIN @FREQUENCY_UPDATED AS [FU]
				ON	[FC].[ID_FREQUENCY] = [FU].[ID_FREQUENCY]
					AND [FC].[CODE_CUSTOMER] = [FU].[CODE_CUSTOMER]
				INNER JOIN @FREQUENCY_UNCHANGED AS [FUN]
				ON	[FU].[ID_FREQUENCY] = [FUN].[ID_FREQUENCY] AND FU.ID = FUN.[FREQUENCY_UPDATED_ID]
				WHERE
					[FUN].[ID] > 0;
			END;

		END TRY
		BEGIN CATCH
			PRINT ('INSERTAMOS ERROR ' + CAST(GETDATE() AS VARCHAR));
			INSERT	INTO @TABLE_RESULT
					(
						[Resultado]
						,[Mensaje]
						,[Codigo]
						,[DbData]
					)
			SELECT
				-1 AS [Resultado]
				,ERROR_MESSAGE() [Mensaje]
				,0 [Codigo]
				,'0' AS [DbData];
		END CATCH;
		PRINT ('MOSTRAMOS EL RESULTADO ' + CAST(GETDATE() AS VARCHAR));
		SELECT
			[TR].[Resultado]
			,[TR].[Mensaje]
			,[TR].[Codigo]
			,[TR].[DbData]
		FROM
			@TABLE_RESULT AS [TR];
	END;
