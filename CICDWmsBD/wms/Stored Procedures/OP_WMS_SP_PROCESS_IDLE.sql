-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	03-Jun-2019 G-Force@Berlin-Swift3PL
-- Description:			Sp que obtiene que procesa todo el inventario inactivo del dia anterior

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_PROCESS_IDLE]
*/
-- =============================================  
CREATE PROCEDURE [wms].[OP_WMS_SP_PROCESS_IDLE]
AS
BEGIN
  BEGIN TRAN;
  BEGIN TRY
    SET NOCOUNT ON;
    -- --------------------------------------------------
    -- Declaramos las variables necearias 
    -- --------------------------------------------------
    DECLARE @ALL_TRANS_TABLE TABLE (
      [LICENSE_ID] INT
     ,[MATERIAL_CODE] VARCHAR(50)
     ,[TRANS_TYPE] VARCHAR(25)
     ,[IDLE] INT NULL DEFAULT (0)
     ,[NUMBER_OF_COMPLETE_RELOCATIONS] INT NULL DEFAULT (0)
     ,[NUMBER_OF_PARTIAL_RELOCATIONS] INT NULL DEFAULT (0)
     ,[NUMBER_OF_PHYSICAL_COUNTS] INT NULL DEFAULT (0)
    )

    DECLARE @TRANS_TABLE TABLE (
      [LICENSE_ID] INT
     ,[MATERIAL_CODE] VARCHAR(50)
     ,[IDLE] INT NULL DEFAULT (0)
     ,[NUMBER_OF_COMPLETE_RELOCATIONS] INT NULL DEFAULT (0)
     ,[NUMBER_OF_PARTIAL_RELOCATIONS] INT NULL DEFAULT (0)
     ,[NUMBER_OF_PHYSICAL_COUNTS] INT NULL DEFAULT (0)
    )

    -- --------------------------------------------------
    -- Obtenemos todas las transacciones del dia anterior para su proceso 
    -- --------------------------------------------------
    INSERT INTO @ALL_TRANS_TABLE ([LICENSE_ID], [MATERIAL_CODE], [TRANS_TYPE], [IDLE], [NUMBER_OF_COMPLETE_RELOCATIONS], [NUMBER_OF_PARTIAL_RELOCATIONS], [NUMBER_OF_PHYSICAL_COUNTS])
      SELECT
        CASE [T].[TRANS_TYPE]
          WHEN 'REUBICACION_PARCIAL' THEN [T].[SOURCE_LICENSE]
          ELSE [T].[LICENSE_ID]
        END AS [LICENSE_ID]
       ,CASE [T].[MATERIAL_CODE]
          WHEN '' THEN NULL
          ELSE [T].[MATERIAL_CODE]
        END [MATERIAL_CODE]
       ,[T].[TRANS_TYPE]
       ,CASE [T].[TRANS_TYPE]
          WHEN 'DESPACHO_ALMGEN' THEN 1
          WHEN 'DESPACHO_FISCAL' THEN 1
          WHEN 'DESPACHO_GENERAL' THEN 1
          ELSE 0
        END AS [IDLE]
       ,CASE [T].[TRANS_TYPE]
          WHEN 'REUBICACION_COMPLETA' THEN 1
          ELSE 0
        END AS [NUMBER_OF_COMPLETE_RELOCATIONS]
       ,CASE [T].[TRANS_TYPE]
          WHEN 'REUBICACION_PARCIAL' THEN 1
          ELSE 0
        END AS [NUMBER_OF_PARTIAL_RELOCATIONS]
       ,CASE [T].[TRANS_TYPE]
          WHEN 'CONTEO_FISICO' THEN 1
          ELSE 0
        END AS [NUMBER_OF_PHYSICAL_COUNTS]
      FROM [wms].[OP_WMS_TRANS] [T]
      WHERE [T].[LICENSE_ID] IS NOT NULL
      AND [T].[TRANS_TYPE] IN ('DESPACHO_ALMGEN', 'DESPACHO_FISCAL', 'DESPACHO_GENERAL', 'CONTEO_FISICO', 'REUBICACION_COMPLETA', 'REUBICACION_PARCIAL')
      AND CAST([T].[TRANS_DATE] AS DATE) = CAST(DATEADD(DAY, -1, GETDATE()) AS DATE)

    -- --------------------------------------------------
    -- Agrupamos las licencias con su material y sumamos todas las transacciones que obtuvimos previamente.
    -- --------------------------------------------------
    INSERT INTO @TRANS_TABLE ([LICENSE_ID], [MATERIAL_CODE], [IDLE], [NUMBER_OF_COMPLETE_RELOCATIONS], [NUMBER_OF_PARTIAL_RELOCATIONS], [NUMBER_OF_PHYSICAL_COUNTS])
      SELECT
        [ATT].[LICENSE_ID]
       ,[ATT].[MATERIAL_CODE]
       ,SUM([ATT].[IDLE]) AS [IDLE]
       ,SUM([ATT].[NUMBER_OF_COMPLETE_RELOCATIONS]) AS [NUMBER_OF_COMPLETE_RELOCATIONS]
       ,SUM([ATT].[NUMBER_OF_PARTIAL_RELOCATIONS]) AS [NUMBER_OF_PARTIAL_RELOCATIONS]
       ,SUM([ATT].[NUMBER_OF_PHYSICAL_COUNTS]) AS [NUMBER_OF_PHYSICAL_COUNTS]
      FROM @ALL_TRANS_TABLE [ATT]
      GROUP BY [ATT].[LICENSE_ID]
              ,[ATT].[MATERIAL_CODE]

    -- --------------------------------------------------
    -- Actualizamos la cantidad de reubicaciones completas
    -- --------------------------------------------------  
    UPDATE [IL]
    SET [IL].[NUMBER_OF_COMPLETE_RELOCATIONS] = [IL].[NUMBER_OF_COMPLETE_RELOCATIONS] + [TT].[NUMBER_OF_COMPLETE_RELOCATIONS]
    FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
    INNER JOIN @TRANS_TABLE [TT]
      ON ([IL].[LICENSE_ID] = [TT].[LICENSE_ID])
    WHERE [IL].[QTY] > 0
    AND [TT].[MATERIAL_CODE] IS NULL


    -- --------------------------------------------------
    -- Actualizamos los campos transacciones de la tabla [OP_WMS_INV_X_LICENSE]
    -- --------------------------------------------------
    UPDATE [IL]
    SET [IL].[IDLE] =
                     CASE
                       WHEN [TT].[IDLE] > 0 THEN 0
                       ELSE [IL].[IDLE] + 1
                     END
       ,[IL].[NUMBER_OF_PARTIAL_RELOCATIONS] = [IL].[NUMBER_OF_PARTIAL_RELOCATIONS] + ISNULL([TT].[NUMBER_OF_PARTIAL_RELOCATIONS], 0)
       ,[IL].[NUMBER_OF_PHYSICAL_COUNTS] = [IL].[NUMBER_OF_PHYSICAL_COUNTS] + ISNULL([TT].[NUMBER_OF_PHYSICAL_COUNTS], 0)
    FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
    LEFT JOIN @TRANS_TABLE [TT]
      ON ([IL].[LICENSE_ID] = [TT].[LICENSE_ID]
      AND [IL].[MATERIAL_ID] = [TT].[MATERIAL_CODE])
    WHERE [IL].[QTY] > 0

    COMMIT TRAN;

    -- --------------------------------------------------
    -- Retornamos el objeto operacion que fue exitoso
    -- --------------------------------------------------
    SELECT
      1 AS [Resultado]
     ,'Proceso Exitoso' [Mensaje]
     ,0 [Codigo];

  END TRY
  BEGIN CATCH
    ROLLBACK;
    SELECT
      -1 AS [Resultado]
     ,ERROR_MESSAGE() [Mensaje]
     ,@@ERROR [Codigo];
  END CATCH
END