
CREATE PROCEDURE [SONDA].[SWIFT_SP_ASSING_QUIZ_BY_CHANNEL]
	(
		@QUIZ_ID INT
		,@XML_CHANNEL XML
	)
AS
	DECLARE	@RESULT TABLE
		(
			[Resultado] INT
			,[Mensaje] VARCHAR(MAX)
			,[Codigo] INT
			,[DbData] VARCHAR(MAX)
		);

	BEGIN TRY
		
		DECLARE	@ROUTES TABLE
			(
				 [ID] INT IDENTITY(1 ,1)
				,[CODE_CHANNEL] VARCHAR(250)
				,[LOGIN_ID] VARCHAR(250)
			);

		-- ------------------------------------------------------------------------------------
		-- Se valida que la encuesta tenga preguntas asociadas
		-- ------------------------------------------------------------------------------------
		IF (
			SELECT
				COUNT([QUESTION_ID])
			FROM
				[SONDA].[SWIFT_QUESTION]
			WHERE
				[QUIZ_ID] = @QUIZ_ID
			) < 1
		BEGIN
			RAISERROR('Se debe tener por lo menos una pregunta para asignar esta encuesta.',16,1);
		END;

		-- ------------------------------------------------------------------------------------
		-- Obtenemos las rutas a procesar
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @ROUTES
				(
					 [CODE_CHANNEL]
					,[LOGIN_ID]
				)
		SELECT
			[x].[Rec].[query]('./CODE_CHANNEL').[value]('.' ,'varchar(150)')
			,[x].[Rec].[query]('./LOGIN').[value]('.' ,'varchar(150)')
		FROM
			@XML_CHANNEL.[nodes]('/ArrayOfAsignacionMicroencuesta/AsignacionMicroencuesta')
			AS [x] ([Rec]);

		-- ------------------------------------------------------------------------------------
		-- Se procesan las rutas para ser asignadas a la encuesta
		-- ------------------------------------------------------------------------------------
		DECLARE
			@CURRENT_CODE_CHANNEL VARCHAR(250)
			,@CURRENT_LOGIN_ID VARCHAR(250)
			,@CURRENT_ID INT;

		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							@ROUTES )
		BEGIN
			
			-- ------------------------------------------------------------------------------------
			-- Obtenemos los valores a procesar
			-- ------------------------------------------------------------------------------------
			SELECT TOP 1
				@CURRENT_ID = [ID]
				,@CURRENT_CODE_CHANNEL = [CODE_CHANNEL]
				,@CURRENT_LOGIN_ID = [LOGIN_ID]
			FROM
				@ROUTES
			WHERE
				[ID] > 0;

			-- ------------------------------------------------------------------------------------
			-- Agregamos control de error
			-- ------------------------------------------------------------------------------------
			BEGIN TRY
				-- ------------------------------------------------------------------------------------
				-- Se inserta la asociacion
				-- ------------------------------------------------------------------------------------
				INSERT	INTO [SONDA].[SWIFT_ASIGNED_QUIZ]
						(
							[QUIZ_ID]
							,[CODE_CHANNEL]
							,[LAST_UPDATE]
							,[LAST_UPDATE_BY]
						)
				VALUES
						(
							@QUIZ_ID
							,@CURRENT_CODE_CHANNEL
							,GETDATE()
							,@CURRENT_LOGIN_ID
						);

				-- ------------------------------------------------------------------------------------
				-- Agrega resultado como EXITOSO
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @RESULT
						(
							[Resultado]
							,[Mensaje]
							,[Codigo]
						)
				SELECT
					1 AS [Resultado]
					,'Proceso Exitoso' [Mensaje]
					,0 [Codigo];

			END TRY
			BEGIN CATCH
				-- ------------------------------------------------------------------------------------
				-- Agrega resultado como FALLIDO
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @RESULT
						(
							[Resultado]
							,[Mensaje]
							,[Codigo]
						)
				SELECT
					-1 AS [Resultado]
					,ERROR_MESSAGE() [Mensaje]
					,@@ERROR [Codigo];
			END CATCH;

			-- ------------------------------------------------------------------------------------
				-- Eliminamos el registro procesado
				-- ------------------------------------------------------------------------------------
			DELETE FROM
				@ROUTES
			WHERE
				[ID] = @CURRENT_ID;
		END;
	END TRY
	BEGIN CATCH
		-- ------------------------------------------------------------------------------------
		-- Inserta proceso como FALLIDO
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @RESULT
				(
					[Resultado]
					,[Mensaje]
					,[Codigo]
				)
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	SELECT
		[Resultado]
		,[Mensaje]
		,[Codigo]
		,[DbData]
	FROM
		@RESULT;
