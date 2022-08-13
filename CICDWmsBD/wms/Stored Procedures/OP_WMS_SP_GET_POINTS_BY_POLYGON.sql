-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	11/6/2017 @ NEXUS-Team Sprint F-Zero 
-- Description:			Obtiene los puntos del poligono

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_POINTS_BY_POLYGON]
					@POLYGON_ID = 9315
					,@EXTERNAL_SOURCE_ID = 1
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_POINTS_BY_POLYGON](
	@POLYGON_ID INT
	,@EXTERNAL_SOURCE_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @SOURCE_NAME VARCHAR(50)
		,@DATA_BASE_NAME VARCHAR(50)
		,@SCHEMA_NAME VARCHAR(50)
		,@QUERY NVARCHAR(MAX);
	--
    CREATE TABLE [#POLYGON_POINT]
        (
        [POLYGON_ID] int NOT NULL,
		[POSITION] int NOT NULL,
		[LATITUDE] varchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL,
		[LONGITUDE] varchar(250) COLLATE SQL_Latin1_General_CP1_CI_AS NOT NULL
        );
	--
	BEGIN TRY 
		SELECT TOP 1
			@SOURCE_NAME = [ES].[SOURCE_NAME]
			,@DATA_BASE_NAME = [ES].[DATA_BASE_NAME]
			,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
			,@QUERY = N''
		FROM [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
		WHERE [EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;
		--
		PRINT '----> @EXTERNAL_SOURCE_ID: ' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR);
		PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
		PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME;
		PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;
		--
		SELECT @QUERY = '
			INSERT INTO [#POLYGON_POINT]
			SELECT  
				[SPP].[POLYGON_ID]
				,[SPP].[POSITION]
				,[SPP].[LATITUDE]
				,[SPP].[LONGITUDE]
			FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SWIFT_POLYGON_POINT] [SPP]
			WHERE [SPP].[POLYGON_ID] = '''+CAST(@POLYGON_ID AS VARCHAR)+'''
		'
		--
		PRINT '--> @QUERY: ' + @QUERY;
		--
		EXEC (@QUERY);

		-- ------------------------------------------------------------------------------------
		-- Resultado final
		-- ------------------------------------------------------------------------------------
		SELECT [POLYGON_ID]
              ,[POSITION]
              ,[LATITUDE]
              ,[LONGITUDE] 
		FROM [#POLYGON_POINT]

	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH
END