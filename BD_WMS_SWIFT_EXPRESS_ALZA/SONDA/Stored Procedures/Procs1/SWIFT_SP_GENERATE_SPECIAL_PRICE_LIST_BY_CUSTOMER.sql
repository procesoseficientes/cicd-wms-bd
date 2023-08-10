-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		11/14/2018 @ G-Force Team Sprint Mamut
-- Historia/Bug:			Product Backlog Item 25662: Precios Especiales en el movil
-- Description:	11/14/2018 - SP que genera las listas de precios especiales por cliente de los acuerdos comerciales		     

/*
-- Ejemplo de Ejecucion:
		-- 
		EXEC [SONDA].[SWIFT_SP_GENERATE_SPECIAL_PRICE_LIST_BY_CUSTOMER]
		@CODE_ROUTE = '136'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GENERATE_SPECIAL_PRICE_LIST_BY_CUSTOMER]
	(
		@CODE_ROUTE VARCHAR(250)
	)
AS
	BEGIN
		SET NOCOUNT ON;

		-- ------------------------------------------------------------------------------------
		-- Obtiene valores iniciales
		-- ------------------------------------------------------------------------------------
		DECLARE
			@SELLER_CODE VARCHAR(50)
			,@LINKED_TO VARCHAR(250);
		--
		DECLARE	@TRADE_AGREEMENT_BY_CUSTOMER TABLE
			(
				[TRADE_AGREEMENT_ID] INT
				,[CODE_TRADE_AGREEMENT] VARCHAR(50)
				,[CODE_CUSTOMER] VARCHAR(50)
				,[LINKED_TO] VARCHAR(250)
				,[CODE_ROUTE] VARCHAR(50)
				,[SPECIAL_PRICE_LIST_NAME] VARCHAR(250)
				,UNIQUE ([TRADE_AGREEMENT_ID] ,[CODE_CUSTOMER])
				,UNIQUE
					([LINKED_TO] ,[CODE_CUSTOMER] ,[SPECIAL_PRICE_LIST_NAME] ,[CODE_ROUTE] ,[TRADE_AGREEMENT_ID])
			);
		--
		SELECT
			@SELLER_CODE = [SONDA].[SWIFT_FN_GET_SELLER_BY_ROUTE](@CODE_ROUTE)
			,@LINKED_TO = 'CUSTOMER';

		-- ------------------------------------------------------------------------------------
		-- Obtiene los acuerdos comerciales
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @TRADE_AGREEMENT_BY_CUSTOMER
				(
					[TRADE_AGREEMENT_ID]
					,[CODE_TRADE_AGREEMENT]
					,[CODE_CUSTOMER]
					,[LINKED_TO]
					,[CODE_ROUTE]
					,[SPECIAL_PRICE_LIST_NAME]
				)
		SELECT DISTINCT
			[TAC].[TRADE_AGREEMENT_ID]
			,[TA].[CODE_TRADE_AGREEMENT]
			,[C].[CODE_CUSTOMER]
			,[TA].[LINKED_TO]
			,@CODE_ROUTE
			,@CODE_ROUTE + '|' + [TA].[CODE_TRADE_AGREEMENT]
		FROM
			[SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
		ON	([C].[CODE_CUSTOMER] = [TAC].[CODE_CUSTOMER])
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA]
		ON	([TAC].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID])
		WHERE
			[C].[SELLER_DEFAULT_CODE] = @SELLER_CODE
			AND [TA].[STATUS] = 1
			AND GETDATE() BETWEEN [TA].[VALID_START_DATETIME]
							AND		[TA].[VALID_END_DATETIME];

		-- ------------------------------------------------------------------------------------
		-- Obtiene los acuerdos comerciales de los clientes que esten en el plan de ruta y no esten asociados por vendedor
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @TRADE_AGREEMENT_BY_CUSTOMER
				(
					[TRADE_AGREEMENT_ID]
					,[CODE_TRADE_AGREEMENT]
					,[CODE_CUSTOMER]
					,[LINKED_TO]
					,[CODE_ROUTE]
					,[SPECIAL_PRICE_LIST_NAME]
				)
		SELECT DISTINCT
			[TAC].[TRADE_AGREEMENT_ID]
			,[TA].[CODE_TRADE_AGREEMENT]
			,[RP].[RELATED_CLIENT_CODE] [CODE_CUSTOMER]
			,[TA].[LINKED_TO]
			,@CODE_ROUTE
			,@CODE_ROUTE + '|' + [TA].[CODE_TRADE_AGREEMENT]
		FROM
			[SONDA].[SONDA_ROUTE_PLAN] [RP]
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
		ON	([RP].[RELATED_CLIENT_CODE] = [TAC].[CODE_CUSTOMER])
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA]
		ON	([TAC].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID])
		LEFT JOIN @TRADE_AGREEMENT_BY_CUSTOMER [TABC]
		ON	([RP].[RELATED_CLIENT_CODE] = [TABC].[CODE_CUSTOMER])
		WHERE
			[RP].[CODE_ROUTE] = @CODE_ROUTE
			AND [TA].[STATUS] = 1
			AND GETDATE() BETWEEN [TA].[VALID_START_DATETIME]
							AND		[TA].[VALID_END_DATETIME]
			AND [TABC].[TRADE_AGREEMENT_ID] IS NULL;

		-- ------------------------------------------------------------------------------------
		-- Genera clientes de las listas de descuentos
		-- ------------------------------------------------------------------------------------
		INSERT	INTO [SONDA].[SWIFT_SPECIAL_PRICE_LIST_BY_CUSTOMER]
				(
					[SPECIAL_PRICE_LIST_ID]
					,[CODE_CUSTOMER]
				)
		SELECT DISTINCT
			[DL].[SPECIAL_PRICE_LIST_ID]
			,[TA].[CODE_CUSTOMER]
		FROM
			@TRADE_AGREEMENT_BY_CUSTOMER [TA]
		INNER JOIN [SONDA].[SWIFT_SPECIAL_PRICE_LIST] [DL]
		ON	(
				[TA].[CODE_ROUTE] = [DL].[CODE_ROUTE]
				AND [TA].[SPECIAL_PRICE_LIST_NAME] = [DL].[SPECIAL_PRICE_LIST_NAME]
			)
		WHERE
			[TA].[LINKED_TO] = @LINKED_TO
			AND [DL].[SPECIAL_PRICE_LIST_ID] > 0;

		-- ------------------------------------------------------------------------------------
		-- Agrega la lista del acuerdo comercial para los nuevos clientes de ser necesario
		-- ------------------------------------------------------------------------------------
		IF (
			SELECT
				[SONDA].[SWIFT_FN_VALIDATE_TRADE_AGREEMENT_BY_ROUTE](@CODE_ROUTE)
			) = 1
		BEGIN
			DECLARE
				@TRADE_AGREEMENT_ID INT = NULL
				,@CODE_TRADE_AGREEMENT VARCHAR(50) = NULL
				,@IS_ALREADY INT = 0;
			--
			SELECT
				@TRADE_AGREEMENT_ID = [SONDA].[SWIFT_FN_GET_TRADE_AGREEMENT_BY_ROUTE](@CODE_ROUTE);
			--
			SELECT
				@CODE_TRADE_AGREEMENT = [TA].[CODE_TRADE_AGREEMENT]
			FROM
				[SONDA].[SWIFT_TRADE_AGREEMENT] [TA]
			WHERE
				[TA].[TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID;

			-- ------------------------------------------------------------------------------------
			-- Se valida si ya se tomo en cuenta el acuerdo comercial
			-- ------------------------------------------------------------------------------------
			IF @TRADE_AGREEMENT_ID IS NOT NULL
			BEGIN
				DECLARE	@NAME_SPECIAL_PRICE_LIST VARCHAR(250) = (@CODE_ROUTE + '|'
															+ @CODE_TRADE_AGREEMENT);
				--
				SELECT TOP 1
					@IS_ALREADY = 1
				FROM
					[SONDA].[SWIFT_SPECIAL_PRICE_LIST_BY_CUSTOMER] [DLC]
				INNER JOIN [SONDA].[SWIFT_SPECIAL_PRICE_LIST] [DL]
				ON	([DL].[SPECIAL_PRICE_LIST_ID] = [DLC].[SPECIAL_PRICE_LIST_ID])
				WHERE
					[DL].[CODE_ROUTE] = @CODE_ROUTE
					AND [DL].[SPECIAL_PRICE_LIST_NAME] = @NAME_SPECIAL_PRICE_LIST;
			END;
    --
			IF @IS_ALREADY = 0
			BEGIN
				INSERT	INTO @TRADE_AGREEMENT_BY_CUSTOMER
						(
							[TRADE_AGREEMENT_ID]
							,[CODE_TRADE_AGREEMENT]
							,[CODE_CUSTOMER]
							,[LINKED_TO]
							,[CODE_ROUTE]
							,[SPECIAL_PRICE_LIST_NAME]
						)
				SELECT
					@TRADE_AGREEMENT_ID
					,@CODE_TRADE_AGREEMENT
					,'-1'
					,@LINKED_TO
					,@CODE_ROUTE
					,@CODE_ROUTE + '|' + [T].[CODE_TRADE_AGREEMENT]
				FROM
					[SONDA].[SWIFT_TRADE_AGREEMENT] [T]
				WHERE
					[T].[TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID;
			END;
		END;

		-- ------------------------------------------------------------------------------------
		-- Genera SKUs de la lista de descuentos
		-- ------------------------------------------------------------------------------------
		INSERT INTO SONDA.[SWIFT_SPECIAL_PRICE_LIST_BY_SCALE]
				(
					[SPECIAL_PRICE_LIST_ID]
					,[CODE_SKU]
					,[PACK_UNIT]
					,[LOW_LIMIT]
					,[HIGH_LIMIT]
					,[SPECIAL_PRICE]
					,[PROMO_ID]
					,[PROMO_NAME]
					,[PROMO_TYPE]
					,[FREQUENCY]
					,[APPLY_DISCOUNT]
				)
		SELECT DISTINCT
			[DL].[SPECIAL_PRICE_LIST_ID]
			,[PDS].[CODE_SKU]
			,[PDS].[PACK_UNIT]
			,[PDS].[LOW_LIMIT]
			,[PDS].[HIGH_LIMIT]
			,[PDS].[PRICE]
			,[P].[PROMO_ID]
			,[P].[PROMO_NAME]
			,[P].[PROMO_TYPE]
			,[TAP].[FREQUENCY]
			,[PDS].[INCLUDE_DISCOUNT]
		FROM
			@TRADE_AGREEMENT_BY_CUSTOMER [TA]
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO] [TAP]
		ON	([TAP].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID])
		INNER JOIN [SONDA].[SWIFT_PROMO] [P]
		ON	([P].[PROMO_ID] = [TAP].[PROMO_ID])
		INNER JOIN [SONDA].[SWIFT_PROMO_SPECIAL_PRICE_LIST_BY_SCALE] [PDS]
		ON	([PDS].[PROMO_ID] = [P].[PROMO_ID])
		INNER JOIN [SONDA].[SWIFT_SPECIAL_PRICE_LIST] [DL]
		ON	(
				[DL].[CODE_ROUTE] = [TA].[CODE_ROUTE]
				AND [DL].[SPECIAL_PRICE_LIST_NAME] = [TA].[SPECIAL_PRICE_LIST_NAME]
			)
		WHERE
			[TA].[LINKED_TO] = @LINKED_TO;

	END;
