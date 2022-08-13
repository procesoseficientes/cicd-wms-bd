-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	11/6/2017 @ NEXUS-Team Sprint F-Zero 
-- Description:			Obtiene las rutas filtradas por sector y fechas

/*
-- Ejemplo de Ejecucion:
				EXEC  [wms].[OP_WMS_SP_GET_ROUTES_BY_POLYGON_AND_DATES]
					@POLYGON = '9315|9319'
					,@EXTERNAL_SOURCE_POLYGON = '1|1'
					,@START_DATE = '2016-09-01 06:10:01.000'
					,@END_DATE = '2017-04-27 12:27:36.000'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_ROUTES_BY_POLYGON_AND_DATES](
	@POLYGON VARCHAR(MAX)
	,@EXTERNAL_SOURCE_POLYGON VARCHAR(MAX)
	,@START_DATE DATETIME
	,@END_DATE DATETIME
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
    CREATE TABLE #ROUTE(
		[LOGIN] VARCHAR(50)
		,[CODE_ROUTE] VARCHAR(50)
		,[NAME_ROUTE] VARCHAR(50)
		,[SELLER_CODE] VARCHAR(100)
		,[SELLER_NAME] VARCHAR(60)
		,[EXTERNAL_SOURCE_ID] INT
		,[SOURCE_NAME] VARCHAR(50)
	)

	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene los poligonos
		-- ------------------------------------------------------------------------------------
		SELECT [P].[ID]
              ,[P].[VALUE] [POLYGON_ID] 
			  ,[ES].[VALUE] [EXTERNAL_SOURCE_ID]
		INTO [#POLYGON]
		FROM [wms].[OP_WMS_FN_SPLIT](@POLYGON,'|') [P]
			INNER JOIN [wms].[OP_WMS_FN_SPLIT](@EXTERNAL_SOURCE_POLYGON, '|') [ES] ON [ES].[ID] = [P].[ID]
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

		--ALTER TABLE [#EXTERNAL_SOURCE]
		--ADD CONSTRAINT [PK_TEMP_EXTERNAL_SOURCE] PRIMARY KEY ([EXTERNAL_SOURCE_ID]);
		
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
				INSERT INTO [#ROUTE]
				(
					[LOGIN]
					,[CODE_ROUTE]
					,[NAME_ROUTE]
					,[SELLER_CODE]
					,[SELLER_NAME]
					,[EXTERNAL_SOURCE_ID]
					,[SOURCE_NAME] 
				)
				SELECT DISTINCT
					U.LOGIN
					,[SR].CODE_ROUTE
					,[SR].NAME_ROUTE
					,S.SELLER_CODE
					,S.SELLER_NAME
					,' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR) + ' [EXTERNAL_SOURCE_ID]
					,''' + @SOURCE_NAME + ''' [SOURCE_NAME]
				FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SONDA_SALES_ORDER_HEADER] [SSOH]
					INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SWIFT_CUSTOMER_ASSOCIATE_TO_POLYGON] [SPC] ON [SSOH].[CLIENT_ID] = [SPC].[CODE_CUSTOMER]
					INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SWIFT_ROUTES] [SR] ON [SSOH].[POS_TERMINAL] = [SR].[CODE_ROUTE]
					INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[USERS] [U]	ON (U.SELLER_ROUTE = SR.CODE_ROUTE)
					INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SWIFT_VIEW_ALL_SELLERS] S ON (U.RELATED_SELLER = S.SELLER_CODE)
					INNER JOIN [#POLYGON] [P] ON ([SPC].[POLYGON_ID] = [P].[POLYGON_ID] AND [P].[EXTERNAL_SOURCE_ID] = '+CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)+')
				WHERE [SSOH].[DELIVERY_DATE] BETWEEN CAST(''' + CONVERT(VARCHAR(30),@START_DATE, 21) + ''' AS DATETIME) AND CAST(''' + CONVERT(VARCHAR(30),@END_DATE, 21) + ''' AS DATETIME)
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
		SELECT [LOGIN]
              ,[CODE_ROUTE]
              ,[NAME_ROUTE]
              ,[SELLER_CODE]
              ,[SELLER_NAME]
              ,[EXTERNAL_SOURCE_ID]
              ,[SOURCE_NAME]
		FROM [#ROUTE]

	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH
END