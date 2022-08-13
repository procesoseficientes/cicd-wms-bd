
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	01-Nov-16 @ A-TEAM Sprint 4 
-- Description:			

-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	31-Ene-17 @ Ergon Team Sprint ERGON II
-- Description:			    Se modifico para que se validara la bodega tambien

-- Modificacion:				rudi.garcia
-- Fecha de Creacion: 	2017-04-18 @Team Ergon  Sprint Epona
-- Description:			    Se modifico para que se validara la bodega tambien


-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-19 ErgonTeam@SHEIK
-- Description:	 Se agregó Join a materials para que sin importar si no se obtuvo en la vista de inventario este muestre el nombre del material.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_VALIDATE_STOCK_INVENTORY_BY_MATERIALS]
					@EXTERNAL_SOURCE_ID = '1|2'
					,@MATERIAL_ID = 'wms/100002|confitesa/000000000000000002'
					,@QTY = '1000|10'
          ,@CODE_WAREHOUSE = 'BODEGA_01'
				--
				EXEC [wms].[OP_WMS_SP_VALIDATE_STOCK_INVENTORY_BY_MATERIALS]
					@EXTERNAL_SOURCE_ID = '1|1'
					,@MATERIAL_ID = 'wms/100002|wms/100002'
					,@QTY = '1500|100'
          ,@CODE_WAREHOUSE = 'BODEGA_01'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_STOCK_INVENTORY_BY_MATERIALS] (@EXTERNAL_SOURCE_ID VARCHAR(MAX)
, @MATERIAL_ID VARCHAR(MAX)
, @QTY VARCHAR(MAX)
, @CODE_WAREHOUSE VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @SOURCE_NAME VARCHAR(50)
         ,@DATA_BASE_NAME VARCHAR(50)
         ,@SCHEMA_NAME VARCHAR(50)
         ,@QUERY NVARCHAR(MAX)
         ,@DELIMITER CHAR(1) = '|'

  -- ------------------------------------------------------------------------------------
  -- Obtiene los materiales
  -- ------------------------------------------------------------------------------------
  SELECT
    [ES].[EXTERNAL_SOURCE_ID]
   ,MAX([ES].[SOURCE_NAME]) [SOURCE_NAME]
   ,[M].[VALUE] [MATERIAL_ID]
   ,SUM(CONVERT(NUMERIC, [Q].[VALUE])) [QTY] INTO [#MATIRIAL]
  FROM [wms].OP_WMS_FUNC_SPLIT_3(@EXTERNAL_SOURCE_ID, @DELIMITER) [E]
  INNER JOIN [wms].OP_WMS_FUNC_SPLIT_3(@MATERIAL_ID, @DELIMITER) [M]
    ON (
    [E].[ID] = [M].[ID]
    )
  INNER JOIN [wms].OP_WMS_FUNC_SPLIT_3(@QTY, @DELIMITER) [Q]
    ON (
    [M].[ID] = [Q].[ID]
    )
  INNER JOIN [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
    ON (
    CONVERT(INT, [E].[VALUE]) = [ES].[EXTERNAL_SOURCE_ID]
    )
  GROUP BY [ES].[EXTERNAL_SOURCE_ID]
          ,[M].[VALUE]

  -- ------------------------------------------------------------------------------------
  -- Obtiene el inventario disponible
  -- ------------------------------------------------------------------------------------
  SELECT
    [TM].[EXTERNAL_SOURCE_ID]
   ,MAX([TM].[SOURCE_NAME]) AS [SOURCE_NAME]
   ,MAX([TM].[SOURCE_NAME]) AS [CLIENT_OWNER]
   ,[TM].[MATERIAL_ID]
   ,MAX([IP].[MATERIAL_NAME]) AS [MATERIAL_NAME]
   ,SUM([TM].[QTY]) AS [REQUEST_QTY]
   ,ISNULL(SUM([IP].[AVAILABLE_QTY]), 0) AS [QTY]
   ,(ISNULL(SUM([IP].[AVAILABLE_QTY]), 0) - SUM([TM].[QTY])) [DIFFERENCE]
   ,CASE
      WHEN (ISNULL(SUM([IP].[AVAILABLE_QTY]), 0) >= SUM([TM].[QTY])) THEN 1
      ELSE 0
    END [IS_AVAILABE] INTO #INVENTORY
  FROM [#MATIRIAL] AS [TM]
--  INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
--    ON [TM].[MATERIAL_ID] = [M].[MATERIAL_ID]
  LEFT JOIN [wms].[OP_WMS_VIEW_INVENTORY_FOR_PICKING] AS [IP]
    ON (
    [TM].[MATERIAL_ID] = [IP].[MATERIAL_ID]
    AND [TM].[SOURCE_NAME] = [IP].[CLIENT_CODE]
    AND [IP].[CURRENT_WAREHOUSE] = @CODE_WAREHOUSE
    )
  GROUP BY [TM].[EXTERNAL_SOURCE_ID]
          ,[TM].[MATERIAL_ID]
  -- ------------------------------------------------------------------------------------
  -- Muestra el resultado
  -- ------------------------------------------------------------------------------------
  SELECT
    [I].[EXTERNAL_SOURCE_ID]
   ,[I].[SOURCE_NAME]
   ,[I].[CLIENT_OWNER]
   ,[I].[MATERIAL_ID]
   ,[I].[MATERIAL_NAME]
   ,[I].[QTY]
   ,[I].[REQUEST_QTY]
   ,[I].[difference]
  FROM [#INVENTORY] [I]
  WHERE [I].[IS_AVAILABE] != 1
END