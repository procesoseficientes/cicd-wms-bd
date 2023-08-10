-- =============================================
-- Autor:				      rudi.garcia
-- Fecha de Creacion: 02-Oct-2018 G-Force@Koala
-- Description:			  SP que actualiza la pregunta

CREATE PROCEDURE [SONDA].SWIFT_SP_UPDATE_QUESTION (@QUESTION_ID INT
, @QUESTION VARCHAR(256)
, @ORDER INT
, @REQUIRED INT
, @TYPE_QUESTION VARCHAR(50)
, @LAST_UPDATE_BY VARCHAR(50))
AS
BEGIN TRY

  UPDATE [SONDA].[SWIFT_QUESTION]
  SET [QUESTION] = @QUESTION
     ,[ORDER] = @ORDER
     ,[REQUIRED] = @REQUIRED
     ,[TYPE_QUESTION] = @TYPE_QUESTION
     ,[LAST_UPDATE] = GETDATE()
     ,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
  WHERE [QUESTION_ID] = @QUESTION_ID


  IF @TYPE_QUESTION = ''
  BEGIN
    DELETE [SONDA].[SWIFT_ANSWER]
    WHERE [QUESTION_ID] = @QUESTION_ID
  END

  SELECT
    1 AS Resultado
   ,'Proceso Exitoso' Mensaje
   ,0 Codigo
   ,CAST(@QUESTION_ID AS VARCHAR) DbData
END TRY
BEGIN CATCH
  SELECT
    -1 AS Resultado
   ,ERROR_MESSAGE() Mensaje
   ,@@ERROR Codigo
END CATCH
