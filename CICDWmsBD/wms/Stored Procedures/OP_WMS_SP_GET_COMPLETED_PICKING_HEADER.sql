-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-02-13 @ Team ERGON - Sprint ERGON IV
-- Description:	        Sp que trae los picking header compeltas

-- Modificacion 31-Aug-17 @ Nexus Team Sprint CommandAndConquer
-- alberto.ruiz
-- Se corrigio 

-- Modificacion 21-Sep-17 @ Nexus Team Sprint CommandAndConquer
-- alberto.ruiz
-- Se agrega el doc num del ERP

-- Modificacion 23-Sep-17 @ Nexus Team Sprint DuckHunt
-- alberto.ruiz
-- Se agrega columnas [STATE_CODE]

-- Modificacion 28-Sep-17 @ Nexus Team Sprint DuckHunt
-- pablo.aguilar
-- Se modifica para que no muestre los pickings que fueron completamente cancelados. 

-- Modificacion 10/19/2017 @ NEXUS-Team Sprint ewms
-- rodrigo.gomez
-- Se agrega query dinamico para determinar la busqueda por ola o por pedido

-- Modificacion:		henry.rodriguez
-- Fecha:				31-Julio-2019 G-Force@Estambul
-- Descripcion:			Se agrega el numero de orden y la ubicacion de salida en query.

-- Modificacion:		henry.rodriguez
-- Fecha:				09-Agosto-2019 G-Force@Estambul
-- Descripcion:			Se modifican propiedades de orden y ubicacoon de salida.

-- Modificacion:		henry.rodriguez
-- Fecha:				30-Noviembre-2019 G-Force@Kioto
-- Descripcion:			Se agrega validacion para tomar en cuenta las cantidades pendientes de entrega

/*
-- Ejemplo de Ejecucion:
			exec wms.OP_WMS_SP_GET_COMPLETED_PICKING_HEADER @INITIAL_DATE='2023-02-20 00:00:00',@END_DATE='2023-02-27 23:59:59',@WAREHOUSE=N'BODEGA_02|BODEGA_PYS|BODEGA_SPS|BODEGA_TGU',@CODE_ROUTE=N'|',@MANIFEST_TYPE=N'SALES_ORDER'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_COMPLETED_PICKING_HEADER] (
		@INITIAL_DATE DATETIME
		,@END_DATE DATETIME
		,@WAREHOUSE VARCHAR(MAX)
		,@CODE_ROUTE VARCHAR(MAX)
		,@MANIFEST_TYPE VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	DECLARE
		@IS_COMPLETED NUMERIC(18, 0) = 1
		,@EMPTY_CODE_ROUTE VARCHAR(MAX) = '|'
		,@CARGO_MANIFEST_CONFIGURATION VARCHAR(50)
		,@QUERY VARCHAR(MAX);
  --
	CREATE TABLE [#ROUTE] (
		[CODE_ROUTE] VARCHAR(50)
		,PRIMARY KEY ([CODE_ROUTE])
	);
  -- ------------------------------------------------------------------------------------
  -- Obtiene la configuracion del manifiesto de carga
  -- ------------------------------------------------------------------------------------
	SELECT
		@CARGO_MANIFEST_CONFIGURATION = [TEXT_VALUE]
	from
		[wms].[OP_WMS_CONFIGURATIONS]
	WHERE
		[PARAM_TYPE] = 'SISTEMA'
		AND [PARAM_NAME] = 'TIPO_MANIFIESTO_DE_CARGA';
  -- ------------------------------------------------------------------------------------
  -- Valida si son todas las rutas
  -- ------------------------------------------------------------------------------------
	IF @CODE_ROUTE != '|'
	BEGIN
		INSERT	INTO [#ROUTE]
				(
					[CODE_ROUTE]
				)
		SELECT DISTINCT
			[S].[VALUE]
		FROM
			[wms].[OP_WMS_FN_SPLIT](@CODE_ROUTE, '|') [S];
	END;

  -- ------------------------------------------------------------------------------------
  -- Muestra el resultado
  -- ------------------------------------------------------------------------------------
 CREATE TABLE	#MANIFEST_DETALLE (
			[MANIFEST_DETAIL_ID] INT
			,[PICKING_DEMAND_HEADER_ID] INT
			,[MATERIAL_ID] VARCHAR(50)
			,[LINE_NUM] INT
			,[QTY_PENDING_DELIVERY] DECIMAL(18, 4)
			,[QTY_DELIVERED] DECIMAL(18, 4)
			,[ROW_NUMBER] INT
		);
    ---
	INSERT	INTO #MANIFEST_DETALLE
			(
				[MANIFEST_DETAIL_ID]
				,[PICKING_DEMAND_HEADER_ID]
				,[MATERIAL_ID]
				,[LINE_NUM]
				,[QTY_PENDING_DELIVERY]
				,[QTY_DELIVERED]
				,[ROW_NUMBER]
			)
    ---
   SELECT
		[D].[MANIFEST_DETAIL_ID]
		,[D].[PICKING_DEMAND_HEADER_ID]
		,[D].[MATERIAL_ID]
		,[D].[LINE_NUM]
		,[D].[QTY_PENDING_DELIVERY]
		,[D].[QTY_DELIVERED]
		,ROW_NUMBER() OVER (PARTITION BY  D.[PICKING_DEMAND_HEADER_ID], [D].[LINE_NUM], [D].[MATERIAL_ID] ORDER BY [H].[CREATED_DATE] DESC) AS [rn]
	FROM
		[wms].[OP_WMS_MANIFEST_DETAIL] [D] WITH (NOLOCK)
	INNER JOIN [wms].[OP_WMS_MANIFEST_HEADER] [H] WITH (NOLOCK) ON [H].[MANIFEST_HEADER_ID] = [D].[MANIFEST_HEADER_ID] 
	WHERE
		[H].[STATUS]  <> 'CANCELED' 
		AND H.CREATED_DATE >= GETDATE()-100

	SELECT * INTO #TASKS 
	 FROM [wms].[OP_WMS_TASK_LIST] 
		WHERE COMPLETED_DATE  >= @INITIAL_DATE

	SELECT * INTO #HEADER
		FROM wms.OP_WMS_NEXT_PICKING_DEMAND_HEADER
			WHERE LAST_UPDATE >= GETDATE()-100

	SELECT D.* INTO #DETALLE
		FROM WMS.OP_WMS_NEXT_PICKING_DEMAND_DETAIL D
			INNER JOIN #HEADER H ON D.PICKING_DEMAND_HEADER_ID = H.PICKING_DEMAND_HEADER_ID

    --
		SELECT 
			CASE WHEN [PDH].[IS_CONSOLIDATED] = 1 AND 
		 @CARGO_MANIFEST_CONFIGURATION
		 = 'POR_OLA'
				THEN 'CONSOLIDADO ' + CAST([TL].[WAVE_PICKING_ID] AS VARCHAR)
				ELSE MAX([PDH].[CLIENT_CODE])
			END [CLIENT_CODE]
			,CASE WHEN [PDH].[IS_CONSOLIDATED] = 1 AND 
		 @CARGO_MANIFEST_CONFIGURATION  = 'POR_OLA'
				THEN '' 
				ELSE MAX([PDH].[CLIENT_NAME])
			END [CLIENT_NAME] 
			,MAX([TL].[ASSIGNED_DATE]) [ASSIGNED_DATE]
			,[TL].[WAVE_PICKING_ID]
			,CASE WHEN [PDH].[IS_CONSOLIDATED] = 1 AND 
		 @CARGO_MANIFEST_CONFIGURATION  = 'POR_OLA'
				THEN '' 
				ELSE MAX([PDH].[CODE_ROUTE])
			END [CODE_ROUTE]
			,[TL].[WAREHOUSE_SOURCE]
			,CASE WHEN [PDH].[IS_CONSOLIDATED] = 1 AND 
		 @CARGO_MANIFEST_CONFIGURATION  = 'POR_OLA'
				THEN '' 
				ELSE MAX( CAST([PDH].[DOC_NUM] AS VARCHAR))
			END [ERP_REFERENCE_DOC_NUM]
			,CASE WHEN [PDH].[IS_CONSOLIDATED] = 1 AND 
		 @CARGO_MANIFEST_CONFIGURATION = 'POR_OLA'
				THEN '' 
				ELSE MAX([PDH].[ADDRESS_CUSTOMER])
			END [ADDRESS_CUSTOMER]
			,CASE WHEN [PDH].[IS_CONSOLIDATED] = 1 AND 
		 @CARGO_MANIFEST_CONFIGURATION
		 = 'POR_OLA'
				THEN '' 
				ELSE MAX(CAST([PDH].[STATE_CODE] AS VARCHAR))
			END [STATE]

      ,CASE MAX([PDH].[IS_CONSOLIDATED])  
        WHEN 1 THEN 0
        ELSE ISNULL(MAX([PDH].[TYPE_DEMAND_CODE]), 0)
       END AS [TYPE_DEMAND_CODE]

      ,CASE MAX([PDH].[IS_CONSOLIDATED])  
        WHEN 1 THEN ''
        ELSE ISNULL(MAX([PDH].[TYPE_DEMAND_NAME]), '')
       END AS [TYPE_DEMAND_NAME]

	   ,0 AS [ORDER_NUMBER] 

	   ,MAX(ISNULL([TL].[LOCATION_SPOT_TARGET], '')) AS [LOCATION_SPOT_TARGET]

			
		,CASE	WHEN @CARGO_MANIFEST_CONFIGURATION = 'POR_PEDIDO'
				THEN [PDH].[PICKING_DEMAND_HEADER_ID] 
				ELSE ''
			END
		
		FROM 
			#HEADER [PDH] WITH (NOLOCK)
			INNER JOIN #TASKS [TL] WITH (NOLOCK) ON [TL].[WAVE_PICKING_ID] = [PDH].[WAVE_PICKING_ID]
			INNER JOIN [wms].[OP_WMS_FUNC_SPLIT_3](
		 @WAREHOUSE
		, '|') [W] ON [W].[VALUE]  = [PDH].[CODE_WAREHOUSE]  
			LEFT JOIN #ROUTE [R] ON [R].[CODE_ROUTE] COLLATE DATABASE_DEFAULT = [PDH].[CODE_ROUTE] COLLATE DATABASE_DEFAULT
			LEFT JOIN #DETALLE [PDD] WITH (NOLOCK) ON (
											[PDD].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
											AND [PDD].[MATERIAL_ID]  = [TL].[MATERIAL_ID] 
											)
	LEFT JOIN #MANIFEST_DETALLE [MD] ON (
											[MD].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
											AND [MD].[LINE_NUM] = [PDD].[LINE_NUM]
											AND [MD].[MATERIAL_ID] COLLATE DATABASE_DEFAULT  = [PDD].[MATERIAL_ID] COLLATE DATABASE_DEFAULT
											AND [MD].[ROW_NUMBER] = 1
										)
		WHERE 
			[TL].[COMPLETED_DATE]   BETWEEN
		 CAST(@INITIAL_DATE AS VARCHAR) COLLATE DATABASE_DEFAULT
									AND	
		CAST(@END_DATE AS VARCHAR)  COLLATE DATABASE_DEFAULT
			AND [TL].[IS_COMPLETED] = 
	 CAST(@IS_COMPLETED AS VARCHAR) 
			AND [PDH].[DEMAND_TYPE]  =  @MANIFEST_TYPE
		
			AND (
					 @CODE_ROUTE = 
		@EMPTY_CODE_ROUTE 
					OR [R].[CODE_ROUTE]  COLLATE DATABASE_DEFAULT = [PDH].[CODE_ROUTE]  COLLATE DATABASE_DEFAULT
				)
			
			AND [TL].[TASK_TYPE]  <>  'TAREA_REUBICACION'
			AND (
				[MD].[PICKING_DEMAND_HEADER_ID] IS NULL
				OR [MD].[QTY_PENDING_DELIVERY] > 0
			)
			AND [PDH].[IS_POSTED_ERP] = 1
		GROUP BY [PDH].[IS_CONSOLIDATED]
			   , [TL].[WAVE_PICKING_ID]
			   , [TL].[WAREHOUSE_SOURCE]
			   
		, CASE	WHEN @CARGO_MANIFEST_CONFIGURATION = 'POR_PEDIDO'
				THEN [PDH].[PICKING_DEMAND_HEADER_ID] 
				ELSE ''
			END 
		HAVING
			MIN([TL].[IS_COMPLETED]) = 
		CAST(@IS_COMPLETED AS VARCHAR)
			AND SUM([TL].[QUANTITY_ASSIGNED]) <> SUM([TL].[QUANTITY_PENDING]);

		;
  --
	/*PRINT (@QUERY);
  --
	EXEC (@QUERY);*/
END;