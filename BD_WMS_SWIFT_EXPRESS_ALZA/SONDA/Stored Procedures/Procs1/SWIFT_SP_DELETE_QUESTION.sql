-- =============================================
-- Autor:				      rudi.garcia
-- Fecha de Creacion: 02-Oct-2018 G-Force@Koala
-- Description:			  SP que borra la pregunta

CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_QUESTION] (@QUESTION_ID INT)
AS
	BEGIN TRY

		DECLARE
			@ASSIGNED_ROUTES_QTY INT = 0
			,@ANSWERS_QTY INT = 0;

		-- ------------------------------------------------------------------------------------
		-- Se obtiene la cantidad de preguntas que tiene asociadas la encuesta
		-- ------------------------------------------------------------------------------------
		SELECT
			@ANSWERS_QTY = COUNT(*)
		FROM
			[SONDA].[SWIFT_QUESTION] AS [Q]
		WHERE
			[Q].[QUIZ_ID] = (
								SELECT TOP 1
									[QA].[QUIZ_ID]
								FROM
									[SONDA].[SWIFT_QUESTION] AS [QA]
								WHERE
									[QA].[QUESTION_ID] = @QUESTION_ID
							);
		
		-- ------------------------------------------------------------------------------------
		-- Se obtiene la cantidad de rutas asociadas a la encuesta
		-- ------------------------------------------------------------------------------------
		SELECT
			@ASSIGNED_ROUTES_QTY = COUNT(*)
		FROM
			[SONDA].[SWIFT_QUESTION] AS [Q]
		INNER JOIN [SONDA].[SWIFT_ASIGNED_QUIZ] AS [AQ]
		ON	([AQ].[QUIZ_ID] = [Q].[QUIZ_ID])
		WHERE
			[Q].[QUESTION_ID] = @QUESTION_ID;
		
		-- ------------------------------------------------------------------------------------------
		-- Se valida si la encuesta tiene asociada alguna ruta y si es la ultima pregunta a eliminar
		-- ------------------------------------------------------------------------------------------
		IF (
			@ASSIGNED_ROUTES_QTY > 0
			AND @ANSWERS_QTY = 1
			)
		BEGIN
			RAISERROR('Debe desasociar las rutas antes de eliminar la última pregunta',16,1);
		END;
		ELSE
		BEGIN
			
			-- ------------------------------------------------------------------------------------
			-- Se eliminan las respuestas
			-- ------------------------------------------------------------------------------------
			DELETE
				[SONDA].[SWIFT_ANSWER]
			WHERE
				[QUESTION_ID] = @QUESTION_ID;
			
			-- ------------------------------------------------------------------------------------
			-- Elimina la pregunta
			-- ------------------------------------------------------------------------------------
			DELETE
				[SONDA].[SWIFT_QUESTION]
			WHERE
				[QUESTION_ID] = @QUESTION_ID;
			
			-- ------------------------------------------------------------------------------------
			-- Se devuelve resultado como exito
			-- ------------------------------------------------------------------------------------
			SELECT
				1 AS [Resultado]
				,'Proceso Exitoso' [Mensaje]
				,0 [Codigo]
				,CAST(@QUESTION_ID AS VARCHAR) [DbData];
		END;
	END TRY
	BEGIN CATCH
		-- ------------------------------------------------------------------------------------
		-- Se devuelve resultado como fallido
		-- ------------------------------------------------------------------------------------
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
