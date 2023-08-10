-- =============================================
-- Autor:					marvin.solares
-- Fecha de Creacion: 		25-Jun-2019 G-Force@Berlin-Swift3PL
-- Description:			    SP que obtiene el sugerido de compra

-- Autor:					marvin.solares
-- Fecha de Creacion: 		03-Jul-2019 G-Force@Berlin-Swift3PL
-- Description:			    se deja el lead time en dias

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].OP_WMS_SP_GET_SUGGESTED_PURCHASE
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_GET_SUGGESTED_PURCHASE_BK] (
		@LOGIN VARCHAR(25)
		,@WAREHOUSE_XML XML
		,@MATERIAL_XML XML
	)
AS
BEGIN
	SET NOCOUNT ON;
  -- -----------------------------------------------------------------
  -- Declaramos las variables necesarias
  -- -----------------------------------------------------------------

	DECLARE	@WAREHOUSE_TABLE TABLE (
			[CODE_WAREHOUSE] VARCHAR(25)
		);


	DECLARE	@ZONE_TABLE TABLE ([ZONE] VARCHAR(25));

	DECLARE	@LOCATION_TABLE TABLE (
			[LOCATION] VARCHAR(25)
			,[ZONE] VARCHAR(25)
		);


	DECLARE	@MATERIAL_TABLE TABLE (
			[MATERIAL_CODE] VARCHAR(50)
		);

  -- -----------------------------------------------------------------
  -- Obtemos las bodegas enviadas
  -- -----------------------------------------------------------------

	INSERT	INTO @WAREHOUSE_TABLE
			(
				[CODE_WAREHOUSE]
			)
	SELECT
		[x].[Rec].[query]('./WAREHOUSE_ID').[value]('.',
											'VARCHAR(25)')
	FROM
		@WAREHOUSE_XML.[nodes]('/ArrayOfBodega/Bodega') AS [x] ([Rec]);

  -- -----------------------------------------------------------------
  -- Obtemos las materiales enviadas
  -- -----------------------------------------------------------------

	INSERT	INTO @MATERIAL_TABLE
			(
				[MATERIAL_CODE]
			)
	SELECT
		[x].[Rec].[query]('./MATERIAL_CODE').[value]('.',
											'VARCHAR(25)')
	FROM
		@MATERIAL_XML.[nodes]('/ArrayOfMaterial/Material')
		AS [x] ([Rec]);

  -- -----------------------------------------------------------------
  -- Validamos si enviaron bodegas para filtrar
  -- -----------------------------------------------------------------
	IF NOT EXISTS ( SELECT
						1
					FROM
						@WAREHOUSE_TABLE )
	BEGIN

    -- -----------------------------------------------------------------
    -- Si no enviarion bodegas para filtrar buscamos las de el usuario
    -- -----------------------------------------------------------------
		INSERT	INTO @WAREHOUSE_TABLE
				(
					[CODE_WAREHOUSE]
				)
		SELECT
			[WU].[WAREHOUSE_ID]
		FROM
			[wms].[OP_WMS_WAREHOUSE_BY_USER] [WU]
		INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON ([W].[WAREHOUSE_ID] = [WU].[WAREHOUSE_ID])
		WHERE
			[WU].[LOGIN_ID] = @LOGIN;
	END;

  -- -----------------------------------------------------------------
  -- Ya que tenemos las bodegas y zonas obtemos las ubicaciones
  -- -----------------------------------------------------------------
	INSERT	INTO @LOCATION_TABLE
			(
				[LOCATION]
				,[ZONE]
			)
	SELECT
		[SS].[LOCATION_SPOT]
		,[SS].[ZONE]
	FROM
		[wms].[OP_WMS_SHELF_SPOTS] [SS]
	INNER JOIN @WAREHOUSE_TABLE [WT] ON ([SS].[WAREHOUSE_PARENT] = [WT].[CODE_WAREHOUSE]);

  -- -----------------------------------------------------------------
  -- Validamos si materiales para filtrar
  -- -----------------------------------------------------------------
	IF NOT EXISTS ( SELECT
						1
					FROM
						@MATERIAL_TABLE )
	BEGIN

    -- -----------------------------------------------------------------
    -- Si no enviarion materiales para filtrar buscamos por las ubicaciones establecidas
    -- -----------------------------------------------------------------
		INSERT	INTO @MATERIAL_TABLE
				(
					[MATERIAL_CODE]
				)
		SELECT
			[IL].[MATERIAL_ID]
		FROM
			[wms].[OP_WMS_INV_X_LICENSE] [IL]
		INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
		INNER JOIN @LOCATION_TABLE [LT] ON ([L].[CURRENT_LOCATION] = [LT].[LOCATION])
		WHERE
			[IL].[QTY] > 0
		GROUP BY
			[IL].[MATERIAL_ID];
	END;

  -- -----------------------------------------------------------------
  -- Si no enviarion materiales para filtrar buscamos por las bodegas y zonas establecidas
  -- -----------------------------------------------------------------

  -- ------------------------------------------------------------------------------------
  -- obtengo la fecha de la ultima corrida de los indices de bodega
  -- ------------------------------------------------------------------------------------
	DECLARE	@DATE_PROCESS DATETIME;

	SELECT
		@DATE_PROCESS = MAX([DATE_OF_PROCESS])
	FROM
		[wms].[OP_WMS_WAREHOUSE_INDICES];
-- ------------------------------------------------------------------------------------
-- obtengo la informacion de la ultima corrida de indices de bodega
-- ------------------------------------------------------------------------------------

	SELECT
		[WI].[MATERIAL_CODE] [MATERIAL_ID]
		,[WI].[MATERIAL_NAME]
		,[WI].[AVARAGE_SALES] [AVERAGE_DEMAND]
		,[WI].[QTY] [QTY_INVENTORY]
		,[WI].[AVARAGE_SALES] - [WI].[QTY] [QTY]
		,[WI].[INVENTORY_ROTATION]
		,[WI].[LAST_PRICE_PURCHASE_BY_ERP] [LAST_PRICE_PURCHASE]
		,[WI].[LAST_DATE_PURCHASE_BY_ERP] [LAST_DATE_PURCHASE]
		,[M].[NAME_SUPPLIER] [SUPPLIER]
		,ISNULL([M].[LEAD_TIME], 0) [LEAD_TIME]
		,GETDATE() [SUGGESTED_PURCHASE_DATE]
		,GETDATE() + ISNULL([M].[LEAD_TIME], 0) [RECEPTION_DATE]
	FROM
		[wms].[OP_WMS_WAREHOUSE_INDICES] [WI]
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [WI].[MATERIAL_CODE] = [M].[MATERIAL_ID]
	INNER JOIN @WAREHOUSE_TABLE [WT] ON [WT].[CODE_WAREHOUSE] = [WI].[CODE_WAREHOUSE]
	INNER JOIN @MATERIAL_TABLE [MT] ON [WI].[MATERIAL_CODE] = [MT].[MATERIAL_CODE]
	WHERE
		[WI].[DATE_OF_PROCESS] = @DATE_PROCESS;

END;