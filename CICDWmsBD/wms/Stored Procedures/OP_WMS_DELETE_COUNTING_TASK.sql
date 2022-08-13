
-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-02-22 @ Team ERGON - Sprint ERGON III
-- Description:	        Elimina una tarea de conteo

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-25 ErgonTeam@Sheik
-- Description:	 Se agrega que devuelva objeto operación por cambio de arquitectura

/*
-- Ejemplo de Ejecucion:
			EXEC  
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_DELETE_COUNTING_TASK] (@TASK_ID INT, @USER AS VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    BEGIN TRANSACTION

    UPDATE [wms].[OP_WMS_TASK]
    SET [IS_COMPLETE] = 1
       ,[IS_CANCELED] = 1
       ,[COMPLETED_DATE] = GETDATE()
       ,[CANCELED_DATE] = GETDATE()
       ,[CANCELED_BY] = @USER
       ,[LAST_UPDATE] = GETDATE()
       ,[LAST_UDATE_BY] = @USER
    WHERE TASK_ID = @TASK_ID

    UPDATE [CH]
    SET [STATUS] = 'CANCELED'
    FROM [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [CH]
    INNER JOIN [wms].[OP_WMS_TASK] [T]
      ON [CH].[TASK_ID] = [T].[TASK_ID]
    WHERE [T].[TASK_ID] = @TASK_ID;
    --
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CONVERT(VARCHAR(16), 1) DbData

    COMMIT TRANSACTION
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@error [Codigo];
    ROLLBACK TRANSACTION

  END CATCH;


END