-- =============================================
-- Autor:				      rudi.garcia
-- Fecha de Creacion: 02-Oct-2018 G-Force@Koala
-- Description:			  SP que actualiza la respuesta

CREATE PROCEDURE [SONDA].SWIFT_SP_UPDATE_ANSWER (@ANSWER_ID INT
, @ANSWER VARCHAR(256)
, @LAST_UPDATE_BY VARCHAR(50))
AS
BEGIN TRY

  UPDATE [SONDA].[SWIFT_ANSWER]
  SET [ANSWER] = @ANSWER
     ,[LAST_UPDATE] = GETDATE()
     ,[LAST_UPDATE_BY] = @LAST_UPDATE_BY
  WHERE [ANSWER_ID] = @ANSWER_ID

  SELECT
    1 AS Resultado
   ,'Proceso Exitoso' Mensaje
   ,0 Codigo
   ,CAST(@ANSWER_ID AS VARCHAR) DbData

END TRY
BEGIN CATCH
  SELECT
    -1 AS Resultado
   ,ERROR_MESSAGE() Mensaje
   ,@@ERROR Codigo
END CATCH
