-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	06-04-2016
-- Description:			obtien orden de venta para interfaz

-- Modificado 2016-05-13
		-- hector.gonzalez
		-- Se agrego al WHERE una linea para que no tomara en cuenta los DRAFT 

-- Modificacion 2/7/2017 @ A-Team Sprint Chatuluka
		-- rodrigo.gomez
		-- Se agrego la columna ORGVENTAS

-- Modificacion 28-Feb-17 @ A-Team Sprint Donkor
					-- alberto.ruiz
					-- Se agrego el campo de organiacion y oficina de ventas desde los vendedores

/*
-- Ejemplo de Ejecucion:
        USE SWIFT_EXPRESS
        GO
        --
        EXEC [SONDA].[SWIFT_SP_GET_SALE_ORDER_HEADER]
			@idOrdenDeVenta = '5160'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_SALE_ORDER_HEADER (
@idOrdenDeVenta INT
) AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @CODE_CUSTOMER VARCHAR(50) = 'C.F.'
         ,@NAME_CUSTOMER VARCHAR(100) = 'Consumidor Final'
         ,@TAX_ID_NUMBER VARCHAR(20) = 'CF'
         ,@ADRESS_CUSTOMER VARCHAR(MAX) = 'CIUDAD'
         ,@SALES_ORDER_TYPE VARCHAR(250)
         ,@SEND_SALES_ORDER_TO_DELIVERY_DATE INT

	-- ------------------------------------------------------------------------------------
	-- Obtiene los parametros necesarios
	-- ------------------------------------------------------------------------------------
	SELECT
		@CODE_CUSTOMER = [svac].[CODE_CUSTOMER]
		,@NAME_CUSTOMER = [svac].[NAME_CUSTOMER]
		,@TAX_ID_NUMBER = [svac].[TAX_ID_NUMBER]
		,@ADRESS_CUSTOMER = [svac].[ADRESS_CUSTOMER]
	FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [svac]
	INNER JOIN [SONDA].[SWIFT_PARAMETER] [sp] ON (
		[sp].[VALUE] = [svac].[CODE_CUSTOMER]
		AND [sp].[GROUP_ID] = 'ERP_HARDCODE_VALUES'
		AND [sp].[PARAMETER_ID] = 'DEFAULT_CUSTOMER'
	);
	--
	SELECT
		@SALES_ORDER_TYPE = [SONDA].[SWIFT_FN_GET_PARAMETER]('SALES_ORDER_TYPE', 'CASH')
		,@SEND_SALES_ORDER_TO_DELIVERY_DATE = [SONDA].[SWIFT_FN_GET_PARAMETER]('SALES_ORDER', 'SEND_SALES_ORDER_TO_DELIVERY_DATE')

	-- ------------------------------------------------------------------------------------
	-- Obtiene la orden de venta
	-- ------------------------------------------------------------------------------------
	SELECT
		[SSOH].[SALES_ORDER_ID]
		,[SSOH].[TERMS]
		,[SSOH].[POSTED_DATETIME]
		,[SSOH].[CLIENT_ID]
		,[SSOH].[POS_TERMINAL]
		,[SSOH].[GPS_URL]
		,[SSOH].[TOTAL_AMOUNT]
		,[SSOH].[STATUS]
		,[SSOH].[POSTED_BY]
		,'' [IMAGE_1]
		,'' [IMAGE_2]
		,'' [IMAGE_3]
		,[SSOH].[DEVICE_BATTERY_FACTOR]
		,[SSOH].[VOID_DATETIME]
		,[SSOH].[VOID_REASON]
		,[SSOH].[VOID_NOTES]
		,[SSOH].[VOIDED]
		,[SSOH].[CLOSED_ROUTE_DATETIME]
		,[SSOH].[IS_ACTIVE_ROUTE]
		,[SSOH].[GPS_EXPECTED]
		,[SSOH].[DELIVERY_DATE]
		,[SSOH].[SALES_ORDER_ID_HH]
		,[SSOH].[ATTEMPTED_WITH_ERROR]
		,[SSOH].[IS_POSTED_ERP]
		,[SSOH].[POSTED_ERP]
		,[SSOH].[POSTED_RESPONSE]
		,[SSOH].[IS_PARENT]
		,[SSOH].[REFERENCE_ID]
		,[SW].[ERP_WAREHOUSE] [WAREHOUSE]
		,[SSOH].[TIMES_PRINTED]
		,CASE [SSOH].[IS_PARENT]
			WHEN 1 THEN [SVAC].[CODE_CUSTOMER]
			WHEN 0 THEN @CODE_CUSTOMER
		END AS [CODE_CUSTOMER]
		,CASE [SSOH].[IS_PARENT]
			WHEN 1 THEN [SVAC].[NAME_CUSTOMER]
			WHEN 0 THEN @NAME_CUSTOMER
		-- ELSE
		END AS [NAME_CUSTOMER]
		,CASE [SSOH].[IS_PARENT]
			WHEN 1 THEN [SVAC].[TAX_ID_NUMBER]
			WHEN 0 THEN @TAX_ID_NUMBER
		END [TAX_ID_NUMBER]
		,CASE [SSOH].[IS_PARENT]
			WHEN 1 THEN [SVAC].[ADRESS_CUSTOMER]
			WHEN 0 THEN [ADRESS_CUSTOMER]
		END AS [ADRESS_CUSTOMER]
		,[U].[RELATED_SELLER] [SALES_PERSON_CODE]
		,CASE [SSOH].[SALES_ORDER_TYPE]
			WHEN @SALES_ORDER_TYPE THEN '**CONTADO**'
			ELSE NULL
		END [SALES_ORDER_TYPE]
		,[SSOH].[DISCOUNT]
		,[SO].[NAME_SALES_OFFICE] [OFIVENTAS]
		,[ORG].[NAME_SALES_ORGANIZATION] [ORGVENTAS]
		,[SVAC].[RUTAVENTAS]
		,[SVAC].[RUTAENTREGA]
		,CASE	WHEN ISNULL([SVAC].[RUTAVENTAS], '..') = '..'
				THEN NULL
				ELSE [SVAC].[RUTAVENTAS] + RIGHT('000000' + CONVERT(VARCHAR(6), [SVAC].[SECUENCIA]), 6)
		END AS [NUM_AT_CARD]
		,'S' AS [SONDA]
		,[SSOH].[COMMENT]
		,[SONDA].[SWIFT_FN_VALIDATE_IS_SCOUTING]([SSOH].[CLIENT_ID]) AS [IS_SCOUTING]
		,[SVAC].[EXTRA_DAYS]
		,[SVAC].[PAYMENT_CONDITIONS]
	FROM [SONDA].[SONDA_SALES_ORDER_HEADER] [SSOH]
	INNER JOIN [SONDA].[SWIFT_WAREHOUSES] [SW] ON ([SSOH].[WAREHOUSE] = [SW].[CODE_WAREHOUSE])
	LEFT JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [SVAC] ON ([SSOH].[CLIENT_ID] = [SVAC].[CODE_CUSTOMER])
	INNER JOIN [SONDA].[USERS] [U] ON ([SSOH].[POSTED_BY] = [U].[LOGIN])
	LEFT JOIN [SONDA].[SWIFT_SELLER] [S] ON ([U].[RELATED_SELLER] = [S].[SELLER_CODE])
	LEFT JOIN [SONDA].[SWIFT_SALES_OFFICE] [SO] ON ([SO].[SALES_OFFICE_ID] = [S].[SALES_OFFICE_ID])
	LEFT JOIN [SONDA].[SWIFT_SALES_ORGANIZATION] [ORG] ON ([ORG].[SALES_ORGANIZATION_ID] = [SO].[SALES_ORGANIZATION_ID])
	WHERE
		[SSOH].[SALES_ORDER_ID] = @idOrdenDeVenta
		AND ISNULL([SSOH].[IS_VOID], 0) = 0
		AND ISNULL([SSOH].[IS_DRAFT], 0) = 0
		AND [SSOH].IS_READY_TO_SEND=1
	ORDER BY [POSTED_DATETIME] ASC;
END
