-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/13/2017 @ NEXUS-Team Sprint HeyYouPikachu! 
-- Description:			Obtiene el reporte de devoluciones por fecha y bodega

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_RECEPTION_RETURN_REPORT] 
				@START_DATE = '2017-12-14 00:00:01', -- datetime
				@END_DATE = '2017-12-14 23:59:59', -- datetime
				@LOGIN = 'ADMIN', -- varchar(50)
				@WAREHOUSE = 'BODEGA_01' -- varchar(max)
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_RECEPTION_RETURN_REPORT](
	@START_DATE DATETIME
	,@END_DATE DATETIME
	,@LOGIN VARCHAR(50)
	,@WAREHOUSE VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @DETAIL AS TABLE(
		[RECEPTION_DOCUMENT_HEADER_ID] INT
		,[TASK_ID] INT
		,[MATERIAL_ID] VARCHAR(50)
		,[MATERIAL_NAME] VARCHAR(150)
		,[QTY] DECIMAL(18,4)
		,PRIMARY KEY([RECEPTION_DOCUMENT_HEADER_ID],[TASK_ID],[MATERIAL_ID])
	)
	--
	DECLARE @WAREHOUSES AS TABLE(
		[WAREHOUSE_CODE] NVARCHAR(100)
		,PRIMARY KEY([WAREHOUSE_CODE])
	)
	--
	INSERT INTO @WAREHOUSES
	SELECT [VALUE] [WAREHOUSE_CODE]
	FROM [wms].[OP_WMS_FN_SPLIT](@WAREHOUSE, '|')
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene las cantidades recepcionadas
	-- ------------------------------------------------------------------------------------
	INSERT INTO @DETAIL
	SELECT [RH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
			,[RH].[TASK_ID]
			,[IL].[MATERIAL_ID]
			,[IL].[MATERIAL_NAME]
			,SUM([IL].[ENTERED_QTY]) [QTY]
	FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH]
	INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [T].[SERIAL_NUMBER] = [RH].[TASK_ID]
	INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [T].[CODIGO_POLIZA_SOURCE] = [L].[CODIGO_POLIZA]
	INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
	WHERE [RH].[SOURCE] = 'INVOICE'
		AND [RH].[ERP_DATE] BETWEEN @START_DATE AND @END_DATE
	GROUP BY [RH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
			,[RH].[TASK_ID]
            ,[IL].[MATERIAL_ID]
            ,[IL].[MATERIAL_NAME]
	
	-- ------------------------------------------------------------------------------------
	-- Despliega el resultado final
	-- ------------------------------------------------------------------------------------
	SELECT	
		[RH].[DOC_NUM]  [INVOICE_DOC_NUM]
		,[RH].[CODE_SUPPLIER] [CLIENT_CODE]
		,[RH].[NAME_SUPPLIER] [CLIENT_NAME]
		,[RH].[PLATE_NUMBER]
		,[RH].[IS_POSTED_ERP] 
		,[RH].[TASK_ID]
		,[RH].[ERP_REFERENCE_DOC_NUM]
		,[RD].[MATERIAL_ID]
		,[M].[MATERIAL_NAME]
		,ISNULL([D].[QTY], 0) QTY
		,[RD].[QTY] [RECEPTION_QTY]
	FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH]
	INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RD] ON [RD].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [RH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
	INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON [RH].[ERP_WAREHOUSE_CODE] = [W].[ERP_WAREHOUSE]
	INNER JOIN @WAREHOUSES [PW] ON [PW].[WAREHOUSE_CODE] = [W].[WAREHOUSE_ID]
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [RD].[MATERIAL_ID]
	LEFT JOIN @DETAIL [D] ON [D].[MATERIAL_ID] = [RD].[MATERIAL_ID] AND [RH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [D].[RECEPTION_DOCUMENT_HEADER_ID]
	WHERE [RH].[SOURCE] = 'INVOICE'
		AND [RH].[ERP_DATE] BETWEEN @START_DATE AND @END_DATE
END