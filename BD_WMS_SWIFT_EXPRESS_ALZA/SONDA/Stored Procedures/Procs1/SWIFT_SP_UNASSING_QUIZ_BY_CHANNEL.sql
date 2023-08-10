-- =============================================
-- Autor:				      christia.hernandez
-- Fecha de Creacion:		2/08/2019 G-Force@Salamandra
-- Description:			  SP que desasigna microencuesta de la pregunta 

CREATE PROCEDURE [SONDA].[SWIFT_SP_UNASSING_QUIZ_BY_CHANNEL] (@QUIZ_ID INT, @CODE_CHANNEL VARCHAR(250))
AS
BEGIN TRY


DELETE FROM SONDA.SWIFT_ASIGNED_QUIZ where QUIZ_ID = @QUIZ_ID and CODE_CHANNEL = @CODE_CHANNEL


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
