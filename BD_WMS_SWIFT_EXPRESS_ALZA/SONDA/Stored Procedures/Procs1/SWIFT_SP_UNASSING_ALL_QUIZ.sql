-- =============================================
-- Autor:				      christian.hernandez
-- Fecha de Creacion: 02-Oct-2018 G-Force@Koala
-- Description:			  SP que desasigna todas los canales de esta microencuesta.


-- Autor:				      christian.hernandez
-- Fecha de Creacion: 02-Oct-2018 G-Force@Salamadra
-- Description:			  modificacion para que elimine solamente las rutas y no canales.

CREATE PROCEDURE [SONDA].[SWIFT_SP_UNASSING_ALL_QUIZ] (@QUIZ_ID INT)
AS
BEGIN TRY

  DELETE 
    FROM SONDA.SWIFT_ASIGNED_QUIZ WHERE QUIZ_ID = @QUIZ_ID AND CODE_CHANNEL IS NULL 


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
