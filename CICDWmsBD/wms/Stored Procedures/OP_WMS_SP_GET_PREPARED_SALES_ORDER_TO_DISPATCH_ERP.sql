-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	4/12/2018 @ GForce-Team Sprint Buho
-- Description:			consultar en inventario las ordenes de ventas preparados por los filtros enviados

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_PREPARED_SALES_ORDER_TO_DISPATCH_ERP]
					@START_DATETIME = '2018-04-12 12:29:19.477',
					@END_DATETIME = '2018-04-12 12:29:19.477',
					@CLIENTS = '',
					@CODE_WAREHOUSE = ''
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_PREPARED_SALES_ORDER_TO_DISPATCH_ERP] (
		@START_DATETIME DATETIME
		,@END_DATETIME DATETIME
		,@CLIENTS VARCHAR(MAX)
		,@CODE_WAREHOUSE VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SET NOCOUNT ON;
	--
	DECLARE	@DELIMITER CHAR(1) = '|';
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene las rutas del filtro
	-- ------------------------------------------------------------------------------------
	SELECT
		[C].[ID] [ORDER]
		,[C].[VALUE] [CLIENT_ID]
	INTO
		[#CLIENT]
	FROM
		[wms].[OP_WMS_FN_SPLIT](@CLIENTS, @DELIMITER) [C];

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado final
	-- ------------------------------------------------------------------------------------
	SELECT DISTINCT
		[PDH].[PICKING_DEMAND_HEADER_ID]
		,[PDH].[DOC_NUM] [SALES_ORDER_ID]
		,MAX([PDH].[CREATED_DATE]) [POSTED_DATETIME]
		,MAX([PDH].[CLIENT_CODE]) [CLIENT_ID]
		,MAX([PDH].[CLIENT_NAME]) [CUSTOMER_NAME]
		,MAX([PDH].[TOTAL_AMOUNT]) [TOTAL_AMOUNT]
		,MAX([PDH].[CODE_ROUTE]) [CODE_ROUTE]
		,MAX([PDH].[CODE_SELLER]) [LOGIN]
		,MAX([PDH].[SERIAL_NUMBER]) [DOC_SERIE]
		,[PDH].[DOC_NUM] [DOC_NUM]
		,'' [COMMENT]
		,MAX([ES].[EXTERNAL_SOURCE_ID]) [EXTERNAL_SOURCE_ID]
		,MAX([ES].[SOURCE_NAME]) [SOURCE_NAME]
		,MAX([PDH].[IS_FROM_SONDA]) [IS_FROM_SONDA]
		,MAX([PDH].[SELLER_OWNER]) [SELLER_OWNER]
		,MAX([PDH].[MASTER_ID_SELLER]) [MASTER_ID_SELLER]
		,MAX([PDH].[CODE_SELLER]) [CODE_SELLER]
		,MAX([PDH].[CLIENT_OWNER]) [CLIENT_OWNER]
		,MAX([PDH].[CLIENT_CODE]) [MASTER_ID_CLIENT]
		,MAX([PDH].[OWNER]) [OWNER]
		,MAX([PDH].[DEMAND_DELIVERY_DATE]) [DELIVERY_DATE]
		,'SO - ERP' [SOURCE]
		,MAX([PDH].[ADDRESS_CUSTOMER]) [ADDRESS_CUSTOMER]
		,MAX([PDH].[DISCOUNT]) [DISCOUNT]
		,MAX([PDH].[IS_FROM_ERP]) [IS_FROM_ERP]
		,[PDH].[DOC_ENTRY] [DOC_ENTRY]
	FROM
		[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
	INNER JOIN [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES] ON [ES].[EXTERNAL_SOURCE_ID] = [PDH].[EXTERNAL_SOURCE_ID]
	INNER JOIN [#CLIENT] [C] ON [C].[CLIENT_ID] = [PDH].[CLIENT_CODE]
	INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON [TL].[WAVE_PICKING_ID] = [PDH].[WAVE_PICKING_ID]
	WHERE
		[PDH].[IS_FROM_ERP] = 1
		AND [PDH].[IS_FOR_DELIVERY_IMMEDIATE] = 0
		AND [PDH].[DEMAND_DELIVERY_DATE] BETWEEN @START_DATETIME
											AND
											@END_DATETIME
		AND [PDH].[CODE_WAREHOUSE] = @CODE_WAREHOUSE
		AND ISNULL([PDH].[TRANSFER_REQUEST_ID], 0) = 0
	GROUP BY
		[PDH].[PICKING_DEMAND_HEADER_ID]
		,[PDH].[DOC_NUM]
		,[PDH].[DOC_ENTRY]
	HAVING
		MIN([TL].[IS_COMPLETED]) = 1;



			


END;