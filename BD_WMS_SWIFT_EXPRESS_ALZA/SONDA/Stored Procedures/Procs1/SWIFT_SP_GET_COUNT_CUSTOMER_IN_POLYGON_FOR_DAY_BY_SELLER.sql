-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	29-Sep-16 @ A-TEAM Sprint 2
-- Description:			Obtiene la cantidad de clientes 

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_COUNT_CUSTOMER_IN_POLYGON_FOR_DAY_BY_SELLER]
					@LOGIN = 'gerente@SONDA'
					,@SELLER_CODE = '-1'
				--
				EXEC [SONDA].[SWIFT_SP_GET_COUNT_CUSTOMER_IN_POLYGON_FOR_DAY_BY_SELLER]
					@LOGIN = 'gerente@SONDA'
					,@SELLER_CODE = '-1|1'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_COUNT_CUSTOMER_IN_POLYGON_FOR_DAY_BY_SELLER](
	@LOGIN VARCHAR(50)
	,@SELLER_CODE VARCHAR(4000)
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
	
	-- ------------------------------------------------------------------------------------
	-- Coloca parametros iniciales
	--------------------------------------------------------------------------------------
	SELECT 
		@DELIMITER = [SONDA].SWIFT_FN_GET_PARAMETER('DELIMITER','DEFAULT_DELIMITER')
		,@DAY_NUMBER = 0
		,@NAME_COL = ''

	-- ------------------------------------------------------------------------------------
	-- Obtiene los vendedires a filtrar
	-- ------------------------------------------------------------------------------------
	SELECT DISTINCT
		[SS].[SELLER_CODE]
		,[SS].[SELLER_NAME]
	INTO #SELLER
	FROM [SONDA].[Split](@SELLER_CODE,@DELIMITER) [S]
	INNER JOIN [SONDA].[SWIFT_SELLER] [SS] ON (
		[SS].[SELLER_CODE] = [S].[Data]
	)

	-- ------------------------------------------------------------------------------------
	-- Obtiene las rutas que puede ver el login
	-- ------------------------------------------------------------------------------------
	SELECT [RUS].[CODE_ROUTE]
	INTO #ROUTE
	FROM [SONDA].[SWIFT_ROUTE_BY_USER] [RUS]
	WHERE RUS.[LOGIN] = @LOGIN

	-- ------------------------------------------------------------------------------------
	-- Obtine las frecuencias
	-- ------------------------------------------------------------------------------------
	SELECT DISTINCT [PBR].[ID_FREQUENCY]
	INTO #FREQUENCY
	FROM [SONDA].[SWIFT_POLYGON_BY_ROUTE] [PBR]
	INNER JOIN [SONDA].[SWIFT_ROUTES] [R] ON (
		[R].[ROUTE] = [PBR].[ROUTE]
	)
	INNER JOIN [#SELLER] [S] ON (
		[S].[SELLER_CODE] = [R].[SELLER_CODE]
	)
	INNER JOIN #ROUTE [RUS] ON (
		[RUS].[CODE_ROUTE] = [R].[CODE_ROUTE]
	)

	-- ------------------------------------------------------------------------------------
	-- Obtiene la cantidad de clientes por dia
	-- ------------------------------------------------------------------------------------
	SELECT DISTINCT
		[F].[CODE_ROUTE]
		,[F].[TYPE_TASK]
		,[F].[FREQUENCY_WEEKS]
		,SUM([F].[SUNDAY]) [SUNDAY]
		,SUM([F].[MONDAY]) [MONDAY]
		,SUM([F].[TUESDAY]) [TUESDAY]
		,SUM([F].[WEDNESDAY]) [WEDNESDAY]
		,SUM([F].[THURSDAY]) [THURSDAY]
		,SUM([F].[FRIDAY]) [FRIDAY]
		,SUM([F].[SATURDAY]) [SATURDAY]
	INTO #CUSTOMER_BY_DAY
	FROM [SONDA].[SWIFT_FREQUENCY] [F]
	INNER JOIN [SONDA].[SWIFT_FREQUENCY_X_CUSTOMER] [FC] ON (
		[FC].[ID_FREQUENCY] = [F].[ID_FREQUENCY]
	)
	INNER JOIN [#FREQUENCY] [TF] ON (
		[TF].[ID_FREQUENCY] = [F].[ID_FREQUENCY]
	)
	GROUP BY 
		[F].[CODE_ROUTE]
		,[F].[TYPE_TASK]
		,[F].[FREQUENCY_WEEKS]
	ORDER BY
		[F].[CODE_ROUTE]
		,[F].[TYPE_TASK]
		,[F].[FREQUENCY_WEEKS]


	-- ------------------------------------------------------------------------------------
	-- Obtiene los datos generales
	-- ------------------------------------------------------------------------------------
	SELECT DISTINCT
		[S].[SELLER_CODE]
		,[S].[SELLER_NAME]
		,[R].[CODE_ROUTE]
		,[R].[NAME_ROUTE]
		,[P3].[POLYGON_ID] POLYGON_ID_REGION
		,[P3].[POLYGON_NAME] POLYGON_NAME_REGION
		,[P2].[POLYGON_ID] POLYGON_ID_SECTOR
		,[P2].[POLYGON_NAME] POLYGON_NAME_SECTOR
		,[P].[POLYGON_ID]
		,[P].[POLYGON_NAME]
		,CASE CAST([PBR].[IS_MULTIPOLYGON] AS VARCHAR)
			WHEN '0' THEN 'Multi-Frecuencia'
			ELSE 'Frecuencia Unica'
		END POLYGON_TYPE
	INTO #INFO
	FROM [SONDA].[SWIFT_POLYGON_BY_ROUTE] [PBR]
	INNER JOIN [SONDA].[SWIFT_ROUTES] [R] ON (
		[R].[ROUTE] = [PBR].[ROUTE]
	)
	INNER JOIN [#SELLER] [S] ON (
		[S].[SELLER_CODE] = [R].[SELLER_CODE]
	)
	INNER JOIN #ROUTE [RUS] ON (
		[RUS].[CODE_ROUTE] = [R].[CODE_ROUTE]
	)
	INNER JOIN [SONDA].[SWIFT_POLYGON] [P] ON (
		[P].[POLYGON_ID] = [PBR].[POLYGON_ID]
	)
	INNER JOIN [SONDA].[SWIFT_POLYGON] [P2] ON (
		[P2].[POLYGON_ID] = [P].[POLYGON_ID_PARENT]
	)
	INNER JOIN [SONDA].[SWIFT_POLYGON] [P3] ON (
		[P3].[POLYGON_ID] = [P2].[POLYGON_ID_PARENT]
	)
	
	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	SELECT
		[I].[SELLER_CODE]
		,[I].[SELLER_NAME]
		,[I].[CODE_ROUTE]
		,[I].[NAME_ROUTE]
		,[I].[POLYGON_ID_REGION]
		,[I].[POLYGON_NAME_REGION]
		,[I].[POLYGON_ID_SECTOR]
		,[I].[POLYGON_NAME_SECTOR]
		,[I].[POLYGON_ID]
		,[I].[POLYGON_NAME]
		,[I].[POLYGON_TYPE]
		,[CBD].[TYPE_TASK] --ISNULL([CBD].[TYPE_TASK],'NA') [TYPE_TASK]
		,ISNULL([CBD].[FREQUENCY_WEEKS],0) [FREQUENCY_WEEKS]
		,ISNULL([CBD].[SUNDAY],0) [SUNDAY]
		,ISNULL([CBD].[MONDAY],0) [MONDAY]
		,ISNULL([CBD].[TUESDAY],0) [TUESDAY]
		,ISNULL([CBD].[WEDNESDAY],0) [WEDNESDAY]
		,ISNULL([CBD].[THURSDAY],0) [THURSDAY]
		,ISNULL([CBD].[FRIDAY],0) [FRIDAY]
		,ISNULL([CBD].[SATURDAY],0) [SATURDAY]
	FROM #INFO [I]
	LEFT JOIN [#CUSTOMER_BY_DAY] [CBD] ON (
		[CBD].[CODE_ROUTE] = [I].[CODE_ROUTE]
	)
END
