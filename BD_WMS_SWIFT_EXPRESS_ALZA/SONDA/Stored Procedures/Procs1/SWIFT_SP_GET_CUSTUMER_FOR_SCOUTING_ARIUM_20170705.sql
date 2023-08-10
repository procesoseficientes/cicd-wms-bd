-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	11-09-2015
-- Description:			SP para obtener los clientes que se le puede hacer scouting por ruta


-- Modificado 11-09-2015
		-- joel.delcompare
		-- Por motivo de que se estaban tomando todos los clientes ahora en adelante se toman solo los clientes de ese vendedor en especifico

-- Modificado 11-11-2015
		-- rudi.garcia
		-- Se agregro que trajiera los clientes de las tareas generadas

-- Modificado 22-02-2016
		-- alberto.ruiz
		-- Se agrego el campo de limite de credito

-- Modificado 27-02-2016
		-- rudi.garcia
		-- Se agrego el campo dias de credito

-- Modificado 06-04-2016
		-- hector.gonzalez
		-- Se agrego el campo DISCOUNT

-- Modificacion 15-07-2016
					-- alberto.ruiz
					-- Se agrago campo de gps

-- Modificacion 25-Oct-16 @ A-Team Sprint 3
					-- alberto.ruiz
					-- Se agrego el replace en la direccion del cliente para quitar el caracter "

-- Modificacion 29-Nov-16 @ A-Team Sprint 5
					-- rudi.garcia
					-- Se agrego el campo RGA_CODE

-- Modificacion 12-Dec-16 @ A-Team Sprint 6
					-- alberto.ruiz
					-- Se agregaron los campos de la lista de descuento y lista de bonificacion

-- Modificacion 26-Dec-16 @ A-Team Sprint Balder
					-- rodrigo.gomez
					-- Se agregaron el campo de la lista de precios

-- Modificacion 08-Feb-17 @ A-Team Sprint Chatuluka
					-- alberto.ruiz
					-- Se agrego el campo de lista de venta por multiplo

-- Modificacion 4/20/2017 @ A-Team Sprint Hondo
					-- diego.as
					-- Se agregan las columnas LAST_PURCHASE y PREVIUS_BALANCE

-- Modificacion 03-May-17 @ A-Team Sprint Hondo
					-- alberto.ruiz
					-- Se coloco que obtenga las listas de precios de la tabla SWIFT_PRICE_LIST_BY_CUSTOMER_FOR_ROUTE y se ajusto como obtiene la lista de precios por defecto para que tome en cuenta la que puede tener configurada el usuario

/*
-- Ejemplo de Ejecucion:
        exec [SONDA].[SWIFT_SP_GET_CUSTUMER_FOR_SCOUTING] @CODE_ROUTE = 'ES000035'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_CUSTUMER_FOR_SCOUTING_ARIUM_20170705] (
	@CODE_ROUTE varchar(50)
) AS
BEGIN
--
	DECLARE @DEFAULT_PRICE_LIST VARCHAR(25)
	--
	DECLARE	@CUSTOMER TABLE (
		[CODE_CUSTOMER] VARCHAR(50)
		,[NAME_CUSTOMER] VARCHAR(250)
		,[TAX_ID_NUMBER] VARCHAR(3)
		,[ADRESS_CUSTOMER] VARCHAR(250)
		,[PHONE_CUSTOMER] VARCHAR(250)
		,[CONTACT_CUSTOMER] VARCHAR(250)
		,[CREDIT_LIMIT] NUMERIC(18 ,6)
		,[EXTRA_DAYS] INT
		,[DISCOUNT] NUMERIC(18 ,6)
		,[GPS] VARCHAR(250)
		,[RGA_CODE] VARCHAR(150)
		,[DISCOUNT_LIST_ID] INT
		,[BONUS_LIST_ID] INT
		,[PRICE_LIST_ID] VARCHAR(50)
		,[SALES_BY_MULTIPLE_LIST_ID] INT
		,[PREVIUS_BALANCE] DECIMAL(18,6)
		,[LAST_PURCHASE] NUMERIC(18,6)
	);
	--
	DECLARE	@RESULT TABLE (
		[CODE_CUSTOMER] VARCHAR(50)
		,[NAME_CUSTOMER] VARCHAR(250)
		,[TAX_ID_NUMBER] VARCHAR(3)
		,[ADRESS_CUSTOMER] VARCHAR(250)
		,[PHONE_CUSTOMER] VARCHAR(250)
		,[CONTACT_CUSTOMER] VARCHAR(250)
		,[CREDIT_LIMIT] NUMERIC(18 ,6)
		,[EXTRA_DAYS] INT
		,[DISCOUNT] NUMERIC(18 ,6)
		,[GPS] VARCHAR(250)
		,[RGA_CODE] VARCHAR(150)
		,[DISCOUNT_LIST_ID] INT
		,[BONUS_LIST_ID] INT
		,[PRICE_LIST_ID] VARCHAR(50)
		,[SALES_BY_MULTIPLE_LIST_ID] INT
		,[PREVIUS_BALANCE] DECIMAL(18,6)
		,[LAST_PURCHASE] NUMERIC(18,6)
	);
	--
	DECLARE @DISCOUNT_LIST TABLE(
		[DISCOUNT_LIST_ID] INT
	)
	--
	DECLARE @BONUS_LIST TABLE(
		[BONUS_LIST_ID] INT
	)
	--
	DECLARE @SKU_SALES_BY_MULTIPLE_LIST TABLE(
		[SALES_BY_MULTIPLE_LIST_ID] INT
	)
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene la lista de precios por defecto de la ruta
	-- ------------------------------------------------------------------------------------
	/*SELECT @DEFAULT_PRICE_LIST = ISNULL([CODE_PRICE_LIST], [SONDA].[SWIFT_FN_GET_PARAMETER] ('ERP_HARDCODE_VALUES','PRICE_LIST'))
	FROM [SONDA].[USERS]
	WHERE [SELLER_ROUTE] = @CODE_ROUTE*/
	SELECT @DEFAULT_PRICE_LIST = '-1'

	-- ------------------------------------------------------------------------------------
	-- Obtiene las listas de descuentos asociadas a la ruta
	-- ------------------------------------------------------------------------------------
	INSERT INTO @DISCOUNT_LIST
	SELECT [DL].[DISCOUNT_LIST_ID]
	FROM [SONDA].[SWIFT_DISCOUNT_LIST] [DL]
	WHERE [DL].[NAME_DISCOUNT_LIST] LIKE (@CODE_ROUTE + '%')

	-- ------------------------------------------------------------------------------------
	-- Obtiene las listas de bonificaciones asociadas a la ruta
	-- ------------------------------------------------------------------------------------
	INSERT INTO @BONUS_LIST
	SELECT [BL].[BONUS_LIST_ID]
	FROM [SONDA].[SWIFT_BONUS_LIST] [BL]
	WHERE [BL].[NAME_BONUS_LIST] LIKE (@CODE_ROUTE + '%')

	-- ------------------------------------------------------------------------------------
	-- Obtiene las listas de venta minima
	-- ------------------------------------------------------------------------------------
	INSERT INTO @SKU_SALES_BY_MULTIPLE_LIST
	SELECT [SM].[SALES_BY_MULTIPLE_LIST_ID]
	FROM [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST] [SM]
	WHERE [SM].[NAME_SALES_BY_MULTIPLE_LIST] LIKE (@CODE_ROUTE + '%')

	-- ------------------------------------------------------------------------------------
	-- Obtener Clientes Scounting
	-- ------------------------------------------------------------------------------------
	INSERT INTO @CUSTOMER
			(
				[CODE_CUSTOMER]
				,[NAME_CUSTOMER]
				,[TAX_ID_NUMBER]
				,[ADRESS_CUSTOMER]
				,[PHONE_CUSTOMER]
				,[CONTACT_CUSTOMER]
				,[CREDIT_LIMIT]
				,[EXTRA_DAYS]
				,[DISCOUNT]
				,[GPS]
				,[RGA_CODE]
				,[DISCOUNT_LIST_ID]
				,[BONUS_LIST_ID]
				,[PRICE_LIST_ID]
				,[SALES_BY_MULTIPLE_LIST_ID]
				,[PREVIUS_BALANCE]
				,[LAST_PURCHASE]
			)
			--quitar top 100
	SELECT --TOP 300
		[C].[CODE_CUSTOMER]
		,[dbo].[FUNC_REMOVE_SPECIAL_CHARS]([C].[NAME_CUSTOMER]) AS [NAME_CUSTOMER]
		,[C].[TAX_ID_NUMBER]
		,REPLACE([dbo].[FUNC_REMOVE_SPECIAL_CHARS](COALESCE([C].[ADRESS_CUSTOMER] ,'')) ,'"' ,'') AS [ADRESS_CUSTOMER]
		,COALESCE([PHONE_CUSTOMER] ,'') AS [PHONE_CUSTOMER]
		,[dbo].[FUNC_REMOVE_SPECIAL_CHARS](COALESCE([C].[CONTACT_CUSTOMER] ,'')) AS [CONTACT_CUSTOMER]
		,ISNULL([C].[CREDIT_LIMIT] ,0.00) [CREDIT_LIMIT]
		,ISNULL([C].[EXTRA_DAYS] ,0) [EXTRA_DAYS]
		,[C].[DISCOUNT] AS [DISCOUNT]
		,ISNULL([C].[GPS] ,'0,0') [GPS]
		,[C].[RGA_CODE]
		,[DLC].[DISCOUNT_LIST_ID]
		,[BLC].[BONUS_LIST_ID]		
		,ISNULL( [PLC].[CODE_PRICE_LIST], @DEFAULT_PRICE_LIST) 
		,[SMC].[SALES_BY_MULTIPLE_LIST_ID]
		,[C].[BALANCE] AS PREVIUS_BALANCE
		,0--[SONDA].[SONDA_FN_GET_LAST_PURCHASE_FOR_CUSTOMER] ([C].[CODE_CUSTOMER]) 
		AS LAST_PURCHASE
	FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
	INNER JOIN [SONDA].[USERS] ON (
		[C].[SELLER_DEFAULT_CODE] = [RELATED_SELLER]
	)
	LEFT JOIN [SONDA].[SWIFT_DISCOUNT_LIST_BY_CUSTOMER] [DLC] ON (
		[DLC].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER]
	)
	LEFT JOIN [SONDA].[SWIFT_BONUS_LIST_BY_CUSTOMER] [BLC] ON (
		[BLC].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER]
	)
	LEFT JOIN [SONDA].[SWIFT_PRICE_LIST_BY_CUSTOMER_FOR_ROUTE] [PLC] ON (
		[PLC].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER]
	)
	LEFT JOIN [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST_BY_CUSTOMER] [SMC] ON (
		[SMC].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER]
	)
	WHERE [SELLER_ROUTE] = @CODE_ROUTE
	
	-- ------------------------------------------------------------------------------------
	-- Obtener Clientes Tareas
	-- ------------------------------------------------------------------------------------
	INSERT INTO @CUSTOMER
			(
				[CODE_CUSTOMER]
				,[NAME_CUSTOMER]
				,[TAX_ID_NUMBER]
				,[ADRESS_CUSTOMER]
				,[PHONE_CUSTOMER]
				,[CONTACT_CUSTOMER]
				,[CREDIT_LIMIT]
				,[EXTRA_DAYS]
				,[DISCOUNT]
				,[GPS]
				,[RGA_CODE]
				,[DISCOUNT_LIST_ID]
				,[BONUS_LIST_ID]
				,[PRICE_LIST_ID]
				,[SALES_BY_MULTIPLE_LIST_ID]
				,[PREVIUS_BALANCE]
				,[LAST_PURCHASE]
			)
			--quitar top 1
	SELECT --TOP 300
		[VAC].[CODE_CUSTOMER]
		,[dbo].[FUNC_REMOVE_SPECIAL_CHARS]([NAME_CUSTOMER]) AS [NAME_CUSTOMER]
		,[TAX_ID_NUMBER]
		,[dbo].[FUNC_REMOVE_SPECIAL_CHARS](COALESCE([ADRESS_CUSTOMER] ,'')) AS [ADRESS_CUSTOMER]
		,COALESCE([PHONE_CUSTOMER] ,'') AS [PHONE_CUSTOMER]
		,[dbo].[FUNC_REMOVE_SPECIAL_CHARS](COALESCE([CONTACT_CUSTOMER] ,'')) AS [CONTACT_CUSTOMER]
		,ISNULL([VAC].[CREDIT_LIMIT] ,0.00) [CREDIT_LIMIT]
		,ISNULL([VAC].[EXTRA_DAYS] ,0) [EXTRA_DAYS]
		,[DISCOUNT] AS [DISCOUNT]
		,ISNULL([VAC].[GPS] ,'0,0') [GPS]
		,[VAC].[RGA_CODE]
		,[DLC].[DISCOUNT_LIST_ID]
		,[BLC].[BONUS_LIST_ID]
		,ISNULL( [PLC].[CODE_PRICE_LIST], @DEFAULT_PRICE_LIST) 
		,[SMC].[SALES_BY_MULTIPLE_LIST_ID]
		,[VAC].[BALANCE] AS PREVIUS_BALANCE
		,0--[SONDA].[SONDA_FN_GET_LAST_PURCHASE_FOR_CUSTOMER] ([VAC].[CODE_CUSTOMER]) 
		AS LAST_PURCHASE
	FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [VAC]
	INNER JOIN [SONDA].[SONDA_ROUTE_PLAN] [RP] ON (
		[VAC].[CODE_CUSTOMER] = [RP].[RELATED_CLIENT_CODE]
	)	
	LEFT JOIN [SONDA].[SWIFT_DISCOUNT_LIST_BY_CUSTOMER] [DLC] ON (
		[DLC].[CODE_CUSTOMER] = [VAC].[CODE_CUSTOMER]
	)
	LEFT JOIN [SONDA].[SWIFT_BONUS_LIST_BY_CUSTOMER] [BLC] ON (
		[BLC].[CODE_CUSTOMER] = [VAC].[CODE_CUSTOMER]
	)
	LEFT JOIN [SONDA].[SWIFT_PRICE_LIST_BY_CUSTOMER_FOR_ROUTE] [PLC] ON (
		[PLC].[CODE_CUSTOMER] = [VAC].[CODE_CUSTOMER]
	)
	LEFT JOIN [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST_BY_CUSTOMER] [SMC] ON (
		[SMC].[CODE_CUSTOMER] = [VAC].[CODE_CUSTOMER]
	)
	WHERE [RP].[CODE_ROUTE] = @CODE_ROUTE;

	-- ------------------------------------------------------------------------------------
	-- Agrego todos los clientes que no estan en algun acuerdo comercial
	-- ------------------------------------------------------------------------------------
	INSERT INTO @RESULT
			(
				[CODE_CUSTOMER]
				,[NAME_CUSTOMER]
				,[TAX_ID_NUMBER]
				,[ADRESS_CUSTOMER]
				,[PHONE_CUSTOMER]
				,[CONTACT_CUSTOMER]
				,[CREDIT_LIMIT]
				,[EXTRA_DAYS]
				,[DISCOUNT]
				,[GPS]
				,[RGA_CODE]
				,[DISCOUNT_LIST_ID]
				,[BONUS_LIST_ID]
				,[PRICE_LIST_ID]
				,[SALES_BY_MULTIPLE_LIST_ID]
				,[PREVIUS_BALANCE]
				,[LAST_PURCHASE]
			)
	SELECT --TOP 300
		[C].[CODE_CUSTOMER]
		,[C].[NAME_CUSTOMER]
		,[C].[TAX_ID_NUMBER]
		,[C].[ADRESS_CUSTOMER]
		,[C].[PHONE_CUSTOMER]
		,[C].[CONTACT_CUSTOMER]
		,[C].[CREDIT_LIMIT]
		,[C].[EXTRA_DAYS]
		,[C].[DISCOUNT]
		,[C].[GPS]
		,[C].[RGA_CODE]
		,[C].[DISCOUNT_LIST_ID]
		,[C].[BONUS_LIST_ID]
		,[C].[PRICE_LIST_ID]
		,[C].[SALES_BY_MULTIPLE_LIST_ID]
		,[C].[PREVIUS_BALANCE]
		,[C].[LAST_PURCHASE]
	FROM @CUSTOMER [C]
	WHERE [C].[DISCOUNT_LIST_ID] IS NULL 
		AND [C].[BONUS_LIST_ID] IS NULL
		AND [C].[SALES_BY_MULTIPLE_LIST_ID] IS NULL

	-- ------------------------------------------------------------------------------------
	-- Elimina los clientes sin acuerdo comercial
	-- ------------------------------------------------------------------------------------
	DELETE [C]
	FROM @CUSTOMER [C]
	INNER JOIN @RESULT [R] ON (
		[R].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER]
	)

	-- ------------------------------------------------------------------------------------
	-- Agrego los clientes que tienen acuerdo comercial y que generaron listas para la ruta solicitada
	-- ------------------------------------------------------------------------------------
	INSERT INTO @RESULT
			(
				[CODE_CUSTOMER]
				,[NAME_CUSTOMER]
				,[TAX_ID_NUMBER]
				,[ADRESS_CUSTOMER]
				,[PHONE_CUSTOMER]
				,[CONTACT_CUSTOMER]
				,[CREDIT_LIMIT]
				,[EXTRA_DAYS]
				,[DISCOUNT]
				,[GPS]
				,[RGA_CODE]
				,[DISCOUNT_LIST_ID]
				,[BONUS_LIST_ID]
				,[PRICE_LIST_ID]
				,[SALES_BY_MULTIPLE_LIST_ID]
				,[PREVIUS_BALANCE]
				,[LAST_PURCHASE]
			)
	SELECT --DISTINCT TOP 300
		[C].[CODE_CUSTOMER]
		,[C].[NAME_CUSTOMER]
		,[C].[TAX_ID_NUMBER]
		,[C].[ADRESS_CUSTOMER]
		,[C].[PHONE_CUSTOMER]
		,[C].[CONTACT_CUSTOMER]
		,[C].[CREDIT_LIMIT]
		,[C].[EXTRA_DAYS]
		,[C].[DISCOUNT]
		,[C].[GPS]
		,[C].[RGA_CODE]
		,[C].[DISCOUNT_LIST_ID]
		,[C].[BONUS_LIST_ID]
		,[C].[PRICE_LIST_ID]
		,[C].[SALES_BY_MULTIPLE_LIST_ID]
		,[C].[PREVIUS_BALANCE]
		,[C].[LAST_PURCHASE]
	FROM @CUSTOMER [C]
	LEFT JOIN @DISCOUNT_LIST [DL] ON (
		ISNULL([DL].[DISCOUNT_LIST_ID],0) = [C].[DISCOUNT_LIST_ID]
	)
	LEFT JOIN @BONUS_LIST [BL] ON (
		ISNULL([BL].[BONUS_LIST_ID],0) = [C].[BONUS_LIST_ID]
	)
	LEFT JOIN @SKU_SALES_BY_MULTIPLE_LIST [SM] ON (
		ISNULL([SM].[SALES_BY_MULTIPLE_LIST_ID],0) = [C].[SALES_BY_MULTIPLE_LIST_ID]
	)

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado final
	-- ------------------------------------------------------------------------------------
	SELECT DISTINCT --TOP 300
		[R].[CODE_CUSTOMER]
		,[R].[NAME_CUSTOMER]
		,[R].[TAX_ID_NUMBER]
		,[R].[ADRESS_CUSTOMER]
		,[R].[PHONE_CUSTOMER]
		,[R].[CONTACT_CUSTOMER]
		,[R].[CREDIT_LIMIT]
		,[R].[EXTRA_DAYS]
		,[R].[DISCOUNT]
		,[R].[GPS]
		,[R].[RGA_CODE]
		,[R].[DISCOUNT_LIST_ID]
		,[R].[BONUS_LIST_ID]
		,[R].[PRICE_LIST_ID]
		,[R].[SALES_BY_MULTIPLE_LIST_ID]
		,[R].[PREVIUS_BALANCE]
		,[R].[LAST_PURCHASE]
	FROM @RESULT [R]
END
