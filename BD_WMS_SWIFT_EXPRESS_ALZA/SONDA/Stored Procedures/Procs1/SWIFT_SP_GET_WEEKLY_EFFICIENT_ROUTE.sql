-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		14-06-2016
-- Description:			    SP para el reporte de eficiencia de ruta

/*
-- Ejemplo de Ejecucion:
				--
				EXEC [SONDA].[SWIFT_SP_GET_WEEKLY_EFFICIENT_ROUTE]
					@STAR_DATE = '20160612'
					,@END_DATE = '20160618'
					,@CODE_ROUTE = 'rudi@SONDA'
				--
				exec [SONDA].SWIFT_SP_GET_WEEKLY_EFFICIENT_ROUTE
				 @STAR_DATE='2017-05-07 00:00:00'
				 ,@END_DATE='2017-05-13 00:00:00'
				 ,@CODE_ROUTE='10'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_WEEKLY_EFFICIENT_ROUTE (
	@STAR_DATE DATETIME
	,@END_DATE DATETIME
	,@CODE_ROUTE VARCHAR(4000)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@DELIMITER CHAR(1)
		,@DAY_NUMBER INT
		,@QUERY NVARCHAR(2000)
		,@NAME_COL VARCHAR(200)
		,@DEFAULT_DISPLAY_DECIMALS INT
	
	-- ------------------------------------------------------------------------------------
	-- Coloca parametros iniciales
	--------------------------------------------------------------------------------------
	SELECT 
		@DELIMITER = [SONDA].SWIFT_FN_GET_PARAMETER('DELIMITER','DEFAULT_DELIMITER')
		,@END_DATE = @END_DATE + ' 23:59:59.997'
		,@DAY_NUMBER = 0
		,@NAME_COL = ''
		,@DEFAULT_DISPLAY_DECIMALS = [SONDA].[SWIFT_FN_GET_PARAMETER]('CALCULATION_RULES','DEFAULT_DISPLAY_DECIMALS')

	-- ------------------------------------------------------------------------------------
	-- Se crea la tabla de resultado
	-- ------------------------------------------------------------------------------------
	CREATE TABLE #RESULT(
		[CODE_ROUTE] VARCHAR(50)
		,[NAME_ROUTE] VARCHAR(50)
		,[SUNDAY] NUMERIC(18,6)
		,[MONDAY] NUMERIC(18,6)
		,[TUESDAY] NUMERIC(18,6)
		,[WEDNESDAY] NUMERIC(18,6)
		,[THURSDAY] NUMERIC(18,6)
		,[FRIDAY] NUMERIC(18,6)
		,[SATURDAY] NUMERIC(18,6)
	)

	-- ------------------------------------------------------------------------------------
	-- Se crea la tabla de los dias
	-- ------------------------------------------------------------------------------------
	CREATE TABLE #DAY (
		[DAY] VARCHAR(15)
		,[DATE] DATE
	)
	--
	WHILE (@DAY_NUMBER < 7)
	BEGIN
		PRINT '--> @DAY_NUMBER: ' + CAST(@DAY_NUMBER AS VARCHAR)
		--
		INSERT INTO [#DAY] 
		SELECT
			CASE CAST(@DAY_NUMBER AS VARCHAR)
				WHEN '0' THEN 'Domingo'
				WHEN '1' THEN 'Lunes'
				WHEN '2' THEN 'Martes'
				WHEN '3' THEN 'Miercoles'
				WHEN '4' THEN 'Jueves'
				WHEN '5' THEN 'Viernes'
				WHEN '6' THEN 'Sabado'
			END
			,DATEADD(DAY,@DAY_NUMBER,@STAR_DATE)
		--
		SET @NAME_COL = @NAME_COL
			+ CASE CAST(@DAY_NUMBER AS VARCHAR)
				WHEN '0' THEN ''
				ELSE ','
			END
			+ '['
			+ CAST(CONVERT(DATE,DATEADD(DAY,@DAY_NUMBER,@STAR_DATE)) AS VARCHAR)
			/*+ '-'
			+ CASE CAST(@DAY_NUMBER AS VARCHAR)
				WHEN '0' THEN 'Domingo'
				WHEN '1' THEN 'Lunes'
				WHEN '2' THEN 'Martes'
				WHEN '3' THEN 'Miercoles'
				WHEN '4' THEN 'Jueves'
				WHEN '5' THEN 'Viernes'
				WHEN '6' THEN 'Sabado'
			END */
			+ ']'
		--
		PRINT '--> @NAME_COL: ' + @NAME_COL
		--
		SET @DAY_NUMBER = (@DAY_NUMBER + 1)
	END
	--
	PRINT '--> Termino de generar dias'

	-- ------------------------------------------------------------------------------------
	-- Obtiene las rutas a filtrar
	-- ------------------------------------------------------------------------------------
	SELECT 
		[R].[CODE_ROUTE]
		,[R].[NAME_ROUTE]
	INTO #PRE_ROUTE
	FROM [SONDA].[Split](@CODE_ROUTE,@DELIMITER) [S]
	INNER JOIN [SONDA].[SWIFT_ROUTES] [R] ON (
		[S].[Data] = [R].[CODE_ROUTE]
	)
	/*FROM [SONDA].[SWIFT_FN_SPLIT](@CODE_ROUTE,@DELIMITER) [S]
	INNER JOIN [SONDA].[SWIFT_ROUTES] [R] ON (
		[S].[VALUE] = [R].[CODE_ROUTE]
	)*/
	--
	PRINT '--> SE CREO #PRE_ROUTE'
	--
	SELECT 
		[R].[CODE_ROUTE]
		,[R].[NAME_ROUTE]
		,[D].[DAY]
		,[D].[DATE]
	INTO #ROUTE
	FROM [#PRE_ROUTE] R,[#DAY] D
	--
	PRINT '--> SE CREO #ROUTE'

	-- ------------------------------------------------------------------------------------
	-- Obtiene las ordenes de venta Y FACTURAS
	-- ------------------------------------------------------------------------------------
	SELECT
		[S].[POS_TERMINAL] [CODE_ROUTE]
		,[R].[DATE]
		,CASE 
			WHEN [S].[DISCOUNT] > 0 THEN (([S].[TOTAL_AMOUNT] * [S].[DISCOUNT]) / 100)
			ELSE [S].[TOTAL_AMOUNT]
		END [TOTAL_AMOUNT]
	INTO #SALES_ORDER
	FROM [SONDA].[SONDA_SALES_ORDER_HEADER] [S]
	INNER JOIN [#ROUTE] [R] ON (
		[S].[POS_TERMINAL] = [R].[CODE_ROUTE]
		AND CAST([S].[POSTED_DATETIME] AS DATE) = [R].[DATE]
	)
	WHERE [S].[POSTED_DATETIME] BETWEEN @STAR_DATE AND @END_DATE
		AND [S].[IS_VOID] = 0
		AND [S].[IS_DRAFT] = 0
		AND [S].IS_READY_TO_SEND=1
	--
	UNION
	SELECT
		[S].[POS_TERMINAL] [CODE_ROUTE]
		,[R].[DATE]
		--,CASE 
		--	WHEN [S].[DISCOUNT] > 0 THEN (([S].[TOTAL_AMOUNT] * [S].[DISCOUNT]) / 100)
		--	ELSE [S].[TOTAL_AMOUNT]
		--END 
		,[S].[TOTAL_AMOUNT]
	FROM [SONDA].[SONDA_POS_INVOICE_HEADER] [S]
	INNER JOIN [#ROUTE] [R] ON (
		[S].[POS_TERMINAL] = [R].[CODE_ROUTE]
		AND CAST([S].[POSTED_DATETIME] AS DATE) = [R].[DATE]
	)
	WHERE [S].[POSTED_DATETIME] BETWEEN @STAR_DATE AND @END_DATE
		AND [S].[VOIDED_INVOICE] IS NULL
		AND [S].IS_READY_TO_SEND=1
		AND [S].IS_POSTED_ERP=1

	 	PRINT '--> SE CREO #SALES_ORDER'

	-- ------------------------------------------------------------------------------------
	-- Obtiene los totales por ruta y dia
	-- ------------------------------------------------------------------------------------
	SELECT
		[R].[CODE_ROUTE]
		,MAX([R].[NAME_ROUTE]) [NAME_ROUTE]
		,[R].[DATE]
		,MAX([R].[DAY]) [DAY]
		,SUM(ISNULL([S].[TOTAL_AMOUNT],0.00)) [TOTAL_AMOUNT]
	INTO #PRE_RESULT
	FROM [#ROUTE] [R]
	LEFT JOIN [#SALES_ORDER] [S] ON (
		[S].[CODE_ROUTE] = [R].[CODE_ROUTE]
		AND [S].[DATE] = [R].[DATE]
	)
	GROUP BY
		[R].[CODE_ROUTE]
		,[R].[DATE]
	ORDER BY
		[R].[CODE_ROUTE]
		,[R].[DATE]
	--
	PRINT '--> SE CREO #PRE_RESULT'

	-- ------------------------------------------------------------------------------------
	-- Forma el query para obtener el resultado
	-- ------------------------------------------------------------------------------------
	PRINT '----> ANTES DE @QUERY'
	--
	SET @QUERY = N'INSERT INTO #RESULT
	SELECT
		[CODE_ROUTE]
		,[NAME_ROUTE]
		,'+ @NAME_COL + '
	FROM (
		SELECT 
			[CODE_ROUTE]
			,[NAME_ROUTE]
			,[DATE]
			,[TOTAL_AMOUNT]
		FROM [#PRE_RESULT]) AS SourceTable
		PIVOT
		(
			SUM([TOTAL_AMOUNT])
			FOR [DATE] IN (' + @NAME_COL + ')
		) AS PivotTable;'
	--
	PRINT '----> @QUERY: ' + @QUERY
	--
	EXEC(@QUERY)
	--
	PRINT '----> DESPUES DE @QUERY'

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	SET @QUERY = N'
	SELECT 
		[U].[LOGIN]
		,[U].[NAME_USER]
		,[R].[CODE_ROUTE]
		,[R].[NAME_ROUTE]
		,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].[SWIFT_FN_GET_DISPLAY_NUMBER]([R].[SUNDAY])) [SUNDAY]
		,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].[SWIFT_FN_GET_DISPLAY_NUMBER]([R].[MONDAY])) [MONDAY]
		,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].[SWIFT_FN_GET_DISPLAY_NUMBER]([R].[TUESDAY])) [TUESDAY]
		,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].[SWIFT_FN_GET_DISPLAY_NUMBER]([R].[WEDNESDAY])) [WEDNESDAY]
		,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].[SWIFT_FN_GET_DISPLAY_NUMBER]([R].[THURSDAY])) [THURSDAY]
		,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].[SWIFT_FN_GET_DISPLAY_NUMBER]([R].[FRIDAY])) [FRIDAY]
		,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].[SWIFT_FN_GET_DISPLAY_NUMBER]([R].[SATURDAY])) [SATURDAY]
		,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].[SWIFT_FN_GET_DISPLAY_NUMBER](([R].[SUNDAY] + [R].[FRIDAY] + [R].[MONDAY] + [R].[SATURDAY] + [R].[THURSDAY] + [R].[TUESDAY] + [R].[WEDNESDAY]))) [TOTAL_AMOUNT] --,[SONDA].[SWIFT_FN_GET_DISPLAY_NUMBER](([R].[SUNDAY] + [R].[FRIDAY] + [R].[MONDAY] + [R].[SATURDAY] + [R].[THURSDAY] + [R].[TUESDAY] + [R].[WEDNESDAY])) [TOTAL_AMOUNT]
	FROM [#RESULT] [R]
	INNER JOIN [SONDA].[USERS] [U] ON (
		[U].[SELLER_ROUTE] = [R].[CODE_ROUTE]
	)
	ORDER BY [U].[LOGIN]'
	--
	PRINT '----> @QUERY: ' + @QUERY
	--
	EXEC(@QUERY)
	--
	PRINT '----> DESPUES DE @QUERY'
END
