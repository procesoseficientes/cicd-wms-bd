-- =============================================
-- Autor:                rudi.garcia
-- Fecha de Creacion:    02-Oct-2018 @ A-TEAM Sprint G-Force@Koala
-- Description:          SP que obtiene las respuestas de la pregunta.

/*
-- Ejemplo de Ejecucion:
                EXEC [SONDA].SWIFT_SP_GET_ANSWER_BY_QUESTION @QUESTION_ID = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_ANSWER_BY_QUESTION (@QUESTION_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [A].[ANSWER_ID]
   ,[A].[QUESTION_ID]
   ,[A].[ANSWER]
   ,[A].[LAST_UPDATE]
   ,[A].[LAST_UPDATE_BY]   
  FROM [SONDA].[SWIFT_ANSWER] [A]
  WHERE [A].[QUESTION_ID] = @QUESTION_ID
END;
