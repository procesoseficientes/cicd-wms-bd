-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-05-17 @ Team ERGON - Sprint ERGON 
-- Description:	        Sp que asigna un operador a una tarea

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_UPDATE_ASSIGNED_TASK_USER] @TASK_ASSIGNEDTO = 'ACAMACHO'
                                                          , @SERIAL_NUMBER = NULL
                                                          , @WAVE_PICKING_ID = 15465
                                                          , @MATERIAL_ID = 'C01096/51755'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_ASSIGNED_TASK_USER] (@TASK_ASSIGNEDTO VARCHAR(25), @SERIAL_NUMBER DECIMAL = NULL, @WAVE_PICKING_ID DECIMAL = NULL, @MATERIAL_ID VARCHAR(25) = NULL)
AS
BEGIN
  SET NOCOUNT ON;
  --

  BEGIN TRY

    IF @SERIAL_NUMBER IS NULL OR @SERIAL_NUMBER = 0
    BEGIN

      UPDATE [wms].[OP_WMS_TASK_LIST]
      SET [TASK_ASSIGNEDTO] = @TASK_ASSIGNEDTO
      WHERE [WAVE_PICKING_ID] = @WAVE_PICKING_ID
      AND [MATERIAL_ID] = @MATERIAL_ID;

    END
    ELSE
    BEGIN

      UPDATE [wms].[OP_WMS_TASK_LIST]
      SET [TASK_ASSIGNEDTO] = @TASK_ASSIGNEDTO
      WHERE [SERIAL_NUMBER] = @SERIAL_NUMBER;

      UPDATE PH
      SET PH.POLIZA_ASSIGNEDTO = @TASK_ASSIGNEDTO
      FROM [wms].[OP_WMS_POLIZA_HEADER] [PH]
      INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL]
        ON ([PH].[DOC_ID] = [TL].[DOC_ID_SOURCE])
      WHERE [TL].[SERIAL_NUMBER] = @SERIAL_NUMBER

    END
    SELECT
      1 AS Resultado
     ,'Proceso Exitoso' Mensaje
     ,0 Codigo
     ,'0' DbData
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@error Codigo
  END CATCH



END