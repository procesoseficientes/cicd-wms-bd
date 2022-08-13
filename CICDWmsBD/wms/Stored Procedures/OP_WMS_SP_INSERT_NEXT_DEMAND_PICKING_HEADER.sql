-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-01-31 @ Team ERGON - Sprint ERGON II
-- Description:	        realiza insersión de todos los campos en OP_WMS_NEXT_PICKING_DEMAND_HEADER

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-02-03 Team ERGON - Sprint ERGON II
-- Description:	 Se ponen nullables los parámetros  @CODE_ROUTE y @SERIAL_NUMBER para cuando la demanda viene de ERP

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-02-17 Team ERGON - Sprint ERGON III
-- Description:	 Se agrega campo de CUSTOMER_NAME

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-03-01 Team ERGON - Sprint ERGON IV
-- Description:	 Se agrega que guarde doc_entry y doc_num por separado cuando vienen de ERP

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-17 ErgonTeam@Sheik
-- Description:	 Se agrega parametro para saber si la demanda de despacho es consolidada. 

-- Modificacion 7/12/2017 @ NEXUS-Team Sprint AgeOfEmpires
-- rodrigo.gomez
-- Se agrego el parametro @HAS_MASTERPACK y se envia al momento de insertar.

-- Modificacion 8/8/2017 @ NEXUS-Team Sprint Banjo-Kazooie
-- rodrigo.gomez
-- Se agregan las columnas SAPSERVER

-- Modificacion 8/28/2017 @ NEXUS-Team Sprint CommandAndConquer
-- rodrigo.gomez
-- Se agregan columnas SOURCE_TYPE y DEMAND_TYPE

-- Modificacion 9/20/2017 @ NEXUS-Team Sprint DuckHunt
-- rodrigo.gomez
-- Se agrega parametro @ADDRESS_CUSTOMER, @STATE_CODE

-- Modificacion 20-Nov-2017 @ Reborn-Team Sprint Nach
-- rodrigo.gomez
-- Se agrega parametro @TYPE_DEMAND_CODE, @TYPE_DEMAND_NAME

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181114 GForce@Narwhal
-- Description:			Se modifica tipo de columna DOC_ENTRY

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_INSERT_NEXT_DEMAND_PICKING_HEADER] @DOC_NUM = 0, -- int
																	@CLIENT_CODE = '', -- varchar(50)
																	@CODE_ROUTE = '', -- varchar(50)
																	@CODE_SELLER = '', -- varchar(50)
																	@TOTAL_AMOUNT = NULL, -- decimal
																	@SERIAL_NUMBER = '', -- varchar(100)
																	@DOC_NUM_SEQUENCE = 0, -- int
																	@EXTERNAL_SOURCE_ID = 1, -- int
																	@IS_FROM_ERP = 0, -- int
																	@IS_FROM_SONDA = 0, -- int
																	@LAST_UPDATE_BY = '', -- varchar(50)
																	@WAVE_PICKING_ID = 0, -- int
																	@CODE_WAREHOUSE = 'BODEGA_01', -- varchar(25)
																	@IS_COMPLETED = 0, -- int
																	@CUSTOMER_NAME = '', -- varchar(100)
																	@DOC_ENTRY = 0, -- int
																	@IS_CONSOLIDATED = 0, -- int
																	@PRIORITY = 0, -- int
																	@HAS_MASTERPACK = 0,
																	@OWNER = 'wms',
																	@CLIENT_OWNER = 'wms',
																	@SELLER_OWNER = 'wms',
																	@MASTER_ID_SELLER = 'wms',
																	@SOURCE_TYPE = 'SO - ERP',
																	@DEMAND_TYPE = 'SALES_ORDER',
																	@ADDRESS_CUSTOMER = 'Guatemala',
																	@STATE_CODE = 100


  SELECT * FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
*/

-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_NEXT_DEMAND_PICKING_HEADER] (
		@DOC_NUM NUMERIC(18,0)
		,@CLIENT_CODE VARCHAR(50)
		,@CODE_ROUTE VARCHAR(50) = NULL
		,@CODE_SELLER VARCHAR(50) = ''
		,@TOTAL_AMOUNT DECIMAL(18, 6)
		,@SERIAL_NUMBER VARCHAR(100) = NULL
		,@DOC_NUM_SEQUENCE NUMERIC(18,0)
		,@EXTERNAL_SOURCE_ID INT
		,@IS_FROM_ERP INT
		,@IS_FROM_SONDA INT
		,@LAST_UPDATE_BY VARCHAR(50)
		,@WAVE_PICKING_ID INT
		,@CODE_WAREHOUSE VARCHAR(25)
		,@IS_COMPLETED INT
		,@CUSTOMER_NAME VARCHAR(100)
		,@DOC_ENTRY NUMERIC(18,0)
		,@IS_CONSOLIDATED INT = 0
		,@PRIORITY INT = NULL
		,@HAS_MASTERPACK INT = 0
		,@OWNER VARCHAR(50) = NULL
		,@CLIENT_OWNER VARCHAR(50) = NULL
		,@SELLER_OWNER VARCHAR(50) = NULL
		,@MASTER_ID_SELLER VARCHAR(50) = NULL
		,@SOURCE_TYPE VARCHAR(50)
		,@DEMAND_TYPE VARCHAR(50)
		, -- WAREHOUSE_TRANSFER / SALES_ORDER
		@WAREHOUSE_FROM VARCHAR(50) = NULL
		,@WAREHOUSE_TO VARCHAR(50) = NULL
		,@DELIVERY_DATE DATETIME = NULL
		,@ADDRESS_CUSTOMER VARCHAR(150) = NULL
		,@STATE_CODE INT = NULL
		,@DISCOUNT DECIMAL(18, 6) = NULL
		,@TYPE_DEMAND_CODE INT = NULL
		,@TYPE_DEMAND_NAME VARCHAR(50) = NULL
	)
AS
SET NOCOUNT ON;
  --
BEGIN TRY
	DECLARE	@DOC_ID INT;
    --
	IF @SOURCE_TYPE = 'WT - ERP'
	BEGIN
		INSERT	INTO [wms].[OP_WMS_TRANSFER_REQUEST_HEADER]
				(
					[REQUEST_TYPE]
					,[WAREHOUSE_FROM]
					,[WAREHOUSE_TO]
					,[DELIVERY_DATE]
					,[STATUS]
					,[CREATED_BY]
					,[LAST_UPDATE]
					,[LAST_UPDATE_BY]
					,[OWNER]
					,[DOC_NUM]
					,[DOC_ENTRY]
					,[IS_FROM_ERP]
					,[COMMENT]
				)
		VALUES
				(
					'TRASLADO_ERP'  -- REQUEST_TYPE - varchar(50)
					,@WAREHOUSE_FROM  -- WAREHOUSE_FROM - varchar(25)
					,@WAREHOUSE_TO  -- WAREHOUSE_TO - varchar(25)
					,@DELIVERY_DATE  -- DELIVERY_DATE - datetime
					,'OPEN'  -- STATUS - varchar(25)
					,@LAST_UPDATE_BY  -- CREATED_BY - varchar(25)
					,GETDATE()  -- LAST_UPDATE - datetime
					,@LAST_UPDATE_BY  -- LAST_UPDATE_BY - varchar(25)
					,@OWNER  -- OWNER - varchar(50)
					,@DOC_NUM
					,@DOC_ENTRY
					,1
					,'Solicitud de traslado desde ERP, DocNum: '
					+ CAST(@DOC_NUM AS VARCHAR)
				);
		SET @DOC_ID = SCOPE_IDENTITY();
	END;
    --
	IF @SOURCE_TYPE = 'WT - SWIFT'
	BEGIN
		SELECT
			@DOC_ID = @DOC_NUM;
	END;
    --
	INSERT	INTO [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
			(
				[DOC_NUM]
				,[CLIENT_CODE]
				,[CODE_ROUTE]
				,[CODE_SELLER]
				,[TOTAL_AMOUNT]
				,[SERIAL_NUMBER]
				,[DOC_NUM_SEQUENCE]
				,[EXTERNAL_SOURCE_ID]
				,[IS_FROM_ERP]
				,[IS_FROM_SONDA]
				,[LAST_UPDATE]
				,[LAST_UPDATE_BY]
				,[IS_COMPLETED]
				,[WAVE_PICKING_ID]
				,[CODE_WAREHOUSE]
				,[CLIENT_NAME]
				,[CREATED_DATE]
				,[DOC_ENTRY]
				,[IS_CONSOLIDATED]
				,[PRIORITY]
				,[HAS_MASTERPACK]
				,[OWNER]
				,[CLIENT_OWNER]
				,[SELLER_OWNER]
				,[MASTER_ID_SELLER]
				,[SOURCE_TYPE]
				,[DEMAND_TYPE]
				,[TRANSFER_REQUEST_ID]
				,[ADDRESS_CUSTOMER]
				,[STATE_CODE]
				,[DISCOUNT]
				,[TYPE_DEMAND_CODE]
				,[TYPE_DEMAND_NAME]
			)
	VALUES
			(
				@DOC_NUM
				,@CLIENT_CODE
				,@CODE_ROUTE
				,@CODE_SELLER
				,@TOTAL_AMOUNT
				,@SERIAL_NUMBER
				,@DOC_NUM_SEQUENCE
				,@EXTERNAL_SOURCE_ID
				,@IS_FROM_ERP
				,@IS_FROM_SONDA
				,GETDATE()
				,@LAST_UPDATE_BY
				,@IS_COMPLETED
				,@WAVE_PICKING_ID
				,@CODE_WAREHOUSE
				,@CUSTOMER_NAME
				,GETDATE()
				,@DOC_ENTRY
				,@IS_CONSOLIDATED
				,@PRIORITY
				,@HAS_MASTERPACK
				,@OWNER
				,@CLIENT_OWNER
				,@SELLER_OWNER
				,@MASTER_ID_SELLER
				,@SOURCE_TYPE
				,@DEMAND_TYPE
				,@DOC_ID
				,@ADDRESS_CUSTOMER
				,@STATE_CODE
				,@DISCOUNT
				,@TYPE_DEMAND_CODE
				,@TYPE_DEMAND_NAME
			);
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  
	IF @SOURCE_TYPE = 'WT - ERP'
		OR @SOURCE_TYPE = 'WT - SWIFT'
	BEGIN
		UPDATE
			[wms].[OP_WMS_TASK_LIST]
		SET	
			[TRANSFER_REQUEST_ID] = @DOC_ID
		WHERE
			[WAVE_PICKING_ID] = @WAVE_PICKING_ID;
	END;

	SET @DOC_ID = SCOPE_IDENTITY();

	SELECT
		1 AS [Resultado]
		,'Proceso Exitoso' [Mensaje]
		,0 [Codigo]
		,CAST(@DOC_ID AS VARCHAR) [DbData];


END TRY
BEGIN CATCH
	SELECT
		-1 AS [Resultado]
		,ERROR_MESSAGE() [Mensaje]
		,@@ERROR [Codigo];
END CATCH;