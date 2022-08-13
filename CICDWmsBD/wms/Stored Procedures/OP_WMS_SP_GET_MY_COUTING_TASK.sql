-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-20 @ Team ERGON - Sprint ERGON III
-- Description:	 Obtienen las tareas de conteo pendientes para un operador. 

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-06-13 ErgonTeam@SHEIK
-- Description:	 Se modifica para que no muestre las tareas pausadas o canceladas. 

/*
-- Ejemplo de Ejecucion:
  EXEC	[wms].[OP_WMS_SP_GET_MY_COUTING_TASK] @LOGIN = 'ACAMACHO'
  SELECT * FROM [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MY_COUTING_TASK] (@LOGIN VARCHAR(25))
AS
BEGIN
    SET NOCOUNT ON;
  --
    SELECT
        [H].[TASK_ID]
       ,[H].[REGIMEN]
       ,[H].[DISTRIBUTION_CENTER]
       ,[T].[PRIORITY]
       ,COUNT([H].[TASK_ID]) [LOCATIONS]
       ,[T].[ASSIGNED_DATE]
       ,[T].[TASK_TYPE]
    FROM
        [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [H]
    INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [D] ON [H].[PHYSICAL_COUNT_HEADER_ID] = [D].[PHYSICAL_COUNT_HEADER_ID]
    INNER JOIN [wms].[OP_WMS_TASK] [T] ON [H].[TASK_ID] = [T].[TASK_ID]
    WHERE
        [D].[ASSIGNED_TO] = @LOGIN
        AND [D].[STATUS] IN ('CREATED', 'IN_PROGRESS')
        AND [H].[STATUS] IN ('CREATED', 'IN_PROGRESS')
        AND [T].[IS_PAUSED] = 0
        AND [T].[IS_CANCELED] = 0
        AND [T].[IS_COMPLETE] = 0
    GROUP BY
        [H].[TASK_ID]
       ,[H].[REGIMEN]
       ,[H].[DISTRIBUTION_CENTER]
       ,[T].[PRIORITY]
       ,[T].[ASSIGNED_DATE]
       ,[T].[TASK_TYPE];

END;