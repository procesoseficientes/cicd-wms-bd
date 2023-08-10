-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		11/14/2018 @ G-Force Team Sprint Mamut
-- Historia/Bug:			Product Backlog Item 25662: Precios Especiales en el movil
-- Description:	11/14/2018 - SP que genera las listas de precios especiales para la ruta que recibe como parametro	     

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_GENERATE_SPECIAL_PRICE_LIST]
		@CODE_ROUTE = '136'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GENERATE_SPECIAL_PRICE_LIST]
	(
		@CODE_ROUTE VARCHAR(250)
	)
AS
	BEGIN
		SET NOCOUNT ON;
		-- ------------------------------------------------------------------------------------
		-- Obtiene valores iniciales
		-- ------------------------------------------------------------------------------------
		DECLARE	@SPECIAL_PRICE_LIST TABLE
			(
				[NAME_SPECIAL_PRICE_LIST] VARCHAR(101)
			);
		--
		DECLARE
			@SELLER_CODE NVARCHAR(155)
			,@NOW DATETIME = GETDATE();
		--
		SELECT
			@SELLER_CODE = [SONDA].[SWIFT_FN_GET_SELLER_BY_ROUTE](@CODE_ROUTE);

		-- ------------------------------------------------------------------------------------
		-- Obtiene los acuerdos comerciales de clientes
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @SPECIAL_PRICE_LIST
				(
					[NAME_SPECIAL_PRICE_LIST]
				)
		SELECT DISTINCT
			@CODE_ROUTE + '|' + [TA].[CODE_TRADE_AGREEMENT] AS [NAME_SPECIAL_PRICE_LIST]
		FROM
			[SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
		ON	([C].[CODE_CUSTOMER] = [TAC].[CODE_CUSTOMER])
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA]
		ON	([TAC].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID])
		WHERE
			[C].[SELLER_DEFAULT_CODE] = @SELLER_CODE
			AND [TA].[STATUS] = 1
			AND @NOW BETWEEN [TA].[VALID_START_DATETIME]
						AND		[TA].[VALID_END_DATETIME];

		-- ------------------------------------------------------------------------------------
		-- Obtiene los clientes que esten en el plan de ruta y no esten asociados por vendedor
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @SPECIAL_PRICE_LIST
				(
					[NAME_SPECIAL_PRICE_LIST]
				)
		SELECT
			[RP].[CODE_ROUTE] + '|' + [TA].[CODE_TRADE_AGREEMENT] AS [NAME_SPECIAL_PRICE_LIST]
		FROM
			[SONDA].[SONDA_ROUTE_PLAN] [RP]
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
		ON	([RP].[RELATED_CLIENT_CODE] = [TAC].[CODE_CUSTOMER])
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA]
		ON	([TAC].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID])
		WHERE
			[RP].[CODE_ROUTE] = @CODE_ROUTE
			AND [TA].[STATUS] = 1
			AND @NOW BETWEEN [TA].[VALID_START_DATETIME]
						AND		[TA].[VALID_END_DATETIME];

		-- ------------------------------------------------------------------------------------
		-- Obtiene los acuerdos comerciales de canal
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @SPECIAL_PRICE_LIST
				(
					[NAME_SPECIAL_PRICE_LIST]
				)
		SELECT
			@CODE_ROUTE + '|' + [TA].[CODE_TRADE_AGREEMENT] AS [NAME_SPECIAL_PRICE_LIST]
		FROM
			[SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
		INNER JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC]
		ON	([C].[CODE_CUSTOMER] = [CC].[CODE_CUSTOMER])
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL] [TAC]
		ON	([CC].[CHANNEL_ID] = [TAC].[CHANNEL_ID])
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA]
		ON	([TAC].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID])
		WHERE
			[C].[SELLER_DEFAULT_CODE] = @SELLER_CODE
			AND [TA].[STATUS] = 1
			AND @NOW BETWEEN [TA].[VALID_START_DATETIME]
						AND		[TA].[VALID_END_DATETIME];

		-- ------------------------------------------------------------------------------------
		-- Obtiene los acuerdos comerciales de los clientes que esten en el plan de ruta y no esten asociados por vendedor
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @SPECIAL_PRICE_LIST
				(
					[NAME_SPECIAL_PRICE_LIST]
				)
		SELECT
			@CODE_ROUTE + '|' + [TA].[CODE_TRADE_AGREEMENT] AS [NAME_SPECIAL_PRICE_LIST]
		FROM
			[SONDA].[SONDA_ROUTE_PLAN] [RP]
		INNER JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC]
		ON	([RP].[RELATED_CLIENT_CODE] = [CC].[CODE_CUSTOMER])
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL] [TAC]
		ON	([CC].[CHANNEL_ID] = [TAC].[CHANNEL_ID])
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA]
		ON	([TAC].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID])
		WHERE
			[RP].[CODE_ROUTE] = @CODE_ROUTE
			AND [TA].[STATUS] = 1
			AND @NOW BETWEEN [TA].[VALID_START_DATETIME]
						AND		[TA].[VALID_END_DATETIME];

		-- ------------------------------------------------------------------------------------
		-- Agrega la lista del acuerdo comercial para los nuevos clientes de ser necesario
		-- ------------------------------------------------------------------------------------
		IF (
			SELECT
				[SONDA].[SWIFT_FN_VALIDATE_TRADE_AGREEMENT_BY_ROUTE](@CODE_ROUTE)
			) = 1
		BEGIN
			DECLARE	@TRADE_AGREEMENT_ID INT = NULL;
			--
			SELECT
				@TRADE_AGREEMENT_ID = [SONDA].[SWIFT_FN_GET_TRADE_AGREEMENT_BY_ROUTE](@CODE_ROUTE);
			--
			INSERT	INTO @SPECIAL_PRICE_LIST
					(
						[NAME_SPECIAL_PRICE_LIST]
					)
			SELECT
				(@CODE_ROUTE + '|' + [T].[CODE_TRADE_AGREEMENT])
			FROM
				[SONDA].[SWIFT_TRADE_AGREEMENT] [T]
			WHERE
				[T].[TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID;
		END;

		-- ------------------------------------------------------------------------------------
		-- Genera la lista de PRECIOS ESPECIALES
		-- ------------------------------------------------------------------------------------
		INSERT	INTO [SONDA].[SWIFT_SPECIAL_PRICE_LIST]
				(
					[SPECIAL_PRICE_LIST_NAME]
					,[CODE_ROUTE]
				)
		SELECT DISTINCT
			[SPL].[NAME_SPECIAL_PRICE_LIST]
			,@CODE_ROUTE
		FROM
			@SPECIAL_PRICE_LIST [SPL];
	END;
