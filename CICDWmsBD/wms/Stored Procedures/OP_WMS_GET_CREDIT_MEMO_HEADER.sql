-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	10/11/2017 @ NEXUS-Team Sprint  
-- Description:			Devuelve el encabezado de una nota de credito para enviar a ERP

-- Modificacion 1/29/2018 @ REBORN-Team Sprint Trotzdem
					-- rodrigo.gomez
					-- Se agregan campos extra para las devoluciones y notas de credito

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_GET_CREDIT_MEMO_HEADER]
					@RECEPTION_HEADER_ID = 4109
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_CREDIT_MEMO_HEADER]
    (
      @RECEPTION_HEADER_ID INT
    )
AS
BEGIN
    SET NOCOUNT ON;
	--
	DECLARE @ERP_WAREHOUSE_CODE VARCHAR(50)
		,@SERIE DECIMAL(18,0)
		,@DOC_NUM INT
		,@OWNER VARCHAR(50)
		,@EXTERNAL_SOURCE_ID INT
		,@SCHEMA_NAME VARCHAR(50)
		,@INTERFACE_DATA_BASE_NAME VARCHAR(50)
		,@ERP_DATA_BASE_NAME VARCHAR(50)
		,@QUERY NVARCHAR(MAX)
		,@USE_SUBSIDIARY INT = 0;
	--
    CREATE TABLE [#INVOICE]
        (
         [DOC_ENTRY] INT
        ,[DOC_NUM] INT
        ,[CLIENT_CODE] NVARCHAR(15)
        ,[CLIENT_NAME] NVARCHAR(100)
        ,[COMMENTS] NVARCHAR(254)
        ,[DOC_DATE] DATETIME
        ,[DELIVERY_DATE] DATETIME
        ,[STATUS] CHAR(1)
        ,[CODE_SELLER] INT
        ,[TOTAL_AMOUNT] DECIMAL(19, 6)
        ,[LINE_NUM] INT
        ,[MATERIAL_ID] NVARCHAR(20)
        ,[MATERIAL_NAME] NVARCHAR(100)
        ,[QTY] DECIMAL(19, 6)
        ,[OPEN_QTY] DECIMAL(19, 6)
        ,[PRICE] DECIMAL(19, 6)
        ,[DISCOUNT_PERCENT] DECIMAL(19, 6)
        ,[TOTAL_LINE] DECIMAL(19, 6)
        ,[WAREHOUSE_CODE] NVARCHAR(8)
        ,[MATERIAL_OWNER] NVARCHAR(30)
        ,[ADDRESS] NVARCHAR(254)
        ,[DOC_CURRENCY] NVARCHAR(3)
        ,[DOC_RATE] DECIMAL(19, 6)
        ,[SUBSIDIARY] VARCHAR(30)
        ,[DET_CURRENCY] NVARCHAR(3)
        ,[DET_RATE] DECIMAL(19, 6)
        ,[DET_TAX_CODE] NVARCHAR(8)
        ,[DET_VAT_PERCENT] DECIMAL(19, 6)
		,[COST_CENTER] VARCHAR(25)
		,[UNIT] VARCHAR(25)
        );
	-- ------------------------------------------------------------------------------------
	-- Verifica si utiliza sucursal
	-- ------------------------------------------------------------------------------------
	SELECT TOP 1
		@USE_SUBSIDIARY = [VALUE] 
	FROM [wms].[OP_WMS_PARAMETER]
	WHERE [GROUP_ID] = 'ERP_RECEPTION'
		AND [PARAMETER_ID] = 'USE_SUBSIDIARY'
	-- ------------------------------------------------------------------------------------
	-- Obtiene las variables de la factura para buscarla
	-- ------------------------------------------------------------------------------------
	SELECT @ERP_WAREHOUSE_CODE = [ERP_WAREHOUSE_CODE]
			,@DOC_NUM = CAST([DOC_NUM] as int) 
			,@OWNER = [OWNER]
			,@EXTERNAL_SOURCE_ID = [EXTERNAL_SOURCE_ID]
	FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] 
	WHERE [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER_ID

	SELECT @SERIE = [NUMERIC_VALUE]
	FROM [wms].[OP_WMS_CONFIGURATIONS]
	WHERE [PARAM_TYPE] = 'SISTEMA'
		AND [PARAM_GROUP] = 'SERIE_DEVOLUCION_BODEGA'
		AND [PARAM_NAME] = @ERP_WAREHOUSE_CODE
	------------------------------------------------------------------------------------
	-- Obtiene la fuente externa
	-- ------------------------------------------------------------------------------------
    SELECT TOP 1
		 @SCHEMA_NAME = [ES].[SCHEMA_NAME]
        , @INTERFACE_DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
        , @ERP_DATA_BASE_NAME = [C].[ERP_DATABASE]
    FROM
        [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
    INNER JOIN [wms].[OP_WMS_COMPANY] [C] ON ( [C].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID] )
    WHERE
        [ES].[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID
        AND [C].[CLIENT_CODE] = @OWNER
        AND [C].[COMPANY_ID] > 0;
	--
    PRINT '----> @INTERFACE_DATA_BASE_NAME: ' + @INTERFACE_DATA_BASE_NAME;
    PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;
    PRINT '----> @ERP_DATA_BASE_NAME: ' + @ERP_DATA_BASE_NAME;
	--
	SELECT
		@QUERY = '
			INSERT INTO #INVOICE
			EXEC ' + @INTERFACE_DATA_BASE_NAME + '.' + @SCHEMA_NAME  + '.[SWIFT_SP_GET_ERP_INVOICE_BY_DOC_NUM_FOR_RETURN_IN_WMS]
					@DATABASE = ''' + CAST(@ERP_DATA_BASE_NAME AS VARCHAR) + '''
					,@DOC_NUM = ' + CAST(@DOC_NUM AS VARCHAR) + '
					,@USE_SUBSIDIARY = ' + CAST(@USE_SUBSIDIARY AS VARCHAR) + '
		';
    PRINT '@QUERY -> ' + @QUERY;
	--
    EXEC (@QUERY);

	-- ------------------------------------------------------------------------------------
	-- Envia el resultado final
	-- ------------------------------------------------------------------------------------
    SELECT DISTINCT
        [ERP_RECEPTION_DOCUMENT_HEADER_ID]
        , [I].[DOC_ENTRY] [DOC_ENTRY]
        , [I].[DOC_NUM] [DOC_NUM]
        , [SOURCE]
        , [CODE_SUPPLIER] [CLIENT_CODE]
        , [NAME_SUPPLIER] [CLIENT_NAME]
		, @SERIE [SERIE]
		, 'I' [DOC_TYPE]
		, [I].[ADDRESS]
		, 'Basado en Factura: ' + CAST([I].[DOC_NUM] AS VARCHAR) [COMMENTS]
		, [I].[CODE_SELLER] [SLP_CODE]
		, 'I' [DATA_SOURCE]
		, [I].[DOC_CURRENCY] [CURRENCY]
		, [I].[DOC_RATE]
		, [I].[SUBSIDIARY]
    FROM
        [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] RDH
	INNER JOIN [#INVOICE] I ON [I].[DOC_NUM] = [RDH].[DOC_NUM]
    WHERE
        [ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER_ID;
END;