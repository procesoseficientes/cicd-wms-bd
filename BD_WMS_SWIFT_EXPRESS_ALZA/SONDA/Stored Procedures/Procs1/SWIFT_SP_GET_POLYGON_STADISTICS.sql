-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	13-Jan-17 @ A-TEAM Sprint Adeben 
-- Description:			SP que obtiene las estadisticas de venta por poligonos

-- Modificacion 4/3/2017 @ A-Team Sprint Garai
-- diego.as
-- Se agrega columna IS_READY_TO_SEND para filtrar las facturas por esa columna.

-- Modificacion 14/4/2017 @ A-Team Sprint Hondo
-- hector.gonzalez
-- Se agrego inner join a usuarios, rutas, y poligonos por rutas para filtrar los usuario por poligono en el while

/*
-- Ejemplo de Ejecucion:
				    EXEC [SONDA].[SWIFT_SP_GET_POLYGON_STADISTICS]
				    	@POLYGON_TYPE = 'REGION'
				    	,@START_DATETIME = '20161201 00:00:00.000'
				    	,@END_DATETIME = '20170201 00:00:00.000'
				    	,@TAG_COLORS = NULL
				    	,@CHANNELS = NULL
				    	,@TYPE = 'SALE'
				    --
				    EXEC [SONDA].[SWIFT_SP_GET_POLYGON_STADISTICS]
				    	@POLYGON_TYPE = 'REGION'
				    	,@START_DATETIME = '20161201 00:00:00.000'
				    	,@END_DATETIME = '20170201 00:00:00.000'
				    	,@TAG_COLORS = NULL
				    	,@CHANNELS = NULL--'21|1'
				    	,@TYPE = 'PRESALE'
				    --
				    EXEC [SONDA].[SWIFT_SP_GET_POLYGON_STADISTICS]
				    	@POLYGON_TYPE = 'SECTOR'
				    	,@POLYGON_SUB_TYPE = 'COMMERCIAL'
				    	,@POLYGON_ID_PARENT = 63
				    	,@START_DATETIME = '20161201 00:00:00.000'
				    	,@END_DATETIME = '20170201 00:00:00.000'
				    	,@TAG_COLORS = '#3D1D1D'--NULL
				    	,@CHANNELS = NULL--'21|1'
				    	,@TYPE = 'SALE'
				    --
				    EXEC [SONDA].[SWIFT_SP_GET_POLYGON_STADISTICS]
				    	@POLYGON_TYPE = 'SECTOR'
				    	,@POLYGON_SUB_TYPE = 'COMMERCIAL'
				    	,@POLYGON_ID_PARENT = 63
				    	,@START_DATETIME = '20161201 00:00:00.000'
				    	,@END_DATETIME = '20170201 00:00:00.000'
				    	,@TAG_COLORS = NULL
				    	,@CHANNELS = NULL
				    	,@TYPE = 'PRESALE'
				    --
				    EXEC [SONDA].[SWIFT_SP_GET_POLYGON_STADISTICS]
				    	@POLYGON_TYPE = 'RUTA'
				    	,@POLYGON_SUB_TYPE = 'COMMERCIAL'
				    	,@POLYGON_ID_PARENT = 5167
				    	,@START_DATETIME = '20161201 00:00:00.000'
				    	,@END_DATETIME = '20170201 00:00:00.000'
				    	,@TAG_COLORS = NULL
				    	,@CHANNELS = NULL
				    	,@TYPE = 'SALE'
				    --
				    EXEC [SONDA].[SWIFT_SP_GET_POLYGON_STADISTICS]
				    	@POLYGON_TYPE = 'RUTA'
				    	,@POLYGON_SUB_TYPE = 'COMMERCIAL'
				    	,@POLYGON_ID_PARENT = 5167
				    	,@START_DATETIME = '20161201 00:00:00.000'
				    	,@END_DATETIME = '20170201 00:00:00.000'
				    	,@TAG_COLORS = NULL
				    	,@CHANNELS = '21|1'
				    	,@TYPE = 'PRESALE'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_POLYGON_STADISTICS]
	(
		@POLYGON_TYPE VARCHAR(250)
		,@POLYGON_SUB_TYPE VARCHAR(250) = NULL
		,@POLYGON_ID_PARENT INT = NULL
		,@START_DATETIME DATETIME
		,@END_DATETIME DATETIME
		,@TAG_COLORS VARCHAR(MAX) = NULL
		,@CHANNELS VARCHAR(MAX) = NULL
		,@TYPE VARCHAR(50)
	)
AS
	BEGIN
		SET NOCOUNT ON;
  --
		BEGIN TRY
    -- ------------------------------------------------------------------------------------
    -- Declaramos las variables a utilizar
    -- ------------------------------------------------------------------------------------
			DECLARE
				@TOTAL_CUSTOMERS INT = 0
				,@vPOLYGON_ID INT
				,@GEOMETRY_POLYGON GEOMETRY
				,@CUSTOMER_COUNT INT
				,@PERCENT NUMERIC(18 ,6)
				,@TOTAL_AMOUNT NUMERIC(18 ,6)
				,@ALL_TOTAL_AMOUNT NUMERIC(18 ,6)
				,@DELIMITER VARCHAR(1)
				,@DEFAULT_DISPLAY_DECIMALS INT
				,@QUERY NVARCHAR(4000);
    --
			CREATE TABLE [#POLYGON_AVG]
				(
					[POLYGON_ID] INT
					,[CUSTOMERS_COUNT] INT
					,[CUSTOMERS_PERCENT] NUMERIC(18 ,6)
				);
    --
			CREATE TABLE [#CUSTOMER_TEMP]
				(
					[CODE_CUSTOMER] VARCHAR(50)
				);
    --
			CREATE TABLE [#POLYGON_AMOUNT]
				(
					[POLYGON_ID] INT
					,[TOTAL_AMOUNT] INT
					,[TOTAL_AMOUNT_PERCENT] NUMERIC(18 ,6)
					,[SELLER_CODE] VARCHAR(155)
					,[SELLER_NAME] VARCHAR(100)
				);
    --
			DECLARE	@TAG TABLE ([TAG_COLOR] VARCHAR(8));
    --
			DECLARE	@CHANNEL TABLE ([CHANNEL_ID] INT);
    --
			DECLARE	@TOTAL_AMOUNT_BY_CUSTOMER TABLE
				(
					[CODE_CUSTOMER] VARCHAR(50)
					,[TOTAL_AMOUNT] NUMERIC(18 ,6)
					,[POLYGON_ID] INT
					,[SELLER_CODE] VARCHAR(155)
				);

    -- ------------------------------------------------------------------------------------
    -- Coloca parametros iniciales
    -- ------------------------------------------------------------------------------------
			SELECT
				@DELIMITER = [SONDA].[SWIFT_FN_GET_PARAMETER]('DELIMITER' ,
																'DEFAULT_DELIMITER')
				,@DEFAULT_DISPLAY_DECIMALS = [SONDA].[SWIFT_FN_GET_PARAMETER]('CALCULATION_RULES' ,
																'DEFAULT_DISPLAY_DECIMALS')
				,@POLYGON_SUB_TYPE = CASE	WHEN @POLYGON_TYPE = 'RUTA'
											THEN NULL
											ELSE @POLYGON_SUB_TYPE
										END;

    -- ------------------------------------------------------------------------------------
    -- Obtenemos todos los poligonos del tipo y subtipo a generar
    -- ------------------------------------------------------------------------------------
			SELECT
				[P].[POLYGON_ID]
				,[P].[POLYGON_ID_PARENT]
			INTO
				[#POLYGON]
			FROM
				[SONDA].[SWIFT_POLYGON] [P]
			WHERE
				[P].[POLYGON_TYPE] = @POLYGON_TYPE
				AND (
						[P].[SUB_TYPE] = @POLYGON_SUB_TYPE
						OR @POLYGON_SUB_TYPE IS NULL
					)
				AND (
						[P].[POLYGON_ID_PARENT] = @POLYGON_ID_PARENT
						OR @POLYGON_ID_PARENT IS NULL
					);

    -- ------------------------------------------------------------------------------------
    -- Obtiene las etiquetas
    -- ------------------------------------------------------------------------------------
			IF @TAG_COLORS IS NOT NULL
			BEGIN
				INSERT	INTO @TAG
				SELECT
					[T].[VALUE]
				FROM
					[SONDA].[SWIFT_FN_SPLIT_2](@TAG_COLORS ,@DELIMITER) [T];
			END;

    -- ------------------------------------------------------------------------------------
    -- Obtiene los canales
    -- ------------------------------------------------------------------------------------
			IF @CHANNELS IS NOT NULL
			BEGIN
				INSERT	INTO @CHANNEL
				SELECT
					[C].[VALUE]
				FROM
					[SONDA].[SWIFT_FN_SPLIT_2](@CHANNELS ,@DELIMITER) [C];
			END;

    -- ------------------------------------------------------------------------------------
    -- Obtiene los clientes
    -- ------------------------------------------------------------------------------------
			SELECT
				[C].[CODE_CUSTOMER]
				,[C].[LATITUDE]
				,[C].[LONGITUDE]
				,[geometry]::[Point]([C].[LATITUDE] ,[C].[LONGITUDE] ,0) [POINT]
				,[C].[SELLER_DEFAULT_CODE] [SELLER_CODE]
			INTO
				[#CUSTOMER]
			FROM
				[SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
			WHERE
				[GPS] <> '0,0'
				AND (
						[C].[LATITUDE] IS NOT NULL
						AND [C].[LONGITUDE] IS NOT NULL
					)
				AND [GPS] IS NOT NULL;
    -- ------------------------------------------------------------------------------------
    -- Elimina los clientes que no esten en las etiquetas
    -- ------------------------------------------------------------------------------------
			IF @TAG_COLORS IS NOT NULL
			BEGIN
				DELETE
					[C]
				FROM
					[#CUSTOMER] [C]
				LEFT JOIN [SONDA].[SWIFT_TAG_X_CUSTOMER] [TC]
				ON	([TC].[CUSTOMER] = [CODE_CUSTOMER])
				LEFT JOIN @TAG [T]
				ON	([T].[TAG_COLOR] = [TC].[TAG_COLOR])
				WHERE
					[T].[TAG_COLOR] IS NULL;
			END;

    -- ------------------------------------------------------------------------------------
    -- Elimina los clientes que no esten en los canales
    -- ------------------------------------------------------------------------------------
			IF @CHANNELS IS NOT NULL
			BEGIN
				DELETE
					[C]
				FROM
					[#CUSTOMER] [C]
				LEFT JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC]
				ON	([CC].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER])
				LEFT JOIN @CHANNEL [CN]
				ON	([CN].[CHANNEL_ID] = [CC].[CHANNEL_ID])
				WHERE
					[CN].[CHANNEL_ID] IS NULL;
			END;

    -- ------------------------------------------------------------------------------------
    -- Obtiene el total de clientes
    -- ------------------------------------------------------------------------------------
			SELECT
				@TOTAL_CUSTOMERS = COUNT([C].[CODE_CUSTOMER])
			FROM
				[#CUSTOMER] [C];
    --
			PRINT '@TOTAL_CUSTOMERS: ' + CAST(@TOTAL_CUSTOMERS AS VARCHAR);
    --
			IF @POLYGON_ID_PARENT IS NOT NULL
			BEGIN
				SELECT
					@GEOMETRY_POLYGON = [SONDA].[SWIFT_GET_GEOMETRY_POLYGON_BY_POLIGON_ID](@POLYGON_ID_PARENT);
      --
				SELECT
					@TOTAL_CUSTOMERS = [SONDA].[SWIFT_GET_CUSTOMERS_COUNT_BY_GEOMETRY_POLYGON](@GEOMETRY_POLYGON);
			END;

    -- ------------------------------------------------------------------------------------
    -- Valida que tipo de consulta es
    -- ------------------------------------------------------------------------------------
			IF @TYPE = 'PRESALE'
			BEGIN
      -- ------------------------------------------------------------------------------------
      -- Obtiene por cliente el total de las ordenes de venta
      -- ------------------------------------------------------------------------------------			
				INSERT	INTO @TOTAL_AMOUNT_BY_CUSTOMER
				SELECT
					[SO].[CLIENT_ID] [CODE_CUSTOMER]
					,SUM([SO].[TOTAL_AMOUNT])
					,[PBR].[POLYGON_ID]
					,[U].[RELATED_SELLER]
				FROM [SONDA].[SONDA_SALES_ORDER_HEADER] [SO]
					INNER JOIN [#CUSTOMER] [C] ON [SO].[CLIENT_ID] = [C].[CODE_CUSTOMER]
					INNER JOIN [SONDA].[USERS] [U] ON [SO].[POS_TERMINAL] = [U].[SELLER_ROUTE]
					INNER JOIN [SONDA].[SWIFT_ROUTES] [R] ON [R].[SELLER_CODE] = [U].[RELATED_SELLER]
					INNER JOIN [SONDA].[SWIFT_POLYGON_BY_ROUTE] [PBR] ON [PBR].[ROUTE] = [R].[ROUTE]
				WHERE [SO].[POSTED_DATETIME] BETWEEN @START_DATETIME AND @END_DATETIME
					AND [SO].[IS_READY_TO_SEND] = 1
				GROUP BY [U].[RELATED_SELLER]
						,[PBR].[POLYGON_ID]
						,[SO].[CLIENT_ID]
			END;
			ELSE
			BEGIN
      -- ------------------------------------------------------------------------------------
      -- Obtiene por cliente el total de las facturas
      -- ------------------------------------------------------------------------------------
				INSERT	INTO @TOTAL_AMOUNT_BY_CUSTOMER
				SELECT
					[I].[CLIENT_ID] [CODE_CUSTOMER]
					,SUM([I].[TOTAL_AMOUNT])
					,[PBR].[POLYGON_ID]
					,[U].[RELATED_SELLER]
				FROM [SONDA].[SONDA_POS_INVOICE_HEADER] [I]
					INNER JOIN [#CUSTOMER] [C] ON [C].[CODE_CUSTOMER] = [I].[CLIENT_ID]
					INNER JOIN [SONDA].[USERS] [U] ON [I].[POS_TERMINAL] = [U].[SELLER_ROUTE]
					INNER JOIN [SONDA].[SWIFT_ROUTES] [R] ON [R].[SELLER_CODE] = [U].[RELATED_SELLER]
					INNER JOIN [SONDA].[SWIFT_POLYGON_BY_ROUTE] [PBR] ON [PBR].[ROUTE] = [R].[ROUTE]
				WHERE [I].[POSTED_DATETIME] BETWEEN @START_DATETIME AND @END_DATETIME
				AND [I].[IS_READY_TO_SEND] = 1
				GROUP BY [U].[RELATED_SELLER]
						,[PBR].[POLYGON_ID]
						,[I].[CLIENT_ID]
			END;
    --
			SELECT
				@ALL_TOTAL_AMOUNT = SUM([T].[TOTAL_AMOUNT])
			FROM
				@TOTAL_AMOUNT_BY_CUSTOMER [T];
    --
			PRINT '@ALL_TOTAL_AMOUNT: ' + CAST(@ALL_TOTAL_AMOUNT AS VARCHAR);

    -- ------------------------------------------------------------------------------------
    -- Inicia ciclo para cada poligono obtenido
    -- ------------------------------------------------------------------------------------
			WHILE EXISTS ( SELECT TOP 1
								1
							FROM
								[#POLYGON] )
			BEGIN
				SELECT TOP 1
					@vPOLYGON_ID = [POLYGON_ID]
				FROM
					[#POLYGON]
				ORDER BY
					[POLYGON_ID_PARENT] ASC;

      -- ------------------------------------------------------------------------------------
      -- ObtIene el poligono actual 
      -- ------------------------------------------------------------------------------------
				SET @GEOMETRY_POLYGON = [SONDA].[SWIFT_GET_GEOMETRY_POLYGON_BY_POLIGON_ID](@vPOLYGON_ID);

      -- ------------------------------------------------------------------------------------
      -- Obtiene los clientes del poligono actual
      -- ------------------------------------------------------------------------------------
				INSERT	INTO [#CUSTOMER_TEMP]
				SELECT
					[C].[CODE_CUSTOMER]
				FROM
					[#CUSTOMER] [C]
				WHERE
					@GEOMETRY_POLYGON.[MakeValid]().[STContains]([C].[POINT]) = 1;

      -- ------------------------------------------------------------------------------------
      -- Obtiene el total de clientes del poligono actual 
      -- ------------------------------------------------------------------------------------
				SELECT
					@CUSTOMER_COUNT = @@ROWCOUNT;
      --PRINT '----> @CUSTOMER_COUNT: ' + CAST(@CUSTOMER_COUNT AS VARCHAR)		
      --
				SELECT
					@PERCENT = CASE CAST(@TOTAL_CUSTOMERS AS NUMERIC(18 ,6))
									WHEN 0 THEN 0
									ELSE (CAST(@CUSTOMER_COUNT AS NUMERIC(18 ,6))
											* 100
											/ CAST(@TOTAL_CUSTOMERS AS NUMERIC(18 ,
																6)))
								END;
      --
				INSERT	INTO [#POLYGON_AVG]
						(
							[POLYGON_ID]
							,[CUSTOMERS_COUNT]
							,[CUSTOMERS_PERCENT]
						)
				VALUES
						(
							@vPOLYGON_ID
							,@CUSTOMER_COUNT
							,@PERCENT
						);

      -- ------------------------------------------------------------------------------------
      -- Obtiene el monto total 
      -- ------------------------------------------------------------------------------------
				SET @TOTAL_AMOUNT = 0
				SELECT
					@TOTAL_AMOUNT = SUM(ISNULL([TA].[TOTAL_AMOUNT],0))
				FROM
					@TOTAL_AMOUNT_BY_CUSTOMER [TA]
				INNER JOIN [#CUSTOMER_TEMP] [C]
				ON	([C].[CODE_CUSTOMER] = [TA].[CODE_CUSTOMER])
				WHERE
					[TA].[POLYGON_ID] = @vPOLYGON_ID;

				--
				IF @POLYGON_TYPE = 'RUTA'
				BEGIN
					IF @TOTAL_AMOUNT IS NOT NULL	
					BEGIN	
						INSERT	INTO [#POLYGON_AMOUNT]
								(
									[POLYGON_ID]
									,[TOTAL_AMOUNT]
									,[TOTAL_AMOUNT_PERCENT]
									,[SELLER_CODE]
									,[SELLER_NAME]
								)
						SELECT
							@vPOLYGON_ID
							,ISNULL(SUM([TA].[TOTAL_AMOUNT]) ,0)
							,CASE CAST(ISNULL(SUM([TA].[TOTAL_AMOUNT]) ,0) AS NUMERIC(18 ,
																	6))
								WHEN 0 THEN 0
								ELSE (CAST(ISNULL(SUM([TA].[TOTAL_AMOUNT]) ,0) AS NUMERIC(18 ,
																	6)) * 100
										/ CAST(@ALL_TOTAL_AMOUNT AS NUMERIC(18 ,6)))
								END
							,[TA].[SELLER_CODE]
							,[SS].[SELLER_NAME]
						FROM
							@TOTAL_AMOUNT_BY_CUSTOMER [TA]
							INNER JOIN [#CUSTOMER_TEMP] [C]
							ON	([C].[CODE_CUSTOMER] = [TA].[CODE_CUSTOMER])
							LEFT JOIN [SONDA].[SWIFT_SELLER] [SS]
							ON	([TA].[SELLER_CODE] = [SS].[SELLER_CODE])
							WHERE [TA].[POLYGON_ID] = @vPOLYGON_ID
							GROUP BY
								[TA].[SELLER_CODE]
								,[SS].[SELLER_NAME];
					END	
					IF @TOTAL_AMOUNT IS NULL 
					BEGIN
						DECLARE @SELLER_CODE VARCHAR(50) = ''
						DECLARE @SELLER_NAME VARCHAR(50) = ''
						

						INSERT	INTO [#POLYGON_AMOUNT]
							(
								[POLYGON_ID]
								,[TOTAL_AMOUNT]
								,[TOTAL_AMOUNT_PERCENT]
								,[SELLER_CODE]
								,[SELLER_NAME]
							)
						VALUES( 
							@vPOLYGON_ID,
							0,
							0,
							@SELLER_CODE,
							@SELLER_NAME
						)
					END
				END;
				ELSE
				BEGIN
					INSERT	INTO [#POLYGON_AMOUNT]
							(
								[POLYGON_ID]
								,[TOTAL_AMOUNT]
								,[TOTAL_AMOUNT_PERCENT]
								,[SELLER_CODE]
								,[SELLER_NAME]
							)
					SELECT
						@vPOLYGON_ID
						,ISNULL(SUM([TA].[TOTAL_AMOUNT]) ,0)
						,CASE CAST(ISNULL(SUM([TA].[TOTAL_AMOUNT]) ,0) AS NUMERIC(18 ,
																6))
							WHEN 0 THEN 0
							ELSE (CAST(ISNULL(SUM([TA].[TOTAL_AMOUNT]) ,0) AS NUMERIC(18 ,
																6)) * 100
									/ CAST(@ALL_TOTAL_AMOUNT AS NUMERIC(18 ,6)))
							END
						,NULL
						,NULL
					FROM
						@TOTAL_AMOUNT_BY_CUSTOMER [TA]
					INNER JOIN [#CUSTOMER_TEMP] [C]
					ON	([C].[CODE_CUSTOMER] = [TA].[CODE_CUSTOMER]);
				END;
	 
      -- ------------------------------------------------------------------------------------
      -- Elimina el registro actual
      -- ------------------------------------------------------------------------------------
				DELETE FROM
					[#POLYGON]
				WHERE
					[POLYGON_ID] = @vPOLYGON_ID;

      -- ------------------------------------------------------------------------------------
      -- Elimina los clientes ya validados
      -- ------------------------------------------------------------------------------------
      --      DELETE [C]
      --        FROM [#CUSTOMER] [C]
      --        INNER JOIN [#CUSTOMER_TEMP] [CT]
      --          ON (
      --          [CT].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER]
      --          )

				TRUNCATE TABLE [#CUSTOMER_TEMP];
			END;

    -- ------------------------------------------------------------------------------------
    -- Muestra el resultado
    -- ------------------------------------------------------------------------------------
			SET @QUERY = N'SELECT DISTINCT
			[A].[POLYGON_ID]
			,[P].[POLYGON_NAME]
			,[P].[SUB_TYPE]
			,[A].[CUSTOMERS_COUNT]
			,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR)
				+ '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER([A].[CUSTOMERS_PERCENT])) [CUSTOMERS_PERCENT]
			,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR)
				+ '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER([PA].[TOTAL_AMOUNT])) [TOTAL_SALES]
			,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR)
				+ '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER([PA].[TOTAL_AMOUNT_PERCENT])) [TOTAL_SALES_PERCENT]
			,[P].[POLYGON_DESCRIPTION]
			,[P].[COMMENT]
			,[P].[LAST_OPTIMIZATION]
			,[R].[CODE_ROUTE]
			,[R].[NAME_ROUTE]
			,CASE [PA].[SELLER_CODE]
				WHEN '''' THEN [SS].[SELLER_CODE]
				ELSE [PA].[SELLER_CODE] 
				END AS [SELLER_CODE]
			,CASE [PA].[SELLER_NAME]
				WHEN '''' THEN [SS].[SELLER_NAME]
				ELSE [PA].[SELLER_NAME] 
				END AS [SELLER_NAME]
			FROM [#POLYGON_AVG] [A]
				INNER JOIN [#POLYGON_AMOUNT] [PA] ON (
					[PA].[POLYGON_ID] = [A].[POLYGON_ID]
				)
				INNER JOIN [SONDA].[SWIFT_POLYGON] [P] ON (
					[A].[POLYGON_ID] = [P].[POLYGON_ID]
				)
				LEFT JOIN [SONDA].[SWIFT_POLYGON_BY_ROUTE] [PR] ON(
					[PR].[POLYGON_ID] = [P].[POLYGON_ID]
				)
				LEFT JOIN [SONDA].[SWIFT_ROUTES] [R] ON	(
					[R].[ROUTE] = [PR].[ROUTE]
				)
				LEFT JOIN [SONDA].[USERS] [U] ON (
					[R].[SELLER_CODE] = [U].[RELATED_SELLER]
				)
				LEFT JOIN [SONDA].[SWIFT_SELLER] [SS] ON (
					[U].[RELATED_SELLER] = [SS].[SELLER_CODE]
				)';
    --
			PRINT '----> @QUERY: ' + @QUERY;
    --
			EXEC (@QUERY);
		END TRY
		BEGIN CATCH
			SELECT
				-1 AS [RESULTADO]
				,ERROR_MESSAGE() [MENSAJE]
				,@@ERROR [CODIGO];
		END CATCH;
	END;
