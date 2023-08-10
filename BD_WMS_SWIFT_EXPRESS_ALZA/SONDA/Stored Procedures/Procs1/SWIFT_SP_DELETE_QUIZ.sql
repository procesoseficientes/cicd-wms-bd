-- =============================================
-- Autor:				      rudi.garcia
-- Fecha de Creacion: 02-Oct-2018 G-Force@Koala
-- Description:			  SP que borra la encuesta

CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_QUIZ] (@QUIZ_ID INT)
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
	
  DELETE [SONDA].SWIFT_ANSWER
  WHERE ANSWER_ID in (SELECT ANSWER_ID FROM SONDA.SWIFT_QUESTION WHERE [QUIZ_ID] = @QUIZ_ID)
	
  DELETE [SONDA].SWIFT_QUESTION
  WHERE [QUIZ_ID] = @QUIZ_ID

  DELETE [SONDA].[SWIFT_QUIZ]
  WHERE [QUIZ_ID] = @QUIZ_ID

  SELECT
    1 AS Resultado
   ,'Proceso Exitoso' Mensaje
   ,0 Codigo
   ,CAST(@QUIZ_ID AS VARCHAR) DbData
END TRY
BEGIN CATCH
  SELECT
    -1 AS Resultado
   ,ERROR_MESSAGE() Mensaje
   ,@@ERROR Codigo
END CATCH
