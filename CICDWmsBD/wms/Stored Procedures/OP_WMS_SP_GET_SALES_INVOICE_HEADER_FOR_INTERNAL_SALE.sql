-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	8/23/2017 @ NEXUS-Team Sprint CommandAndConquer 
-- Description:			

-- Modificacion 08-Sep-17 @ Nexus Team Sprint CommandAndConquer
					-- alberto.ruiz
					-- Se agrego el campo de last update

-- Modificacion 10/25/2017 @ NEXUS-Team Sprint ewms
					-- rodrigo.gomez
					-- Se agrega DocEntry y FactSerie al envio de encabezados facturas de compra

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_SALES_INVOICE_HEADER_FOR_INTERNAL_SALE]
					@PICKING_HEADER_ID = 6610, -- int
					@OWNER = 'motorganica', -- varchar(50)
					@INTERNAL_SALE_OWNER = 'motorganica' -- varchar(50)
				--
				EXEC [wms].[OP_WMS_SP_GET_SALES_INVOICE_HEADER_FOR_INTERNAL_SALE]
					@PICKING_HEADER_ID = 5229, -- int
					@OWNER = 'viscosa', -- varchar(50)
					@INTERNAL_SALE_OWNER = 'motorganica' -- varchar(50)
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_SALES_INVOICE_HEADER_FOR_INTERNAL_SALE](
	@PICKING_HEADER_ID INT
	,@OWNER	VARCHAR(50)
	,@INTERNAL_SALE_OWNER VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @SERIAL_NUMBER VARCHAR(25);
	--
	SELECT @SERIAL_NUMBER = [FACT_SERIE]
	FROM [wms].[OP_WMS_COMPANY]
	WHERE @OWNER = [COMPANY_NAME]
	--
	DECLARE @SALE_INVOICES TABLE (
		[DEMAND_HEADER_ID] INT
		,[OWNER] VARCHAR(50)
		,[DOC_ENTRY] INT
	)
	--
	IF(@OWNER != @INTERNAL_SALE_OWNER)
	BEGIN
		SELECT	
			@PICKING_HEADER_ID HEADER_ID
			,[CI].[CARD_CODE] [CODE_CLIENT]
			,[CI].[CARD_NAME]
			,[C].[CODE_PRICE_LIST]
			,[CI].[LICTRADNUM] [TAX_ID]
			,GETDATE() [DocDate]
			,@SERIAL_NUMBER [SERIAL_NUMBER]
			,GETDATE() [LAST_UPDATE]
		FROM [wms].[OP_WMS_COMPANY] [C]
			INNER JOIN [wms].[OP_WMS_CUSTOMER_INTERCOMPANY] [CI] ON [CI].[MASTER_ID] = [C].[MASTER_ID_CLIENT_CODE] AND [CI].[SOURCE] = @OWNER
		WHERE [COMPANY_NAME] = @INTERNAL_SALE_OWNER AND [C].[COMPANY_ID] > 0
	END
	ELSE
	BEGIN
		INSERT INTO @SALE_INVOICES
		SELECT DISTINCT	
			[PICKING_DEMAND_HEADER_ID],
			[MATERIAL_OWNER],
			CAST([wms].[OP_WMS_FN_SPLIT_COLUMNS](REPLACE([INNER_SALE_RESPONSE],';',' '),5,' ') AS INT)
		FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL]
		WHERE [PICKING_DEMAND_HEADER_ID] = @PICKING_HEADER_ID
		--
		SELECT	
			@PICKING_HEADER_ID HEADER_ID
			,[CI].[CARD_CODE] [CODE_CLIENT]
			,[CI].[CARD_NAME]
			,[C].[CODE_PRICE_LIST]
			,[CI].[LICTRADNUM] [TAX_ID]
			,GETDATE() [DocDate]
			,[C].[COMPANY_NAME] [OWNER]
			,GETDATE() [LAST_UPDATE]
			,[C].[FACT_SERIE] [UFacSerie]
			,[SI].[DOC_ENTRY] [DocEntry]
		FROM [wms].[OP_WMS_COMPANY] [C]
			INNER JOIN [wms].[OP_WMS_CUSTOMER_INTERCOMPANY] [CI] ON [CI].[MASTER_ID] = [C].[MASTER_ID_SUPPLIER] AND [CI].[SOURCE] = @OWNER
			INNER JOIN @SALE_INVOICES [SI] ON [SI].[OWNER] = [C].[COMPANY_NAME]
		WHERE [C].[COMPANY_ID] > 0
		AND [C].[COMPANY_NAME] <> @OWNER
	END
	--
END