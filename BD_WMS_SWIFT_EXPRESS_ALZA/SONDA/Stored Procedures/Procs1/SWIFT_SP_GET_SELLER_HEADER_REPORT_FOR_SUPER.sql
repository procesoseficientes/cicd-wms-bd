-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/28/2018 @ GFORCE-Team Sprint Elefante
-- Description:			Obtiene el encabezado de resumen de pedidos para SONDA_SUPER

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_SELLER_HEADER_REPORT_FOR_SUPER]
					@TEAM_ID = 2
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SELLER_HEADER_REPORT_FOR_SUPER] (@TEAM_ID INT)
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
        ,[SUPER_NAME] VARCHAR(100)
        ,[TEAM_NAME] VARCHAR(100)
        ,[DOCUMENT_QTY] INT
        ,[DOCUMENT_TOTAL] DECIMAL(18, 6)
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
	-- Obtiene las ordenes de venta puestas
	-- ------------------------------------------------------------------------------------
    INSERT  INTO @RESULT
            (
             [TEAM_ID]
            ,[SUPER_NAME]
            ,[TEAM_NAME]
            ,[DOCUMENT_QTY]
            ,[DOCUMENT_TOTAL]
	        )
    SELECT
        @TEAM_ID [TEAM_ID]
       ,[S].[NAME_USER] [SUPER_NAME]
       ,[T].[NAME_TEAM] [TEAM_NAME]
       ,COUNT([SOH].[SALES_ORDER_ID]) [DOCUMENT_QTY]
       ,SUM([SONDA].[SWIFT_FN_GET_SALES_ORDER_TOTAL]([SOH].[SALES_ORDER_ID])) [DOCUMENT_TOTAL]
    FROM
        [SONDA].[SONDA_SALES_ORDER_HEADER] [SOH]
    INNER JOIN [SONDA].[SWIFT_TASKS] [TS] ON [TS].[TASK_ID] = [SOH].[TASK_ID]
    INNER JOIN [SONDA].[USERS] [U] ON [SOH].[POSTED_BY] = [U].[LOGIN]
    INNER JOIN [SONDA].[SWIFT_USER_BY_TEAM] [UT] ON [UT].[USER_ID] = [U].[CORRELATIVE]
    INNER JOIN [SONDA].[SWIFT_TEAM] [T] ON [T].[TEAM_ID] = [UT].[TEAM_ID]
    INNER JOIN [SONDA].[USERS] [S] ON [S].[CORRELATIVE] = [T].[SUPERVISOR]
    WHERE
        [UT].[TEAM_ID] = @TEAM_ID
        AND FORMAT([TS].[TASK_DATE], 'yyyyMMdd') = FORMAT(GETDATE(),
                                                              'yyyyMMdd')
        AND [SOH].[IS_READY_TO_SEND] = 1
    GROUP BY
        [S].[NAME_USER]
       ,[T].[NAME_TEAM];

	-- ------------------------------------------------------------------------------------
	-- Obtiene las facturas
	-- ------------------------------------------------------------------------------------
    INSERT  INTO @RESULT
            (
             [TEAM_ID]
            ,[SUPER_NAME]
            ,[TEAM_NAME]
            ,[DOCUMENT_QTY]
            ,[DOCUMENT_TOTAL]
	        )
    SELECT
        @TEAM_ID [TEAM_ID]
       ,[S].[NAME_USER] [SUPER_NAME]
       ,[T].[NAME_TEAM] [TEAM_NAME]
       ,COUNT([SPH].[INVOICE_ID]) [DOCUMENT_QTY]
       ,SUM([SPH].[TOTAL_AMOUNT]) [DOCUMENT_TOTAL]
    FROM
        [SONDA].[SONDA_POS_INVOICE_HEADER] [SPH]
    INNER JOIN [SONDA].[USERS] [U] ON [SPH].[POSTED_BY] = [U].[LOGIN]
    INNER JOIN [SONDA].[SWIFT_USER_BY_TEAM] [UT] ON [UT].[USER_ID] = [U].[CORRELATIVE]
    INNER JOIN [SONDA].[SWIFT_TEAM] [T] ON [T].[TEAM_ID] = [UT].[TEAM_ID]
    INNER JOIN [SONDA].[USERS] [S] ON [S].[CORRELATIVE] = [T].[SUPERVISOR]
    WHERE
        [UT].[TEAM_ID] = @TEAM_ID
        AND FORMAT([SPH].[POSTED_DATETIME], 'yyyyMMdd') = FORMAT(GETDATE(),
                                                              'yyyyMMdd')
        AND [SPH].[IS_READY_TO_SEND] = 1
    GROUP BY
        [S].[NAME_USER]
       ,[T].[NAME_TEAM];

	-- ------------------------------------------------------------------------------------
	-- Inserta un registro con 0 si aun no han facturado o han enviado ningun pedido
	-- ------------------------------------------------------------------------------------
    INSERT  INTO @RESULT
            (
             [TEAM_ID]
            ,[SUPER_NAME]
            ,[TEAM_NAME]
            ,[DOCUMENT_QTY]
            ,[DOCUMENT_TOTAL]
	        )
    SELECT
        @TEAM_ID [TEAM_ID]
       ,[U].[NAME_USER] [SUPER_NAME]
       ,[T].[NAME_TEAM] [TEAM_NAME]
       ,0 [DOCUMENT_QTY]
       ,0 [DOCUMENT_TOTAL]
    FROM
        [SONDA].[SWIFT_TEAM] [T]
    INNER JOIN [SONDA].[USERS] [U] ON [U].[CORRELATIVE] = [T].[SUPERVISOR]
    WHERE
        [T].[TEAM_ID] = @TEAM_ID;
	-- ------------------------------------------------------------------------------------
	-- Resultado final
	-- ------------------------------------------------------------------------------------
    SELECT
        [TEAM_ID]
       ,[SUPER_NAME]
       ,[TEAM_NAME]
       ,SUM([DOCUMENT_QTY]) [DOCUMENT_QTY]
       ,SUM([DOCUMENT_TOTAL]) [DOCUMENT_TOTAL]
       ,@CURRENCY [CURRENCY]
       ,@DISPLAY_DECIMALS AS [DECIMALS]
    FROM
        @RESULT
    GROUP BY
        [TEAM_ID]
       ,[SUPER_NAME]
       ,[TEAM_NAME];
END;
