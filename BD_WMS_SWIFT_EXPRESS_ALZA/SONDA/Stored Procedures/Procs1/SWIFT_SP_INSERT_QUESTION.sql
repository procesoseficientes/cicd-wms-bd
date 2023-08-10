-- =============================================
-- Autor:				      rudi.garcia
-- Fecha de Creacion: 02-Oct-2018 G-Force@Koala
-- Description:			  SP que inserta una encuesta

CREATE PROCEDURE [SONDA].SWIFT_SP_INSERT_QUESTION (@QUIZ_ID INT
, @QUESTION VARCHAR(256)
, @ORDER INT
, @REQUIRED INT
, @TYPE_QUESTION VARCHAR(50)
, @LAST_UPDATE_BY VARCHAR(50))
AS
BEGIN TRY

  DECLARE @ID INT

  INSERT INTO [SONDA].[SWIFT_QUESTION] ([QUIZ_ID], [QUESTION], [ORDER], [REQUIRED], [TYPE_QUESTION], [LAST_UPDATE], [LAST_UPDATE_BY])
    VALUES (@QUIZ_ID, @QUESTION, @ORDER, @REQUIRED, @TYPE_QUESTION, GETDATE(), @LAST_UPDATE_BY);

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
