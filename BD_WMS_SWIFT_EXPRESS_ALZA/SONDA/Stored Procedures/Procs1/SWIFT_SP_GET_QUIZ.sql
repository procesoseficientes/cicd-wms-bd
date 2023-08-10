-- =============================================
-- Autor:                rudi.garcia
-- Fecha de Creacion:    02-Oct-2018 @ A-TEAM Sprint G-Force@Koala
-- Description:          SP que obtiene las encuestas

/*
-- Ejemplo de Ejecucion:
                EXEC [SONDA].SWIFT_SP_GET_QUIZ
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_QUIZ
AS
BEGIN
  SET NOCOUNT ON;
  --
  SELECT
    [Q].[QUIZ_ID]
   ,[Q].[NAME_QUIZ]
   ,[Q].[VALID_START_DATETIME]
   ,[Q].[VALID_END_DATETIME]
   ,[Q].[ORDER]
   ,[Q].[REQUIRED]
   ,CASE [Q].[REQUIRED]
      WHEN 1 THEN 'SI'
      ELSE 'NO'
    END [DESCRIPTION_REQUIRED]
   ,[Q].[QUIZ_START]
   ,CASE [Q].[QUIZ_START]
      WHEN 1 THEN 'Al Iniciar'
      WHEN 2 THEN 'Al Finalizar'
    END [DESCRIPTION_QUIZ_START]
   ,[Q].[LAST_UPDATE]
   ,[Q].[LAST_UPDATE_BY]
  FROM [SONDA].[SWIFT_QUIZ] [Q]

END;
