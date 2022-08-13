-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	4/12/2018 @ GForce-Team Sprint Buho
-- Description:			Consulta en inventario las ordenes de venta preparadas por los filtros enviados

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_PREPARED_SALES_ORDER_TO_DISPATCH_SONDA]
					@START_DATETIME = '2018-04-05 22:30:02', -- datetime
					@END_DATETIME = '2018-04-05 22:30:02', -- datetime
					@SOURCE_CODE_ROUTE = '', -- varchar(max)
					@CODE_ROUTE = '', -- varchar(max)
					@CODE_WAREHOUSE = '' -- varchar(25)
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_PREPARED_SALES_ORDER_TO_DISPATCH_SONDA]
    (
     @START_DATETIME DATETIME
    ,@END_DATETIME DATETIME
    ,@SOURCE_CODE_ROUTE VARCHAR(MAX)
    ,@CODE_ROUTE VARCHAR(MAX)
    ,@CODE_WAREHOUSE VARCHAR(25)
    )
AS
BEGIN
    SET NOCOUNT ON;
	--
    DECLARE @DELIMITER CHAR(1) = '|';
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene las rutas del filtro
	-- ------------------------------------------------------------------------------------
    SELECT
        [SCR].[ID] [ORDER]
       ,CAST([SCR].[VALUE] AS INT) [EXTERNAL_SOURCE_ID]
       ,[CR].[VALUE] [CODE_ROUTE]
    INTO
        [#ROUTE]
    FROM
        [wms].[OP_WMS_FN_SPLIT](@SOURCE_CODE_ROUTE, @DELIMITER) [SCR]
    INNER JOIN [wms].[OP_WMS_FN_SPLIT](@CODE_ROUTE, @DELIMITER) [CR] ON ([CR].[ID] = [SCR].[ID]);
	
	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado final
	-- ------------------------------------------------------------------------------------
    SELECT DISTINCT
        [PDH].[PICKING_DEMAND_HEADER_ID]
       ,[PDH].[DOC_NUM] [SALES_ORDER_ID]
       ,[PDH].[CREATED_DATE] [POSTED_DATETIME]
       ,[PDH].[CLIENT_CODE] [CLIENT_ID]
       ,[PDH].[CLIENT_NAME] [CUSTOMER_NAME]
       ,[PDH].[TOTAL_AMOUNT] [TOTAL_AMOUNT]
       ,[R].[CODE_ROUTE] [CODE_ROUTE]
       ,[PDH].[CODE_SELLER] [LOGIN]
       ,[PDH].[SERIAL_NUMBER] [DOC_SERIE]
       ,[PDH].[DOC_NUM] [DOC_NUM]
       ,'' [COMMENT]
       ,[ES].[EXTERNAL_SOURCE_ID]
       ,[ES].[SOURCE_NAME]
       ,[PDH].[IS_FROM_SONDA]
       ,[PDH].[SELLER_OWNER]
       ,[PDH].[MASTER_ID_SELLER]
       ,[PDH].[CODE_SELLER]
       ,[PDH].[CLIENT_OWNER]
       ,[PDH].[CLIENT_CODE] [MASTER_ID_CLIENT]
       ,[PDH].[OWNER]
       ,[PDH].[DEMAND_DELIVERY_DATE] [DELIVERY_DATE]
       ,'SO - SONDA' [SOURCE]
       ,[PDH].[ADDRESS_CUSTOMER]
       ,[PDH].[DISCOUNT]
	   ,[PDH].[IS_FROM_ERP]
    FROM
        [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
    INNER JOIN [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES] ON [ES].[EXTERNAL_SOURCE_ID] = [PDH].[EXTERNAL_SOURCE_ID]
    INNER JOIN [#ROUTE] [R] ON [R].[CODE_ROUTE] = [PDH].[CODE_ROUTE]
                               AND [R].[EXTERNAL_SOURCE_ID] = [PDH].[EXTERNAL_SOURCE_ID]
    INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON [TL].[WAVE_PICKING_ID] = [PDH].[WAVE_PICKING_ID]
    WHERE
        [PDH].[IS_FROM_SONDA] = 1
        AND [PDH].[IS_FOR_DELIVERY_IMMEDIATE] = 0
        AND [PDH].[DEMAND_DELIVERY_DATE] BETWEEN @START_DATETIME
                                         AND     @END_DATETIME
        AND [PDH].[CODE_WAREHOUSE] = @CODE_WAREHOUSE
        AND [TL].[IS_COMPLETED] = 1
        AND ISNULL([PDH].[TRANSFER_REQUEST_ID], 0) = 0;
END;