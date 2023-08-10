-- =============================================
-- Autor:				      christia.hernandez
-- Fecha de Creacion: 02-Oct-2018 G-Force@Koala
-- Description:			  SP que desasigna microencuesta de la pregunta 

CREATE PROCEDURE [SONDA].[SWIFT_SP_UNASSING_QUIZ] (@QUIZ_ID INT, @ROUTE_CODE VARCHAR(250))
AS
BEGIN TRY


DELETE FROM SONDA.SWIFT_ASIGNED_QUIZ where QUIZ_ID = @QUIZ_ID and ROUTE_CODE =@ROUTE_CODE


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
