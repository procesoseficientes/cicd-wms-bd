-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		09-May-17 @ A-Team Sprint Anekbah
-- Description:			    SP que obtiene los productos de preventa y venta directa

/*
-- Ejemplo de Ejecucion:
		EXEC [SONDA].[SONDA_SP_GET_SKU]
			@CODE_ROUTE = '44';
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_SKU]
(@CODE_ROUTE VARCHAR(50))
AS
BEGIN
    SET NOCOUNT ON;
    --
    DECLARE @SALE_WAREHOUSE VARCHAR(50),
            @PRESALE_WAREHOUSE VARCHAR(50),
            @DISTRIBUTION_CENTER_ID INT,
            @CANTIDAD_MINIMA FLOAT = 0,
            @SELLER_CODE VARCHAR(50),
            @CODE_PORTFOLIO VARCHAR(25) = NULL,
            @COUNT_RESULT INT = 0,
            @USE_REGIONAL_INVENTORY INT = 0;

    CREATE TABLE [#PRESALE_SKU]
    (
        [WAREHOUSE] VARCHAR(50),
        [SKU] VARCHAR(50),
        [SKU_DESCRIPTION] VARCHAR(MAX),
        [ON_HAND] FLOAT,
        [IS_COMITED] [NUMERIC](18, 0)
    );
    -- ------------------------------------------------------------------------------------
    -- Obtiene las Bodegas, Vendedor y el CDD de la ruta
    -- ------------------------------------------------------------------------------------
    SELECT @SALE_WAREHOUSE = [DEFAULT_WAREHOUSE],
           @PRESALE_WAREHOUSE = [PRESALE_WAREHOUSE],
           @DISTRIBUTION_CENTER_ID = [DISTRIBUTION_CENTER_ID],
           @SELLER_CODE = [RELATED_SELLER]
    FROM [SONDA].[USERS]
    WHERE [SELLER_ROUTE] = @CODE_ROUTE;

    -- ------------------------------------------------------------------------------------
    -- Obtiene Parametro de uso de Inventario Regional
    -- ------------------------------------------------------------------------------------
    SELECT @USE_REGIONAL_INVENTORY = [SONDA].[SWIFT_FN_GET_PARAMETER]('IMPLEMENTATION', 'USE_REGIONAL_INVENTORY');

    -- =============================================
    -- Obtenemos si vendedor tiene asociado un potafolios
    -- =============================================
    SELECT TOP 1
           @CODE_PORTFOLIO = [PS].[CODE_PORTFOLIO]
    FROM [SONDA].[SWIFT_PORTFOLIO_BY_SELLER] [PS]
    WHERE [PS].[CODE_SELLER] = @SELLER_CODE;

    -- =============================================
    -- Se obtienen las listas de precio y ademas se agrega la lista default
    -- =============================================
    SELECT DISTINCT
           [splbc].[CODE_PRICE_LIST]
    INTO [#PRICE_LIST]
    FROM [SONDA].[SONDA_ROUTE_PLAN] [srp]
        INNER JOIN [SONDA].[SWIFT_PRICE_LIST_BY_CUSTOMER_FOR_ROUTE] [splbc]
            ON (
                   [srp].[RELATED_CLIENT_CODE] = [splbc].[CODE_CUSTOMER] COLLATE DATABASE_DEFAULT
                   AND [splbc].[CODE_ROUTE] = [srp].[CODE_ROUTE] COLLATE DATABASE_DEFAULT
               )
    WHERE [srp].[CODE_ROUTE] = @CODE_ROUTE;
    --
    INSERT INTO [#PRICE_LIST]
    (
        [CODE_PRICE_LIST]
    )
    SELECT [SONDA].[SWIFT_FN_GET_PARAMETER]('ERP_HARDCODE_VALUES', 'PRICE_LIST');

    -- =============================================
    -- Se valida si la regla PreventaSinExistencia esta activa y si si se cambia el valor a la variable para que tome en cuenta los valores desde 0
    -- =============================================
    SELECT @CANTIDAD_MINIMA = -0.01
    FROM [SONDA].[SWIFT_EVENT] [se]
        INNER JOIN [SONDA].[SWIFT_RULE_X_EVENT] [srxe]
            ON [se].[EVENT_ID] = [srxe].[EVENT_ID]
        INNER JOIN [SONDA].[SWIFT_RULE_X_ROUTE] [srxr]
            ON [srxe].[RULE_ID] = [srxr].[RULE_ID]
    WHERE [se].[TYPE_ACTION] = 'PreventaSinExistencia'
          AND [se].[ENABLED] = 'Si'
          AND [srxr].[CODE_ROUTE] = @CODE_ROUTE;


    IF (@USE_REGIONAL_INVENTORY = 1)
    BEGIN
        -- =============================================
        -- Se obtiene el inventario de todas las bodegas del CDD del usuario, dejando su bodega preventa como Default
        -- =============================================
        INSERT INTO [#PRESALE_SKU]
		SELECT @PRESALE_WAREHOUSE [WAREHOUSE],
               [I].[SKU],
               MAX([I].[SKU_DESCRIPTION]) [SKU_DESCRIPTION],
               SUM([I].[ON_HAND]) AS [ON_HAND],
               SUM(ISNULL([CW].[IS_COMITED], 0)) AS [IS_COMITED]
        FROM [SONDA].[SONDA_IS_COMITED_BY_WAREHOUSE] [CW]
            INNER JOIN [SONDA].[SWIFT_INVENTORY] [I]
                ON (
                       [CW].[CODE_WAREHOUSE] COLLATE DATABASE_DEFAULT = [I].[WAREHOUSE] COLLATE DATABASE_DEFAULT
                       AND [I].[SKU] = [CW].[CODE_SKU] COLLATE DATABASE_DEFAULT  
                   )
            INNER JOIN [SONDA].[SWIFT_WAREHOUSE_X_DISTRIBUTION_CENTER] [W]
                ON ([W].[CODE_WAREHOUSE] COLLATE DATABASE_DEFAULT = [CW].[CODE_WAREHOUSE] COLLATE DATABASE_DEFAULT )
        WHERE [W].[DISTRIBUTION_CENTER_ID] = @DISTRIBUTION_CENTER_ID
              AND [I].[ON_HAND] > @CANTIDAD_MINIMA
        GROUP BY [I].[SKU]
        ORDER BY [I].[SKU];
    END;
    ELSE
    BEGIN
        -- =============================================
        -- Se inserta en la tabla temporal el select que se tenia en la vista [SWIFT_VIEW_PRESALE_SKU] ya con el valor de @CANTIDAD_MINIMA
        -- =============================================
        INSERT INTO [#PRESALE_SKU]
		SELECT [I].[WAREHOUSE],
               [I].[SKU],
               MAX([I].[SKU_DESCRIPTION]) [SKU_DESCRIPTION],
               SUM([I].[ON_HAND]) AS [ON_HAND],
               SUM(ISNULL([CW].[IS_COMITED], 0)) AS [IS_COMITED]
        FROM [SONDA].[SONDA_IS_COMITED_BY_WAREHOUSE] [CW]
            INNER JOIN [SONDA].[SWIFT_INVENTORY] [I]
                ON (
                       [CW].[CODE_WAREHOUSE] = [I].[WAREHOUSE] COLLATE DATABASE_DEFAULT
                       AND [I].[SKU] = [CW].[CODE_SKU] COLLATE DATABASE_DEFAULT
                   )
        WHERE [CW].[CODE_WAREHOUSE] = @PRESALE_WAREHOUSE
              AND [I].[ON_HAND] > @CANTIDAD_MINIMA
        GROUP BY [I].[WAREHOUSE],
                 [I].[SKU]
        ORDER BY [I].[WAREHOUSE],
                 [I].[SKU];
    END;

    -- =============================================
    -- Se hace el select de los skus ya con la vista cambiada por la tabla temporal anterior y su cantidad minima a buscar
    -- =============================================
    SELECT DISTINCT
           [I].[WAREHOUSE],
           [I].[SKU],
           [S].[DESCRIPTION_SKU] AS [SKU_NAME],
           [I].[ON_HAND],
           [IS_COMITED],
           ([I].[ON_HAND] - [I].[IS_COMITED]) AS [DIFFERENCE],
           0 AS [SKU_PRICE],
           [S].[CODE_FAMILY_SKU],
           [S].[CODE_PACK_UNIT] AS [SALES_PACK_UNIT],
           [S].[HANDLE_DIMENSION],
           [S].[OWNER],
           [S].[OWNER_ID],
           [S].[HANDLE_SERIAL_NUMBER]
    INTO [#RESULT]
    FROM [#PRESALE_SKU] [I]
        INNER JOIN [SONDA].[SWIFT_PRICE_LIST_BY_SKU_PACK_SCALE_FOR_ROUTE] [splbs]
            ON ([I].[SKU] = [splbs].[CODE_SKU] COLLATE DATABASE_DEFAULT)
        INNER JOIN [#PRICE_LIST] [pl]
            ON ([pl].[CODE_PRICE_LIST] = [splbs].[CODE_PRICE_LIST])
        INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S]
            ON ([I].[SKU] = [S].[CODE_SKU] COLLATE DATABASE_DEFAULT)
        LEFT JOIN [SONDA].[SWIFT_PORTFOLIO_BY_SKU] [PS]
            ON ([PS].[CODE_SKU] = [I].[SKU] COLLATE DATABASE_DEFAULT)
    WHERE @CODE_PORTFOLIO IS NULL
          OR [PS].[CODE_PORTFOLIO] = @CODE_PORTFOLIO;

    -- ------------------------------------------------------------------------------------
    -- Valida si la bodega de venta directa es diferente a la de preventa
    -- ------------------------------------------------------------------------------------
    IF @PRESALE_WAREHOUSE != @SALE_WAREHOUSE
    BEGIN
        INSERT INTO [#RESULT]
        (
            [WAREHOUSE],
            [SKU],
            [SKU_NAME],
            [ON_HAND],
            [IS_COMITED],
            [DIFFERENCE],
            [SKU_PRICE],
            [CODE_FAMILY_SKU],
            [SALES_PACK_UNIT],
            [HANDLE_DIMENSION],
            [OWNER],
            [OWNER_ID],
            [HANDLE_SERIAL_NUMBER]
        )
        SELECT [I].[ROUTE_ID],
               [I].[SKU],
               [I].[SKU_NAME],
               [I].[ON_HAND],
               0,
               0,
               0,
               [S].[CODE_FAMILY_SKU],
               [S].[CODE_PACK_UNIT],
               [S].[HANDLE_DIMENSION],
               [S].[OWNER],
               [S].[OWNER_ID],
               [S].[HANDLE_SERIAL_NUMBER]
        FROM [SONDA].[SONDA_POS_SKUS] [I]
            INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S]
                ON ([I].[SKU] = [S].[CODE_SKU] COLLATE DATABASE_DEFAULT)
            LEFT JOIN [SONDA].[SWIFT_PORTFOLIO_BY_SKU] [PS]
                ON ([PS].[CODE_SKU] = [I].[SKU] COLLATE DATABASE_DEFAULT)
        WHERE [ROUTE_ID] = @SALE_WAREHOUSE
              AND
              (
                  @CODE_PORTFOLIO IS NULL
                  OR [PS].[CODE_PORTFOLIO] = @CODE_PORTFOLIO
              )
              AND [I].[ON_HAND] > 0;
    END;

    -- ------------------------------------------------------------------------------------
    -- Muestra el resultado final
    -- ------------------------------------------------------------------------------------
    SELECT [R].[WAREHOUSE],
           [R].[SKU],
           [R].[SKU_NAME],
           [R].[ON_HAND],
           [R].[IS_COMITED],
           [R].[DIFFERENCE],
           [R].[SKU_PRICE],
           [R].[CODE_FAMILY_SKU],
           [F].[DESCRIPTION_FAMILY_SKU],
           [R].[SALES_PACK_UNIT],
           [R].[HANDLE_DIMENSION],
           [R].[OWNER],
           [R].[OWNER_ID],
           [R].[HANDLE_SERIAL_NUMBER],
           [PU].[PACK_UNIT],
           [PU].[CODE_PACK_UNIT]
    FROM [#RESULT] [R]
        INNER JOIN [SONDA].[SONDA_PACK_CONVERSION] [PC]
            ON ([PC].[CODE_SKU] = [R].[SKU] COLLATE DATABASE_DEFAULT)
        INNER JOIN [SONDA].[SONDA_PACK_UNIT] [PU]
            ON ([PU].[CODE_PACK_UNIT] = [PC].[CODE_PACK_UNIT_FROM])
        LEFT JOIN [SONDA].[SWIFT_FAMILY_SKU] AS [F]
            ON [F].[CODE_FAMILY_SKU] = [R].[CODE_FAMILY_SKU] COLLATE DATABASE_DEFAULT
    WHERE [PC].[ORDER] = 1;

    -- =============================================
    -- Se validad si el portafolios 
    -- =============================================
    SELECT @COUNT_RESULT = @@ROWCOUNT;
    --
    IF @CODE_PORTFOLIO IS NOT NULL
       AND @COUNT_RESULT = 0
    BEGIN
        RAISERROR('El portafolios asignado no tiene productos.', 16, 1);
    END;
END;




