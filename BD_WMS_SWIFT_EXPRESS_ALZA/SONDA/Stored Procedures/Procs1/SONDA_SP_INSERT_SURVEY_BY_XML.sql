-- =============================================
-- Autor:				christian.hernandez
-- Fecha de Creacion: 	11/30/2018 @ A-TEAM Sprint Nutria
-- Description:			SP que inserta microencuestas desde SONDA

-- Modificacion		12/4/2018 @ G-Force Team Sprint G-Force@Nutria
-- Autor:			diego.as
-- Historia/Bug:	Product Backlog Item 23773: Micro Encuestas en Preventa
-- Descripcion:		12/4/2018 - Se corrige SP ya que estaba mal estructurado y no funcionaba correctamente

/*
-- Ejemplo de Ejecucion:
		EXEC [SONDA].[SONDA_SP_INSERT_SURVEY_BY_XML]
		@XML = '
			<Data>
    <encuestas>
        <rowId>1</rowId>
        <docSerie>136</docSerie>
        <docNum>2</docNum>
        <codeRoute>46</codeRoute>
        <codeCustomer>SO-151109</codeCustomer>
        <createdDate>Mon Dec 03 2018 16:36:06 GMT-0600 (hora estándar central)</createdDate>
        <gps>14.6499463,-90.5397046</gps>
        <customerGps></customerGps>
        <surveyId>13</surveyId>
        <surveyName>Microencuesta Inico</surveyName>
        <question>¿Compra articulos de limpieza?</question>
        <typeQuestion>UNIQUE</typeQuestion>
        <answer>Posiblemente</answer>
    </encuestas>
    <encuestas>
        <rowId>2</rowId>
        <docSerie>136</docSerie>
        <docNum>2</docNum>
        <codeRoute>46</codeRoute>
        <codeCustomer>SO-151109</codeCustomer>
        <createdDate>Mon Dec 03 2018 16:36:06 GMT-0600 (hora estándar central)</createdDate>
        <gps>14.6499463,-90.5397046</gps>
        <customerGps></customerGps>
        <surveyId>13</surveyId>
        <surveyName>Microencuesta Inico</surveyName>
        <question>¿Qué producto ha comprado en los ultimos 15 días?</question>
        <typeQuestion>MULTIPLE</typeQuestion>
        <answer>Paletas</answer>
    </encuestas>
    <encuestas>
        <rowId>3</rowId>
        <docSerie>136</docSerie>
        <docNum>2</docNum>
        <codeRoute>46</codeRoute>
        <codeCustomer>SO-151109</codeCustomer>
        <createdDate>Mon Dec 03 2018 16:36:06 GMT-0600 (hora estándar central)</createdDate>
        <gps>14.6499463,-90.5397046</gps>
        <customerGps></customerGps>
        <surveyId>13</surveyId>
        <surveyName>Microencuesta Inico</surveyName>
        <question>¿Qué producto ha comprado en los ultimos 15 días?</question>
        <typeQuestion>MULTIPLE</typeQuestion>
        <answer>Jugos</answer>
    </encuestas>
    <encuestas>
        <rowId>4</rowId>
        <docSerie>136</docSerie>
        <docNum>2</docNum>
        <codeRoute>46</codeRoute>
        <codeCustomer>SO-151109</codeCustomer>
        <createdDate>Mon Dec 03 2018 16:36:06 GMT-0600 (hora estándar central)</createdDate>
        <gps>14.6499463,-90.5397046</gps>
        <customerGps></customerGps>
        <surveyId>13</surveyId>
        <surveyName>Microencuesta Inico</surveyName>
        <question>¿Cuándo fue la última vez que lo compro?</question>
        <typeQuestion>DATE</typeQuestion>
        <answer>2018-12-03</answer>
    </encuestas>
    <encuestas>
        <rowId>5</rowId>
        <docSerie>136</docSerie>
        <docNum>3</docNum>
        <codeRoute>46</codeRoute>
        <codeCustomer>SO-151113</codeCustomer>
        <createdDate>Mon Dec 03 2018 16:38:05 GMT-0600 (hora estándar central)</createdDate>
        <gps>14.6499463,-90.5397046</gps>
        <customerGps></customerGps>
        <surveyId>13</surveyId>
        <surveyName>Microencuesta Inico</surveyName>
        <question>¿Compra articulos de limpieza?</question>
        <typeQuestion>UNIQUE</typeQuestion>
        <answer>Tal vez</answer>
    </encuestas>
    <dbuser>USONDA</dbuser>
    <dbuserpass>SONDAServer1237710</dbuserpass>
    <routeid>46</routeid>
    <loginId>adolfo@SONDA</loginId>
</Data>
		'
*/

CREATE PROCEDURE [SONDA].[SONDA_SP_INSERT_SURVEY_BY_XML]
	(
		@XML XML
		,@JSON VARCHAR(MAX) = NULL
	)
AS
	BEGIN
		SET NOCOUNT ON;
	-- ------------------------------------------------------
	-- Declara la tabla para insertar las respuestas 
	-- ------------------------------------------------------
		DECLARE	@NEW_SURVEY TABLE
			(
				[ROW_ID] INT
				,[DOC_SERIE] VARCHAR(50) NOT NULL
				,[DOC_NUM] INT NOT NULL
				,[CODE_ROUTE] VARCHAR(50) NOT NULL
				,[CODE_CUSTOMER] VARCHAR(250) NULL
				,[CREATED_DATE] DATETIME
				,[GPS] VARCHAR(250) NULL
				,[CUSTOMER_GPS] VARCHAR(50) NULL
				,[SURVEY_ID] VARCHAR(50) NOT NULL
				,[SURVEY_NAME] VARCHAR(255) NOT NULL
				,[QUESTION] VARCHAR(255) NOT NULL
				,[TYPE_QUESTION] VARCHAR(255) NOT NULL
				,[ANSWER] VARCHAR(255) NOT NULL
				,[JSON] VARCHAR(MAX) NOT NULL
				,[XML] XML
			);
		
	-- ------------------------------------------------------
	-- Declara la tabla resultados
	-- ------------------------------------------------------
		DECLARE	@RESULT TABLE
			(
				[ROW_ID] INT
				,[DOC_SERIE] VARCHAR(50) NOT NULL
				,[DOC_NUM] INT NOT NULL
				,[IS_SUCCESSFUL] INT NULL
			);

	-- ------------------------------------------------------
	-- Declara las variables que usaremos
	-- ------------------------------------------------------
		DECLARE
			@CODE_ROUTE VARCHAR(50)
			,@DOC_SERIE VARCHAR(50)
			,@DOC_NUM INT
			,@ROW_ID INT
			,@POSTED_DATETIME DATETIME
			,@IS_SUCCESSFUL INT;

		BEGIN TRY 
		-- ------------------------------------------------------
		-- Obtiene el LOGIN_ID y el CODE_ROUTE
		-- ------------------------------------------------------
			SELECT
				@CODE_ROUTE = [x].[Rec].[query]('./routeid').[value]('.' ,
																'varchar(50)')
			FROM
				@XML.[nodes]('Data') AS [x] ([Rec]);

			-- ------------------------------------------------------------------------------------
			-- Obtiene las encuestas enviadas desde el movil
			-- ------------------------------------------------------------------------------------
			INSERT	INTO @NEW_SURVEY
					(
						[ROW_ID]
						,[DOC_SERIE]
						,[DOC_NUM]
						,[CODE_ROUTE]
						,[CODE_CUSTOMER]
						,[CREATED_DATE]
						,[GPS]
						,[SURVEY_ID]
						,[SURVEY_NAME]
						,[QUESTION]
						,[TYPE_QUESTION]
						,[ANSWER]
						,[JSON]
						,[XML]
					)
			SELECT
				[x].[Rec].[query]('./rowId').[value]('.' ,'INT')
				,[x].[Rec].[query]('./docSerie').[value]('.' ,'varchar(50)')
				,[x].[Rec].[query]('./docNum').[value]('.' ,'INT')
				,@CODE_ROUTE
				,[x].[Rec].[query]('./codeCustomer').[value]('.' ,'varchar(50)')
				,[x].[Rec].[query]('./createdDate').[value]('.' ,'DATETIME')
				,[x].[Rec].[query]('./gps').[value]('.' ,'varchar(50)')
				,[x].[Rec].[query]('./surveyId').[value]('.' ,'INT')
				,[x].[Rec].[query]('./surveyName').[value]('.' ,'varchar(150)')
				,[x].[Rec].[query]('./question').[value]('.' ,'varchar(150)')
				,[x].[Rec].[query]('./typeQuestion').[value]('.' ,'varchar(50)')
				,[x].[Rec].[query]('./answer').[value]('.' ,'varchar(50)')
				,@JSON
				,@XML
			FROM
				@XML.[nodes]('Data/encuestas') AS [x] ([Rec]);

			-- ------------------------------------------------------------------------------------
			-- Recorre cada encuesta para insertarla en el servidor
			-- ------------------------------------------------------------------------------------
			SET @POSTED_DATETIME = GETDATE();
			WHILE EXISTS ( SELECT TOP 1
								1
							FROM
								@NEW_SURVEY )
			BEGIN

			-- ------------------------------------------------------------------------------------
			-- Obtiene los datos de la encuesta a procesar
			-- ------------------------------------------------------------------------------------
				SELECT TOP 1
					@ROW_ID = [ROW_ID]
					,@DOC_SERIE = [DOC_SERIE]
					,@DOC_NUM = [DOC_NUM]
				FROM
					@NEW_SURVEY;

				-- ------------------------------------------------------------------------------------
				-- Realiza intento de insercion del registro obtenido
				-- ------------------------------------------------------------------------------------
				BEGIN TRY
					INSERT	INTO [SONDA].[SONDA_SURVEY]
							(
								[SURVEY_NAME]
								,[QUESTION]
								,[TYPE_QUESTION]
								,[ANSWER]
								,[DOC_SERIE]
								,[DOC_NUM]
								,[CODE_ROUTE]
								,[CODE_CUSTOMER]
								,[IS_POSTED]
								,[CREATED_DATE]
								,[POSTED_DATE]
								,[GPS]
								,[CUSTOMER_GPS]
								,[SURVEY_ID]
								,[JSON]
								,[XML]
							)
					SELECT
						[S].[SURVEY_NAME]
						,[S].[QUESTION]
						,[S].[TYPE_QUESTION]
						,[S].[ANSWER]
						,[S].[DOC_SERIE]
						,[S].[DOC_NUM]
						,[S].[CODE_ROUTE]
						,[S].[CODE_CUSTOMER]
						,2
						,[S].[CREATED_DATE]
						,@POSTED_DATETIME
						,[S].[GPS]
						,(
							SELECT TOP 1
								[VC].[GPS]
							FROM
								[SONDA].[SWIFT_VIEW_ALL_COSTUMER] AS [VC]
							WHERE
								[VC].[CODE_CUSTOMER] = [S].[CODE_CUSTOMER]
							)
						,[S].[SURVEY_ID]
						,[S].[JSON]
						,[S].[XML]
					FROM
						@NEW_SURVEY AS [S]
					WHERE
						[S].[ROW_ID] = @ROW_ID;

					SET @IS_SUCCESSFUL = 1;
				END TRY
				BEGIN CATCH
					SET @IS_SUCCESSFUL = 0;
				END CATCH;
				
				-- ------------------------------------------------------------------------------------
				-- Inserta el registro en la tabla que se devolvera al movil
				-- ------------------------------------------------------------------------------------
				INSERT	INTO @RESULT
						(
							[ROW_ID]
							,[DOC_SERIE]
							,[DOC_NUM]
							,[IS_SUCCESSFUL]
						)
				VALUES
						(
							@ROW_ID -- ROW_ID - int
							,@DOC_SERIE  -- DOC_SERIE - varchar(50)
							,@DOC_NUM  -- DOC_NUM - int
							,@IS_SUCCESSFUL  -- IS_SUCCESSFUL - int
						);

				-- ------------------------------------------------------------------------------------
				-- Elimina el registro procesado
				-- ------------------------------------------------------------------------------------
				DELETE FROM
					@NEW_SURVEY
				WHERE
					[ROW_ID] = @ROW_ID;
			END;

			-- ------------------------------------------------------------------------------------
			-- Devuelve el resultado
			-- ------------------------------------------------------------------------------------
			SELECT
				[ROW_ID]
				,[DOC_SERIE]
				,[DOC_NUM]
				,[IS_SUCCESSFUL]
			FROM
				@RESULT;
		--
		END TRY
		BEGIN CATCH
			DECLARE	@ERROR VARCHAR(1000) = ERROR_MESSAGE();
			PRINT 'CATCH: ' + @ERROR;
			RAISERROR (@ERROR,16,1);
		END CATCH;
	END;
