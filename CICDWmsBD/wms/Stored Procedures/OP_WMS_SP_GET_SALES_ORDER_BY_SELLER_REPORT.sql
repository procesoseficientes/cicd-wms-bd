-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	11/15/2017 @ NEXUS-Team Sprint F-Zero 
-- Description:			Nos da el reporte de ordenes de venta por vendedor.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_SALES_ORDER_BY_SELLER_REPORT]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_SALES_ORDER_BY_SELLER_REPORT](
	@START_DATETIME DATETIME
	,@END_DATETIME DATETIME
	,@CODE_WAREHOUSE VARCHAR(50)
	,@LOGIN VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @SALES_ORDER TABLE(
		[SALES_ORDER_ID] [INT] NOT NULL
		,[CLIENT_CODE] VARCHAR(50) NOT NULL
		,[POSTED_DATETIME] [DATETIME] NULL
		,[DELIVERY_DATETIME] DATETIME NULL
		,[SOURCE] VARCHAR(50) NOT NULL
		,[SELLER_CODE] VARCHAR(50) NULL
		,[SELLER_NAME] VARCHAR(50) NULL
		,[DOC_TOTAL] DECIMAL(18, 6) NULL
		,[OWNER] VARCHAR(50) NULL
		,[EXTERNAL_SOURCE_ID] INT NOT NULL
		,[SOURCE_NAME] VARCHAR(50) NOT NULL

		,PRIMARY KEY([SALES_ORDER_ID],[EXTERNAL_SOURCE_ID],[SOURCE])
	)

	-- -------------------------------------------------------------------------------------------
	-- Obtiene las ordenes de venta de Sonda
	-- ------------------------------------------------------------------------------------
	INSERT INTO @SALES_ORDER
	EXEC [wms].[OP_WMS_SP_GET_SONDA_SALES_ORDER_REPORT] 
		@START_DATETIME = @START_DATETIME, -- datetime
		@END_DATETIME = @END_DATETIME, -- datetime
		@CODE_WAREHOUSE = @CODE_WAREHOUSE -- varchar(50)

	-- ------------------------------------------------------------------------------------
	-- Obtiene las ordenes de venta de ERP
	-- ------------------------------------------------------------------------------------
	INSERT INTO @SALES_ORDER
	EXEC [wms].[OP_WMS_SP_GET_ERP_SALES_ORDER_REPORT] 
		@START_DATETIME = @START_DATETIME, -- datetime
		@END_DATETIME = @END_DATETIME, -- datetime
		@CODE_WAREHOUSE = @CODE_WAREHOUSE -- varchar(50)

	-- ------------------------------------------------------------------------------------
	-- Despliega el resultado final
	-- -----------------------------------------------------------------------------
	SELECT 
		[SO].[SALES_ORDER_ID]
        ,[SO].[CLIENT_CODE]
        ,[SO].[POSTED_DATETIME]
        ,[SO].[DELIVERY_DATETIME]
        ,[SO].[SOURCE]
        ,[SO].[SELLER_CODE]
        ,[SO].[SELLER_NAME]
        ,[SO].[DOC_TOTAL]
        ,[SO].[OWNER]
        ,[SO].[EXTERNAL_SOURCE_ID]
        ,[SO].[SOURCE_NAME] 
		,[DH].[WAVE_PICKING_ID]
		,CASE WHEN [DH].[PICKING_DEMAND_HEADER_ID] IS NULL THEN 0 ELSE 1 END [IN_PICKING_DEMAND]
		,MIN([TL].[IS_COMPLETED]) [TASK_IS_COMPLETED]
		,MIN([TL].[ACCEPTED_DATE]) [TASK_ACCEPTED_DATE]
		,MAX([TL].[COMPLETED_DATE]) [TASK_COMPLETED_DATE]
	FROM @SALES_ORDER [SO]
	LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH] ON [DH].[DOC_NUM] = [SO].[SALES_ORDER_ID] AND [DH].[EXTERNAL_SOURCE_ID] = [SO].[EXTERNAL_SOURCE_ID]
	LEFT JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON [TL].[WAVE_PICKING_ID] = [DH].[WAVE_PICKING_ID]
	GROUP BY [DH].[PICKING_DEMAND_HEADER_ID]
            ,[SO].[SALES_ORDER_ID]
            ,[SO].[CLIENT_CODE]
            ,[SO].[POSTED_DATETIME]
            ,[SO].[DELIVERY_DATETIME]
            ,[SO].[SOURCE]
            ,[SO].[SELLER_CODE]
            ,[SO].[SELLER_NAME]
            ,[SO].[DOC_TOTAL]
            ,[SO].[OWNER]
            ,[SO].[EXTERNAL_SOURCE_ID]
            ,[SO].[SOURCE_NAME]
            ,[DH].[WAVE_PICKING_ID]

	INSERT INTO [wms].[OP_WMS_LOG_REPORT]
	        (
	         [LOG_DATETIME]
	        ,[REPORT_NAME]
	        ,[PARAMETER_LOGIN]
	        ,[PARAMETER_WAREHOUSE]
	        ,[PARAMETER_START_DATETIME]
	        ,[PARAMETER_END_DATETIME]
	        ,[EXTRA_PARAMETER]
	        )
	VALUES
	        (
	         GETDATE()  -- LOG_DATETIME - datetime
	        ,'REPORTE PEDIDOS POR VENDEDOR'  -- REPORT_NAME - varchar(250)
	        ,@LOGIN  -- PARAMETER_LOGIN - varchar(50)
	        ,@CODE_WAREHOUSE  -- PARAMETER_WAREHOUSE - varchar(50)
	        ,@START_DATETIME  -- PARAMETER_START_DATETIME - datetime
	        ,@END_DATETIME  -- PARAMETER_END_DATETIME - datetime
	        ,NULL  -- EXTRA_PARAMETER - varchar(max)
	        )
END