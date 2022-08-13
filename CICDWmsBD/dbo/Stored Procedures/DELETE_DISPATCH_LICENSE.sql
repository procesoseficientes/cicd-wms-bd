-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	24-Oct-19 @ Nexus Team Sprint  
-- Description:			SP que 
/*
-- Ejemplo de Ejecucion:
				EXEC  [dbo].[DELETE_DISPATCH_LICENSE] @DAYS = -3
*/
-- =============================================
CREATE PROCEDURE [dbo].[DELETE_DISPATCH_LICENSE](@DAYS  INT )
AS
BEGIN
    SET NOCOUNT ON;
    --
    /*
SELECT *
FROM [wms].[OP_WMS_INV_X_LICENSE] [il]
    INNER JOIN [wms].[OP_WMS_LICENSES] [l]
        ON [l].[LICENSE_ID] = [il].[LICENSE_ID]
    INNER JOIN [wms].[OP_WMS_TASK_LIST] [t]
        ON [t].[WAVE_PICKING_ID] = [l].[WAVE_PICKING_ID] 
WHERE [T].[TASK_TYPE] = 'TAREA_PICKING'
      AND [T].[IS_COMPLETED] = 1
	  AND [il].[QTY] >0
      AND [T].[DISPATCH_LICENSE_EXIT_COMPLETED] = 0
      AND [T].[COMPLETED_DATE] < DATEADD(DAY, -2, GETDATE());



SELECT *
FROM [wms].[OP_WMS_TASK_LIST]
WHERE [TASK_TYPE] = 'TAREA_PICKING'
      AND [IS_COMPLETED] = 1
      AND [DISPATCH_LICENSE_EXIT_COMPLETED] = 0
      AND [COMPLETED_DATE] < DATEADD(DAY, -2, GETDATE());


SELECT *
FROM [wms].[OP_WMS_TASK_LIST] [T]
    INNER JOIN [wms].[OP_WMS_LICENSES] [L]
        ON [L].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID]
    INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
        ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
           AND [IL].[QTY] > 0
WHERE [T].[TASK_TYPE] = 'TAREA_PICKING'
      AND [T].[IS_COMPLETED] = 1
      AND [T].[DISPATCH_LICENSE_EXIT_COMPLETED] = 0
      AND [T].[COMPLETED_DATE] < DATEADD(DAY, -31, GETDATE());

*/
    
    SELECT DISTINCT
           [L].[WAVE_PICKING_ID]
    INTO [#WAVES_TO_DISPATCH]
    FROM [wms].[OP_WMS_TASK_LIST] [T]
        INNER JOIN [wms].[OP_WMS_LICENSES] [L]
            ON [L].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID]
        INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
            ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
               AND [IL].[MATERIAL_ID] = [T].[MATERIAL_ID]
               AND [IL].[QTY] > 0
    WHERE [T].[TASK_TYPE] = 'TAREA_PICKING'
          AND [T].[IS_COMPLETED] = 1
          AND [IL].[QTY] > 0
          AND [T].[DISPATCH_LICENSE_EXIT_COMPLETED] = 0
          AND [T].[COMPLETED_DATE] < DATEADD(DAY, @DAYS, GETDATE());
    SELECT *
    FROM [#WAVES_TO_DISPATCH];


    UPDATE [IL]
    SET [IL].[QTY] = 0,
        [IL].[COMMENTS] = 'Despacho Automatico qty:' + CAST([IL].[QTY] AS VARCHAR)
    FROM [#WAVES_TO_DISPATCH] [T]
        INNER JOIN [wms].[OP_WMS_LICENSES] [L]
            ON [L].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID]
        INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
            ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
               AND [IL].[QTY] > 0
    WHERE [IL].[QTY] > 0
          AND [L].[WAVE_PICKING_ID] > 0;



    UPDATE [T]
    SET [T].[DISPATCH_LICENSE_EXIT_COMPLETED] = 1,
        [T].[DISPATCH_LICENSE_EXIT_DATETIME] = GETDATE(),
        [T].[DISPATCH_LICENSE_EXIT_BY] = 'ADMIN'
    FROM [wms].[OP_WMS_TASK_LIST] [T]
        INNER JOIN [#WAVES_TO_DISPATCH] [T1]
            ON [T1].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID];


    UPDATE [H]
    SET [H].[DISPATCH_LICENSE_EXIT_BY] = 'ADMIN',
        [H].[DISPATCH_LICENSE_EXIT_DATETIME] = GETDATE()
    FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
        INNER JOIN [#WAVES_TO_DISPATCH] [T]
            ON [T].[WAVE_PICKING_ID] = [H].[WAVE_PICKING_ID]
    WHERE [H].[DISPATCH_LICENSE_EXIT_BY] IS NULL;



END;

