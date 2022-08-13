-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-02-22 @ Team ERGON - Sprint ERGON 
-- Description:	        sp que trae el detalle de un conteo

-- Modificación: rudi.garcia
-- Fecha de Creacion: 	2017-03-01 Team ERGON - Sprint IV ERGON
-- Description:	 Se agrego el parametro @LOGIN para el filtrado de operadores releacionados al CD del login

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_GET_TASK_DETAIL_FOR_COUNT] @TASK_ID = 8, @LOGIN = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TASK_DETAIL_FOR_COUNT] (@TASK_ID INT
, @LOGIN VARCHAR(25))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @TB_USERS TABLE (
    [LOGIN_ID] VARCHAR(25)
   ,[LOGIN_NAME] VARCHAR(50)
  );

  -- --------------------
  -- Se obtine los usuarios tipo operador relacionados al login enviado
  -- --------------------

  INSERT INTO @TB_USERS ([LOGIN_ID], [LOGIN_NAME])
  EXEC [wms].[OP_WMS_SP_GET_OPERATORS_ASSIGNED_TO_DISTRIBUTION_CENTER_BY_USER] @LOGIN

  --
  SELECT
    [CD].[PHYSICAL_COUNT_DETAIL_ID]
   ,[CD].[WAREHOUSE_ID]
   ,[CD].[ZONE]
   ,[CD].[LOCATION]
   ,[CD].[CLIENT_CODE]
   ,[CD].[MATERIAL_ID]
   ,[CD].[ASSIGNED_TO]   
   ,CASE [CD].[STATUS]
      WHEN 'CREATED' THEN 'CREADO'
      WHEN 'IN_PROGRESS' THEN 'EN_PROGRESO'
      WHEN 'COMPLETED' THEN 'COMPLETA'
    END AS [STATUS]
   ,[CH].[REGIMEN]
   ,[CH].[DISTRIBUTION_CENTER]
   ,[CE].[QTY_SCANNED]
   ,[CE].[QTY_EXPECTED]
   ,[CE].[QTY_SCANNED] - [CE].[QTY_EXPECTED] [DIFFERENCE]
  FROM [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [CD]
  INNER JOIN @TB_USERS [U]
    ON (
      [U].[LOGIN_ID] = [CD].[ASSIGNED_TO]
      )
  INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [CH]
    ON [CD].[PHYSICAL_COUNT_HEADER_ID] = [CH].[PHYSICAL_COUNT_HEADER_ID]
  INNER JOIN [wms].[OP_WMS_TASK] [T]
    ON [CH].[TASK_ID] = [T].[TASK_ID]
  LEFT JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_EXECUTION] [CE] 
    ON [CD].[PHYSICAL_COUNT_DETAIL_ID] = [CE].[PHYSICAL_COUNT_DETAIL_ID]
							AND (
							[CD].[MATERIAL_ID] IS NULL
							OR [CD].[MATERIAL_ID] = [CE].[MATERIAL_ID]
							)
 WHERE [T].[TASK_ID] = @TASK_ID


END