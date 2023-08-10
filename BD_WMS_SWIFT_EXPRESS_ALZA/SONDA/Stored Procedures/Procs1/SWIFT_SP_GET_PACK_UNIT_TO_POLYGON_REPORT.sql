-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	13-Jan-17 @ A-TEAM Sprint Adeben 
-- Description:			SP que obtiene las estadisticas de venta por poligonos

-- Modificacion:        hector.gonzalez
-- Fecha:               14/4/2017 @ A-Team Sprint Hondo
-- Descripcion:         Se agrego inner join a usuarios, rutas, y poligonos por rutas para filtrar los usuario por poligono en el while

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_PACK_UNIT_TO_POLYGON_REPORT]
				    	@POLYGON_TYPE = 'REGION'
				    	,@START_DATETIME = '20161201 00:00:00.000'
				    	,@END_DATETIME = '20170201 00:00:00.000'
				    	,@TAG_COLORS = NULL
				    	,@CHANNELS = NULL
				    	,@TYPE = 'SALE'
				    --
				    EXEC [SONDA].[SWIFT_SP_GET_PACK_UNIT_TO_POLYGON_REPORT]
				    	@POLYGON_TYPE = 'REGION'
				    	,@START_DATETIME = '20161201 00:00:00.000'
				    	,@END_DATETIME = '20170201 00:00:00.000'
				    	,@TAG_COLORS = NULL
				    	,@CHANNELS = '21|1'
				    	,@TYPE = 'PRESALE'
				    --
				    EXEC [SONDA].[SWIFT_SP_GET_PACK_UNIT_TO_POLYGON_REPORT]
				    	@POLYGON_TYPE = 'SECTOR'
				    	,@POLYGON_SUB_TYPE = 'COMMERCIAL'
				    	,@POLYGON_ID_PARENT = 63
				    	,@START_DATETIME = '20161201 00:00:00.000'
				    	,@END_DATETIME = '20170201 00:00:00.000'
				    	,@TAG_COLORS = '#3D1D1D'--NULL
				    	,@CHANNELS = NULL--'21|1'
				    	,@TYPE = 'SALE'
				    --
				    EXEC [SONDA].[SWIFT_SP_GET_PACK_UNIT_TO_POLYGON_REPORT]
				    	@POLYGON_TYPE = 'SECTOR'
				    	,@POLYGON_SUB_TYPE = 'COMMERCIAL'
				    	,@POLYGON_ID_PARENT = 63
				    	,@START_DATETIME = '20161201 00:00:00.000'
				    	,@END_DATETIME = '20170201 00:00:00.000'
				    	,@TAG_COLORS = NULL
				    	,@CHANNELS = NULL
				    	,@TYPE = 'PRESALE'
				    --
				    EXEC [SONDA].[SWIFT_SP_GET_PACK_UNIT_TO_POLYGON_REPORT]
				    	@POLYGON_TYPE = 'RUTA'
				    	,@POLYGON_SUB_TYPE = 'COMMERCIAL'
				    	,@POLYGON_ID_PARENT = 5167
				    	,@START_DATETIME = '20161201 00:00:00.000'
				    	,@END_DATETIME = '20170201 00:00:00.000'
				    	,@TAG_COLORS = NULL
				    	,@CHANNELS = NULL
				    	,@TYPE = 'SALE'
				    --
				    EXEC [SONDA].[SWIFT_SP_GET_PACK_UNIT_TO_POLYGON_REPORT]
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
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_PACK_UNIT_TO_POLYGON_REPORT (@POLYGON_TYPE VARCHAR(250)
, @POLYGON_SUB_TYPE VARCHAR(250) = NULL
, @POLYGON_ID_PARENT INT = NULL
, @START_DATETIME DATETIME
, @END_DATETIME DATETIME
, @TAG_COLORS VARCHAR(MAX) = NULL
, @CHANNELS VARCHAR(MAX) = NULL
, @TYPE VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  BEGIN TRY
    -- ------------------------------------------------------------------------------------
    -- Declaramos las variables a utilizar
    -- ------------------------------------------------------------------------------------
    DECLARE @TOTAL_CUSTOMERS INT = 0
           ,@vPOLYGON_ID INT
           ,@GEOMETRY_POLYGON GEOMETRY
           ,@DELIMITER VARCHAR(1)
           ,@DEFAULT_DISPLAY_DECIMALS INT
           ,@QUERY NVARCHAR(4000)
    --
    CREATE TABLE [#CUSTOMER_TEMP] (
      [CODE_CUSTOMER] VARCHAR(50)
    );
    --
    CREATE TABLE [#POLYGON_PACK_UNIT] (
      [POLYGON_ID] INT
     ,[PACK_UNIT] VARCHAR(250)
     ,[QTY] NUMERIC(18, 6)
    );
    --
    DECLARE @TAG TABLE (
      [TAG_COLOR] VARCHAR(8)
    )
    --
    DECLARE @CHANNEL TABLE (
      [CHANNEL_ID] INT
    )
    --
    DECLARE @TOTAL_QTY_BY_SKU_AND_PACK_UNIT TABLE (
      [CODE_CUSTOMER] VARCHAR(50)
     ,[PACK_UNIT] VARCHAR(250)
     ,[QTY] NUMERIC(18, 6)
     ,[POLYGON_ID] INT
    )
    -- ------------------------------------------------------------------------------------
    -- Coloca parametros iniciales
    -- ------------------------------------------------------------------------------------
    SELECT
      @DELIMITER = [SONDA].[SWIFT_FN_GET_PARAMETER]('DELIMITER', 'DEFAULT_DELIMITER')
     ,@DEFAULT_DISPLAY_DECIMALS = [SONDA].[SWIFT_FN_GET_PARAMETER]('CALCULATION_RULES', 'DEFAULT_DISPLAY_DECIMALS')
     ,@POLYGON_SUB_TYPE =
                         CASE
                           WHEN @POLYGON_TYPE = 'RUTA' THEN NULL
                           ELSE @POLYGON_SUB_TYPE
                         END

    -- ------------------------------------------------------------------------------------
    -- Obtenemos todos los poligonos del tipo y subtipo a generar
    -- ------------------------------------------------------------------------------------
    SELECT
      [P].[POLYGON_ID]
     ,[P].[POLYGON_ID_PARENT] INTO [#POLYGON]
    FROM [SONDA].[SWIFT_POLYGON] [P]
    WHERE [P].[POLYGON_TYPE] = @POLYGON_TYPE
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
      INSERT INTO @TAG
        SELECT
          [T].[VALUE]
        FROM [SONDA].[SWIFT_FN_SPLIT_2](@TAG_COLORS, @DELIMITER) [T]
    END

    -- ------------------------------------------------------------------------------------
    -- Obtiene los canales
    -- ------------------------------------------------------------------------------------
    IF @CHANNELS IS NOT NULL
    BEGIN
      INSERT INTO @CHANNEL
        SELECT
          [C].[VALUE]
        FROM [SONDA].[SWIFT_FN_SPLIT_2](@CHANNELS, @DELIMITER) [C]
    END

    -- ------------------------------------------------------------------------------------
    -- Obtiene los clientes
    -- ------------------------------------------------------------------------------------
    SELECT
      [C].[CODE_CUSTOMER]
     ,[C].[LATITUDE]
     ,[C].[LONGITUDE]
     ,[GEOMETRY]::Point([C].[LATITUDE], [C].[LONGITUDE], 0) [POINT]
     ,[C].[SELLER_DEFAULT_CODE] AS [SELLER_CODE] INTO [#CUSTOMER]
    FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
    WHERE [GPS] <> '0,0'
    AND ([C].[LATITUDE] IS NOT NULL
    AND [C].[LONGITUDE] IS NOT NULL)
    AND [GPS] IS NOT NULL;

    -- ------------------------------------------------------------------------------------
    -- Obtiene el total de clientes
    -- ------------------------------------------------------------------------------------
    SELECT
      @TOTAL_CUSTOMERS = @@rowcount;
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
    -- Elimina los clientes que no esten en las etiquetas
    -- ------------------------------------------------------------------------------------
    IF @TAG_COLORS IS NOT NULL
    BEGIN
      DELETE [C]
        FROM [#CUSTOMER] [C]
        LEFT JOIN [SONDA].[SWIFT_TAG_X_CUSTOMER] [TC]
          ON (
          [TC].[CUSTOMER] = [CODE_CUSTOMER]
          )
        LEFT JOIN @TAG [T]
          ON (
          [T].[TAG_COLOR] = [TC].[TAG_COLOR]
          )
      WHERE [T].[TAG_COLOR] IS NULL
    END

    -- ------------------------------------------------------------------------------------
    -- Elimina los clientes que no esten en los canales
    -- ------------------------------------------------------------------------------------
    IF @CHANNELS IS NOT NULL
    BEGIN
      DELETE [C]
        FROM [#CUSTOMER] [C]
        LEFT JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC]
          ON (
          [CC].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER]
          )
        LEFT JOIN @CHANNEL [CN]
          ON (
          [CN].[CHANNEL_ID] = [CC].[CHANNEL_ID]
          )
      WHERE [CN].[CHANNEL_ID] IS NULL
    END

    -- ------------------------------------------------------------------------------------
    -- Valida que tipo de consulta es
    -- ------------------------------------------------------------------------------------
    IF @TYPE = 'PRESALE'
    BEGIN
      -- ------------------------------------------------------------------------------------
      -- Obtiene por cliente el total de las ordenes de venta
      -- ------------------------------------------------------------------------------------			
      INSERT INTO @TOTAL_QTY_BY_SKU_AND_PACK_UNIT
        SELECT
          [SO].[CLIENT_ID]
         ,MAX([PU].[DESCRIPTION_PACK_UNIT])
         ,SUM([SD].[QTY])
         ,[PBR].[POLYGON_ID]
        FROM [SONDA].[SONDA_SALES_ORDER_DETAIL] [SD]
        INNER JOIN [SONDA].[SONDA_SALES_ORDER_HEADER] [SO]
          ON (
          [SO].[SALES_ORDER_ID] = [SD].[SALES_ORDER_ID]
          )
        INNER JOIN [#CUSTOMER] [C]
          ON (
          [C].[CODE_CUSTOMER] = [SO].[CLIENT_ID]
          )
        INNER JOIN [SONDA].[SONDA_PACK_UNIT] [PU]
          ON (
          [PU].[CODE_PACK_UNIT] = [SD].[CODE_PACK_UNIT]
          )
        INNER JOIN [SONDA].[USERS] [U]
          ON (
			[U].[SELLER_ROUTE] = [SO].[POS_TERMINAL]
          )
        INNER JOIN [SONDA].[SWIFT_ROUTES] [R]
          ON (
          R.[SELLER_CODE] = [U].[RELATED_SELLER]
          )
        INNER JOIN [SONDA].[SWIFT_POLYGON_BY_ROUTE] [PBR]
          ON (
          [PBR].[ROUTE] = [R].[ROUTE]
          )
        WHERE [SO].[POSTED_DATETIME] BETWEEN @START_DATETIME AND @END_DATETIME
        AND [SO].IS_READY_TO_SEND = 1
        GROUP BY [PBR].[POLYGON_ID]
                ,[SO].[CLIENT_ID]
                ,[SD].[CODE_PACK_UNIT]

    END
    ELSE
    BEGIN
      -- ------------------------------------------------------------------------------------
      -- Obtiene por cliente el total de las facturas
      -- ------------------------------------------------------------------------------------
      INSERT INTO @TOTAL_QTY_BY_SKU_AND_PACK_UNIT
        SELECT
          [I].[CLIENT_ID]
         ,'Manual'
         ,SUM([D].[QTY])
         ,[PBR].[POLYGON_ID]
        FROM [SONDA].[SONDA_POS_INVOICE_DETAIL] [D]
        INNER JOIN [SONDA].[SONDA_POS_INVOICE_HEADER] [I]
          ON (
          [I].[CDF_RESOLUCION] = [D].[INVOICE_RESOLUTION]
          AND [I].[CDF_SERIE] = [D].[INVOICE_SERIAL]
          AND [I].[INVOICE_ID] = [D].[INVOICE_ID]
          )
        INNER JOIN [#CUSTOMER] [C]
          ON (
          [C].[CODE_CUSTOMER] = [I].[CLIENT_ID]
          )
        INNER JOIN [SONDA].[USERS] [U]
          ON (
          [U].[SELLER_ROUTE] = [I].[POS_TERMINAL]
          )
        INNER JOIN [SONDA].[SWIFT_ROUTES] [R]
          ON (
          R.[SELLER_CODE] = [U].[RELATED_SELLER]
          )
        INNER JOIN [SONDA].[SWIFT_POLYGON_BY_ROUTE] [PBR]
          ON (
          [PBR].[ROUTE] = [R].[ROUTE]
          )
        WHERE [I].[POSTED_DATETIME] BETWEEN @START_DATETIME AND @END_DATETIME
        GROUP BY [PBR].[POLYGON_ID]
                ,[I].[CLIENT_ID]

    END

    -- ------------------------------------------------------------------------------------
    -- Inicia ciclo para cada poligono obtenido
    -- ------------------------------------------------------------------------------------
    WHILE EXISTS (SELECT TOP 1
          1
        FROM [#POLYGON])
    BEGIN
      SELECT TOP 1
        @vPOLYGON_ID = [POLYGON_ID]
      FROM [#POLYGON]
      ORDER BY [POLYGON_ID_PARENT] ASC;

      -- ------------------------------------------------------------------------------------
      -- ObtIene el poligono actual 
      -- ------------------------------------------------------------------------------------
      SET @GEOMETRY_POLYGON = [SONDA].[SWIFT_GET_GEOMETRY_POLYGON_BY_POLIGON_ID](@vPOLYGON_ID);

      -- ------------------------------------------------------------------------------------
      -- Obtiene los clientes del poligono actual
      -- ------------------------------------------------------------------------------------
      INSERT INTO [#CUSTOMER_TEMP]
        SELECT
          [C].[CODE_CUSTOMER]
        FROM [#CUSTOMER] [C]
        WHERE @GEOMETRY_POLYGON.[MakeValid]().[STContains]([C].[Point]) = 1;

      -- ------------------------------------------------------------------------------------
      -- Obtiene la cantidad por unidad de medida en el poligono
      -- ------------------------------------------------------------------------------------
      IF @POLYGON_TYPE = 'RUTA'
	  BEGIN
		INSERT INTO [#POLYGON_PACK_UNIT] ([POLYGON_ID]
		, [PACK_UNIT]
		, [QTY])
		SELECT
			@vPOLYGON_ID
			,[TQ].[PACK_UNIT]
			,SUM([TQ].[QTY])
		FROM @TOTAL_QTY_BY_SKU_AND_PACK_UNIT [TQ]
		INNER JOIN [#CUSTOMER_TEMP] [C]
			ON (
			[C].[CODE_CUSTOMER] = [TQ].[CODE_CUSTOMER]
			)
		WHERE [TQ].[POLYGON_ID] = @vPOLYGON_ID
		GROUP BY [TQ].[PACK_UNIT]
	  END
	  ELSE
	  BEGIN
	    INSERT INTO [#POLYGON_PACK_UNIT] ([POLYGON_ID]
		, [PACK_UNIT]
		, [QTY])
		SELECT
			@vPOLYGON_ID
			,[TQ].[PACK_UNIT]
			,SUM([TQ].[QTY])
		FROM @TOTAL_QTY_BY_SKU_AND_PACK_UNIT [TQ]
		INNER JOIN [#CUSTOMER_TEMP] [C]
			ON (
			[C].[CODE_CUSTOMER] = [TQ].[CODE_CUSTOMER]
			)
		GROUP BY [TQ].[PACK_UNIT]
	  END
      -- ------------------------------------------------------------------------------------
      -- Elimina el registro actual
      -- ------------------------------------------------------------------------------------
      DELETE FROM [#POLYGON]
      WHERE [POLYGON_ID] = @vPOLYGON_ID;

      -- ------------------------------------------------------------------------------------
      -- Elimina los clientes ya validados
      -- ------------------------------------------------------------------------------------
      --      DELETE [C]
      --        FROM [#CUSTOMER] [C]
      --        INNER JOIN [#CUSTOMER_TEMP] [CT]
      --          ON (
      --          [CT].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER]
      --          )
      --
      TRUNCATE TABLE [#CUSTOMER_TEMP]
    END;

    -- ------------------------------------------------------------------------------------
    -- Muestra el resultado
    -- ------------------------------------------------------------------------------------
    SET @QUERY = N'SELECT
			[PPU].[POLYGON_ID]
			,[P].[POLYGON_NAME]
			,[PPU].[PACK_UNIT]
			,CONVERT(DECIMAL(18,' + CAST(@DEFAULT_DISPLAY_DECIMALS AS VARCHAR) + '),[SONDA].SWIFT_FN_GET_DISPLAY_NUMBER([PPU].[QTY])) [QTY]
		FROM [#POLYGON_PACK_UNIT] [PPU]
		INNER JOIN [SONDA].[SWIFT_POLYGON] [P] ON (
			[PPU].[POLYGON_ID] = [P].[POLYGON_ID]
		)'
    --
    PRINT '----> @QUERY: ' + @QUERY
    --
    EXEC (@QUERY)
  END TRY
  BEGIN CATCH
    SELECT
      -1 AS [RESULTADO]
     ,ERROR_MESSAGE() [MENSAJE]
     ,@@error [CODIGO];
  END CATCH;
END;
