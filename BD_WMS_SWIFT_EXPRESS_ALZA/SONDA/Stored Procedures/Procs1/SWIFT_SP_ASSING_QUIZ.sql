-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		11/6/2018 @ G-Force-Team Sprint Leon
-- Description:			    SP que asocia una encuesta a una ruta

/*
-- Ejemplo de Ejecucion:
        EXEC SONDA.SWIFT_SP_ASSING_QUIZ
		@XML_ROUTES = '
			<ArrayOfAsignacionMicroencuesta>
			  <AsignacionMicroencuesta>
				<CODE_ROUTE>1</CODE_ROUTE>
				<CORRELATIVE>0</CORRELATIVE>
				<LOGIN>gerente@SONDA</LOGIN>
				<QUIZ_ID>12</QUIZ_ID>
			  </AsignacionMicroencuesta>
			  <AsignacionMicroencuesta>
				<CODE_ROUTE>10</CODE_ROUTE>
				<CORRELATIVE>0</CORRELATIVE>
				<LOGIN>gerente@SONDA</LOGIN>
				<QUIZ_ID>12</QUIZ_ID>
			  </AsignacionMicroencuesta>
			  <AsignacionMicroencuesta>
				<CODE_ROUTE>100</CODE_ROUTE>
				<CORRELATIVE>0</CORRELATIVE>
				<LOGIN>gerente@SONDA</LOGIN>
				<QUIZ_ID>12</QUIZ_ID>
			  </AsignacionMicroencuesta>
			  <AsignacionMicroencuesta>
				<CODE_ROUTE>101</CODE_ROUTE>
				<CORRELATIVE>0</CORRELATIVE>
				<LOGIN>gerente@SONDA</LOGIN>
				<QUIZ_ID>12</QUIZ_ID>
			  </AsignacionMicroencuesta>
			  <AsignacionMicroencuesta>
				<CODE_ROUTE>10106</CODE_ROUTE>
				<CORRELATIVE>0</CORRELATIVE>
				<LOGIN>gerente@SONDA</LOGIN>
				<QUIZ_ID>12</QUIZ_ID>
			  </AsignacionMicroencuesta>
			</ArrayOfAsignacionMicroencuesta>
		',
		@QUIZ_ID = 12
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_ASSING_QUIZ]
	(
		@QUIZ_ID INT
		,@XML_ROUTES XML
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
				,[CODE_ROUTE] VARCHAR(250)
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
					[CODE_ROUTE]
					,[LOGIN_ID]
				)
		SELECT
			[x].[Rec].[query]('./CODE_ROUTE').[value]('.' ,'varchar(150)')
			,[x].[Rec].[query]('./LOGIN').[value]('.' ,'varchar(150)')
		FROM
			@XML_ROUTES.[nodes]('/ArrayOfAsignacionMicroencuesta/AsignacionMicroencuesta')
			AS [x] ([Rec]);

		-- ------------------------------------------------------------------------------------
		-- Se procesan las rutas para ser asignadas a la encuesta
		-- ------------------------------------------------------------------------------------
		DECLARE
			@CURRENT_CODE_ROUTE VARCHAR(250)
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
				,@CURRENT_CODE_ROUTE = [CODE_ROUTE]
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
							,[ROUTE_CODE]
							,[LAST_UPDATE]
							,[LAST_UPDATE_BY]
						)
				VALUES
						(
							@QUIZ_ID
							,@CURRENT_CODE_ROUTE
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
