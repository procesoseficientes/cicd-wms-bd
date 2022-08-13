
-- =============================================
-- Autor:	rudi.garcia
-- Fecha de Creacion: 	2017-03-01 @ Team ERGON - Sprint IV ERGON 
-- Description:	 Obtiene los detalles de las tareas para el reporte de graficas en el administrador de tareas



-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-24 ErgonTeam@Sheik
-- Description:	 Se modifica para que traiga el nombre del operador y del tipo de tarea



/*
-- Ejemplo de Ejecucion:
	EXEC [wms].OP_WMS_GET_GET_OPERATORS_GRAPHICS_TASK @START_DATETIME = '2017-02-03 00:00:00.000'
												,@END_DATETIME = '2018-02-03 23:59:00.000'
                        ,@USERS = 'ACAMACHO|BCORADO|AREYES'
                        ,@TYPES = 'TAREA_PICKING|TAREA_RECEPCION|TAREA_CONTEO_FISICO' 
                        ,@LOGIN = 'ADMIN'  

*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_GET_GET_OPERATORS_GRAPHICS_TASK (@START_DATETIME DATETIME
, @END_DATETIME DATETIME
, @USERS VARCHAR(MAX) = NULL
, @TYPES VARCHAR(MAX) = NULL
, @LOGIN VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @MAX_ATTEMPTS INT = 5;

  DECLARE @TB_WAREHOUSE TABLE (
    [WAREHOUSE_ID] VARCHAR(25)
  );

  SET @USERS = @USERS + '|'

  SELECT
    @MAX_ATTEMPTS = [C].[NUMERIC_VALUE]
  FROM [wms].[OP_WMS_CONFIGURATIONS] [C]
  WHERE [C].[PARAM_TYPE] = 'SISTEMA'
  AND [C].[PARAM_GROUP] = 'MAX_NUMBER_OF_ATTEMPTS'
  AND [C].[PARAM_NAME] = 'MAX_NUMBER_OF_SENDING_ATTEMPTS_TO_ERP'

  SELECT
    [T].[VALUE] AS [TYPE]
   ,[C].[PARAM_CAPTION] AS TYPE_NAME INTO #TYPES
  FROM [wms].[OP_WMS_FN_SPLIT](@TYPES, '|') [T]
  INNER JOIN [wms].[OP_WMS_CONFIGURATIONS] [C]
    ON [C].[PARAM_NAME] = [T].[VALUE]
    AND [C].[PARAM_TYPE] = 'SISTEMA'
    AND [C].[PARAM_GROUP] = 'TASK_TYPES'



  SELECT
    [T].[VALUE] AS [LOGIN]
   ,[L].[LOGIN_NAME] AS [NAME] INTO #USERS
  FROM [wms].[OP_WMS_FN_SPLIT](@USERS, '|') [T]
  INNER JOIN [wms].[OP_WMS_LOGINS] [L]
    ON [L].[LOGIN_ID] = [T].[VALUE]


  -- --------------------
  -- Se obtine las bodegas asociadas al login enviado
  -- --------------------

  INSERT INTO @TB_WAREHOUSE ([WAREHOUSE_ID])
    SELECT
      [WU].[WAREHOUSE_ID]
    FROM [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU]
    WHERE [WU].[LOGIN_ID] = @LOGIN
  --

  SELECT
    * INTO #RESULT
  FROM (SELECT
      [VT].[TASK_TYPE]
     ,[U].[NAME] [TASK_ASSIGNEDTO]
     ,ISNULL(DATEDIFF(MINUTE, [VT].[ACCEPTED_DATE], [VT].[PICKING_FINISHED_DATE]), 0) AS [TIME]
    FROM [wms].OP_WMS_VIEW_TASK VT
    LEFT JOIN [#USERS] [U]
      ON ([U].[login] = [VT].[TASK_ASSIGNEDTO])
    WHERE [VT].[ASSIGNED_DATE] BETWEEN @START_DATETIME
    AND @END_DATETIME
    AND (@USERS IS NULL
    OR [U].[login] IS NOT NULL)
    AND [VT].[IS_CANCELED] = 0
    AND [VT].[TASK_TYPE] = 'TAREA_RECEPCION'

    UNION

    SELECT
      [VT].[TASK_TYPE]
     ,[U].[NAME] [TASK_ASSIGNEDTO]
     ,ISNULL(DATEDIFF(MINUTE, [VT].[ACCEPTED_DATE], [VT].[PICKING_FINISHED_DATE]), 0) AS [TIME]
    FROM [wms].[OP_WMS_VIEW_TASK] [VT]
    INNER JOIN @TB_WAREHOUSE [W]
      ON (
      [W].[WAREHOUSE_ID] = [VT].[WAREHOUSE_SOURCE]
      )
    LEFT JOIN [#USERS] [U]
      ON (
      [U].[login] = [VT].[TASK_ASSIGNEDTO]
      )
    WHERE [VT].[ASSIGNED_DATE] BETWEEN @START_DATETIME
    AND @END_DATETIME
    AND (@USERS IS NULL
    OR [U].[login] IS NOT NULL)
    AND [VT].[IS_CANCELED] = 0
    AND [VT].[TASK_TYPE] = 'TAREA_PICKING'


    UNION

    SELECT
      [T].[TASK_TYPE]
     ,[U].[NAME] AS [TASK_ASSIGNEDTO]
     ,ISNULL(DATEDIFF(MINUTE, [T].[ACCEPTED_DATE], [T].[COMPLETED_DATE]), 0) AS [TIME]
    FROM [wms].[OP_WMS_TASK] [T]
    INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [CH]
      ON [T].[TASK_ID] = [CH].[TASK_ID]
    INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [CD]
      ON [CH].[PHYSICAL_COUNT_HEADER_ID] = [CD].[PHYSICAL_COUNT_HEADER_ID]
    INNER JOIN #USERS [U]
      ON (
      [U].[login] = [CD].[ASSIGNED_TO]
      )
    WHERE [T].[ASSIGNED_DATE] BETWEEN @START_DATETIME
    AND @END_DATETIME
    AND [T].[IS_CANCELED] = 0
    AND [T].[TASK_TYPE] = 'TAREA_CONTEO_FISICO') AS T
  ORDER BY [T].[TASK_TYPE]


  SELECT
    [T].[type_name] [TASK_TYPE]
   ,[R].[TASK_ASSIGNEDTO]
   ,[R].[TIME]
  FROM [#RESULT] R
  LEFT JOIN [#TYPES] [T]
    ON [R].[TASK_TYPE] = [T].[type]
  WHERE (@TYPES IS NULL
  OR [T].[type] IS NOT NULL)
  AND [R].[TIME] > 0


END