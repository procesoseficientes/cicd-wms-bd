-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		03-May-17 @ A-Team Sprint Hondo
-- Description:			    SP que obtienelos produtos para la preventa


-- Modificacion 30-May-17 @ A-Team Sprint Jibade
					-- alberto.ruiz
					-- Ajuste para que tome en cuenta la lista de precios por defecto del usuario
/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SONDA_SP_GET_SKU_PRESALE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_SKU_PRESALE] (
	@WAREHOUSES VARCHAR(50)
	,@CODE_ROUTE VARCHAR(50)
) AS
BEGIN
	SET NOCOUNT ON;

	-- =============================================
	-- Se declara la variable @CANTIDAD_MINIMA y se setea en 1
	-- =============================================
	DECLARE
		@CANTIDAD_MINIMA FLOAT = 0
		,@SELLER_CODE VARCHAR(50)
		,@CODE_PORTFOLIO VARCHAR(25) = NULL
		,@COUNT_RESULT INT = 0;

	-- =============================================
	-- Se obtiene el codigo de vendedor de la bodega
	-- =============================================
	SELECT TOP 1 @SELLER_CODE = [U].[RELATED_SELLER]
	FROM [SONDA].[USERS] [U]
	WHERE [U].[SELLER_ROUTE] = @CODE_ROUTE;

	-- =============================================
	-- Obtenemos si vendedor tiene asociado un potafolios
	-- =============================================
	SELECT TOP 1 @CODE_PORTFOLIO = [PS].[CODE_PORTFOLIO]
	FROM [SONDA].[SWIFT_PORTFOLIO_BY_SELLER] [PS]
	WHERE [PS].[CODE_SELLER] = @SELLER_CODE;

	-- =============================================
	-- Se obtienen las listas de precio y ademas se agrega la lista default
	-- =============================================
	SELECT DISTINCT [splbc].[CODE_PRICE_LIST]
	INTO [#PRICE_LIST]
	FROM [SONDA].[SONDA_ROUTE_PLAN] [srp]
	INNER JOIN [SONDA].[SWIFT_PRICE_LIST_BY_CUSTOMER] [splbc] ON ([srp].[RELATED_CLIENT_CODE] = [splbc].[CODE_CUSTOMER]);
	--
	INSERT INTO [#PRICE_LIST] ([CODE_PRICE_LIST])
	SELECT ISNULL([U].[CODE_PRICE_LIST],[SONDA].[SWIFT_FN_GET_PARAMETER]('ERP_HARDCODE_VALUES','PRICE_LIST'))
	FROM [SONDA].[USERS] [U]
	WHERE [U].[SELLER_ROUTE] = @CODE_ROUTE


	
	-- =============================================
	-- Se valida si la regla PreventaSinExistencia esta activa y si si se cambia el valor a la variable para que tome en cuenta los valores desde 0
	-- =============================================
	SELECT @CANTIDAD_MINIMA = -0.01
	FROM [SONDA].[SWIFT_EVENT] [se]
	INNER JOIN [SONDA].[SWIFT_RULE_X_EVENT] [srxe] ON [se].[EVENT_ID] = [srxe].[EVENT_ID]
	INNER JOIN [SONDA].[SWIFT_RULE_X_ROUTE] [srxr] ON [srxe].[RULE_ID] = [srxr].[RULE_ID]
	WHERE [se].[TYPE_ACTION] = 'PreventaSinExistencia'
		AND [se].[ENABLED] = 'Si'
		AND [srxr].[CODE_ROUTE] = @CODE_ROUTE;

	-- =============================================
	-- Se inserta en la tabla temporal el select que se tenia en la vista [SWIFT_VIEW_PRESALE_SKU] ya con el valor de @CANTIDAD_MINIMA 
	-- =============================================	
	SELECT
		[I].[WAREHOUSE]
		,[I].[SKU]
		,MAX([I].[SKU_DESCRIPTION]) [SKU_DESCRIPTION]
		,SUM([I].[ON_HAND]) AS [ON_HAND]
		,ISNULL([CW].[IS_COMITED], 0) AS [IS_COMITED]
	INTO [#PRESALE_SKU]
	FROM [SONDA].[SONDA_IS_COMITED_BY_WAREHOUSE] [CW]
	INNER JOIN [SONDA].[SWIFT_INVENTORY] [I] ON (
		[CW].[CODE_WAREHOUSE] = [I].[WAREHOUSE]
		AND [I].[SKU] = [CW].[CODE_SKU]
	)
	WHERE [I].[ON_HAND] > @CANTIDAD_MINIMA
	GROUP BY
		[I].[WAREHOUSE]
		,[I].[SKU]
		,[CW].[IS_COMITED];

	-- =============================================
	-- Se hace el select de los skus ya con la vista cambiada por la tabla temporal anterior y su cantidad minima a buscar
	-- =============================================
	SELECT DISTINCT
		[I].[WAREHOUSE]
		,[I].[SKU]
		,[S].[DESCRIPTION_SKU] AS [SKU_NAME]
		,[I].[ON_HAND]
		,[IS_COMITED]
		,([I].[ON_HAND] - [I].[IS_COMITED]) AS [DIFFERENCE]
		,0 AS [SKU_PRICE]
		,[S].[CODE_FAMILY_SKU]
		,[S].[CODE_PACK_UNIT] AS [SALES_PACK_UNIT]
		,[S].[HANDLE_DIMENSION]
		,[S].[OWNER]
		,[S].[OWNER_ID]
	FROM [#PRESALE_SKU] [I]
	INNER JOIN [SONDA].[SWIFT_PRICE_LIST_BY_SKU] [splbs] ON ([I].[SKU] = [splbs].[CODE_SKU])
	INNER JOIN [#PRICE_LIST] [pl] ON ([pl].[CODE_PRICE_LIST] = [splbs].[CODE_PRICE_LIST])
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S] ON ([I].[SKU] = [S].[CODE_SKU])
	LEFT JOIN [SONDA].[SWIFT_PORTFOLIO_BY_SKU] [PS] ON ([PS].[CODE_SKU] = [I].[SKU])
	WHERE [WAREHOUSE] = @WAREHOUSES
		AND (
				@CODE_PORTFOLIO IS NULL
				OR [PS].[CODE_PORTFOLIO] = @CODE_PORTFOLIO
			);

	-- =============================================
	-- Se validad si el portafolios 
	-- =============================================
	SELECT @COUNT_RESULT = @@ROWCOUNT;

	IF @CODE_PORTFOLIO IS NOT NULL
		AND @COUNT_RESULT = 0
	BEGIN
		RAISERROR ('El portafolios asignado no tiene productos.', 16, 1);
	END;
END;
