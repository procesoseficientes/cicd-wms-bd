-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-20 @ Team ERGON - Sprint ERGON III
-- Description:	 Obtienen las ubicaciones de una tarea de conteo fisico. 




/*
-- Ejemplo de Ejecucion:
  EXEC	[wms].[OP_WMS_SP_GET_LOCATIONS_FOR_COUNT] @LOGIN = 'ACAMACHO' , @TASK_ID = 2
  SELECT * FROM [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [OWPCD]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LOCATIONS_FOR_COUNT]
    (
     @LOGIN VARCHAR(25)
    ,@TASK_ID INT
    )
AS
BEGIN
    SET NOCOUNT ON;
  --
    SELECT
        [D].[WAREHOUSE_ID]
       ,[D].[ZONE]
       ,[D].[LOCATION]
       ,[Z].[DESCRIPTION] [ZONE_DESCRIPTION]
    FROM
        [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [D]
    INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [H] ON [H].[PHYSICAL_COUNT_HEADER_ID] = [D].[PHYSICAL_COUNT_HEADER_ID]
    INNER JOIN [wms].[OP_WMS_ZONE] [Z] ON [Z].[ZONE] = [D].[ZONE]
    WHERE
        [D].[ASSIGNED_TO] = @LOGIN
        AND [H].[TASK_ID] = @TASK_ID
        AND [D].[STATUS] IN ('CREATED', 'IN_PROGRESS')
        AND [H].[STATUS] IN ('CREATED', 'IN_PROGRESS')
    GROUP BY
        [D].[WAREHOUSE_ID]
       ,[D].[ZONE]
       ,[D].[LOCATION]
       ,[Z].[DESCRIPTION]
    ORDER BY
        [D].[LOCATION];



END;