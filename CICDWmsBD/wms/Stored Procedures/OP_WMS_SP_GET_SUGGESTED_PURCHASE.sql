



-- =============================================
-- Autor:					marvin.solares
-- Fecha de Creacion: 		25-Jun-2019 G-Force@Berlin-Swift3PL
-- Description:			    SP que obtiene el sugerido de compra

-- Autor:					marvin.solares
-- Fecha de Creacion: 		03-Jul-2019 G-Force@Berlin-Swift3PL
-- Description:			    se deja el lead time en dias

-- Autor:					kevin.guerra
-- Fecha de Creacion: 		11-Mar-2020 G-Force@Paris
-- Description:			    Se agrega columna Min y Max Stock, Transit y average_consumption, se modifica la columna inventario y sugerido, se elimina lead_time.

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].OP_WMS_SP_GET_SUGGESTED_PURCHASE
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_GET_SUGGESTED_PURCHASE]
(
    @LOGIN VARCHAR(25),
    @WAREHOUSE_XML XML,
    @MATERIAL_XML XML
)
AS
BEGIN
    SET NOCOUNT ON;
    -- -----------------------------------------------------------------
    -- Declaramos las variables necesarias
    -- -----------------------------------------------------------------

    DECLARE @WAREHOUSE_TABLE TABLE
    (
        [CODE_WAREHOUSE] VARCHAR(25),
        [ERP_WAREHOUSE] VARCHAR(50)
    );


    DECLARE @ZONE_TABLE TABLE
    (
        [ZONE] VARCHAR(25)
    );

    DECLARE @LOCATION_TABLE TABLE
    (
        [LOCATION] VARCHAR(25),
        [ZONE] VARCHAR(25)
    );


    DECLARE @MATERIAL_TABLE TABLE
    (
        [MATERIAL_CODE] VARCHAR(50)
    );

    -- -----------------------------------------------------------------
    -- Obtemos las bodegas enviadas
    -- -----------------------------------------------------------------

    INSERT INTO @WAREHOUSE_TABLE
    (
        [CODE_WAREHOUSE],
        [ERP_WAREHOUSE]
    )
    SELECT [x].[Rec].[query]('./WAREHOUSE_ID').[value]('.', 'VARCHAR(25)'),
           [x].[Rec].[query]('./ERP_WAREHOUSE').[value]('.', 'VARCHAR(50)')
    FROM @WAREHOUSE_XML.[nodes]('/ArrayOfBodega/Bodega') AS [x]([Rec]);

    -- -----------------------------------------------------------------
    -- Obtemos las materiales enviadas
    -- -----------------------------------------------------------------

    INSERT INTO @MATERIAL_TABLE
    (
        [MATERIAL_CODE]
    )
    SELECT [x].[Rec].[query]('./MATERIAL_CODE').[value]('.', 'VARCHAR(25)')
    FROM @MATERIAL_XML.[nodes]('/ArrayOfMaterial/Material') AS [x]([Rec]);

    -- -----------------------------------------------------------------
    -- Validamos si enviaron bodegas para filtrar
    -- -----------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM @WAREHOUSE_TABLE)
    BEGIN

        -- -----------------------------------------------------------------
        -- Si no enviarion bodegas para filtrar buscamos las de el usuario
        -- -----------------------------------------------------------------
        INSERT INTO @WAREHOUSE_TABLE
        (
            [CODE_WAREHOUSE]
        )
        SELECT [WU].[WAREHOUSE_ID]
        FROM [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU]
            INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W]
                ON ([W].[WAREHOUSE_ID] COLLATE DATABASE_DEFAULT = [WU].[WAREHOUSE_ID] COLLATE DATABASE_DEFAULT)
        WHERE [WU].[LOGIN_ID] = @LOGIN;
    END;

    -- -----------------------------------------------------------------
    -- Ya que tenemos las bodegas y zonas obtemos las ubicaciones
    -- -----------------------------------------------------------------
    INSERT INTO @LOCATION_TABLE
    (
        [LOCATION],
        [ZONE]
    )
    SELECT [SS].[LOCATION_SPOT],
           [SS].[ZONE]
    FROM [wms].[OP_WMS_SHELF_SPOTS] [SS]
        INNER JOIN @WAREHOUSE_TABLE [WT]
            ON ([SS].[WAREHOUSE_PARENT] COLLATE DATABASE_DEFAULT = [WT].[CODE_WAREHOUSE] COLLATE DATABASE_DEFAULT);

    -- -----------------------------------------------------------------
    -- Validamos si materiales para filtrar
    -- -----------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM @MATERIAL_TABLE)
    BEGIN

        -- -----------------------------------------------------------------
        -- Si no enviarion materiales para filtrar buscamos por las ubicaciones establecidas
        -- -----------------------------------------------------------------
        INSERT INTO @MATERIAL_TABLE
        (
            [MATERIAL_CODE]
        )
        SELECT [IL].[MATERIAL_ID]
        FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
            INNER JOIN [wms].[OP_WMS_LICENSES] [L]
                ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
            INNER JOIN @LOCATION_TABLE [LT]
                ON ([L].[CURRENT_LOCATION] = [LT].[LOCATION])
        WHERE [IL].[QTY] > 0
        GROUP BY [IL].[MATERIAL_ID];
    END;

    -- -----------------------------------------------------------------
    -- Si no enviarion materiales para filtrar buscamos por las bodegas y zonas establecidas
    -- -----------------------------------------------------------------

    -- ------------------------------------------------------------------------------------
    -- obtengo la fecha de la ultima corrida de los indices de bodega
    -- ------------------------------------------------------------------------------------
    DECLARE @DATE_PROCESS DATETIME;

    SELECT @DATE_PROCESS = MAX([DATE_OF_PROCESS])
    FROM [wms].[OP_WMS_WAREHOUSE_INDICES];
    -- ------------------------------------------------------------------------------------
    -- obtengo la informacion de la ultima corrida de indices de bodega
    -- ------------------------------------------------------------------------------------

	SELECT
		[WI].[MATERIAL_CODE] [MATERIAL_ID]
		,[WI].[MATERIAL_NAME]
		,SUM(MultiAlmacen.STOCK_MIN) [STOCK_MIN]
		,SUM(MultiAlmacen.STOCK_MAX) [STOCK_MAX]
		,SUM([WI].[QTY]) [QTY_INVENTORY]
		,SUM([PROM].[Transito]) [TRANSIT]
		,SUM(MultiAlmacen.STOCK_MIN) - SUM([WI].[QTY]) - SUM([PROM].[Transito]) [QTY]
		, CASE  
			WHEN SUM([PROM].ConsumoPromedio) = 0 
			THEN (SUM([WI].[QTY])+SUM([PROM].[Transito])) 
			ELSE (SUM([WI].[QTY])+SUM([PROM].[Transito])) / SUM([PROM].ConsumoPromedio)
		 END [COVERAGE_MONTHS]
		,MAX(Inventario.[FCH_ULTCOM]) [LAST_DATE_PURCHASE]
		,MAX([M].[NAME_SUPPLIER]) [SUPPLIER]
		,GETDATE() [SUGGESTED_PURCHASE_DATE]
		,GETDATE() + ISNULL(MAX([M].[LEAD_TIME]), 0) [RECEPTION_DATE]
		,SUM([PROM].ConsumoPromedio) [AVERAGE_CONSUMPTION]
	FROM
		[wms].[OP_WMS_WAREHOUSE_INDICES] [WI]
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [WI].[MATERIAL_CODE] COLLATE DATABASE_DEFAULT = [M].[MATERIAL_ID] COLLATE DATABASE_DEFAULT
	INNER JOIN @WAREHOUSE_TABLE [WT] ON [WT].[CODE_WAREHOUSE] COLLATE DATABASE_DEFAULT = [WI].[CODE_WAREHOUSE] COLLATE DATABASE_DEFAULT
	INNER JOIN @MATERIAL_TABLE [MT] ON [WI].[MATERIAL_CODE] COLLATE DATABASE_DEFAULT = [MT].[MATERIAL_CODE] COLLATE DATABASE_DEFAULT
	INNER JOIN SAE70EMPRESA01.dbo.INVE01 Inventario ON Inventario.CVE_ART COLLATE DATABASE_DEFAULT = [M].BARCODE_ID  
    LEFT JOIN SAE70EMPRESA01.dbo.MULT01 MultiAlmacen ON Inventario.CVE_ART = MultiAlmacen.CVE_ART  AND [MultiAlmacen].[CVE_ALM]  = [WT].[ERP_WAREHOUSE] 
	LEFT JOIN SAE70EMPRESA01.dbo.vConsumoPromedio PROM ON ([PROM].CVE_ART COLLATE DATABASE_DEFAULT = M.[BARCODE_ID] COLLATE DATABASE_DEFAULT AND [PROM].[ALMACEN]  = [WT].[ERP_WAREHOUSE] )
	WHERE
		[WI].[DATE_OF_PROCESS] = @DATE_PROCESS
	GROUP BY
		[WI].[MATERIAL_CODE]
		,[WI].[MATERIAL_NAME]

END;


