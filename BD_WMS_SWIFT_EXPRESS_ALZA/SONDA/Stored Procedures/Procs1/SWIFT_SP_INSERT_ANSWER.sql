-- =============================================
-- Autor:				      rudi.garcia
-- Fecha de Creacion: 02-Oct-2018 G-Force@Koala
-- Description:			  SP que inserta una respuesta

CREATE PROCEDURE [SONDA].SWIFT_SP_INSERT_ANSWER (@QUESTION_ID INT
, @ANSWER VARCHAR(256)
, @LAST_UPDATE_BY VARCHAR(50))
AS
BEGIN TRY

  DECLARE @ID INT

  INSERT INTO [SONDA].[SWIFT_ANSWER] ([QUESTION_ID], [ANSWER], [LAST_UPDATE], [LAST_UPDATE_BY])
    VALUES (@QUESTION_ID, @ANSWER, GETDATE(), @LAST_UPDATE_BY);

  SET @ID = SCOPE_IDENTITY()

  SELECT
    1 AS Resultado
   ,'Proceso Exitoso' Mensaje
   ,0 Codigo
   ,CAST(@ID AS VARCHAR) DbData
END TRY
BEGIN CATCH
  SELECT
    -1 AS Resultado
   ,ERROR_MESSAGE() Mensaje
   ,@@ERROR Codigo
END CATCH
