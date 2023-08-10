-- =============================================
-- Autor:				      christian.hernandez
-- Fecha de Creacion: 02-Oct-2018 G-Force@Salamadra
-- Description:			  SP que desasigna todas los canales de esta microencuesta.



CREATE PROCEDURE [SONDA].[SWIFT_SP_UNASSING_ALL_QUIZ_BY_CHANNEL] (@QUIZ_ID INT)
AS
BEGIN TRY

  DELETE 
    FROM SONDA.SWIFT_ASIGNED_QUIZ WHERE QUIZ_ID = @QUIZ_ID AND ROUTE_CODE IS NULL 


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
