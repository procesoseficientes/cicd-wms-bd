-- =============================================
-- Autor:				      rudi.garcia
-- Fecha de Creacion: 02-Oct-2018 G-Force@Koala
-- Description:			  SP que borra la todas las preguntas.

-- Modificacion 11/6/2018 @ G-FORCE Sprint Leon
					-- diego.as
					-- Se corrige error al validar las rutas asociadas a la microencuesta y se ordena el codigo

CREATE PROCEDURE [SONDA].[SWIFT_SP_ALL_DELETE_QUESTION] (@QUIZ_ID INT)
AS
	BEGIN TRY
	
		DECLARE	@ASSIGNED_ROUTES_QTY INT = 0;

	-- ------------------------------------------------------------------------------------
	-- Cuenta la cantidad de rutas asociadas a la microencuesta
	-- ------------------------------------------------------------------------------------
		SELECT
			@ASSIGNED_ROUTES_QTY = COUNT([QUESTION_ID])
		FROM
			[SONDA].[SWIFT_QUESTION]
		WHERE
			[QUIZ_ID] IN (SELECT
								[QUIZ_ID]
							FROM
								[SONDA].[SWIFT_ASIGNED_QUIZ]
							WHERE
								[QUIZ_ID] = @QUIZ_ID);

		IF (@ASSIGNED_ROUTES_QTY) > 0
		BEGIN
			RAISERROR('Hay rutas asignadas a esta encuesta',16,1);
		END;


		-- ------------------------------------------------------------------------------------
		-- Elimina las respuestas
		-- ------------------------------------------------------------------------------------
		DELETE
			[A]
		FROM
			[SONDA].[SWIFT_ANSWER] [A]
		INNER JOIN [SONDA].[SWIFT_QUESTION] [Q]
		ON	([A].[QUESTION_ID] = [Q].[QUESTION_ID])
		WHERE
			[Q].[QUIZ_ID] = @QUIZ_ID;

		-- ------------------------------------------------------------------------------------
		-- Elimina la pregunta
		-- ------------------------------------------------------------------------------------
		DELETE
			[SONDA].[SWIFT_QUESTION]
		WHERE
			[QUIZ_ID] = @QUIZ_ID;

		-- ------------------------------------------------------------------------------------
		-- Muestra resultado EXITOSO
		-- ------------------------------------------------------------------------------------
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@QUIZ_ID AS VARCHAR) [DbData];
	END TRY
	BEGIN CATCH
		-- ------------------------------------------------------------------------------------
		-- Muestra resultado FALLIDO
		-- ------------------------------------------------------------------------------------
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
