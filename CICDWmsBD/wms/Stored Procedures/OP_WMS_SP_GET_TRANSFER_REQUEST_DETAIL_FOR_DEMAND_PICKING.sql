-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		17-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- Description:			    SP que obtiene el detalle de las solicitudes de transferencia solicitadas del ERP

-- Autor:				marvin.solares
-- Fecha de Creacion: 	30-Ago-2019 @ G-Force-Team Sprint FlorencioVarela
-- Description:			se corrige escenario de error de conversion con ids de documento y id de documento de erp

-- Modificación:			Elder Lucas
-- Fecha de Modificación:	25 de enero 2022	
-- Description:				Se añade calculo de cantidades en base a posibles picking ya creados

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_TRANSFER_REQUEST_DETAIL_FOR_DEMAND_PICKING]
					@XML = N'<?xml version="1.0" encoding="utf-16"?>
<ArrayOfDocumento xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <Documento>
    <DocumentId>3137</DocumentId>
    <ExternalSourceId>0</ExternalSourceId>
    <Owner>ALZA</Owner>
  </Documento>
</ArrayOfDocumento>'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TRANSFER_REQUEST_DETAIL_FOR_DEMAND_PICKING] (@XML XML)
AS
BEGIN
	SET NOCOUNT ON;
	--
	CREATE TABLE [#PICKING_DOCUMENT_DETAIL] (
		[SALES_ORDER_ID] VARCHAR(100) NOT NULL
		,[SKU] VARCHAR(200)
		,[LINE_SEQ] INT NULL
		,[QTY] DECIMAL(18, 4) NULL
		,[QTY_PENDING] DECIMAL(18, 4) NULL
		,[QTY_ORIGINAL] DECIMAL(18, 4) NULL
		,[PRICE] MONEY NULL
		,[DISCOUNT] MONEY NULL
		,[TOTAL_LINE] MONEY NULL
		,[POSTED_DATETIME] DATETIME
		,[SERIE] VARCHAR(50)
		,[SERIE_2] VARCHAR(50)
		,[REQUERIES_SERIE] INT
		,[COMBO_REFERENCE] VARCHAR(50)
		,[PARENT_SEQ] INT
		,[IS_ACTIVE_ROUTE] INT
		,[CODE_PACK_UNIT] VARCHAR(50)
		,[IS_BONUS] INT
		,[DESCRIPTION_SKU] VARCHAR(200)
		,[BARCODE_ID] VARCHAR(25)
		,[ALTERNATE_BARCODE] VARCHAR(25)
		,[EXTERNAL_SOURCE_ID] INT
		,[SOURCE_NAME] VARCHAR(50)
		,[ERP_OBJECT_TYPE] INT
		,[IS_MASTER_PACK] INT
		,[MATERIAL_OWNER] VARCHAR(50)
		,[MASTER_ID_MATERIAL] VARCHAR(50)
		,[SOURCE] VARCHAR(50)
		,[USE_PICKING_LINE] INT
		,[STATUS_CODE] VARCHAR(50)
		,PRIMARY KEY
			([SALES_ORDER_ID], [EXTERNAL_SOURCE_ID], [SKU], [STATUS_CODE])
	);
	--
	DECLARE	@PICKING_DOCUMENT TABLE (
			[PICKING_DOCUMENT_ID] INT
			,UNIQUE ([PICKING_DOCUMENT_ID])
		);

		DECLARE @WAREHOUSE TABLE (
		WAREHOUSE_ID VARCHAR(25))
	--
	DECLARE @ALREADY_CREATED_PICKINGS TABLE (
			DOC_NUM INT,
			MATERIAL_ID VARCHAR(200),
			QYT INT,
			STATUS_CODE VARCHAR(50),
			IS_COMPLETED INT
			);
	--
	DECLARE
		@CLIENT_CODE VARCHAR(25)
		,@CLIENT_NAME VARCHAR(150);
	--
	SELECT TOP 1
		@CLIENT_CODE = [CLIENT_CODE]
		,@CLIENT_NAME = [COMPANY_NAME]
	FROM
		[wms].[OP_WMS_COMPANY];
		-- ------------------------------------------------------------------------------------
		-- Obtiene los documentos con su fuente externa
		-- ------------------------------------------------------------------------------------
	INSERT	INTO @PICKING_DOCUMENT
			(
				[PICKING_DOCUMENT_ID]
				
			)
	SELECT
		[x].[Rec].[query]('./DocumentId').[value]('.', 'int')
	FROM
		@XML.[nodes]('/ArrayOfDocumento/Documento') AS [x] ([Rec]);

	INSERT INTO @ALREADY_CREATED_PICKINGS
			(
				DOC_NUM,
				MATERIAL_ID,
				QYT,
				STATUS_CODE,
				IS_COMPLETED
			)
	SELECT PDH.DOC_NUM,
		   PDD.MATERIAL_ID,
		   SUM(PDD.QTY),
		   PDD.STATUS_CODE,
		   PDH.IS_COMPLETED
		   FROM wms.OP_WMS_NEXT_PICKING_DEMAND_HEADER PDH
	INNER JOIN @PICKING_DOCUMENT PD ON PDH.DOC_NUM = PD.PICKING_DOCUMENT_ID 
	INNER JOIN wms.OP_WMS_NEXT_PICKING_DEMAND_DETAIL PDD ON PDH.PICKING_DEMAND_HEADER_ID = PDD.PICKING_DEMAND_HEADER_ID
	--INNER JOIN wms.OP_WMS_TASK_LIST TL ON TL.TASK_SUBTYPE = 'RECEPCION_TRASLADO' AND TL.IS_COMPLETED = 1 AND PD.PICKING_DOCUMENT_ID = TL.TRANSFER_REQUEST_ID
	GROUP BY PDD.MATERIAL_ID, PDD.STATUS_CODE, PDH.DOC_NUM, PDH.IS_COMPLETED


	--SELECT * FROM @ALREADY_CREATED_PICKINGS
			-- ------------------------------------------------------------------------------------
		-- Obtiene la bodega
		-- ------------------------------------------------------------------------------------
		INSERT INTO @WAREHOUSE 
		([WAREHOUSE_ID] )
		SELECT TRH.WAREHOUSE_FROM FROM 
		[wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [TRH]			
		INNER JOIN @PICKING_DOCUMENT [PD] ON ([PD].[PICKING_DOCUMENT_ID] = [TRH].[TRANSFER_REQUEST_ID]);

	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene los documentos con su fuente externa
		-- ------------------------------------------------------------------------------------
		INSERT	INTO [#PICKING_DOCUMENT_DETAIL]
				(
					[SALES_ORDER_ID]
					,[SKU]
					,[LINE_SEQ]
					,[QTY]
					,[QTY_PENDING]
					,[QTY_ORIGINAL]
					,[PRICE]
					,[DISCOUNT]
					,[TOTAL_LINE]
					,[POSTED_DATETIME]
					,[SERIE]
					,[SERIE_2]
					,[REQUERIES_SERIE]
					,[COMBO_REFERENCE]
					,[PARENT_SEQ]
					,[IS_ACTIVE_ROUTE]
					,[CODE_PACK_UNIT]
					,[IS_BONUS]
					,[DESCRIPTION_SKU]
					,[BARCODE_ID]
					,[ALTERNATE_BARCODE]
					,[EXTERNAL_SOURCE_ID]
					,[SOURCE_NAME]
					,[ERP_OBJECT_TYPE]
					,[IS_MASTER_PACK]
					,[MATERIAL_OWNER]
					,[MASTER_ID_MATERIAL]
					,[SOURCE]
					,[USE_PICKING_LINE]
					,[STATUS_CODE]
				)
		SELECT
			[TRD].[TRANSFER_REQUEST_ID]
			,[TRD].[MATERIAL_ID]
			,ROW_NUMBER() OVER (PARTITION BY [TRD].[TRANSFER_REQUEST_ID] ORDER BY [TRD].[TRANSFER_REQUEST_ID] DESC) [LINE_NUM]
			,[TRD].[QTY] - SUM(ISNULL([DD].[QTY], 0)) [QTY]
			,[TRD].[QTY] - SUM(ISNULL([DD].[QTY], 0)) [QTY_PENDING]
			,[TRD].[QTY] [QTY_ORIGINAL]
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,NULL
			,[M].[MATERIAL_NAME] [DESCRIPTION_SKU]
			,[M].[BARCODE_ID]
			,[M].[ALTERNATE_BARCODE]
			,[C].[EXTERNAL_SOURCE_ID]
			,NULL
			,-1
			,[M].[IS_MASTER_PACK]
			,[M].[CLIENT_OWNER] [MATERIAL_OWNER]
			,CASE	WHEN [MI].[MASTER_ID] IS NULL
					THEN [TRD].[MATERIAL_ID]
					ELSE [MI].[MASTER_ID]
				END
			,@CLIENT_CODE
			,MAX([M].[USE_PICKING_LINE]) [USE_PICKING_LINE]
			,ISNULL([TRD].[STATUS_CODE],'BUEN-ESTADO')
		FROM
			[wms].[OP_WMS_TRANSFER_REQUEST_DETAIL] [TRD]
		INNER JOIN @PICKING_DOCUMENT [PD] ON ([PD].[PICKING_DOCUMENT_ID] = [TRD].[TRANSFER_REQUEST_ID])
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([M].[MATERIAL_ID] = [TRD].[MATERIAL_ID])
		LEFT JOIN [wms].[OP_WMS_MATERIAL_INTERCOMPANY] [MI] ON (
											[M].[CLIENT_OWNER] = [MI].[SOURCE]
											AND [M].[MATERIAL_ID] = ([MI].[SOURCE]
											+ '/'
											+ [MI].[ITEM_CODE])
											)
		INNER JOIN [wms].[OP_WMS_COMPANY] [C] ON ([M].[CLIENT_OWNER] = [C].[CLIENT_CODE])
		LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH] ON (
											[DH].[PICKING_DEMAND_HEADER_ID] > 0
											AND [DH].[DOC_NUM] = [TRD].[TRANSFER_REQUEST_ID]
											AND [DH].[IS_FROM_ERP] = 0
											AND [DH].[DEMAND_TYPE] = 'TRANSFER_REQUEST'
											)
		LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD] ON (
											[DD].[PICKING_DEMAND_HEADER_ID] > 0
											AND [DD].[PICKING_DEMAND_HEADER_ID] = [DH].[PICKING_DEMAND_HEADER_ID]
											AND [DD].[MATERIAL_ID] = [TRD].[MATERIAL_ID]
											AND DD.STATUS_CODE = TRD.STATUS_CODE
											)
		WHERE
			[C].[COMPANY_ID] > 0
			AND [TRD].[TRANSFER_REQUEST_ID] > 0
		GROUP BY
			[MI].[MASTER_ID]
			,[TRD].[TRANSFER_REQUEST_ID]
			,[TRD].[MATERIAL_ID]
			,[TRD].[QTY]
			,[M].[MATERIAL_NAME]
			,[M].[BARCODE_ID]
			,[M].[ALTERNATE_BARCODE]
			,[C].[EXTERNAL_SOURCE_ID]
			,[M].[IS_MASTER_PACK]
			,[M].[CLIENT_OWNER]
			,[TRD].[STATUS_CODE]
		ORDER BY
			[TRD].[TRANSFER_REQUEST_ID]
			,[TRD].[MATERIAL_ID];

		
		
		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado
		-- ------------------------------------------------------------------------------------
		SELECT distinct
			[PDD].[SALES_ORDER_ID]
			,[PDD].[SKU]
			,[PDD].[LINE_SEQ]
			,[PDD].QTY_ORIGINAL - ISNULL(ACP.QYT, 0) [QTY]
			,[PDD].QTY_ORIGINAL - ISNULL(ACP.QYT, 0) [QTY_PENDING]
			,[PDD].[QTY_ORIGINAL]
			,[PDD].[PRICE]
			,[PDD].[DISCOUNT]
			,[PDD].[TOTAL_LINE]
			,[PDD].[POSTED_DATETIME]
			,[PDD].[SERIE]
			,[PDD].[SERIE_2]
			,[PDD].[REQUERIES_SERIE]
			,[PDD].[COMBO_REFERENCE]
			,[PDD].[PARENT_SEQ]
			,[PDD].[IS_ACTIVE_ROUTE]
			,[PDD].[CODE_PACK_UNIT]
			,[PDD].[IS_BONUS]
			,[PDD].[DESCRIPTION_SKU]
			,[PDD].[BARCODE_ID]
			,[PDD].[ALTERNATE_BARCODE]
			,[PDD].[EXTERNAL_SOURCE_ID]
			,[PDD].[SOURCE_NAME]
			,[PDD].[ERP_OBJECT_TYPE]
			,[PDD].[IS_MASTER_PACK]
			,[PDD].[MATERIAL_OWNER]
			,[PDD].[MASTER_ID_MATERIAL]
			,[PDD].[SOURCE]
			,[PDD].[USE_PICKING_LINE]
			,([IP].STATUS_CODE) STATUS_CODE
			,([IP].STATUS_NAME) STATUS_NAME
		FROM
			[#PICKING_DOCUMENT_DETAIL] [PDD]
			INNER JOIN  wms.[OP_WMS_VIEW_INVENTORY_FOR_PICKING_BY_STATUS_MATERIAL] [IP]
			ON PDD.SKU = [IP].MATERIAL_ID COLLATE DATABASE_DEFAULT
			AND PDD.STATUS_CODE = IP.STATUS_CODE COLLATE DATABASE_DEFAULT
			INNER JOIN @WAREHOUSE W ON (W.WAREHOUSE_ID = IP.CURRENT_WAREHOUSE)
			LEFT JOIN @ALREADY_CREATED_PICKINGS [ACP] ON ACP.DOC_NUM = PDD.SALES_ORDER_ID 
													  AND ACP.MATERIAL_ID = PDD.SKU COLLATE DATABASE_DEFAULT
													  AND ACP.STATUS_CODE = PDD.STATUS_CODE COLLATE DATABASE_DEFAULT
		WHERE
			[PDD].[SALES_ORDER_ID] > 0
			AND [PDD].[EXTERNAL_SOURCE_ID] > 0
			AND ([PDD].QTY_ORIGINAL - ISNULL(ACP.QYT, 0)) > 0
			--AND ACP.IS_COMPLETED IS NULL OR ACP.IS_COMPLETED = 1
			--AND ACP.DOC_NUM IS NOT NULL;
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;