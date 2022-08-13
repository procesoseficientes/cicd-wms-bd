-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-02-01 @ Team ERGON - Sprint ERGON 
-- Description:	        

-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-05-022 @ Team ERGON - Sprint Sheik
-- Description:	        Se volvieron null SalesPersonCode y TrnspCode ya que nos daba problemas y no son necesarios

-- Modificacion 14-Jul-17 @ Nexus Team Sprint AgeOfEmperies
-- alberto.ruiz
-- Se agrega la consulta para el @HAS_MASTERPACK_IMPLODED y se agrega a los select

-- Modificacion 8/23/2017 @ NEXUS-Team Sprint CommandAndConquer
-- rodrigo.gomez
-- Se agrega parametro IS_INVOICE

-- Modificacion 9/29/2017 @ NEXUS-Team Sprint DuckHunt
-- rodrigo.gomez
-- Se agrega campo PAYMENT_CONDITION

-- Modificacion 10/16/2017 @ NEXUS-Team Sprint ewms
-- rodrigo.gomez
-- Se agrega parametro @POSTED_STATUS a la ejecucion del SP SWIFT_SP_GET_ERP_DOCUMENT_FOR_DELIVERY_NOTE_BY_DOC_NUM

-- Modificacion 11/3/2017 @ NEXUS-Team Sprint F-Zero
-- rodrigo.gomez
-- Se agrega columna de descuento

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_GET_PICKING_DOCUMENT] @PICKING_DEMAND_HEADER_ID = 5228, @IS_INVOICE = 0, @OWNER = 'motorganica'
			--
			EXEC  [wms].[OP_WMS_GET_PICKING_DOCUMENT] @PICKING_DEMAND_HEADER_ID = 5228, @IS_INVOICE = 1, @OWNER = 'motorganica'
			--
			EXEC  [wms].[OP_WMS_GET_PICKING_DOCUMENT] @PICKING_DEMAND_HEADER_ID = 5230, @IS_INVOICE = 0, @OWNER = 'motorganica'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_PICKING_DOCUMENT]
    (
     @PICKING_DEMAND_HEADER_ID INT
    ,@IS_INVOICE INT = 0
    ,@OWNER VARCHAR(50)
    )
AS
BEGIN
    SET NOCOUNT ON;
  --
    DECLARE
        @DOC_NUM VARCHAR(50) = '-1'
       ,@INTERFACE_DATA_BASE_NAME VARCHAR(50)
       ,@SCHEMA_NAME VARCHAR(50)
       ,@IS_FROM_ERP INT = -1
       ,@SQL NVARCHAR(MAX)
       ,@DATA_BASE_NAME VARCHAR(50)
       ,@EXTERNAL_SOURCE_ID INT
       ,@SOURCE_NAME VARCHAR(50)
       ,@HAS_MASTERPACK_IMPLODED INT = 0
       ,@ERP_DATABASE VARCHAR(50)
       ,@POSTED_STATUS INT = 0;


  --------------------------------------------------------------------------------------------
  --Se obtiene el numero del documento su base de datos interfaz y su esquema 
  --------------------------------------------------------------------------------------------
    SELECT TOP 1
        @DOC_NUM = [PH].[DOC_NUM]
       ,@INTERFACE_DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
       ,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
       ,@IS_FROM_ERP = [PH].[IS_FROM_ERP]
       ,@EXTERNAL_SOURCE_ID = [ES].[EXTERNAL_SOURCE_ID]
       ,@SOURCE_NAME = [ES].[SOURCE_NAME]
       ,@DATA_BASE_NAME = [ES].[DATA_BASE_NAME]
       ,@ERP_DATABASE = [C].[ERP_DATABASE]
       ,@POSTED_STATUS = [PH].[POSTED_STATUS]
    FROM
        [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PH]
    INNER JOIN [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES] ON ([PH].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID])
    INNER JOIN [wms].[OP_WMS_COMPANY] [C] ON (
                                              [C].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID]
                                              AND [C].[CLIENT_CODE] = @OWNER
                                             )
    WHERE
        [PH].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;

  -- ------------------------------------------------------------------------------------
  -- Obtiene si tiene master pack explotado
  -- ------------------------------------------------------------------------------------
    SELECT TOP 1
        @HAS_MASTERPACK_IMPLODED = 1
    FROM
        [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D]
    WHERE
        [D].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
        AND [D].[WAS_IMPLODED] = 1
        AND [D].[QTY_IMPLODED] > 0;
  --------------------------------------------------------------------------------------------
  --Se valida si viene de ERP o de sonda y se procede a obtener datos 
  --------------------------------------------------------------------------------------------
    IF @IS_FROM_ERP = 1
    BEGIN
    --IF @IS_INVOICE = 0
    --BEGIN
        SELECT
            @SQL = N'EXEC ' + @INTERFACE_DATA_BASE_NAME + '.' + @SCHEMA_NAME
            + '.[SWIFT_SP_GET_ERP_DOCUMENT_FOR_DELIVERY_NOTE_BY_DOC_NUM]
					@DATABASE = ' + @ERP_DATABASE + '
					,@DOC_NUM = ' + CAST(@DOC_NUM AS VARCHAR) + '
					,@PICKING_DEMAND_HEADER_ID = '
            + CAST(@PICKING_DEMAND_HEADER_ID AS VARCHAR) + '
					,@HAS_MASTERPACK_IMPLODED = '
            + CAST(@HAS_MASTERPACK_IMPLODED AS VARCHAR) + '
					,@POSTED_STATUS = ' + CAST(@POSTED_STATUS AS VARCHAR) + '';
      --
        PRINT @SQL;
      --
        EXEC [sp_executesql] @SQL;
    --END
    --ELSE
    --BEGIN
    --  SELECT
    --    [PICKING_DEMAND_HEADER_ID]
    --   ,[PICKING_DEMAND_HEADER_ID] [DocNum]
    --  FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
    --  WHERE [PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
    --END
    END;
    ELSE
    BEGIN
    -- ------------------------------------------------------------------------------------
    -- Obtiene las ordenes de venta de la fuente externa
    -- ------------------------------------------------------------------------------------
        SELECT
            @SQL = N'SELECT 
				[PH].[PICKING_DEMAND_HEADER_ID] AS DocNum
				,[SOH].[SALES_ORDER_ID] AS DocEntry
				,[SOH].[POSTED_DATETIME] AS DocDate
				,[CI].[CARD_CODE]	AS CardCode
				,[CI].[CARD_NAME] AS CardName
				,''N'' AS HandWritten
				,CAST(NULL AS VARCHAR)	AS Comments
				,[SC].[CODE_CURRENCY] AS DocCur
				,ISNULL(NULL, 0) AS DocRate
				,NULL AS SalesPersonCode 
				,CAST(NULL AS VARCHAR) ASTrnspCode 
				,CAST(NULL AS VARCHAR) ASShipToAddressType
				,CAST(NULL AS VARCHAR) ASShipToStreet
				,CAST(NULL AS VARCHAR) ASShipToState
				,CAST(NULL AS VARCHAR) ASShipToCountry
				,AC.[ADRESS_CUSTOMER] AS Address
				,CAST(NULL AS VARCHAR) AS Address2
				,ISNULL(NULL, 0) AS DiscPrcnt
				,CAST(NULL AS VARCHAR) AS UFacSerie
				,CAST(NULL AS VARCHAR) AS UFacNit
				,CAST(NULL AS VARCHAR) AS UFacNom
				,CAST(NULL AS VARCHAR) AS UFacFecha
				,CAST(NULL AS VARCHAR) AS UTienda
				,CAST(NULL AS VARCHAR) AS UStatusNc
				,CAST(NULL AS VARCHAR) AS UnoExencion
				,CAST(NULL AS VARCHAR) AS UtipoDocumento
				,CAST(NULL AS VARCHAR) AS UUsuario
				,CAST(NULL AS VARCHAR) AS UFacnum
				,CAST(NULL AS VARCHAR) AS USucursal
				,CAST(NULL AS VARCHAR) AS U_Total_Flete
				,CAST(NULL AS VARCHAR) AS UTipoPago
				,CAST(NULL AS VARCHAR) AS UCuotas
				,CAST(NULL AS VARCHAR) AS UTotalTarjeta
				,CAST(NULL AS VARCHAR) AS UFechap
				,CAST(NULL AS VARCHAR) AS UTrasladoOC
  					,[SOH].[TOTAL_AMOUNT]
						,[SOH].[POS_TERMINAL] [CODE_ROUTE]
						,[SOH].[POSTED_BY] [LOGIN]
						,[SOH].[DOC_SERIE]
						,[SOH].[DOC_NUM] AS DOC_NUM_SERIE			
						,' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
            + ' [EXTERNAL_SOURCE_ID]
						,''' + @SOURCE_NAME + ''' [SOURCE_NAME]
				,''0'' AS Classification
				,' + CAST(@HAS_MASTERPACK_IMPLODED AS VARCHAR)
            + ' AS HAS_MASTERPACK
				,[PH].[IS_POSTED_ERP]
				,[PH].[POSTED_STATUS]
				,CASE WHEN [SOH].[SALES_ORDER_TYPE] = ''CASH''
				THEN 1
				ELSE 2
				END [PAYMENT_CONDITION]
				,[SOH].[DISCOUNT_BY_GENERAL_AMOUNT] DISCOUNT
			FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
            + '.[SONDA_SALES_ORDER_HEADER] [SOH]		
			LEFT JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
            + '.[SWIFT_VIEW_ALL_COSTUMER] [AC] ON [SOH].[CLIENT_ID] = AC.[CODE_CUSTOMER]
			LEFT JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
            + '.[SWIFT_CURRENCY] [SC]  ON ([SC].[IS_DEFAULT] = 1)
			LEFT JOIN [wms].[OP_WMS_CUSTOMER_INTERCOMPANY] [CI] ON ([SOH].[CLIENT_ID] = [CI].[MASTER_ID] AND [CI].[SOURCE] = '''
            + @OWNER
            + ''')
			INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PH] ON ([PH].DOC_NUM = [SOH].[SALES_ORDER_ID])
			WHERE [SOH].[IS_VOID] = 0
				AND [SOH].[IS_DRAFT] = 0
				AND ISNULL([SOH].[HAVE_PICKING],0) = 0
				AND [PH].[PICKING_DEMAND_HEADER_ID] = '
            + CAST(@PICKING_DEMAND_HEADER_ID AS VARCHAR) + '
        ';
    --
        PRINT '--> @QUERY: ' + @SQL;
    --
        EXEC (@SQL);
    END;
END;