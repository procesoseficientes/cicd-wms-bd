-- =============================================
-- Autor: pablo.aguilar
-- Fecha de Creación: 2017-05-17 ErgonTeam@Sheik
-- Description:	 Se crea para que reciba varios documentos y fuentes de externas separados por | para eficientar el proceso de consultar detalles de ordenes para canal moderno

-- Modificacion 8/8/2017 @ NEXUS-Team Sprint Banjo Kazooie
-- rodrigo.gomez
-- Se agregan las columnas intercompany

-- Modificacion 8/30/2017 @ NEXUS-Team Sprint CommandAndConquer
-- rodrigo.gomez
-- Se agrega columna SOURCE

-- Modificacion 9/23/2017 @ NEXUS-Team Sprint DuckHunt
					-- rodrigo.gomez
					-- Se agrega condicion al join con DEMAND_DETAIL

-- Modificacion 03-Nov-17 @ Nexus Team Sprint F-ZERO
					-- pablo.aguilar
					-- Se agrega retornar datos de descuento.

-- Modificacion 5/31/2018 @ GFORCE-Team Sprint Dinosaurio
					-- rodrigo.gomez
					-- Se agrega unidad de medida

	-- Modificacion 25-07-2019 @ Nexus Team Sprint 
						-- pablo.aguilar
						-- Se modifica para contemplar docnum y docentry como varchar
/*
-- Ejemplo de Ejecucion:
		EXEC  [wms].OP_WMS_GET_ERP_SALES_ORDER_DETAIL_BY_ORDERS_CHANNEL_MODERN 
			@DOC_NUMS = '99780|', 
			@EXTERNAL_SOURCE_IDS = '2|', 
			@CODE_WAREHOUSE = 'BODEGA_01',
			@START_DATE = '2016-09-26 00:00:00.00',
			@END_DATE = '2020-09-26 09:37:47.493'

			SELECT * FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_ERP_SALES_ORDER_DETAIL_BY_ORDERS_CHANNEL_MODERN]
    (
      @DOC_NUMS VARCHAR(MAX) ,
      @EXTERNAL_SOURCE_IDS VARCHAR(MAX) ,
      @CODE_WAREHOUSE VARCHAR(50) ,
      @START_DATE DATETIME ,
      @END_DATE DATETIME
	)
AS
    BEGIN
        SET NOCOUNT ON;
  --
        DECLARE @SOURCE_NAME VARCHAR(50) ,
            @EXTERNAL_SOURCE_ID INT ,
            @DATA_BASE_NAME VARCHAR(50) ,
            @SCHEMA_NAME VARCHAR(50) ,
            @QUERY NVARCHAR(MAX) ,
            @DELIMITER CHAR(1) = '|' ,
            @DOC_NUM INT ,
            @ERP_WAREHOUSE VARCHAR(50);

        BEGIN
            CREATE TABLE [#SALES_ORDERS]
                (
                  [ORDE] VARCHAR(50) NOT NULL ,
                  [EXTERNAL_SOURCE_ID] [INT] NOT NULL ,
                  [SALE_ORDER_ID] VARCHAR(50) NOT NULL ,
                  [SOURCE_NAME] VARCHAR(50) NULL ,
                  [DATA_BASE_NAME] VARCHAR(50) NULL ,
                  [SCHEMA_NAME] VARCHAR(50) NULL
                );
    
		-- ------------------------------------------------------------------------------------
		-- Obtiene las ordenes con su respectiva fuente
		-- ------------------------------------------------------------------------------------
            INSERT  INTO [#SALES_ORDERS]
                    SELECT  [ES].[ID] [ORDER] ,
                            CAST([ES].[VALUE] AS INT) [EXTERNAL_SOURCE_ID] ,
                            [SO].[VALUE] [SALE_ORDER_ID] ,
                            [SES].[SOURCE_NAME] ,
                            [SES].[INTERFACE_DATA_BASE_NAME] [DATA_BASE_NAME] ,
                            [SES].[SCHEMA_NAME]
                    FROM    [wms].[OP_WMS_FN_SPLIT](@EXTERNAL_SOURCE_IDS,
                                                      @DELIMITER) [ES]
                            INNER JOIN [wms].[OP_WMS_FN_SPLIT](@DOC_NUMS,
                                                              @DELIMITER) [SO] ON ( [SO].[ID] = [ES].[ID] )
                            INNER JOIN [wms].[OP_SETUP_EXTERNAL_SOURCE] [SES] ON [ES].[VALUE] = [SES].[EXTERNAL_SOURCE_ID];
        END;

	--	ALTER TABLE [#SALES_ORDERS]
	--	ADD CONSTRAINT PK_TEMP_SALES_ORDERS PRIMARY KEY([SALE_ORDER_ID])
        SELECT  @ERP_WAREHOUSE = [ERP_WAREHOUSE]
        FROM    [wms].[OP_WMS_WAREHOUSES]
        WHERE   [WAREHOUSE_ID] = @CODE_WAREHOUSE;


        SELECT DISTINCT
                [EXTERNAL_SOURCE_ID] ,
                [SOURCE_NAME] ,
                [DATA_BASE_NAME] ,
                [SCHEMA_NAME]
        INTO    [#EXTERNAL_SOURCE]
        FROM    [#SALES_ORDERS];

	---------------------------------------------------------------------------------
	-- Crear detalle
	---------------------------------------------------------------------------------  
        CREATE TABLE [#PICKING_DEMAND_DETAIL]
            (
              [DOC_NUM] VARCHAR(50) ,
              [MATERIAL_ID] VARCHAR(50) ,
              [QTY] DECIMAL(16, 6) ,
              [OWNER] VARCHAR(50) ,
              [LINE_SEQ] INT
            );


        CREATE TABLE [#RESULTADO]
            (
              [POSTED_DATETIME] DATETIME ,
              [SALES_ORDER_ID]VARCHAR(50) COLLATE DATABASE_DEFAULT,
              [U_Serie] NVARCHAR(50) ,
              [U_NoDocto] NVARCHAR(10) ,
              [CLIENT_ID] NVARCHAR(15) ,
              [NAME_CUSTOMER] NVARCHAR(MAX) ,
              [SLPNAME] NVARCHAR(155) ,
              [CODE_SELLER] NVARCHAR(50) ,
              [SKU] NVARCHAR(50) ,
              [DESCRIPTION_SKU] NVARCHAR(100) ,
              [BARCODE_ID] VARCHAR(25) ,
              [ALTERNATE_BARCODE] VARCHAR(25) ,
              [QTY] DECIMAL(19, 6) ,
              [QTY_PENDING] DECIMAL(19, 6) ,
              [QTY_ORIGINAL] DECIMAL(19, 6) ,
              [PRICE] DECIMAL(19, 6) ,
              [TOTAL_LINE] DECIMAL(38, 11) ,
              [TOTAL_LINEA_CON_DESCUENTO_APLICADO] DECIMAL(38, 6) ,
              [CODE_WAREHOUSE] NVARCHAR(8) ,
              [DISCOUNT] DECIMAL(24, 6) ,
              [LINE_SEQ] INT ,
              [EXTERNAL_SOURCE_ID] INT ,
              [SOURCE_NAME] VARCHAR(50) ,
              [MASTER_ID_MATERIAL] VARCHAR(50) ,
              [MATERIAL_OWNER] VARCHAR(50) ,
              [SOURCE] VARCHAR(50) ,
              [IS_MASTER_PACK] INT ,
              [DISCOUNT_TYPE] VARCHAR(50) ,
              [IS_BONUS] INT ,
              [MATERIAL_WEIGHT] DECIMAL(18, 6) ,
              [MATERIAL_VOLUME] DECIMAL(18, 4) ,
              [USE_PICKING_LINE] INT ,
              [unitMsr] VARCHAR(250) ,
              [statusOfMaterial] VARCHAR(100)
            );



	-- ------------------------------------------------------------------------------------
	-- Ciclo para obtener las ordenes de venta de todas las fuentes externas
	-- ------------------------------------------------------------------------------------
        PRINT '--> Inicia el ciclo';
	--
        WHILE EXISTS ( SELECT TOP 1
                                1
                       FROM     [#EXTERNAL_SOURCE] )
            BEGIN
		-- ------------------------------------------------------------------------------------
		-- Se toma la primera fuente extermna
		-- ------------------------------------------------------------------------------------
                SELECT TOP 1
                        @EXTERNAL_SOURCE_ID = [SO].[EXTERNAL_SOURCE_ID] ,
                        @SOURCE_NAME = [SO].[SOURCE_NAME] ,
                        @DATA_BASE_NAME = [SO].[DATA_BASE_NAME] ,
                        @SCHEMA_NAME = [SO].[SCHEMA_NAME]
			--,@DOC_NUM = CAST([SO].[SALE_ORDER_ID] AS INT)
                        ,
                        @QUERY = N''
                FROM    [#EXTERNAL_SOURCE] [SO]
                ORDER BY [SO].[EXTERNAL_SOURCE_ID];

		--
                PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
                PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME;
                PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;

                INSERT  [#PICKING_DEMAND_DETAIL]
                        SELECT  [H].[DOC_NUM] ,
                                [D].[MATERIAL_ID] ,
                                SUM([D].[QTY]) [QTY] ,
                                [H].[OWNER] ,
                                [D].[LINE_NUM] [LINE_SEQ]
                        FROM    [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D]
                                INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H] ON [D].[PICKING_DEMAND_HEADER_ID] = [H].[PICKING_DEMAND_HEADER_ID]
                                INNER JOIN [#SALES_ORDERS] [S] ON [S].[SALE_ORDER_ID] = [H].[DOC_NUM] COLLATE DATABASE_DEFAULT
                                                              AND [S].[EXTERNAL_SOURCE_ID] = [H].[EXTERNAL_SOURCE_ID]
                        WHERE   [H].[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID 
                                AND [H].[IS_FROM_ERP] = 1
                        GROUP BY [H].[OWNER] ,
                                [H].[DOC_NUM] ,
                                [D].[MATERIAL_ID] ,
                                [D].[LINE_NUM];

     
		-- ------------------------------------------------------------------------------------
		-- Obtiene el detalle de la ordenes de venta de la fuente externa
		-- ------------------------------------------------------------------------------------
                SELECT  @QUERY = N'
		DECLARE @SEQUENCE INT

		EXEC ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
                        + '.ERP_SP_INSERT_SALES_ORDER_DETAIL 
			@START_DATE = ''' + CAST(@START_DATE AS VARCHAR) + ''', 
			@END_DATE = ''' + CAST(@END_DATE AS VARCHAR) + ''', 
			@WAREHOUSE =  ''' + @ERP_WAREHOUSE 
                        + ''',
			@SEQUENCE = @SEQUENCE OUTPUT	-- int


		INSERT INTO #RESULTADO
		SELECT
			SOD.DocDate AS POSTED_DATETIME
			,SOD.DOCNUM AS SALES_ORDER_ID
			,SOD.U_Serie
			,SOD.U_NoDocto
			,SOD.CardCode AS CLIENT_ID
			,SOD.CardName AS NAME_CUSTOMER
			,SOD.SLPNAME
			,SOD.U_OPER AS CODE_SELLER
			,M.MATERIAL_ID AS SKU
			,M.MATERIAL_NAME AS DESCRIPTION_SKU
			,M.BARCODE_ID
			,M.ALTERNATE_BARCODE 
			,(SOD.Quantity* ISNULL(UMM.QTY, 1)) - ISNULL(DD.QTY, 0) QTY
			,(SOD.Quantity* ISNULL(UMM.QTY, 1)) - ISNULL(DD.QTY, 0) QTY_PENDING
			,(SOD.Quantity* ISNULL(UMM.QTY, 1)) QTY_ORIGINAL
			,SOD.PRECIO_CON_IVA AS PRICE
			,SOD.TOTAL_LINEA_SIN_DESCUENTO AS TOTAL_LINE
			,SOD.TOTAL_LINEA_CON_DESCUENTO_APLICADO
			,SOD.WhsCode AS CODE_WAREHOUSE
			,SOD.LINE_DISCOUNT AS DISCOUNT
			,SOD.NUMERO_LINEA AS LINE_SEQ
			,' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR) + ' EXTERNAL_SOURCE_ID
			,''' + @SOURCE_NAME
                        + ''' SOURCE_NAME
			,SOD.U_MasterIdSKU MASTER_ID_MATERIAL
			,SOD.U_OwnerSKU MATERIAL_OWNER
			,SOD.Owner SOURCE
			,M.IS_MASTER_PACK
			,''PERCENTAGE'' DISCOUNT_TYPE
			, 0 IS_BONUS
			,[wms].OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT(M.WEIGTH, M.WEIGHT_MEASUREMENT) MATERIAL_WEIGHT
			,M.VOLUME_FACTOR MATERIAL_VOLUME
			,M.USE_PICKING_LINE
			,SOD.unitMsr
      ,SOD.[statusOfMaterial] 
		FROM
			' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
                        + '.ERP_SALES_ORDER_DETAIL_CHANNEL_MODERN SOD WITH(NOLOCK)
		INNER JOIN [wms].OP_WMS_COMPANY OWC WITH(NOLOCK) ON (OWC.CLIENT_CODE COLLATE DATABASE_DEFAULT = SOD.U_OwnerSKU  COLLATE DATABASE_DEFAULT AND OWC.EXTERNAL_SOURCE_ID = '
                        + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
                        + ')
		INNER JOIN [wms].OP_WMS_MATERIALS M WITH(NOLOCK) ON (SOD.ItemCode COLLATE DATABASE_DEFAULT = [M].[ITEM_CODE_ERP] COLLATE DATABASE_DEFAULT AND SOD.U_OwnerSKU COLLATE DATABASE_DEFAULT= M.CLIENT_OWNER COLLATE DATABASE_DEFAULT )
		INNER JOIN #SALES_ORDERS SOTMP WITH(NOLOCK) ON (SOD.DOCNUM COLLATE DATABASE_DEFAULT = SOTMP.SALE_ORDER_ID AND SOTMP.EXTERNAL_SOURCE_ID = '
                        + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
                        + ' )
		LEFT JOIN #PICKING_DEMAND_DETAIL DD ON (SOD.DOCNUM COLLATE DATABASE_DEFAULT  = DD.DOC_NUM  COLLATE DATABASE_DEFAULT
											AND M.MATERIAL_ID COLLATE DATABASE_DEFAULT = DD.MATERIAL_ID COLLATE DATABASE_DEFAULT
											AND DD.OWNER COLLATE DATABASE_DEFAULT = SOD.Owner COLLATE DATABASE_DEFAULT
											AND SOD.NUMERO_LINEA = DD.LINE_SEQ )
		LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [M].[MATERIAL_ID] COLLATE DATABASE_DEFAULT = [UMM].[MATERIAL_ID]  COLLATE DATABASE_DEFAULT
                                                              AND [UMM].[MEASUREMENT_UNIT] = SOD.unitMsr 
		WHERE 
			CEILING((SOD.Quantity * ISNULL(UMM.QTY, 1)) - ISNULL(DD.QTY, 0)) > 0 
			AND SOD.Sequence = @SEQUENCE
			AND SOD.WhsCode = ''' + @ERP_WAREHOUSE + ''' ;

		EXEC ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
                        + '.ERP_SP_DELETE_SALES_ORDER_BY_SEQUENCE 
				@SEQUENCE = @SEQUENCE ';
		--
                PRINT '--> @QUERY: ' + @QUERY;
		--
                EXEC (@QUERY);

                DELETE  [#PICKING_DEMAND_DETAIL];
                DELETE  [#EXTERNAL_SOURCE]
                WHERE   [EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID ;
            END;

        SELECT DISTINCT
                [R].[POSTED_DATETIME] ,
                [R].[SALES_ORDER_ID] ,
                [R].[U_Serie] ,
                [R].[U_NoDocto] ,
                [R].[CLIENT_ID] ,
                [R].[NAME_CUSTOMER] ,
                [R].[SLPNAME] ,
                [R].[CODE_SELLER] ,
                [R].[SKU] ,
                [R].[DESCRIPTION_SKU] ,
                [R].[BARCODE_ID] ,
                [R].[ALTERNATE_BARCODE] ,
                [R].[QTY] [QTY] ,
                [R].[QTY_PENDING] [QTY_PENDING] ,
                [R].[QTY_ORIGINAL] [QTY_ORIGINAL] ,
                ISNULL([A].[AVAILABLE_QTY], 0) [AVAILABLE_QTY] ,
                [R].[PRICE] ,
                [R].[TOTAL_LINE] ,
                [R].[TOTAL_LINEA_CON_DESCUENTO_APLICADO] ,
                [R].[CODE_WAREHOUSE] ,
                [R].[DISCOUNT] ,
                [R].[LINE_SEQ] ,
                [R].[EXTERNAL_SOURCE_ID] ,
                [R].[SOURCE_NAME] ,
                [R].[MASTER_ID_MATERIAL] ,
                [R].[MATERIAL_OWNER] ,
                [R].[SOURCE] ,
                [R].[IS_MASTER_PACK] ,
                [R].[DISCOUNT_TYPE] ,
                [R].[IS_BONUS] ,
                [R].[MATERIAL_WEIGHT] ,
                [R].[MATERIAL_VOLUME] ,
                [R].[USE_PICKING_LINE] ,
                ISNULL([UMM].[MEASUREMENT_UNIT], 'Unidad Base') + ' 1x'
                + CAST(ISNULL([UMM].[QTY], 1) AS VARCHAR) [MEASUREMENT_UNIT] ,
                ISNULL([UMM].[MEASUREMENT_UNIT], 'Unidad Base') [unitMsr] ,
                [R].[statusOfMaterial] AS [STATUS_CODE]
        FROM    [#RESULTADO] [R]
                LEFT JOIN [wms].[OP_WMS_VIEW_INVENTORY_FOR_PICKING] [A] ON [R].[SKU] COLLATE DATABASE_DEFAULT = [A].[MATERIAL_ID] COLLATE DATABASE_DEFAULT
                                                              AND [A].[CURRENT_WAREHOUSE]COLLATE DATABASE_DEFAULT= @CODE_WAREHOUSE COLLATE DATABASE_DEFAULT
                LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [UMM].[MATERIAL_ID]COLLATE DATABASE_DEFAULT = [R].[SKU]COLLATE DATABASE_DEFAULT
                                                              AND [UMM].[MEASUREMENT_UNIT]COLLATE DATABASE_DEFAULT = [R].[unitMsr] COLLATE DATABASE_DEFAULT;
    END;