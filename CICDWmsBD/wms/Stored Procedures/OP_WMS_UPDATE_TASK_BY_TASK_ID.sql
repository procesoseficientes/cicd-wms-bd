-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-02-22 @ Team ERGON - Sprint ERGON 
-- Description:	        

/*
-- Ejemplo de Ejecucion:
			EXEC  
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_UPDATE_TASK_BY_TASK_ID (@TASK_ID INT, @NEW_STATUS VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    BEGIN TRANSACTION
    
    UPDATE [wms].[OP_WMS_TASK]
    SET [IS_PAUSED] = @NEW_STATUS
    WHERE TASK_ID = @TASK_ID;

    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'0' DbData
    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    ROLLBACK TRANSACTION
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo
  END CATCH;
END