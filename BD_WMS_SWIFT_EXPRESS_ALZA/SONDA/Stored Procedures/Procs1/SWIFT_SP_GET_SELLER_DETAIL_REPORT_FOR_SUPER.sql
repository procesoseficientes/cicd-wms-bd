-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/28/2018 @ GFORCE-Team Sprint Elefante 
-- Description:			Obtiene el resumen de pedidos y facturas detallado por vendedor para SONDA_SUPER

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_SELLER_DETAIL_REPORT_FOR_SUPER]
					@TEAM_ID = 2
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SELLER_DETAIL_REPORT_FOR_SUPER] (@TEAM_ID INT)
AS
BEGIN
    SET NOCOUNT ON;
	--
    DECLARE
        @CURRENCY VARCHAR(5)
       ,@DISPLAY_DECIMALS INT;
    DECLARE @RESULT TABLE
        (
         [TEAM_ID] INT
        ,[DOC_TYPE] VARCHAR(50)
        ,[SELLER_NAME] VARCHAR(100)
        ,[SELLER_PICTURE] VARCHAR(MAX)
        ,[LAST_UPDATE] DATETIME
        ,[DOCUMENT_QTY] INT
        ,[DOCUMENT_TOTAL] DECIMAL(18, 6)
        ,[CUSTOMER_QTY] INT
        ,[VISITED_CUSTOMERS] INT
        ,[PENDING_CUSTOMERS] INT
        ,[LOGIN] VARCHAR(50)
        );
	-- ------------------------------------------------------------------------------------
	-- Obtiene la moneda por defecto y la cantidad de decimales a mostrar
	-- ------------------------------------------------------------------------------------
    SELECT TOP 1
        @CURRENCY = [SYMBOL_CURRENCY]
       ,@DISPLAY_DECIMALS = [SONDA].[SWIFT_FN_GET_PARAMETER]('CALCULATION_RULES',
                                                             'DEFAULT_DISPLAY_DECIMALS')
    FROM
        [SONDA].[SWIFT_CURRENCY]
    WHERE
        [IS_DEFAULT] = 1;
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene datos de preventa
	-- ------------------------------------------------------------------------------------
    INSERT  INTO @RESULT
            (
             [TEAM_ID]
            ,[DOC_TYPE]
            ,[SELLER_NAME]
            ,[SELLER_PICTURE]
            ,[LAST_UPDATE]
            ,[DOCUMENT_QTY]
            ,[DOCUMENT_TOTAL]
            ,[CUSTOMER_QTY]
            ,[VISITED_CUSTOMERS]
            ,[PENDING_CUSTOMERS]
            ,[LOGIN]
	        )
    SELECT
        @TEAM_ID [TEAM_ID]
       ,[T].[TASK_TYPE] [DOC_TYPE]
       ,[U].[NAME_USER] [SELLER_NAME]
       ,[U].[IMAGE] [SELLER_PICTURE]
       ,MAX([SOH].[POSTED_DATETIME]) [LAST_UPDATE]
       ,COUNT([SOH].[SALES_ORDER_ID]) [DOCUMENT_QTY]
       ,SUM([SONDA].[SWIFT_FN_GET_SALES_ORDER_TOTAL]([SOH].[SALES_ORDER_ID])) [DOCUMENT_TOTAL]
       ,COUNT([T].[COSTUMER_CODE]) [CUSTOMER_QTY]
       ,COUNT(CASE [T].[TASK_STATUS]
                WHEN 'COMPLETED' THEN 1
                WHEN 'ACCEPTED' THEN 1
                ELSE NULL
              END) [VISITED_CUSTOMERS]
       ,COUNT(CASE [T].[TASK_STATUS]
                WHEN 'ASSIGNED' THEN 1
                ELSE NULL
              END) [PENDING_CUSTOMERS]
       ,[U].[LOGIN]
    FROM
        [SONDA].[SWIFT_TASKS] [T]
    INNER JOIN [SONDA].[USERS] [U] ON [T].[ASSIGEND_TO] = [U].[LOGIN]
    INNER JOIN [SONDA].[SWIFT_USER_BY_TEAM] [UT] ON [UT].[USER_ID] = [U].[CORRELATIVE]
    LEFT JOIN [SONDA].[SONDA_SALES_ORDER_HEADER] [SOH] ON [SOH].[TASK_ID] = [T].[TASK_ID]
                                                          AND [SOH].[IS_READY_TO_SEND] = 1
    WHERE
        [UT].[TEAM_ID] = @TEAM_ID
        AND FORMAT([T].[TASK_DATE], 'yyyyMMdd') = FORMAT(GETDATE(), 'yyyyMMdd')
        AND [T].[TASK_TYPE] = 'PRESALE'
    GROUP BY
        [T].[TASK_TYPE]
       ,[U].[NAME_USER]
       ,[U].[IMAGE]
       ,[U].[LOGIN]
    HAVING
        COUNT([T].[TASK_ID]) > 0;

	-- ------------------------------------------------------------------------------------
	-- Obtiene datos de venta
	-- ------------------------------------------------------------------------------------
    SELECT
        [U].[LOGIN]
       ,COUNT([SPH].[INVOICE_ID]) [DOCUMENT_QTY]
       ,SUM([SPH].[TOTAL_AMOUNT]) [DOCUMENT_TOTAL]
       ,MAX([SPH].[POSTED_DATETIME]) [LAST_UPDATE]
    INTO
        [#INVOICES]
    FROM
        [SONDA].[SONDA_POS_INVOICE_HEADER] [SPH]
    INNER JOIN [SONDA].[USERS] [U] ON [SPH].[POSTED_BY] = [U].[LOGIN]
    INNER JOIN [SONDA].[SWIFT_USER_BY_TEAM] [UT] ON [UT].[USER_ID] = [U].[CORRELATIVE]
    WHERE
        [UT].[TEAM_ID] = @TEAM_ID
        AND FORMAT([SPH].[POSTED_DATETIME], 'yyyyMMdd') = FORMAT(GETDATE(),
                                                              'yyyyMMdd')
        AND [SPH].[IS_READY_TO_SEND] = 1
    GROUP BY
        [U].[LOGIN];

    INSERT  INTO @RESULT
            (
             [TEAM_ID]
            ,[DOC_TYPE]
            ,[SELLER_NAME]
            ,[SELLER_PICTURE]
            ,[LAST_UPDATE]
            ,[DOCUMENT_QTY]
            ,[DOCUMENT_TOTAL]
            ,[CUSTOMER_QTY]
            ,[VISITED_CUSTOMERS]
            ,[PENDING_CUSTOMERS]
            ,[LOGIN]
	        )
    SELECT
        @TEAM_ID [TEAM_ID]
       ,[T].[TASK_TYPE] [DOC_TYPE]
       ,[U].[NAME_USER] [SELLER_NAME]
       ,[U].[IMAGE] [SELLER_PICTURE]
       ,[I].[LAST_UPDATE]
       ,[I].[DOCUMENT_QTY]
       ,[I].[DOCUMENT_TOTAL]
       ,COUNT([T].[COSTUMER_CODE]) [CUSTOMER_QTY]
       ,COUNT(CASE [T].[TASK_STATUS]
                WHEN 'COMPLETED' THEN 1
                WHEN 'ACCEPTED' THEN 1
                ELSE NULL
              END) [VISITED_CUSTOMERS]
       ,COUNT(CASE [T].[TASK_STATUS]
                WHEN 'ASSIGNED' THEN 1
                ELSE NULL
              END) [PENDING_CUSTOMERS]
       ,[U].[LOGIN]
    FROM
        [SONDA].[SWIFT_TASKS] [T]
    INNER JOIN [SONDA].[USERS] [U] ON [T].[ASSIGEND_TO] = [U].[LOGIN]
    INNER JOIN [SONDA].[SWIFT_USER_BY_TEAM] [UT] ON [UT].[USER_ID] = [U].[CORRELATIVE]
    INNER JOIN [#INVOICES] [I] ON [I].[LOGIN] = [U].[LOGIN]
    WHERE
        [UT].[TEAM_ID] = @TEAM_ID
        AND FORMAT([T].[TASK_DATE], 'yyyyMMdd') = FORMAT(GETDATE(), 'yyyyMMdd')
        AND [T].[TASK_TYPE] = 'SALE'
    GROUP BY
        [T].[TASK_TYPE]
       ,[U].[NAME_USER]
       ,[U].[IMAGE]
       ,[I].[LAST_UPDATE]
       ,[I].[DOCUMENT_QTY]
       ,[I].[DOCUMENT_TOTAL]
       ,[U].[LOGIN]
    HAVING
        COUNT([T].[TASK_ID]) > 0;;

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado final
	-- ------------------------------------------------------------------------------------
    SELECT
        [TEAM_ID]
       ,[DOC_TYPE]
       ,[SELLER_NAME]
       ,[SELLER_PICTURE]
       ,ISNULL([LAST_UPDATE], DATEADD(d, DATEDIFF(d, 0, GETDATE()), 0)) [LAST_UPDATE]
       ,[DOCUMENT_QTY]
       ,ISNULL([DOCUMENT_TOTAL], 0) [DOCUMENT_TOTAL]
       ,[CUSTOMER_QTY]
       ,[VISITED_CUSTOMERS]
       ,[PENDING_CUSTOMERS]
       ,@CURRENCY [CURRENCY]
       ,@DISPLAY_DECIMALS [DECIMALS]
	   ,[LOGIN]
    FROM
        @RESULT
    ORDER BY
        [DOCUMENT_TOTAL] DESC;
END;
