-- =============================================
-- Autor:				      rudi.garcia
-- Fecha de Creacion: 02-Oct-2018 G-Force@Koala
-- Description:			  SP que actualiza la encuesta

CREATE PROCEDURE [SONDA].SWIFT_SP_UPDATE_QUIZ (@QUIZ_ID INT
, @NAME_QUIZ VARCHAR(50)
, @VALID_START_DATETIME DATETIME
, @VALID_END_DATETIME DATETIME
, @ORDER INT
, @REQUIRED INT
, @QUIZ_START INT
, @LAST_UPDATE VARCHAR(50))
AS
BEGIN TRY

  UPDATE [SONDA].[SWIFT_QUIZ]
  SET [NAME_QUIZ] = @NAME_QUIZ
     ,[VALID_START_DATETIME] = @VALID_START_DATETIME
     ,[VALID_END_DATETIME] = @VALID_END_DATETIME
     ,[ORDER] = @ORDER
     ,[REQUIRED] = @REQUIRED
     ,[QUIZ_START] = @QUIZ_START
     ,[LAST_UPDATE] = GETDATE()
     ,[LAST_UPDATE_BY] = @LAST_UPDATE
  WHERE [QUIZ_ID] = @QUIZ_ID;

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
