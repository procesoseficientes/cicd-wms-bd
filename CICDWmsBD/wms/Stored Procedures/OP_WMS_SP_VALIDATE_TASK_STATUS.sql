-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-06-08 Ergon@sheik
-- Description:	 Se agrega SP para validar el estado de cualquier tarea antes de continuar operando en la HH 


/*
-- Ejemplo de Ejecucion:
		EXEC	[wms].[OP_WMS_SP_VALIDATE_TASK_STATUS] @LOGIN = 'ACAMACHO',
            @SERIAL_NUMBER = 0,
            @TASK_ID  = 16,
            @WAVE_PICKING_ID = 0,
            @MATERIAL_ID = '',
            @TASK_TYPE ='TAREA_CONTEO'
  
SELECT *
          FROM [wms].[OP_WMS_TASK_LIST] T
          WHERE [T].[WAVE_PICKING_ID] = 4474  

          select * FROM [wms].[OP_WMS_TASK_LIST] [T]
          WHERE [T].[TASK_ASSIGNEDTO] = 'BCORADO'
          AND [T].[WAVE_PICKING_ID] = 4417
          AND [T].[MATERIAL_ID] = 'wms/100003'
          AND ([T].[IS_COMPLETED] > 0
          OR [T].[IS_PAUSED] > 0
          OR [T].[IS_CANCELED] > 0)
          AND [T].[REGIMEN] = 'GENERAL'
          AND [T].[TASK_TYPE] = 'TAREA_PICKING'

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_TASK_STATUS] (@LOGIN VARCHAR(50),
@SERIAL_NUMBER INT,
@TASK_ID INT,
@WAVE_PICKING_ID INT,
@MATERIAL_ID VARCHAR(50) = NULL,
@TASK_TYPE VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @PRESULT VARCHAR(MAX)
  BEGIN TRY
    --

    IF @TASK_TYPE = 'TAREA_RECEPCION'
    BEGIN

      IF EXISTS (SELECT TOP 1
            1
          FROM [wms].[OP_WMS_TASK_LIST] T
          WHERE [T].[SERIAL_NUMBER] = @SERIAL_NUMBER
          AND [T].[IS_CANCELED] = 1)
      BEGIN
        PRINT 'ERROR'
        SELECT
          @PRESULT = 'ERROR, la tarea ha sido cancelada. Favor contactar al administrador de tareas.'
        RAISERROR (@PRESULT, 16, 1);
      END


      IF NOT EXISTS (SELECT
          TOP 1
            1
          FROM [wms].[OP_WMS_TASK_LIST] [TL]
          WHERE [TL].[SERIAL_NUMBER] = @SERIAL_NUMBER
          AND [TL].[TASK_TYPE] = 'TAREA_RECEPCION'
          AND [TL].[IS_COMPLETED] = 0
          AND [TL].[IS_PAUSED] = 0
          AND [TL].[IS_CANCELED] = 0
          AND [TL].[TASK_ASSIGNEDTO] = @LOGIN)
      BEGIN
        PRINT 'ERROR'
        SELECT
          @PRESULT = 'ERROR, el estado de la tarea ya no permite operar o esta fue asignada a otro operador. Favor contactar al administrador de tareas.'
        RAISERROR (@PRESULT, 16, 1);

      END

    END

    IF @TASK_TYPE = 'TAREA_PICKING'
      OR @TASK_TYPE = 'TAREA_REUBICACION'
    BEGIN

      IF EXISTS (SELECT TOP 1
            1
          FROM [wms].[OP_WMS_TASK_LIST] T
          WHERE [T].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
          AND [T].[MATERIAL_ID] = @MATERIAL_ID
          AND [T].[IS_CANCELED] = 1)
      BEGIN
        PRINT 'ERROR'
        SELECT
          @PRESULT = 'ERROR, la tarea ha sido cancelada. Favor contactar al administrador de tareas.'
        RAISERROR (@PRESULT, 16, 1);
      END

      IF NOT EXISTS (SELECT
          TOP 1
            1
          FROM [wms].[OP_WMS_TASK_LIST] [T]
          WHERE [T].[TASK_ASSIGNEDTO] = @LOGIN
          AND [T].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
          AND [T].[MATERIAL_ID] = @MATERIAL_ID
          AND [T].[IS_COMPLETED] = 0
          AND [T].[IS_PAUSED] = 0
          AND [T].[IS_CANCELED] = 0          
          AND ([T].[TASK_TYPE] = 'TAREA_PICKING'
          OR [T].[TASK_TYPE] = 'TAREA_REUBICACION'))
      BEGIN
        PRINT 'ERROR'
        SELECT
          @PRESULT = 'ERROR,  el estado de la tarea ya no permite operar o esta fue asignada a otro operador. Favor contactar al administrador de tareas.'
        RAISERROR (@PRESULT, 16, 1);

      END

    END

    IF @TASK_TYPE = 'TAREA_CONTEO'
    BEGIN

      IF EXISTS (SELECT TOP 1
            1
          FROM [wms].[OP_WMS_TASK] T
          WHERE [T].[TASK_ID] = @TASK_ID
          AND [T].[IS_CANCELED] = 1)
      BEGIN
        PRINT 'ERROR'
        SELECT
          @PRESULT = 'ERROR, la tarea ha sido cancelada. Favor contactar al administrador de tareas.'
        RAISERROR (@PRESULT, 16, 1);
      END

      IF NOT EXISTS (SELECT TOP 1
            1
          FROM [wms].[OP_WMS_TASK] [T]
          INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [H]
            ON [T].[TASK_ID] = [H].[TASK_ID]
          INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [D]
            ON [D].[PHYSICAL_COUNT_HEADER_ID] = [H].[PHYSICAL_COUNT_HEADER_ID]
          WHERE [T].[TASK_ID] = @TASK_ID
          AND [D].[ASSIGNED_TO] = @LOGIN
          AND [T].[IS_COMPLETE] = 0
          AND [T].[IS_PAUSED] = 0
          AND [T].[IS_CANCELED] = 0)
      BEGIN
        SELECT
          @PRESULT = 'ERROR,  el estado de la tarea ya no permite operar o esta fue asignada a otro operador. Favor contactar al administrador de tareas.'
        RAISERROR (@PRESULT, 16, 1);
      END
    END

    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,CAST('1' AS VARCHAR) DbData

  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo
	 ,'' DbData
    PRINT ERROR_MESSAGE();


  END CATCH;

END