-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	11/6/2017 @ NEXUS-Team Sprint F-Zero 
-- Description:			Obtiene los poligonos de sector filtrados por bodega

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_DISTRIBUTION_POLYGON_BY_WAREHOUSE]
				 @WAREHOUSE_ID = 'BODEGA_01'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_DISTRIBUTION_POLYGON_BY_WAREHOUSE](
	@WAREHOUSE_ID VARCHAR(25)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @EXTERNAL_SOURCE_ID INT
		,@SOURCE_NAME VARCHAR(50)
		,@DATA_BASE_NAME VARCHAR(50)
		,@SCHEMA_NAME VARCHAR(50)
		,@QUERY NVARCHAR(MAX);
	--
    CREATE TABLE [#POLYGON]
        (
         [POLYGON_ID] INT
        ,[POLYGON_NAME] VARCHAR(250)
        ,[POLYGON_DESCRIPTION] VARCHAR(250)
        ,[COMMENT] VARCHAR(250)
        ,[LAST_UPDATE_BY] VARCHAR(50)
        ,[LAST_UPDATE_DATETIME] DATETIME
        ,[POLYGON_ID_PARENT] INT
        ,[POLYGON_TYPE] VARCHAR(250)
        ,[SUB_TYPE] VARCHAR(250)
        ,[OPTIMIZE] INT
        ,[TYPE_TASK] VARCHAR(20)
        ,[CODE_WAREHOUSE] VARCHAR(50)
        ,[LAST_OPTIMIZATION] DATETIME
        ,[AVAILABLE] INT
        ,[IS_MULTISELLER] INT
		,[EXTERNAL_SOURCE_ID] INT NOT NULL
		,[SOURCE_NAME] VARCHAR(50) NOT NULL
		,PRIMARY KEY ([POLYGON_ID],[EXTERNAL_SOURCE_ID])
        );

	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene fuentes externas
		-- ------------------------------------------------------------------------------------
		SELECT
			[ES].[EXTERNAL_SOURCE_ID]
			,[ES].[SOURCE_NAME]
			,[ES].[DATA_BASE_NAME]
			,[ES].[SCHEMA_NAME]
		INTO [#EXTERNAL_SOURCE]
		FROM [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
		WHERE [ES].[EXTERNAL_SOURCE_ID] > 0;

		ALTER TABLE [#EXTERNAL_SOURCE]
		ADD CONSTRAINT [PK_TEMP_EXTERNAL_SOURCE] PRIMARY KEY ([EXTERNAL_SOURCE_ID]);
		
		WHILE EXISTS (SELECT TOP 1 1 FROM [#EXTERNAL_SOURCE] WHERE [EXTERNAL_SOURCE_ID] > 0)
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
			FROM [#EXTERNAL_SOURCE] [ES]
			WHERE [EXTERNAL_SOURCE_ID] > 0
			ORDER BY [ES].[EXTERNAL_SOURCE_ID];
			--
			PRINT '----> @EXTERNAL_SOURCE_ID: ' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR);
			PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
			PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME;
			PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;
			--
			SELECT @QUERY = '
				INSERT INTO [#POLYGON]
				SELECT [SP].[POLYGON_ID]
					  ,[SP].[POLYGON_NAME]
					  ,[SP].[POLYGON_DESCRIPTION]
					  ,[SP].[COMMENT]
					  ,[SP].[LAST_UPDATE_BY]
					  ,[SP].[LAST_UPDATE_DATETIME]
					  ,[SP].[POLYGON_ID_PARENT]
					  ,[SP].[POLYGON_TYPE]
					  ,[SP].[SUB_TYPE]
					  ,[SP].[OPTIMIZE]
					  ,[SP].[TYPE_TASK]
					  ,[SP].[CODE_WAREHOUSE]
					  ,[SP].[LAST_OPTIMIZATION]
					  ,[SP].[AVAILABLE]
					  ,[SP].[IS_MULTISELLER] 
					  ,' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR) + ' [EXTERNAL_SOURCE_ID]
					  ,''' + @SOURCE_NAME + ''' [SOURCE_NAME]
				FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SWIFT_POLYGON] [SP]
					INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SWIFT_WAREHOUSES] [SW] ON [SW].[CODE_WAREHOUSE] = [SP].[CODE_WAREHOUSE]
					INNER JOIN [wms].[OP_WMS_WAREHOUSES] [OW] ON [OW].[WAREHOUSE_ID] = [SW].[CODE_WAREHOUSE_3PL]
				WHERE [SP].[POLYGON_TYPE] = ''SECTOR'' AND [SP].[SUB_TYPE] = ''DISTRIBUTION'' AND [OW].[WAREHOUSE_ID] = ''' + @WAREHOUSE_ID + '''
			'
			--
			PRINT '--> @QUERY: ' + @QUERY;
			--
			EXEC (@QUERY);
			---- ------------------------------------------------------------------------------------
			-- Elimina la fuente externa
			-- ------------------------------------------------------------------------------------
			DELETE FROM [#EXTERNAL_SOURCE]
			WHERE [EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;
		END
		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado final
		-- ------------------------------------------------------------------------------------
		SELECT [POLYGON_ID]
              ,[POLYGON_NAME]
              ,[POLYGON_DESCRIPTION]
              ,[COMMENT]
              ,[LAST_UPDATE_BY]
              ,[LAST_UPDATE_DATETIME]
              ,[POLYGON_ID_PARENT]
              ,[POLYGON_TYPE]
              ,[SUB_TYPE]
              ,[OPTIMIZE]
              ,[TYPE_TASK]
              ,[CODE_WAREHOUSE]
              ,[LAST_OPTIMIZATION]
              ,[AVAILABLE]
              ,[IS_MULTISELLER]
              ,[EXTERNAL_SOURCE_ID]
              ,[SOURCE_NAME] 
		FROM [#POLYGON]

	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH
END