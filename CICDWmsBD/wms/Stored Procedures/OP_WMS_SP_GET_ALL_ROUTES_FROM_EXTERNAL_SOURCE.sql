-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	15-02-17 @ Team Ergon SPRINT ERGON III 
-- Description:			    SP que obtiene las rutas de las fuentes externas (solo rutas)

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_ALL_ROUTES_FROM_EXTERNAL_SOURCE]
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_ALL_ROUTES_FROM_EXTERNAL_SOURCE
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @EXTERNAL_SOURCE_ID INT
         ,@SOURCE_NAME VARCHAR(50)
         ,@DATA_BASE_NAME VARCHAR(50)
         ,@SCHEMA_NAME VARCHAR(50)
         ,@QUERY NVARCHAR(MAX)
  
  CREATE TABLE #ROUTE (
    [ROUTE] INT
   ,[CODE_ROUTE] VARCHAR(50)
   ,[NAME_ROUTE] VARCHAR(50)
   ,[GEOREFERENCE_ROUTE] VARCHAR(50)
   ,[COMMENT_ROUTE] VARCHAR(MAX)
   ,[LAST_UPDATE] DATETIME
   ,[LAST_UPDATE_BY] VARCHAR(50)
   ,[EXTERNAL_SOURCE_ID] INT
   ,[SOURCE_NAME] VARCHAR(50)
  )

  BEGIN TRY
    -- ------------------------------------------------------------------------------------
    -- Obtiene las fuentes externas
    -- ------------------------------------------------------------------------------------
    SELECT
      [ES].[EXTERNAL_SOURCE_ID]
     ,[ES].[SOURCE_NAME]
     ,[ES].[DATA_BASE_NAME]
     ,[ES].[SCHEMA_NAME] INTO #EXTERNAL_SOURCE
    FROM [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]

    -- ------------------------------------------------------------------------------------
    -- Ciclo para obtener las rutas
    -- ------------------------------------------------------------------------------------
    PRINT '--> Inicia el ciclo'
    --
    WHILE EXISTS (SELECT TOP 1
          1
        FROM [#EXTERNAL_SOURCE])
    BEGIN
      -- ------------------------------------------------------------------------------------
      -- Se toma la primera fuente extermna
      -- ------------------------------------------------------------------------------------
      SELECT TOP 1
        @EXTERNAL_SOURCE_ID = [ES].[EXTERNAL_SOURCE_ID]
       ,@SOURCE_NAME = [ES].[SOURCE_NAME]
       ,@DATA_BASE_NAME = [ES].[DATA_BASE_NAME]
       ,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
       ,@QUERY = N''
      FROM #EXTERNAL_SOURCE [ES]
      ORDER BY [ES].[EXTERNAL_SOURCE_ID]
      --
      PRINT '----> @EXTERNAL_SOURCE_ID: ' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
      PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME
      PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME
      PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME

      -- ------------------------------------------------------------------------------------
      -- Obtiene las ordenes de venta de la fuente externa
      -- ------------------------------------------------------------------------------------
      SELECT
        @QUERY = N' INSERT INTO #ROUTE
        SELECT 
          [R].[ROUTE]
         ,[R].[CODE_ROUTE]
         ,[R].[NAME_ROUTE]
         ,[R].[GEOREFERENCE_ROUTE]
         ,[R].[COMMENT_ROUTE]
         ,[R].[LAST_UPDATE]
         ,[R].[LAST_UPDATE_BY]  
         ,' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR) + ' AS [EXTERNAL_SOURCE_ID]
         ,''' + @SOURCE_NAME + ''' AS [SOURCE_NAME]         
			FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SWIFT_VIEW_ALL_ROUTE] [R]'
      --
      PRINT '--> @QUERY: ' + @QUERY
      --
      EXEC (@QUERY)

      
      -- ------------------------------------------------------------------------------------
      -- Eleminamos la fuente externa
      -- ------------------------------------------------------------------------------------
      DELETE FROM [#EXTERNAL_SOURCE]
      WHERE [EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID
    END
    --
    PRINT '--> Termino el ciclo'

    -- ------------------------------------------------------------------------------------
    -- Muestra el resultado
    -- ------------------------------------------------------------------------------------
    SELECT
      [R].[ROUTE]
     ,[R].[CODE_ROUTE]
     ,[R].[NAME_ROUTE]
     ,[R].[GEOREFERENCE_ROUTE]
     ,[R].[COMMENT_ROUTE]
     ,[R].[LAST_UPDATE]
     ,[R].[LAST_UPDATE_BY]
     ,[R].[EXTERNAL_SOURCE_ID]
     ,[R].[SOURCE_NAME]
    FROM [#ROUTE] [R]
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS Resultado
     ,ERROR_MESSAGE() Mensaje
     ,@@ERROR Codigo
  END CATCH
END