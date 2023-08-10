-- =============================================
-- Autor:                rudi.garcia
-- Fecha de Creacion:    02-Oct-2018 @ A-TEAM Sprint G-Force@Koala
-- Description:          SP que obtiene las preunta de la encuesta

/*
-- Ejemplo de Ejecucion:
                EXEC [SONDA].SWIFT_SP_GET_QUESTION_BY_QUIZ @QUIZ_ID = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_QUESTION_BY_QUIZ] (@QUIZ_ID INT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [Q].[QUESTION_ID]
   ,[Q].[QUIZ_ID]
   ,[Q].[QUESTION]
   ,[Q].[ORDER]
   ,CASE WHEN [Q].[REQUIRED] = 1 THEN 'Si' ELSE 'No' END AS [IS_REQUIRED]
   ,[Q].[TYPE_QUESTION]
   ,CASE WHEN [Q].[TYPE_QUESTION] ='TEXT' THEN 'Texto' 
	WHEN [Q].[TYPE_QUESTION] ='NUMBER' THEN 'Número' 
	WHEN [Q].[TYPE_QUESTION] ='UNIQUE' THEN 'Único'	
	WHEN [Q].[TYPE_QUESTION] ='MULTIPLE' THEN 'Multiple'
	WHEN [Q].[TYPE_QUESTION] ='DATE' THEN 'Fecha' END AS [TRANSLATE_TYPE_QUESTION] 
   ,[Q].[LAST_UPDATE]
   ,[Q].[LAST_UPDATE_BY]   
  FROM [SONDA].[SWIFT_QUESTION] [Q]
  WHERE [Q].[QUIZ_ID] = @QUIZ_ID
END;
