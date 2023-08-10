-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		21-Nov-17 @ Nexus Team Sprint GTA
-- Description:			    SP que crea los documentos necesarios para atender una demanda

-- Autor:					rudi.garcia
-- Fecha de Creacion: 		11-Dic-2017 @ Reborn Team Sprint Nach
-- Description:			    Se agrego los campos tipos despacho

-- Modificacion 1/8/2018 @ Reborn-Team Sprint Ramsey
-- diego.as
-- Se agrega insercion de columna @IS_FOR_DELIVERY_IMMEDIATE

-- Modificacion 1/8/2018 @ Reborn-Team Sprint Ramsey
-- diego.as
-- Se agrega insert de columna DEMAND_DELIVERY_DATE que alberga la fecha de entrega de la demanda de despacho

-- Modificacion 10-Jan-18 @ Nexus Team Sprint Ramsey
-- alberto.ruiz
-- Se corrige validacion para tomar el transfer request id

-- Modificacion 26-Ene-18 @ Reborn Team Sprint @Trotzdem
-- marvin.solares
-- se envia el parametro prioridad en la ejecucion de los sps: OP_WMS_SP_INSERT_TASKS_GENERAL
-- OP_WMS_SP_INSERT_TASKS_GENERAL_PICKING_DEMAND

-- Modificacion 09-Apr-18 @ Nexus Team Sprint Buho 
-- pablo.aguilar
-- se agrega el manejo de proyecto. 

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181114 GForce@Narwhal
-- Description:			Se modifica tipo de columna DOC_ENTRY

-- Autor:				rudi.garcia
-- Fecha de Creacion: 	26-Jul-2019 @ G-Force-Team Sprint Dublin
-- Description:			se agrega manejo de proyecto

-- Autor:				marvin.solares
-- Fecha de Creacion: 	21-Ago-2019 @ G-Force-Team Sprint FlorencioVarela
-- Description:			envío el valor de días mínimo de fecha de expiración al proceso de generacion de tareas

-- Modificación:		Elder Lucas
-- Fecha Modificación: 	30 de octubre 2022
-- Description:			Implementación SP de creación de tareas de picking por canal [wms].[OP_WMS_SP_INSERT_TASKS_GENERAL_PICKING_DEMAND_PER_CHANNEL]

-- Modificación:		Elder Lucas
-- Fecha Modificación: 	8 de noviembre
-- Description:			Envio de ordenes consolidadas en una sola petición al SP de picking por canal

-- Modificación:		Elder Lucas
-- Fecha Modificación:  9 de marzo 2023
-- Description:			Se retiraron validaciones que no se utilizan para el actual algoritmo de picking por canal, se corrige el conteo de material por documento para funcionar con
--						documentos que tienen lineas repetidas de material pero con diferente cantidad

/*
-- Ejemplo de Ejecucion:
        EXEC [wms].[OP_WMS_SP_CREATE_DEMAND]
			@LOGIN = 'BETO'
			,@LOCATION_TARGET = 'PUERTA_1'
			,@IS_CONSOLIDATE = 0
			,@DEMAND_TYPE = '' 
			,@SOURCE = 'SO-SONDA'
			,@CODE_WAREHOUSE = 'C002'
			,@IN_PICKING_LINE = 1
			,@DEMAND = N'<?xml version="1.0" encoding="utf-16"?>'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CREATE_DEMAND] (
		@LOGIN VARCHAR(50)
		,@LOCATION_TARGET VARCHAR(50)
		,@IS_CONSOLIDATED VARCHAR(50)
		,@DEMAND_TYPE VARCHAR(50)
		,@SOURCE VARCHAR(50)
		,@CODE_WAREHOUSE VARCHAR(50)
		,@IN_PICKING_LINE INT
		,@LINE_ID VARCHAR(50) = NULL
		,@DEMAND XML
		,@IS_FOR_DELIVERY_IMMEDIATE INT
		,@PRIORITY INT = 2
		,@PROJECT_ID UNIQUEIDENTIFIER = NULL
		,@ORDER_NUMBER VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT OFF;
  -- ------------------------------------------
  -- Declaramos las variables necesarias
  -- ------------------------------------------

	DECLARE
		@PROJECT_CODE VARCHAR(50) = NULL
		,@PROJECT_NAME VARCHAR(150) = NULL
		,@PROJECT_SHORT_NAME VARCHAR(25) = NULL;

	DECLARE	@pMIN_DAYS_EXPIRATION_DATE INT = 0;

	DECLARE	@HEADER TABLE (
			[HEADER_ID] INT NOT NULL
							PRIMARY KEY
			,[SALES_ORDER_ID] VARCHAR(50)
			,[POSTED_DATETIME] DATETIME
			,[CLIENT_ID] VARCHAR(50)
			,[CUSTOMER_NAME] VARCHAR(250)
			,[TOTAL_AMOUNT] NUMERIC(18, 6)
			,[STATUS] VARCHAR(50)
			,[DEVICE_BATTERY_FACTOR] INT
			,[VOID_DATETIME] DATETIME
			,[VOIDED] INT
			,[CLOSED_ROUTE_DATETIME] DATETIME
			,[IS_ACTIVE_ROUTE] INT
			,[SALES_ORDER_ID_HH] INT
			,[DELIVERY_DATE] DATETIME
			,[IS_PARENT] INT
			,[CODE_WAREHOUSE] VARCHAR(50)
			,[DOC_NUM] VARCHAR(50)
			,[DISCOUNT] NUMERIC(18, 6)
			,[IS_DRAFT] INT
			,[TOTAL_CD] NUMERIC(18, 6)
			,[IS_POSTED_ERP] INT
			,[CREDIT_AMOUNT] NUMERIC(18, 6)
			,[CASH_AMOUNT] NUMERIC(18, 6)
			,[EXTERNAL_SOURCE_ID] INT
			,[SOURCE_NAME] VARCHAR(50)
			,[AdvertenciaFaltaInventario] INT
			,[IS_FROM_SONDA] INT
			,[IS_FROM_ERP] INT
			,[CODE_SELLER] VARCHAR(50)
			,[Prioridad] INT
			,[IS_COMPLETED] INT
			,[DOC_ENTRY] VARCHAR(50)
			,[CLIENT_OWNER] VARCHAR(50)
			,[MASTER_ID_SELLER] VARCHAR(50)
			,[SELLER_OWNER] VARCHAR(50)
			,[OWNER] VARCHAR(50)
			,[ADDRESS_CUSTOMER] VARCHAR(250)
			,[STATE_CODE] VARCHAR(50)
			,[WAVE_PICKING_ID] INT
			,[PICKING_DEMAND_HEADER_ID] INT
			,[ORDER_VOLUME] NUMERIC(18, 6)
			,[ORDER_WEIGHT] NUMERIC(18, 6)
			,[CODIGO_POLIZA] VARCHAR(50)
			,[POLIZA_HEADER_DOC_ID] INT
			,[USED] INT NOT NULL
						DEFAULT (0)
			,[CODE_ROUTE] VARCHAR(50)
			,[DOC_SERIE] VARCHAR(50)
			,[LINE_DOC] VARCHAR(50)
			,[BOX_QTY] INT NOT NULL
							DEFAULT (0)
			,[TYPE_DEMAND_CODE] INT
			,[TYPE_DEMAND_NAME] VARCHAR(50)
			,[WAREHOUSE_FROM] VARCHAR(25)
			,[WAREHOUSE_TO] VARCHAR(50)
			,[TRANSFER_REQUEST_ID] INT
			,[PROJECT] VARCHAR(50)
			,[NON_IMMEDIATE_PICKING_HEADER_ID] INT
			,[TRANSFER_REQUEST_FIRST_TIME] INT
			,[PROJECT_ID] UNIQUEIDENTIFIER
			,[PROJECT_CODE] VARCHAR(50)
			,[PROJECT_NAME] VARCHAR(150)
			,[PROJECT_SHORT_NAME] VARCHAR(25)
			,[MIN_DAYS_EXPIRATION_DATE] INT
		);
  --
	DECLARE	@DETAIL TABLE (
			[HEADER_ID] INT NOT NULL
			,[DETAIL_ID] INT NOT NULL
								PRIMARY KEY
			,[SALES_ORDER_ID] NUMERIC(18, 0)
			,[SKU] VARCHAR(50)
			,[DESCRIPTION_SKU] VARCHAR(250)
			,[LINE_SEQ] INT
			,[QTY] NUMERIC(18, 6)
			,[QTY_ORIGINAL] NUMERIC(18, 6)
			,[QTY_PENDING] NUMERIC(18, 6)
			,[PRICE] NUMERIC(18, 6)
			,[DISCOUNT] NUMERIC(18, 6)
			,[TOTAL_LINE] NUMERIC(18, 6)
			,[POSTED_DATETIME] DATETIME
			,[REQUERIES_SERIE] INT
			,[PARENT_SEQ] INT
			,[IS_ACTIVE_ROUTE] INT
			,[EXTERNAL_SOURCE_ID] INT
			,[SOURCE_NAME] VARCHAR(50)
			,[IS_BONUS] INT
			,[ALTERNATE_BARCODE] VARCHAR(50)
			,[BARCODE_ID] VARCHAR(50)
			,[AdvertenciaFaltaInventario] INT
			,[ERP_OBJECT_TYPE] INT
			,[fechaModificacion] DATETIME
			,[CODE_WAREHOUSE_SOURCE] VARCHAR(50)
			,[AVAILABLE_QTY] NUMERIC(18, 6)
			,[IS_MASTER_PACK] INT
			,[MASTER_ID_MATERIAL] VARCHAR(50)
			,[MATERIAL_OWNER] VARCHAR(50)
			,[SOURCE] VARCHAR(50)
			,[TONE] VARCHAR(50)
			,[CALIBER] VARCHAR(50)
			,[MATERIAL_WEIGHT] NUMERIC(18, 6)
			,[MATERIAL_VOLUME] NUMERIC(18, 6)
			,[USE_PICKING_LINE] INT
			,[ASSEMBLED_QTY] INT NOT NULL
									DEFAULT (0)
			,[USED] INT NOT NULL
						DEFAULT (0)
			,[WAS_IMPLODED] INT NOT NULL
								DEFAULT (0)
			,[DISCOUNT_TYPE] VARCHAR(50)
			,[unitMsr] VARCHAR(200)
			,[STATUS_CODE] VARCHAR(50)
		);
  --
	DECLARE	@POLIZA_HEADER TABLE (
			[DOC_ID] INT NOT NULL
			,[CODIGO_POLIZA] VARCHAR(50) UNIQUE
		);
  --
	DECLARE	@PICKING_DEMAND_HEADER TABLE (
			[PICKING_DEMAND_HEADER_ID] INT NOT NULL
			,[HEADER_ID] INT NOT NULL
								PRIMARY KEY
		);

	DECLARE @CONSOLIDATED_MATERIALS TABLE (
		 MATERIAL_ID VARCHAR(50)
		,QTY DECIMAL(18,6)
		,TAKEN INT
	);
  --
	DECLARE	@OPERACION TABLE (
			[Resultado] INT
			,[Mensaje] VARCHAR(MAX)
			,[Codigo] INT
			,[DbData] VARCHAR(MAX)
		);

  -- ------------------------------------------------------------------------------------
  -- Variables para crear tareas
  -- ------------------------------------------------------------------------------------
	DECLARE
		@TASK_ASSIGNEDTO VARCHAR(25)
		,@QUANTITY_ASSIGNED NUMERIC(18, 6)
		,@CODIGO_POLIZA_TARGET VARCHAR(25)
		,@MATERIAL_ID VARCHAR(50)
		,@BARCODE_ID VARCHAR(50)
		,@ALTERNATE_BARCODE VARCHAR(50)
		,@MATERIAL_NAME VARCHAR(200)
		,@CLIENT_OWNER VARCHAR(25)
		,@CLIENT_NAME VARCHAR(150)
		,@IS_FROM_SONDA INT
		,@IS_FROM_ERP INT
		,@DOC_ID_TARGET NUMERIC(18, 0)
		,@TRANSFER_REQUEST_ID NUMERIC(18, 0)
		,@TONE VARCHAR(20)
		,@CALIBER VARCHAR(20)
		,@ASSEMBLED_QTY INT = 0
		,@NON_IMMEDIATE_PICKING_HEADER_ID INT = 0
		,@TRANSFER_REQUEST_FIRST_TIME INT = 0
		,@NON_STORAGE INT = 0
		,@STATUS_CODE VARCHAR(50) = NULL
		,@COSOLIDATED_QTY DECIMAL(18,6)
		,@CONSOLIDATED_QTY_LOWER_ROOF DECIMAL(18,6)
		,@ROOF_QTY NUMERIC(18,6);

  -- ------------------------------------------------------------------------------------
  -- Obtenemos la informacion del proyecto si lo mandaran
  -- ------------------------------------------------------------------------------------
	SELECT TOP 1
		@PROJECT_CODE = [P].[OPPORTUNITY_CODE]
		,@PROJECT_NAME = [P].[OPPORTUNITY_NAME]
		,@PROJECT_SHORT_NAME = [P].[SHORT_NAME]
	FROM
		[wms].[OP_WMS_PROJECT] [P]
	WHERE
		@PROJECT_ID = [P].[ID];

  -- ------------------------------------------------------------------------------------
  -- Variables para inducir 
  -- ------------------------------------------------------------------------------------
	DECLARE
		@LINE_DOC VARCHAR(50) = ''
		,@BOX_QTY INT = 0;

  -- ------------------------------------------------------------------------------------
  -- Variables globales
  -- ------------------------------------------------------------------------------------
	DECLARE
		@TIPO VARCHAR(25) = 'EGRESO'
		,@HEADER_ID INT = 0
		,@DETAIL_ID INT = 0
		,@WAVE_PICKING_ID INT = 0
		,@Resultado INT = -1
		,@Mensaje VARCHAR(MAX)
		,@IS_COMPLETE_DOCUMENT INT = 1
		,@WAREHOUSE_FROM VARCHAR(50)
		,@WAREHOUSE_TO VARCHAR(50)
		,@DELIVERY_DATE DATETIME
		,@IS_FROM_ERP_FRO_REQUEST INT = 0
		,@OWNER VARCHAR(50)
		,@DOC_NUM NUMERIC(18, 0)
		,@pDOC_NUM varchar(50)
		,@DOC_ENTRY NUMERIC(18, 0)
		,@QTY NUMERIC(18, 4)
		,@TRANSFER_REQUEST_ID_H NUMERIC(18, 4)
		,@DOCS_AND_QTYS VARCHAR(MAX);
  -- ------------------------------------------------------------------------------------
  -- Obtiene los encabezados de la demanda
  -- ------------------------------------------------------------------------------------

 --if(@SOURCE = 'SO - ERP') return;

	INSERT	INTO @HEADER
			(
				[HEADER_ID]
				,[SALES_ORDER_ID]
				,[POSTED_DATETIME]
				,[CLIENT_ID]
				,[CUSTOMER_NAME]
				,[TOTAL_AMOUNT]
				,[STATUS]
				,[DEVICE_BATTERY_FACTOR]
				,[VOID_DATETIME]
				,[VOIDED]
				,[CLOSED_ROUTE_DATETIME]
				,[IS_ACTIVE_ROUTE]
				,[SALES_ORDER_ID_HH]
				,[DELIVERY_DATE]
				,[IS_PARENT]
				,[CODE_WAREHOUSE]
				,[DOC_NUM]
				,[DISCOUNT]
				,[IS_DRAFT]
				,[TOTAL_CD]
				,[IS_POSTED_ERP]
				,[CREDIT_AMOUNT]
				,[CASH_AMOUNT]
				,[EXTERNAL_SOURCE_ID]
				,[SOURCE_NAME]
				,[AdvertenciaFaltaInventario]
				,[IS_FROM_SONDA]
				,[IS_FROM_ERP]
				,[CODE_SELLER]
				,[Prioridad]
				,[IS_COMPLETED]
				,[DOC_ENTRY]
				,[CLIENT_OWNER]
				,[MASTER_ID_SELLER]
				,[SELLER_OWNER]
				,[OWNER]
				,[ADDRESS_CUSTOMER]
				,[STATE_CODE]
				,[ORDER_VOLUME]
				,[ORDER_WEIGHT]
				,[CODIGO_POLIZA]
				,[CODE_ROUTE]
				,[DOC_SERIE]
				,[TYPE_DEMAND_CODE]
				,[TYPE_DEMAND_NAME]
				,[WAREHOUSE_FROM]
				,[WAREHOUSE_TO]
				,[PROJECT]
				,[NON_IMMEDIATE_PICKING_HEADER_ID]
				,[TRANSFER_REQUEST_FIRST_TIME]
				,[PROJECT_ID]
				,[PROJECT_CODE]
				,[PROJECT_NAME]
				,[PROJECT_SHORT_NAME]
				,[MIN_DAYS_EXPIRATION_DATE]
			)
	SELECT
		[x].[Rec].[query]('./ID').[value]('.', 'int')
		,[x].[Rec].[query]('./SALES_ORDER_ID').[value]('.',
											'VARCHAR(50)')
		,[x].[Rec].[query]('./POSTED_DATETIME').[value]('.',
											'DATETIME')
		,[x].[Rec].[query]('./CLIENT_ID').[value]('.',
											'VARCHAR(50)')
		,[x].[Rec].[query]('./CUSTOMER_NAME').[value]('.',
											'VARCHAR(250)')
		,[x].[Rec].[query]('./TOTAL_AMOUNT').[value]('.',
											'NUMERIC(18,6)')
		,[x].[Rec].[query]('./STATUS').[value]('.',
											'VARCHAR(50)')
		,[x].[Rec].[query]('./DEVICE_BATTERY_FACTOR').[value]('.',
											'int')
		,[x].[Rec].[query]('./VOID_DATETIME').[value]('.',
											'DATETIME')
		,[x].[Rec].[query]('./VOIDED').[value]('.', 'int')
		,[x].[Rec].[query]('./CLOSED_ROUTE_DATETIME').[value]('.',
											'DATETIME')
		,[x].[Rec].[query]('./IS_ACTIVE_ROUTE').[value]('.',
											'int')
		,[x].[Rec].[query]('./SALES_ORDER_ID_HH').[value]('.',
											'int')
		,[x].[Rec].[query]('./DELIVERY_DATE').[value]('.',
											'DATETIME')
		,[x].[Rec].[query]('./IS_PARENT').[value]('.', 'int')
		,[x].[Rec].[query]('./CODE_WAREHOUSE').[value]('.',
											'VARCHAR(50)')
		,[x].[Rec].[query]('./DOC_NUM').[value]('.',
											'VARCHAR(50)')
		,[x].[Rec].[query]('./DISCOUNT').[value]('.',
											'NUMERIC(18,6)')
		,[x].[Rec].[query]('./IS_DRAFT').[value]('.', 'int')
		,[x].[Rec].[query]('./TOTAL_CD').[value]('.',
											'NUMERIC(18,6)')
		,[x].[Rec].[query]('./IS_POSTED_ERP').[value]('.',
											'int')
		,CASE	WHEN [x].[Rec].[query]('./CREDIT_AMOUNT').[value]('.',
											'varchar(50)') = ''
				THEN NULL
				ELSE [x].[Rec].[query]('./CREDIT_AMOUNT').[value]('.',
											'NUMERIC(18,6)')
			END
		,CASE	WHEN [x].[Rec].[query]('./CASH_AMOUNT').[value]('.',
											'varchar(50)') = ''
				THEN NULL
				ELSE [x].[Rec].[query]('./CASH_AMOUNT').[value]('.',
											'NUMERIC(18,6)')
			END
		,[x].[Rec].[query]('./EXTERNAL_SOURCE_ID').[value]('.',
											'int')
		,[x].[Rec].[query]('./SOURCE_NAME').[value]('.',
											'VARCHAR(50)')
		,[x].[Rec].[query]('./AdvertenciaFaltaInvent').[value]('.',
											'int')
		,[x].[Rec].[query]('./IS_FROM_SONDA').[value]('.',
											'int')
		,[x].[Rec].[query]('./IS_FROM_ERP').[value]('.',
											'int')
		,[x].[Rec].[query]('./CODE_SELLER').[value]('.',
											'VARCHAR(50)')
		,[x].[Rec].[query]('./Prioridad').[value]('.', 'int')
		,[x].[Rec].[query]('./IS_COMPLETED').[value]('.',
											'int')
		,[x].[Rec].[query]('./DOC_ENTRY').[value]('.',
											'VARCHAR(50)')
		,[x].[Rec].[query]('./CLIENT_OWNER').[value]('.',
											'VARCHAR(50)')
		,[x].[Rec].[query]('./MASTER_ID_SELLER').[value]('.',
											'VARCHAR(50)')
		,[x].[Rec].[query]('./SELLER_OWNER').[value]('.',
											'VARCHAR(50)')
		,[x].[Rec].[query]('./OWNER').[value]('.',
											'VARCHAR(50)')
		,[x].[Rec].[query]('./ADDRESS_CUSTOMER').[value]('.',
											'VARCHAR(250)')
		,[x].[Rec].[query]('./STATE_CODE').[value]('.',
											'VARCHAR(50)')
		,[x].[Rec].[query]('./ORDER_VOLUME').[value]('.',
											'NUMERIC(18,6)')
		,[x].[Rec].[query]('./ORDER_WEIGHT').[value]('.',
											'NUMERIC(18,6)')
		,CAST([x].[Rec].[query]('./SALES_ORDER_ID').[value]('.',
											'varchar(50)')
		+ @SOURCE + [x].[Rec].[query]('./CLIENT_ID').[value]('.',
											'VARCHAR(50)') AS VARCHAR(25))
		,[x].[Rec].[query]('./CODE_ROUTE').[value]('.',
											'VARCHAR(50)')
		,[x].[Rec].[query]('./DOC_SERIE').[value]('.',
											'VARCHAR(50)')
		,[x].[Rec].[query]('./TYPE_DEMAND_CODE').[value]('.',
											'int')
		,[x].[Rec].[query]('./TYPE_DEMAND_NAME').[value]('.',
											'VARCHAR(50)')
		,[x].[Rec].[query]('./WAREHOUSE_FROM').[value]('.',
											'VARCHAR(25)')
		,[x].[Rec].[query]('./WAREHOUSE_TO').[value]('.',
											'VARCHAR(25)')
		,[x].[Rec].[query]('./PROJECT').[value]('.',
											'VARCHAR(25)')
		,[x].[Rec].[query]('./PICKING_DEMAND_HEADER_ID').[value]('.',
											'VARCHAR(25)')
		,1
		,@PROJECT_ID
		,@PROJECT_CODE
		,@PROJECT_NAME
		,@PROJECT_SHORT_NAME
		,[x].[Rec].[query]('./MIN_DAYS_EXPIRATION_DATE').[value]('.',
											'int')
	FROM
		@DEMAND.[nodes]('/ArrayOfOrdenDeVentaEncabezado/OrdenDeVentaEncabezado')
		AS [x] ([Rec]);
		
  -- ------------------------------------------------------------------------------------
  -- Obtiene los encabezados de la demanda
  -- ------------------------------------------------------------------------------------
	INSERT	INTO @DETAIL
			(
				[HEADER_ID]
				,[DETAIL_ID]
				,[SALES_ORDER_ID]
				,[SKU]
				,[DESCRIPTION_SKU]
				,[LINE_SEQ]
				,[QTY]
				,[QTY_ORIGINAL]
				,[QTY_PENDING]
				,[PRICE]
				,[DISCOUNT]
				,[TOTAL_LINE]
				,[POSTED_DATETIME]
				,[REQUERIES_SERIE]
				,[PARENT_SEQ]
				,[IS_ACTIVE_ROUTE]
				,[EXTERNAL_SOURCE_ID]
				,[SOURCE_NAME]
				,[IS_BONUS]
				,[ALTERNATE_BARCODE]
				,[BARCODE_ID]
				,[AdvertenciaFaltaInventario]
				,[ERP_OBJECT_TYPE]
				,[fechaModificacion]
				,[CODE_WAREHOUSE_SOURCE]
				,[AVAILABLE_QTY]
				,[IS_MASTER_PACK]
				,[MASTER_ID_MATERIAL]
				,[MATERIAL_OWNER]
				,[SOURCE]
				,[TONE]
				,[CALIBER]
				,[MATERIAL_WEIGHT]
				,[MATERIAL_VOLUME]
				,[USE_PICKING_LINE]
				,[DISCOUNT_TYPE]
				,[unitMsr]
				,[STATUS_CODE]
			)
	SELECT
		[x].[Rec].[query]('./HEADER_ID').[value]('.', 'int')
		,[x].[Rec].[query]('./ID').[value]('.', 'int')
		,[x].[Rec].[query]('./SALES_ORDER_ID').[value]('.',
											'VARCHAR(50)')
		,[x].[Rec].[query]('./SKU').[value]('.',
											'VARCHAR (50)')
		,[x].[Rec].[query]('./DESCRIPTION_SKU').[value]('.',
											'VARCHAR (250)')
		,[x].[Rec].[query]('./LINE_SEQ').[value]('.', 'int')
		,[x].[Rec].[query]('./QTY').[value]('.',
											'NUMERIC(18,6)')
		,[x].[Rec].[query]('./QTY_ORIGINAL').[value]('.',
											'NUMERIC(18,6)')
		,[x].[Rec].[query]('./QTY_PENDING').[value]('.',
											'NUMERIC(18,6)')
		,[x].[Rec].[query]('./PRICE').[value]('.',
											'NUMERIC(18,6)')
		,[x].[Rec].[query]('./DISCOUNT').[value]('.',
											'NUMERIC(18,6)')
		,[x].[Rec].[query]('./TOTAL_LINE').[value]('.',
											'NUMERIC(18,6)')
		,CASE	WHEN [x].[Rec].[query]('./POSTED_DATETIME').[value]('.',
											'varchar(50)') = ''
				THEN NULL
				ELSE [x].[Rec].[query]('./POSTED_DATETIME').[value]('.',
											'DATETIME')
			END
		,[x].[Rec].[query]('./REQUERIES_SERIE').[value]('.',
											'int')
		,[x].[Rec].[query]('./PARENT_SEQ').[value]('.',
											'int')
		,[x].[Rec].[query]('./IS_ACTIVE_ROUTE').[value]('.',
											'int')
		,[x].[Rec].[query]('./EXTERNAL_SOURCE_ID').[value]('.',
											'int')
		,[x].[Rec].[query]('./SOURCE_NAME').[value]('.',
											'VARCHAR (50)')
		,[x].[Rec].[query]('./IS_BONUS').[value]('.', 'int')
		,[x].[Rec].[query]('./ALTERNATE_BARCODE').[value]('.',
											'VARCHAR (50)')
		,[x].[Rec].[query]('./BARCODE_ID').[value]('.',
											'VARCHAR (50)')
		,[x].[Rec].[query]('./AdvertenciaFaltaInventario').[value]('.',
											'int')
		,[x].[Rec].[query]('./ERP_OBJECT_TYPE').[value]('.',
											'int')
		,[x].[Rec].[query]('./fechaModificacion').[value]('.',
											'DATETIME')
		,[x].[Rec].[query]('./CODE_WAREHOUSE_SOURCE').[value]('.',
											'VARCHAR (50)')
		,[x].[Rec].[query]('./AVAILABLE_QTY').[value]('.',
											'NUMERIC(18,6)')
		,[x].[Rec].[query]('./IS_MASTER_PACK').[value]('.',
											'int')
		,[x].[Rec].[query]('./MASTER_ID_MATERIAL').[value]('.',
											'VARCHAR (50)')
		,[x].[Rec].[query]('./MATERIAL_OWNER').[value]('.',
											'VARCHAR (50)')
		,[x].[Rec].[query]('./SOURCE').[value]('.',
											'VARCHAR (50)')
		,[x].[Rec].[query]('./TONE').[value]('.',
											'VARCHAR (50)')
		,[x].[Rec].[query]('./CALIBER').[value]('.',
											'VARCHAR (50)')
		,[x].[Rec].[query]('./MATERIAL_WEIGHT').[value]('.',
											'NUMERIC(18,6)')
		,[x].[Rec].[query]('./MATERIAL_VOLUME').[value]('.',
											'NUMERIC(18,6)')
		,[x].[Rec].[query]('./USE_PICKING_LINE').[value]('.',
											'int')
		,[x].[Rec].[query]('./DISCOUNT_TYPE').[value]('.',
											'VARCHAR (50)')
		,[x].[Rec].[query]('./unitMsr').[value]('.',
											'VARCHAR (200)')
		,[x].[Rec].[query]('./STATUS_CODE').[value]('.',
											'VARCHAR (50)')
	FROM
		@DEMAND.[nodes]('/ArrayOfOrdenDeVentaEncabezado/OrdenDeVentaEncabezado/Detalles/OrdenDeVentaDetalle')
		AS [x] ([Rec]);

  -- --------------------------------------------------------------------------------------------------------
  -- Se insertan los materiales en una tabla temporal que los agrupará para ser procesados como consolidados
  -- --------------------------------------------------------------------------------------------------------
	IF(@IS_CONSOLIDATED = 1 )
	BEGIN
		INSERT INTO @CONSOLIDATED_MATERIALS
	    SELECT
			 SKU
			,SUM(QTY)
			,0
		FROM @DETAIL
	  GROUP BY SKU
	END

  -- ------------------------------------------------------------------------------------
  -- Poliza
  -- ------------------------------------------------------------------------------------
	BEGIN
    -- ------------------------------------------------------------------------------------
    -- Obtiene el ID de la poliza si ya existiera
    -- ------------------------------------------------------------------------------------
		UPDATE
			[H]
		SET	
			[H].[POLIZA_HEADER_DOC_ID] = [PH].[DOC_ID]
		FROM
			@HEADER [H]
		INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH] ON (
											[PH].[CODIGO_POLIZA] = [H].[CODIGO_POLIZA]
											AND [PH].[TIPO] = @TIPO
											);
    -- ------------------------------------------------------------------------------------
    -- Crea las polizas nuevas
    -- ------------------------------------------------------------------------------------
		INSERT	INTO [wms].[OP_WMS_POLIZA_HEADER]
				(
					[FECHA_LLEGADA]
					,[LAST_UPDATED_BY]
					,[LAST_UPDATED]
					,[CLIENT_CODE]
					,[FECHA_DOCUMENTO]
					,[TIPO]
					,[CODIGO_POLIZA]
					,[ACUERDO_COMERCIAL]
					,[STATUS]
					,[NUMERO_ORDEN]
				)
		OUTPUT	[Inserted].[DOC_ID]
				,[Inserted].[CODIGO_POLIZA]
				INTO @POLIZA_HEADER
					([DOC_ID], [CODIGO_POLIZA])
		SELECT
			GETDATE()
			,@LOGIN
			,GETDATE()
			,[H].[CLIENT_ID]
			,GETDATE()
			,@TIPO
			,[H].[CODIGO_POLIZA]
			,''
			,'CREATED'
			,@ORDER_NUMBER
		FROM
			@HEADER [H]
		WHERE
			[H].[POLIZA_HEADER_DOC_ID] IS NULL;

    -- ------------------------------------------------------------------------------------
    -- Coloca el ID para las nuevas polizas
    -- ------------------------------------------------------------------------------------
		UPDATE
			[H]
		SET	
			[H].[POLIZA_HEADER_DOC_ID] = [PH].[DOC_ID]
		FROM
			@HEADER [H]
		INNER JOIN @POLIZA_HEADER [PH] ON ([PH].[CODIGO_POLIZA] = [H].[CODIGO_POLIZA]);
	END;

	-- ------------------------------------------------------------------------------------
	-- obtengo el valor máximo de días para el mínimo de días de expiración por ola
	-- si el cliente no maneja el valor se asigna 0, también puede venir 0 configurado
	-- si es consolidado se devuelve el valor máximo de todos los clientes de la ola
	-- si no es consolidado se obtiene el valor configurado para el cliente
	-- ------------------------------------------------------------------------------------
	SELECT
		@pMIN_DAYS_EXPIRATION_DATE = MAX([MIN_DAYS_EXPIRATION_DATE])
	FROM
		@HEADER;

	IF @pMIN_DAYS_EXPIRATION_DATE IS NULL
	BEGIN
		SET @pMIN_DAYS_EXPIRATION_DATE = 0;
	END;

  -- ------------------------------------------------------------------------------------
  -- Crea tareas de picking
  -- ------------------------------------------------------------------------------------
	BEGIN
		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							@HEADER
						WHERE
							[HEADER_ID] > 0
							AND [USED] = 0 )
		BEGIN
      -- ------------------------------------------------------------------------------------
      -- Obtiene los datos para crear el documento
      -- ------------------------------------------------------------------------------------
			DECLARE	@MIN_DAYS_BY_SALE_ORDER INT = 0;
			SELECT TOP 1
				@HEADER_ID = [H].[HEADER_ID]
				,@DETAIL_ID = [D].[DETAIL_ID]
				,@Resultado = -1
				,@Mensaje = 'Error inesperado al crear tareas de picking'
				,@ASSEMBLED_QTY = 0
				,@IS_COMPLETE_DOCUMENT = 1
				,@TASK_ASSIGNEDTO = CASE	WHEN @IN_PICKING_LINE = 1
											THEN @LINE_ID
											ELSE ''
									END
				,@QUANTITY_ASSIGNED = [D].[QTY]
				,@CODIGO_POLIZA_TARGET = [H].[CODIGO_POLIZA]
				,@MATERIAL_ID = [D].[SKU]
				,@BARCODE_ID = [D].[BARCODE_ID]
				,@ALTERNATE_BARCODE = [D].[ALTERNATE_BARCODE]
				,@MATERIAL_NAME = [D].[DESCRIPTION_SKU]
				,@CLIENT_OWNER = [D].[MATERIAL_OWNER]
				,@CLIENT_NAME = [C].[COMPANY_NAME]
				,@IS_FROM_SONDA = [H].[IS_FROM_SONDA]
				,@IS_FROM_ERP = [H].[IS_FROM_ERP]
				,@DOC_ID_TARGET = [H].[POLIZA_HEADER_DOC_ID]
				,@IS_CONSOLIDATED = @IS_CONSOLIDATED
				,@TRANSFER_REQUEST_ID = CASE
											WHEN [H].[IS_FROM_ERP] = 0
											AND @DEMAND_TYPE = 'TRANSFER_REQUEST'
											AND [H].[IS_FROM_SONDA] = 0
											AND @SOURCE = 'WT - ERP'
											THEN [H].[TRANSFER_REQUEST_ID]
											WHEN @DEMAND_TYPE = 'TRANSFER_REQUEST'
											AND [H].[IS_FROM_ERP] = 0
											THEN [H].[SALES_ORDER_ID]
											WHEN @DEMAND_TYPE = 'TRANSFER_REQUEST'
											AND [H].[IS_FROM_ERP] = 1
											THEN [H].[SALES_ORDER_ID]
											ELSE NULL
										END
				,@TONE = CASE	WHEN [D].[TONE] = ''
								THEN NULL
								ELSE [D].[TONE]
							END
				,@CALIBER = CASE	WHEN [D].[CALIBER] = ''
									THEN NULL
									ELSE [D].[CALIBER]
							END
				,@WAREHOUSE_FROM = [H].[WAREHOUSE_FROM]
				,@WAREHOUSE_TO = [H].[WAREHOUSE_TO]
				,@DELIVERY_DATE = [H].[DELIVERY_DATE]
				,@OWNER = [H].[OWNER]
				,@DOC_NUM = [H].[DOC_NUM]
				,@DOC_ENTRY = [H].[DOC_ENTRY]
				,@QTY = [D].[QTY]
				,@NON_IMMEDIATE_PICKING_HEADER_ID = [H].[NON_IMMEDIATE_PICKING_HEADER_ID]
				,@TRANSFER_REQUEST_FIRST_TIME = [H].[TRANSFER_REQUEST_FIRST_TIME]
				,@STATUS_CODE = [D].[STATUS_CODE]
				,@MIN_DAYS_BY_SALE_ORDER = [H].[MIN_DAYS_EXPIRATION_DATE]
			FROM
				@HEADER [H]
			INNER JOIN @DETAIL [D] ON ([D].[HEADER_ID] = [H].[HEADER_ID])
			LEFT JOIN [wms].[OP_WMS_COMPANY] [C] ON [C].[CLIENT_CODE] = [D].[MATERIAL_OWNER]
			WHERE
				[H].[HEADER_ID] > 0
				AND [D].[DETAIL_ID] > 0
				AND [D].[USED] = 0
			ORDER BY
				[H].[HEADER_ID] ASC
				,[D].[DETAIL_ID] ASC;
      --
			PRINT '--> @HEADER_ID: '
				+ CAST(@HEADER_ID AS VARCHAR);
			PRINT '--> @DETAIL_ID: '
				+ CAST(@DETAIL_ID AS VARCHAR);

			--Obtiene la cantidad de materiales consolidados que no se hayan tomado anteriormente, caso contrario no se vuele a ejecutar como picking por canal 
			SET @COSOLIDATED_QTY = (SELECT QTY FROM @CONSOLIDATED_MATERIALS WHERE MATERIAL_ID = @MATERIAL_ID AND TAKEN = 0)
			--Obtiene la cantidad de materiales consolidados aún si ya fue tomado para validar consolidados cuya suma no supere la cantidad de techo
			set @CONSOLIDATED_QTY_LOWER_ROOF = (SELECT QTY FROM @CONSOLIDATED_MATERIALS WHERE MATERIAL_ID = @MATERIAL_ID)
			--Obtenemos el techo del material
			SET @ROOF_QTY = (SELECT ISNULL(ROOF_QUANTITY, 999999) FROM WMS.OP_WMS_MATERIALS WHERE MATERIAL_ID = @MATERIAL_ID)
      -- ------------------------------------------------------------------------------------
      -- inserta transfer request
      -- ------------------------------------------------------------------------------------
			IF (
				@DEMAND_TYPE = 'TRANSFER_REQUEST'
				AND @IS_FROM_ERP = 1
				AND @TRANSFER_REQUEST_FIRST_TIME = 1
				AND @WAREHOUSE_FROM <> ''
				AND @WAREHOUSE_TO <> ''
				)
			BEGIN
        --
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
							,@LOGIN  -- CREATED_BY - varchar(25)
							,GETDATE()  -- LAST_UPDATE - datetime
							,@LOGIN  -- LAST_UPDATE_BY - varchar(25)
							,@OWNER  -- OWNER - varchar(50)
							,@DOC_NUM -- DOC_NUM - int
							,@DOC_ENTRY -- DOC_ENTRY - int
							,1 -- IS_FROM_ERP - int
							,'Solicitud de traslado desde ERP, DocNum: '
							+ CAST(@DOC_NUM AS VARCHAR)
						);

        --
				SET @TRANSFER_REQUEST_ID = SCOPE_IDENTITY();

				UPDATE
					@HEADER
				SET	
					[TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
					,[TRANSFER_REQUEST_FIRST_TIME] = 0
				WHERE
					[HEADER_ID] = @HEADER_ID;



				INSERT	INTO [wms].[OP_WMS_TRANSFER_REQUEST_DETAIL]
						(
							[TRANSFER_REQUEST_ID]
							,[MATERIAL_ID]
							,[MATERIAL_NAME]
							,[IS_MASTERPACK]
							,[QTY]
							,[STATUS]
							,[STATUS_CODE]
						)
				SELECT
					@TRANSFER_REQUEST_ID
					,[M].[MATERIAL_ID]
					,[M].[MATERIAL_NAME]
					,[M].[IS_MASTER_PACK]
					,[D].[QTY]
					,'OPEN'
					,[D].[STATUS_CODE]
				FROM
					@HEADER [H]
				INNER JOIN @DETAIL [D] ON ([D].[HEADER_ID] = [H].[HEADER_ID])
				INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([D].[MATERIAL_OWNER]
											+ '/'
											+ [D].[MASTER_ID_MATERIAL] = [M].[MATERIAL_ID])
				WHERE
					[D].[HEADER_ID] = @HEADER_ID;



			END;

      -- ------------------------------------------------------------------------------------
      -- Manda a crear el documento
      -- ------------------------------------------------------------------------------------

      -- ------------------------------------------------------------------------------------
      -- NON_STORAGE SE UTILIZA PARA EL MATERIAL DE wms DE FLETE, HABILITARLO DE SER NECESARIO
      -- ------------------------------------------------------------------------------------

			IF @IS_CONSOLIDATED = 1
			BEGIN
				SET @MIN_DAYS_BY_SALE_ORDER = @pMIN_DAYS_EXPIRATION_DATE;
				--Convertimos los documentos y sus cantidades en un varchar que se podrá mandar al SP que crea la tarea
				 SELECT
					SALES_ORDER_ID,
					QTY
				  INTO #DOCS_TEMP
				  FROM @DETAIL WHERE  DETAIL_ID = @DETAIL_ID --SKU = @MATERIAL_ID AND HEADER_ID = @HEADER_ID AND QTY = @QUANTITY_ASSIGNED and DETAIL_ID = @DETAIL_ID

				WHILE EXISTS(SELECT TOP 1 1 FROM #DOCS_TEMP)
				BEGIN
					SELECT @DOCS_AND_QTYS = CONCAT(@DOCS_AND_QTYS,
					(SELECT TOP 1 CONCAT(SALES_ORDER_ID, ',',QTY,',') FROM #DOCS_TEMP))

					DELETE TOP (1) FROM #DOCS_TEMP
				END
				DROP TABLE #DOCS_TEMP
				PRINT '@MATERIAL_ID'
				PRINT @MATERIAL_ID
				PRINT '@DOCS_AND_QTYS'
				PRINT @DOCS_AND_QTYS
			END;

			SELECT
				@NON_STORAGE = [NON_STORAGE]
			FROM
				[wms].[OP_WMS_MATERIALS]
			WHERE
				[MATERIAL_ID] = @MATERIAL_ID;

			IF (@NON_STORAGE = 1)
			BEGIN
				INSERT	INTO @OPERACION
						(
							[Resultado]
							,[Mensaje]
							,[Codigo]
							,[DbData]
						)
				VALUES
						(
							1  -- Resultado - int
							,'Proceso exitoso'  -- Mensaje - varchar(max)
							,1  -- Codigo - int
							,CAST(@WAVE_PICKING_ID AS VARCHAR)
							+ '|1'-- DbData - varchar(max)
						);
			END;


										--print 'Material ID ' + @MATERIAL_ID
										--print 'Code warehouse ' + @CODE_WAREHOUSE
										--print '--> @QUANTITY_ASIGNED: '+ CAST(@QUANTITY_ASSIGNED AS VARCHAR);
										--print '--> @NON_IMMEDIATE_PICKING_HEADER_ID: '+ CAST(@NON_IMMEDIATE_PICKING_HEADER_ID AS VARCHAR);
										--print '--> @STATUS_CODE: '+ CAST(@STATUS_CODE AS VARCHAR);
										--print '--> @MIN_DAYS_BY_SALE_ORDER: '+ CAST(@MIN_DAYS_BY_SALE_ORDER AS VARCHAR);

			IF (@NON_STORAGE = 0)
			BEGIN
				--SET @pDOC_NUM = CAST(@DOC_NUM AS VARCHAR);
				--IF((IIF(@IS_CONSOLIDATED = 1, @COSOLIDATED_QTY, @QUANTITY_ASSIGNED)) > @ROOF_QTY)
				--BEGIN
					PRINT 'OPERACIÓN POR CANAL'
					--Verificamos si este material puede ir consolidado
					IF(ISNULL(@COSOLIDATED_QTY, 0) > 0)
					BEGIN
					print 'Cantidad Consolidada: ' + cast(@COSOLIDATED_QTY AS VARCHAR) 
						--SET @QUANTITY_ASSIGNED = @COSOLIDATED_QTY
						SET @COSOLIDATED_QTY = 0
						UPDATE @CONSOLIDATED_MATERIALS SET TAKEN = 1 WHERE MATERIAL_ID = @MATERIAL_ID
					END
						INSERT	INTO @OPERACION
							(
							[Resultado]
							,[Mensaje]
							,[Codigo]
							,[DbData]
							)
						EXEC [wms].[OP_WMS_SP_INSERT_TASKS_GENERAL_PICKING_DEMAND_PER_CHANNEL] @TASK_OWNER = @LOGIN, -- varchar(25)
							@TASK_ASSIGNEDTO = @TASK_ASSIGNEDTO, -- varchar(25)
							@QUANTITY_ASSIGNED = @QUANTITY_ASSIGNED, -- numeric
							@CODIGO_POLIZA_TARGET = @CODIGO_POLIZA_TARGET, -- varchar(25)
							@MATERIAL_ID = @MATERIAL_ID, -- varchar(50)
							@BARCODE_ID = @BARCODE_ID, -- varchar(50)
							@ALTERNATE_BARCODE = @ALTERNATE_BARCODE, -- varchar(50)
							@MATERIAL_NAME = @MATERIAL_NAME, -- varchar(200)
							@CLIENT_OWNER = @CLIENT_OWNER, -- varchar(25)
							@CLIENT_NAME = @CLIENT_NAME, -- varchar(150)
							@IS_FROM_SONDA = @IS_FROM_SONDA, -- int
							@CODE_WAREHOUSE = @CODE_WAREHOUSE, -- varchar(50)
							@IS_FROM_ERP = @IS_FROM_ERP, -- int
							@WAVE_PICKING_ID = @WAVE_PICKING_ID, -- numeric
							@DOC_ID_TARGET = @DOC_ID_TARGET, -- int
							@LOCATION_SPOT_TARGET = @LOCATION_TARGET, -- varchar(25)
							@IS_CONSOLIDATED = @IS_CONSOLIDATED, -- int
							@SOURCE_TYPE = @SOURCE, -- varchar(50)
							@TRANSFER_REQUEST_ID = @TRANSFER_REQUEST_ID, -- int
							@TONE = @TONE, -- varchar(20)
							@CALIBER = @CALIBER, -- varchar(20)
							@IN_PICKING_LINE = @IN_PICKING_LINE, -- int
							@IS_FOR_DELIVERY_IMMEDIATE = @IS_FOR_DELIVERY_IMMEDIATE,
							@PRIORITY = @PRIORITY,
							@PICKING_HEADER_ID = @NON_IMMEDIATE_PICKING_HEADER_ID,
							@STATUS_CODE = @STATUS_CODE,
							@ORDER_NUMBER = @ORDER_NUMBER,
							@MIN_DAYS_EXPIRATION_DATE = @MIN_DAYS_BY_SALE_ORDER,
							@DOC_NUM = @pDOC_NUM,
							@DOCS_AND_QTYS = @DOCS_AND_QTYS;
				--END
				--ELSE IF ((ISNULL((SELECT TOP 1 1 FROM @CONSOLIDATED_MATERIALS WHERE MATERIAL_ID = @MATERIAL_ID), 0) = 0) OR 
				--		(ISNULL((SELECT TOP 1 1 FROM @CONSOLIDATED_MATERIALS WHERE MATERIAL_ID = @MATERIAL_ID), 0) = 1 AND @CONSOLIDATED_QTY_LOWER_ROOF < @ROOF_QTY))
				--BEGIN
				--	PRINT CONCAT('OPERACIÓN NORMAL: @pDOC_NUM = ', @pDOC_NUM, ' @QUANTITY_ASSIGNED = ', CAST(@QUANTITY_ASSIGNED AS VARCHAR))
				--	INSERT	INTO @OPERACION
				--		(
				--		[Resultado]
				--		,[Mensaje]
				--		,[Codigo]
				--		,[DbData]
				--		)
				--	EXEC [wms].[OP_WMS_SP_INSERT_TASKS_GENERAL_PICKING_DEMAND_PER_CHANNEL] @TASK_OWNER = @LOGIN, -- varchar(25)
				--			@TASK_ASSIGNEDTO = @TASK_ASSIGNEDTO, -- varchar(25)
				--			@QUANTITY_ASSIGNED = @QUANTITY_ASSIGNED, -- numeric
				--			@CODIGO_POLIZA_TARGET = @CODIGO_POLIZA_TARGET, -- varchar(25)
				--			@MATERIAL_ID = @MATERIAL_ID, -- varchar(50)
				--			@BARCODE_ID = @BARCODE_ID, -- varchar(50)
				--			@ALTERNATE_BARCODE = @ALTERNATE_BARCODE, -- varchar(50)
				--			@MATERIAL_NAME = @MATERIAL_NAME, -- varchar(200)
				--			@CLIENT_OWNER = @CLIENT_OWNER, -- varchar(25)
				--			@CLIENT_NAME = @CLIENT_NAME, -- varchar(150)
				--			@IS_FROM_SONDA = @IS_FROM_SONDA, -- int
				--			@CODE_WAREHOUSE = @CODE_WAREHOUSE, -- varchar(50)
				--			@IS_FROM_ERP = @IS_FROM_ERP, -- int
				--			@WAVE_PICKING_ID = @WAVE_PICKING_ID, -- numeric
				--			@DOC_ID_TARGET = @DOC_ID_TARGET, -- int
				--			@LOCATION_SPOT_TARGET = @LOCATION_TARGET, -- varchar(25)
				--			@IS_CONSOLIDATED = @IS_CONSOLIDATED, -- int
				--			@SOURCE_TYPE = @SOURCE, -- varchar(50)
				--			@TRANSFER_REQUEST_ID = @TRANSFER_REQUEST_ID, -- int
				--			@TONE = @TONE, -- varchar(20)
				--			@CALIBER = @CALIBER, -- varchar(20)
				--			@IN_PICKING_LINE = @IN_PICKING_LINE, -- int
				--			@IS_FOR_DELIVERY_IMMEDIATE = @IS_FOR_DELIVERY_IMMEDIATE,
				--			@PRIORITY = @PRIORITY,
				--			@PICKING_HEADER_ID = @NON_IMMEDIATE_PICKING_HEADER_ID,
				--			@STATUS_CODE = @STATUS_CODE,
				--			@ORDER_NUMBER = @ORDER_NUMBER,
				--			@MIN_DAYS_EXPIRATION_DATE = @MIN_DAYS_BY_SALE_ORDER,
				--			@DOC_NUM = @pDOC_NUM,
				--			@DOCS_AND_QTYS = @DOCS_AND_QTYS;
				--END

				SET @DOCS_AND_QTYS = ''

			END;
      -- ------------------------------------------------------------------------------------
      -- Valida el resultado
      -- ------------------------------------------------------------------------------------
			SELECT
				@Resultado = [O].[Resultado]
				,@Mensaje = [O].[Mensaje]
				,@WAVE_PICKING_ID = CAST([wms].[OP_WMS_FN_SPLIT_COLUMNS]([O].[DbData],
											1, '|') AS INT)
				,@ASSEMBLED_QTY = ISNULL(CAST([wms].[OP_WMS_FN_SPLIT_COLUMNS]([O].[DbData],
											2, '|') AS INT),
											0)
			FROM
				@OPERACION [O];
      --
			PRINT '--> @WAVE_PICKING_ID: '
				+ CAST(@WAVE_PICKING_ID AS VARCHAR);
			PRINT '--> @ASSEMBLED_QTY: '
				+ CAST(@ASSEMBLED_QTY AS VARCHAR);
      
			IF @Resultado = -1
			BEGIN
				RAISERROR (@Mensaje, 16, 1);
				RETURN;
			END;

      -- ------------------------------------------------------------------------------------
      -- Marca como usado el detalle
      -- ------------------------------------------------------------------------------------
			UPDATE
				@DETAIL
			SET	
				[USED] = 1
				,[ASSEMBLED_QTY] = @ASSEMBLED_QTY
				,[WAS_IMPLODED] = CASE @ASSEMBLED_QTY
									WHEN 0 THEN 0
									ELSE 1
									END
			WHERE
				[DETAIL_ID] = @DETAIL_ID;
      -- ------------------------------------------------------------------------------------
      -- Marca como bloqueado en SAE
      -- ------------------------------------------------------------------------------------
	  DECLARE @DOC_VARCHAR VARCHAR=CAST(@DOC_NUM AS VARCHAR);
	  PRINT 'Marca como bloqueado en SAE: '+ @DOC_VARCHAR
	 -- RAISERROR (15600,-1,-1, @DOC_VARCHAR );  

			UPDATE FACT 
			SET	FACT.BLOQ='W',FACT.[ENLAZADO] = 'W'
			FROM [SAE70EMPRESA01].[dbo].[FACTP01] FACT
			INNER JOIN @HEADER HEADER
			ON TRIM(FACT.[CVE_DOC]) = TRIM(HEADER.SALES_ORDER_ID) COLLATE DATABASE_DEFAULT
			
	  PRINT 'END UPDATE'

      -- ------------------------------------------------------------------------------------
      -- Marca como usado el documento
      -- ------------------------------------------------------------------------------------
			SELECT TOP 1
				@IS_COMPLETE_DOCUMENT = 0
			FROM
				@DETAIL [D]
			WHERE
				[D].[DETAIL_ID] > 0
				AND [D].[HEADER_ID] = @HEADER_ID
				AND [D].[USED] = 0;
      --
			IF @TRANSFER_REQUEST_FIRST_TIME = 1
			BEGIN
				UPDATE
					@HEADER
				SET	
					[TRANSFER_REQUEST_ID] = @TRANSFER_REQUEST_ID
				WHERE
					[HEADER_ID] = @HEADER_ID;
			END;

			IF @IS_COMPLETE_DOCUMENT = 1
			BEGIN
				UPDATE
					@HEADER
				SET	
					[WAVE_PICKING_ID] = @WAVE_PICKING_ID
					,[USED] = 1
				WHERE
					[HEADER_ID] = @HEADER_ID;
        --
				SELECT
					@WAVE_PICKING_ID = CASE	WHEN @IS_CONSOLIDATED = 0
											THEN 0
											ELSE @WAVE_PICKING_ID
										END;


			END;

		END;
    --
		DELETE FROM
			@OPERACION;
	END;

  -- ------------------------------------------------------------------------------------
  -- Crea documentos de picking
  -- ------------------------------------------------------------------------------------
	BEGIN
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
					,[OWNER]
					,[CLIENT_OWNER]
					,[MASTER_ID_SELLER]
					,[SELLER_OWNER]
					,[SOURCE_TYPE]
					,[DEMAND_TYPE]
					,[TRANSFER_REQUEST_ID]
					,[ADDRESS_CUSTOMER]
					,[STATE_CODE]
					,[DISCOUNT]
					,[DEMAND_SEQUENCE]
					,[TYPE_DEMAND_CODE]
					,[TYPE_DEMAND_NAME]
					,[IS_FOR_DELIVERY_IMMEDIATE]
					,[DEMAND_DELIVERY_DATE]
					,[PROJECT]
					,[PROJECT_ID]
					,[PROJECT_CODE]
					,[PROJECT_NAME]
					,[PROJECT_SHORT_NAME]
					,[MIN_DAYS_EXPIRATION_DATE]
				)
		OUTPUT	[Inserted].[PICKING_DEMAND_HEADER_ID]
				,[Inserted].[DEMAND_SEQUENCE]
				INTO @PICKING_DEMAND_HEADER
					([PICKING_DEMAND_HEADER_ID], [HEADER_ID])
		SELECT
			[H].[SALES_ORDER_ID]
			,[H].[CLIENT_ID]
			,[H].[CODE_ROUTE]
			,[H].[CODE_SELLER]
			,[H].[TOTAL_AMOUNT]
			,[H].[DOC_SERIE]
			,[H].[DOC_NUM]
			,[H].[EXTERNAL_SOURCE_ID]
			,[H].[IS_FROM_ERP]
			,[H].[IS_FROM_SONDA]
			,GETDATE()
			,@LOGIN
			,[H].[IS_COMPLETED]
			,[H].[WAVE_PICKING_ID]
			,@CODE_WAREHOUSE
			,[H].[CUSTOMER_NAME]
			,GETDATE()
			,[H].[DOC_ENTRY]
			,@IS_CONSOLIDATED
			,[H].[Prioridad]
			,[H].[OWNER]
			,[H].[CLIENT_OWNER]
			,[H].[MASTER_ID_SELLER]
			,[H].[SELLER_OWNER]
			,@SOURCE
			,@DEMAND_TYPE
			,CASE	WHEN @DEMAND_TYPE = 'TRANSFER_REQUEST'
					THEN [H].[TRANSFER_REQUEST_ID]
					ELSE NULL
				END
			,[H].[ADDRESS_CUSTOMER]
			,[H].[STATE_CODE]
			,[H].[DISCOUNT]
			,[H].[HEADER_ID]
			,[H].[TYPE_DEMAND_CODE]
			,[H].[TYPE_DEMAND_NAME]
			,@IS_FOR_DELIVERY_IMMEDIATE
			,[H].[DELIVERY_DATE]
			,[H].[PROJECT]
			,@PROJECT_ID
			,@PROJECT_CODE
			,@PROJECT_NAME
			,@PROJECT_SHORT_NAME
			,[H].[MIN_DAYS_EXPIRATION_DATE]
		FROM
			@HEADER [H]
		WHERE
			[H].[HEADER_ID] > 0;

    -- ------------------------------------------------------------------------------------
    -- Coloca el ID para las demandas
    -- ------------------------------------------------------------------------------------
		UPDATE
			[H]
		SET	
			[H].[PICKING_DEMAND_HEADER_ID] = [PH].[PICKING_DEMAND_HEADER_ID]
		FROM
			@HEADER [H]
		INNER JOIN @PICKING_DEMAND_HEADER [PH] ON ([PH].[HEADER_ID] = [H].[HEADER_ID]);

    -- ------------------------------------------------------------------------------------
    -- Agrega el detalle de los documentos
    -- ------------------------------------------------------------------------------------
		INSERT	INTO [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL]
				(
					[PICKING_DEMAND_HEADER_ID]
					,[MATERIAL_ID]
					,[QTY]
					,[LINE_NUM]
					,[ERP_OBJECT_TYPE]
					,[PRICE]
					,[WAS_IMPLODED]
					,[QTY_IMPLODED]
					,[MASTER_ID_MATERIAL]
					,[MATERIAL_OWNER]
					,[TONE]
					,[CALIBER]
					,[DISCOUNT]
					,[IS_BONUS]
					,[DISCOUNT_TYPE]
					,[UNIT_MEASUREMENT]
					,[STATUS_CODE]
				)
		SELECT
			[H].[PICKING_DEMAND_HEADER_ID]
			,[D].[SKU]
			,[D].[QTY]
			,[D].[LINE_SEQ]
			,[D].[ERP_OBJECT_TYPE]
			,[D].[PRICE]
			,[D].[WAS_IMPLODED]
			,[D].[ASSEMBLED_QTY]
			,[D].[MASTER_ID_MATERIAL]
			,[D].[MATERIAL_OWNER]
			,[D].[TONE]
			,[D].[CALIBER]
			,[D].[DISCOUNT]
			,[D].[IS_BONUS]
			,[D].[DISCOUNT_TYPE]
			,[D].[unitMsr]
			,[D].[STATUS_CODE]
		FROM
			@HEADER [H]
		INNER JOIN @DETAIL [D] ON ([D].[HEADER_ID] = [H].[HEADER_ID])
		WHERE
			[H].[HEADER_ID] > 0
			AND [D].[DETAIL_ID] > 0;
	END;

  -- ------------------------------------------------------------------------------------
  -- Induce a la linea de picking
  -- ------------------------------------------------------------------------------------
	UPDATE
		@HEADER
	SET	
		[USED] = 0
	WHERE
		[HEADER_ID] > 0;
  --
	WHILE @IN_PICKING_LINE = 1
		AND EXISTS ( SELECT TOP 1
							1
						FROM
							@HEADER
						WHERE
							[HEADER_ID] > 0
							AND [USED] = 0 )
	BEGIN
    -- ------------------------------------------------------------------------------------
    -- Obtiene los datos para crear el documento
    -- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@WAVE_PICKING_ID = [H].[WAVE_PICKING_ID]
			,@Resultado = -1
			,@Mensaje = 'Error inesperado al inducir en la linea de picking'
			,@LINE_DOC = ''
			,@BOX_QTY = 0
		FROM
			@HEADER [H]
		WHERE
			[H].[HEADER_ID] > 0
			AND [H].[USED] = 0
		ORDER BY
			[H].[HEADER_ID] ASC;
    --
		PRINT '--> @WAVE_PICKING_ID: '
			+ CAST(@WAVE_PICKING_ID AS VARCHAR);

    -- ------------------------------------------------------------------------------------
    -- Manda a inducir el documento
    -- ------------------------------------------------------------------------------------
		INSERT	INTO @OPERACION
				(
					[Resultado]
					,[Mensaje]
					,[Codigo]
					,[DbData]
				)
				EXEC [wms].[OP_WMS_SP_INSERT_PICKING_LINE_TASK] @WAVE_PICKING_ID = @WAVE_PICKING_ID, -- int
					@IS_CONSOLIDATED = @IS_CONSOLIDATED, -- int
					@PICKING_LINE_ID = @LINE_ID, -- varchar(15)
					@LOGIN = @LOGIN; -- varchar(50)

    -- ------------------------------------------------------------------------------------
    -- Valida el resultado
    -- ------------------------------------------------------------------------------------
		SELECT
			@Resultado = [O].[Resultado]
			,@Mensaje = [O].[Mensaje]
			,@LINE_DOC = [wms].[OP_WMS_FN_SPLIT_COLUMNS]([O].[DbData],
											1, '|')
			,@BOX_QTY = ISNULL(CAST([wms].[OP_WMS_FN_SPLIT_COLUMNS]([O].[DbData],
											2, '|') AS INT),
								0)
		FROM
			@OPERACION [O];
    --
		PRINT '--> @LINE_DOC: ' + @LINE_DOC;
		PRINT '--> @BOX_QTY: ' + CAST(@BOX_QTY AS VARCHAR);
		PRINT '--> @Resultado: '
			+ CAST(@Resultado AS VARCHAR);
    --
		IF @Resultado = -1
		BEGIN
			RAISERROR (@Mensaje, 16, 1);
			RETURN;
		END;

    -- ------------------------------------------------------------------------------------
    -- Coloca como usado el documento
    -- ------------------------------------------------------------------------------------
		UPDATE
			@HEADER
		SET	
			[USED] = 1
			,[LINE_DOC] = @LINE_DOC
			,[BOX_QTY] = @BOX_QTY
		WHERE
			[WAVE_PICKING_ID] = @WAVE_PICKING_ID;
    --
		DELETE FROM
			@OPERACION;
	END;

  -- ------------------------------------------------------------------------------------
  -- Retorna 
  -- ------------------------------------------------------------------------------------
	SELECT
		[H].[HEADER_ID] [ID]
		,[H].[SALES_ORDER_ID]
		,[H].[WAVE_PICKING_ID]
		,[H].[PICKING_DEMAND_HEADER_ID]
		,[H].[CODIGO_POLIZA]
		,[H].[POLIZA_HEADER_DOC_ID]
		,[H].[LINE_DOC]
		,[H].[BOX_QTY]
	FROM
		@HEADER [H]
	WHERE
		[H].[HEADER_ID] > 0;



END;