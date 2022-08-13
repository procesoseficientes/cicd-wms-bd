-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	17-Aug-17 @ Nexus Team Sprint Banjo-Kazooie 
-- Description:			SP que obtiene las solicitudes de transferencia

-- Autor:				henry.rodriguez
-- Fecha:				03-Septiembre-2019 G-Force@FlorencioVarela
-- Descripcion:			Se modifica tipo de datos de [SALES_ORDER_ID], [DOC_NUM]

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_TRANSFER_REQUEST_HEADER_BY_DATE]
					@WAREHOUSE_ID = 'BODEGA_01' 
					,@START_DATETIME = '2017-08-01 00:00:00.000'
					,@END_DATETIME = '2017-12-18 00:00:00.000'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TRANSFER_REQUEST_HEADER_BY_DATE] (
		@WAREHOUSE_ID VARCHAR(25)
		,@START_DATETIME DATETIME
		,@END_DATETIME DATETIME
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	DECLARE
		@STATUS VARCHAR(25) = 'OPEN'
		,@CLIENT_CODE VARCHAR(25)
		,@CLIENT_NAME VARCHAR(150);
  --
	SELECT TOP 1
		@CLIENT_CODE = [CLIENT_CODE]
		,@CLIENT_NAME = [COMPANY_NAME]
	FROM
		[wms].[OP_WMS_COMPANY];
  --
	CREATE TABLE [#PICKING_DOCUMENT] (
		[SALES_ORDER_ID] VARCHAR(50) NOT NULL
		,[POSTED_DATETIME] [DATETIME] NULL
		,[CLIENT_ID] [VARCHAR](50) NULL
		,[CUSTOMER_NAME] VARCHAR(100)
		,[TOTAL_AMOUNT] [MONEY] NULL
		,[CODE_ROUTE] [VARCHAR](25) NULL
		,[login] [VARCHAR](25) NULL
		,[DOC_SERIE] [VARCHAR](100) NULL
		,[DOC_NUM] VARCHAR(50) NULL
		,[COMMENT] [VARCHAR](250) NULL
		,[EXTERNAL_SOURCE_ID] INT NULL
		,[SOURCE_NAME] VARCHAR(50) NULL
		,[SELLER_OWNER] VARCHAR(50)
		,[MASTER_ID_SELLER] VARCHAR(50)
		,[CODE_SELLER] VARCHAR(50)
		,[CLIENT_OWNER] VARCHAR(50)
		,[MASTER_ID_CLIENT] VARCHAR(50)
		,[OWNER] VARCHAR(50)
		,[DELIVERY_DATE] DATE
		,[FROM_WAREHOUSE_ID] VARCHAR(25)
		,[TO_WAREHOUSE_ID] VARCHAR(25)
		,[IS_FROM_SONDA] INT
		,[IS_FROM_ERP] INT
		,PRIMARY KEY ([SALES_ORDER_ID])
	);
  --
	BEGIN TRY
    -- ------------------------------------------------------------------------------------
    -- Obtiene las solicitudes
    -- ------------------------------------------------------------------------------------
		INSERT	INTO [#PICKING_DOCUMENT]
				(
					[SALES_ORDER_ID]
					,[POSTED_DATETIME]
					,[CLIENT_ID]
					,[CUSTOMER_NAME]
					,[TOTAL_AMOUNT]
					,[CODE_ROUTE]
					,[login]
					,[DOC_SERIE]
					,[DOC_NUM]
					,[COMMENT]
					,[EXTERNAL_SOURCE_ID]
					,[SOURCE_NAME]
					,[SELLER_OWNER]
					,[MASTER_ID_SELLER]
					,[CODE_SELLER]
					,[CLIENT_OWNER]
					,[MASTER_ID_CLIENT]
					,[OWNER]
					,[DELIVERY_DATE]
					,[FROM_WAREHOUSE_ID]
					,[TO_WAREHOUSE_ID]
					,[IS_FROM_SONDA]
					,[IS_FROM_ERP]
					
				)
		SELECT
			[TH].[TRANSFER_REQUEST_ID]
			,[TH].[REQUEST_DATE]
			,@CLIENT_CODE
			,@CLIENT_NAME
			,0
			,NULL
			,[TH].[CREATED_BY]
			,NULL
			,[TH].[TRANSFER_REQUEST_ID]
			,[TH].[COMMENT]
			,0
			,@CLIENT_CODE
			,NULL
			,NULL
			,NULL
			,@CLIENT_CODE
			,@CLIENT_CODE
			,@CLIENT_CODE
			,[TH].[DELIVERY_DATE]
			,[TH].[WAREHOUSE_FROM]
			,[TH].[WAREHOUSE_TO]
			,0
			,[TH].[IS_FROM_ERP]
		FROM
			[wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [TH]
		WHERE
			[TH].[TRANSFER_REQUEST_ID] > 0
			AND [TH].[STATUS] = @STATUS
			AND [TH].[REQUEST_DATE] BETWEEN @START_DATETIME
									AND		@END_DATETIME
			AND [TH].[WAREHOUSE_FROM] = @WAREHOUSE_ID
			--AND [TH].[IS_FROM_ERP] = 0;

    -- ------------------------------------------------------------------------------------
    -- Se crean indice a [#PICKING_DOCUMENT]
    -- ------------------------------------------------------------------------------------
		CREATE INDEX [IN_TEMP_PICKING_DOCUMENT]
		ON [#PICKING_DOCUMENT]
		([SALES_ORDER_ID], [EXTERNAL_SOURCE_ID]) INCLUDE (
		[DOC_NUM]
		, [POSTED_DATETIME]
		, [CLIENT_ID]
		, [CUSTOMER_NAME]
		, [TOTAL_AMOUNT]
		, [CODE_ROUTE]
		, [login]
		, [DOC_SERIE]
		, [COMMENT]
		, [SOURCE_NAME]
		, [IS_FROM_SONDA]
		, [SELLER_OWNER]
		, [MASTER_ID_SELLER]
		, [CODE_SELLER]
		, [CLIENT_OWNER]
		, [MASTER_ID_CLIENT]
		, [DELIVERY_DATE]
		, [OWNER]
		, [FROM_WAREHOUSE_ID]
		, [TO_WAREHOUSE_ID]
		);

    -- ------------------------------------------------------------------------------------
    -- Muestra el resultado
    -- ------------------------------------------------------------------------------------
		SELECT DISTINCT
			[PD].[SALES_ORDER_ID]
			,[PD].[POSTED_DATETIME]
			,[PD].[CLIENT_ID]
			,[PD].[CUSTOMER_NAME]
			,[PD].[TOTAL_AMOUNT]
			,[PD].[CODE_ROUTE]
			,[PD].[login]
			,[PD].[DOC_SERIE]
			,[PD].[DOC_NUM]
			,[PD].[DOC_NUM] [DOC_ENTRY]
			,[PD].[COMMENT]
			,[PD].[EXTERNAL_SOURCE_ID]
			,[PD].[SOURCE_NAME]
			,[PD].[IS_FROM_SONDA]
			,[PD].[IS_FROM_ERP]
			,[PD].[SELLER_OWNER]
			,[PD].[MASTER_ID_SELLER]
			,[PD].[CODE_SELLER]
			,[PD].[CLIENT_OWNER]
			,[PD].[MASTER_ID_CLIENT]
			,[PD].[OWNER]
			,[PD].[DELIVERY_DATE]
			,'WT - SWIFT' [SOURCE]
			,[PD].[FROM_WAREHOUSE_ID]
			,[PD].[TO_WAREHOUSE_ID]
			,[PD].[TO_WAREHOUSE_ID] [ADDRESS_CUSTOMER]
		FROM
			[#PICKING_DOCUMENT] [PD]
		LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [P] ON (
											[PD].[SALES_ORDER_ID] = [P].[DOC_NUM]  COLLATE DATABASE_DEFAULT
											AND [PD].[EXTERNAL_SOURCE_ID] = [P].[EXTERNAL_SOURCE_ID]
											)
		WHERE
			[PD].[SALES_ORDER_ID] > 0
			AND (P.IS_COMPLETED IS NULL OR P.IS_COMPLETED = 1)
		GROUP BY
			[PD].[DOC_NUM]
			,[PD].[SALES_ORDER_ID]
			,[PD].[POSTED_DATETIME]
			,[PD].[CLIENT_ID]
			,[PD].[CUSTOMER_NAME]
			,[PD].[TOTAL_AMOUNT]
			,[PD].[CODE_ROUTE]
			,[PD].[login]
			,[PD].[DOC_SERIE]
			,[PD].[COMMENT]
			,[PD].[EXTERNAL_SOURCE_ID]
			,[PD].[SOURCE_NAME]
			,[PD].[IS_FROM_SONDA]
			,[PD].[IS_FROM_ERP]
			,[PD].[SELLER_OWNER]
			,[PD].[MASTER_ID_SELLER]
			,[PD].[CODE_SELLER]
			,[PD].[CLIENT_OWNER]
			,[PD].[MASTER_ID_CLIENT]
			,[PD].[DELIVERY_DATE]
			,[PD].[OWNER]
			,[PD].[FROM_WAREHOUSE_ID]
			,[PD].[TO_WAREHOUSE_ID]
		HAVING
			ISNULL(MAX([P].[IS_COMPLETED]), 0) = 0;
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;

	PRINT 'HOLA MUNDO'
END;