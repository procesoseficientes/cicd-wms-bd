-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		11/14/2018 @ G-Force Team Sprint 
-- Historia/Bug:			Product Backlog Item 25662: Precios Especiales en el movil
-- Description:	11/14/2018 - SP que genera las listas de precios especiales para los clientes duplicados, para la ruta que recibe como parametro		     

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_GENERATE_SPECIAL_PRICE_LIST_BY_ROUTE_FOR_REPEATED_CUSTOMER]
		@CODE_ROUTE = '136'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GENERATE_SPECIAL_PRICE_LIST_BY_ROUTE_FOR_REPEATED_CUSTOMER]
	(
		@CODE_ROUTE VARCHAR(250)
	)
AS
	BEGIN
		SET NOCOUNT ON;

		-- ------------------------------------------------------------------------------------
		-- Obtiene valores iniciales
		-- ------------------------------------------------------------------------------------
		DECLARE	@CUSTOMER TABLE
			(
				[CODE_CUSTOMER] VARCHAR(50)
				,UNIQUE ([CODE_CUSTOMER])
			);
		--
		DECLARE
			@SELLER_CODE VARCHAR(50)
			,@CODE_CUSTOMER VARCHAR(50)
			,@SPECIAL_PRICE_LIST_ID INT
			,@LINKED_TO VARCHAR(50)
			,@NOW DATETIME = GETDATE()
			,@STATUS INT = 1;
		--
		SELECT
			@SELLER_CODE = [SONDA].[SWIFT_FN_GET_SELLER_BY_ROUTE](@CODE_ROUTE);

		-- ------------------------------------------------------------------------------------
		-- Obtiene los clientes a repetidos
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @CUSTOMER
				(
					[CODE_CUSTOMER]
				)
		SELECT DISTINCT
			[C].[CODE_CUSTOMER]
		FROM
			[SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
		INNER JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC]
		ON	([C].[CODE_CUSTOMER] = [CC].[CODE_CUSTOMER])
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
		ON	([C].[CODE_CUSTOMER] = [TAC].[CODE_CUSTOMER])
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA1]
		ON	([TA1].[TRADE_AGREEMENT_ID] = [TAC].[TRADE_AGREEMENT_ID])
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL] [TA]
		ON	([TA].[CHANNEL_ID] = [CC].[CHANNEL_ID])
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA2]
		ON	([TA2].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID])
		WHERE
			[C].[SELLER_DEFAULT_CODE] = @SELLER_CODE
			AND [TAC].[TRADE_AGREEMENT_ID] > 0
			AND [TA1].[STATUS] = @STATUS
			AND @NOW BETWEEN [TA1].[VALID_START_DATETIME]
						AND		[TA1].[VALID_END_DATETIME]
			AND [TA2].[STATUS] = @STATUS
			AND @NOW BETWEEN [TA2].[VALID_START_DATETIME]
						AND		[TA2].[VALID_END_DATETIME]
			AND [TA].[TRADE_AGREEMENT_ID] > 0;


		-- ------------------------------------------------------------------------------------
		-- Obtiene los clientes que esten en el plan de ruta y no esten asociados por vendedor
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @CUSTOMER
				(
					[CODE_CUSTOMER]
				)
		SELECT DISTINCT
			[RP].[RELATED_CLIENT_CODE]
		FROM
			[SONDA].[SONDA_ROUTE_PLAN] [RP]
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
		ON	([RP].[RELATED_CLIENT_CODE] = [TAC].[CODE_CUSTOMER])
		INNER JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC]
		ON	([RP].[RELATED_CLIENT_CODE] = [CC].[CODE_CUSTOMER])
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA1]
		ON	([TA1].[TRADE_AGREEMENT_ID] = [TAC].[TRADE_AGREEMENT_ID])
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL] [TACH]
		ON	([CC].[CHANNEL_ID] = [TACH].[CHANNEL_ID])
		INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA2]
		ON	([TA2].[TRADE_AGREEMENT_ID] = [TACH].[TRADE_AGREEMENT_ID])
		LEFT JOIN @CUSTOMER [C2]
		ON	([RP].[RELATED_CLIENT_CODE] = [C2].[CODE_CUSTOMER])
		WHERE
			[RP].[CODE_ROUTE] = @CODE_ROUTE
			AND [TA1].[STATUS] = @STATUS
			AND [TA2].[STATUS] = @STATUS
			AND @NOW BETWEEN [TA1].[VALID_START_DATETIME]
						AND		[TA1].[VALID_END_DATETIME]
			AND @NOW BETWEEN [TA2].[VALID_START_DATETIME]
						AND		[TA2].[VALID_END_DATETIME]
			AND [C2].[CODE_CUSTOMER] IS NULL;

		-- ------------------------------------------------------------------------------------
		-- Obtiene la prioridad
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@LINKED_TO = [LINKED_TO]
		FROM
			[SONDA].[SWIFT_SPECIAL_PRICE_PRIORITY]
		WHERE
			[ORDER] > 0
			AND [ACTIVE_SWIFT_EXPRESS] = @STATUS
		ORDER BY
			[ORDER];

		-- ------------------------------------------------------------------------------------
		-- Genera lista de precios especiales para cada cliente repetido
		-- ------------------------------------------------------------------------------------
		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							@CUSTOMER )
		BEGIN
			-- ------------------------------------------------------------------------------------
			-- Obtiene cliente para el cual se genera la lista
			-- ------------------------------------------------------------------------------------
			SELECT TOP 1
				@CODE_CUSTOMER = [C].[CODE_CUSTOMER]
				,@SPECIAL_PRICE_LIST_ID = NULL
			FROM
				@CUSTOMER [C];

			-- ------------------------------------------------------------------------------------
			-- Crea la lista de precios especiales
			-- ------------------------------------------------------------------------------------
			INSERT	INTO [SONDA].[SWIFT_SPECIAL_PRICE_LIST]
					(
						[SPECIAL_PRICE_LIST_NAME]
						,[CODE_ROUTE]
					)
			VALUES
					(
						(@CODE_ROUTE + '|' + @CODE_CUSTOMER)  -- SPECIAL_PRICE_LIST_NAME - varchar(250)
						,@CODE_ROUTE  -- CODE_ROUTE - varchar(50)
					);
			--
			SET @SPECIAL_PRICE_LIST_ID = SCOPE_IDENTITY();

			-- ------------------------------------------------------------------------------------
			-- Asocia el cliente a la lista de precios especiales
			-- ------------------------------------------------------------------------------------
			INSERT	INTO [SONDA].[SWIFT_SPECIAL_PRICE_LIST_BY_CUSTOMER]
					(
						[SPECIAL_PRICE_LIST_ID]
						,[CODE_CUSTOMER]
					)
			VALUES
					(
						@SPECIAL_PRICE_LIST_ID  -- SPECIAL_PRICE_LIST_ID - int
						,@CODE_CUSTOMER  -- CODE_CUSTOMER - varchar(50)
					);

			-- ------------------------------------------------------------------------------------
			-- Valida si es primero canal o cliente produto
			-- ------------------------------------------------------------------------------------
			IF @LINKED_TO = 'CHANNEL'
			BEGIN
				INSERT	INTO [SONDA].[SWIFT_SPECIAL_PRICE_LIST_BY_SCALE]
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
				SELECT
					@SPECIAL_PRICE_LIST_ID
					,[TAD].[CODE_SKU]
					,[TAD].[PACK_UNIT]
					,[TAD].[LOW_LIMIT]
					,[TAD].[HIGH_LIMIT]
					,[TAD].[PRICE]
					,[P].[PROMO_ID]
					,[P].[PROMO_NAME]
					,[P].[PROMO_TYPE]
					,[TAP].[FREQUENCY]
					,[TAD].[INCLUDE_DISCOUNT]
				FROM
					[SONDA].[SWIFT_PROMO_SPECIAL_PRICE_LIST_BY_SCALE] [TAD]
				INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO] [TAP]
				ON	([TAP].[PROMO_ID] = [TAD].[PROMO_ID])
				INNER JOIN [SONDA].[SWIFT_PROMO] [P]
				ON	([P].[PROMO_ID] = [TAP].[PROMO_ID])
				INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL] [TAC]
				ON	([TAC].[TRADE_AGREEMENT_ID] = [TAP].[TRADE_AGREEMENT_ID])
				INNER JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC]
				ON	([CC].[CHANNEL_ID] = [TAC].[CHANNEL_ID])
				WHERE
					[CC].[CODE_CUSTOMER] = @CODE_CUSTOMER;
				--
				INSERT	INTO [SONDA].[SWIFT_SPECIAL_PRICE_LIST_BY_SCALE]
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
				SELECT
					@SPECIAL_PRICE_LIST_ID
					,[TAD].[CODE_SKU]
					,[TAD].[PACK_UNIT]
					,[TAD].[LOW_LIMIT]
					,[TAD].[HIGH_LIMIT]
					,[TAD].[PRICE]
					,[P].[PROMO_ID]
					,[P].[PROMO_NAME]
					,[P].[PROMO_TYPE]
					,[TAP].[FREQUENCY]
					,[TAD].[INCLUDE_DISCOUNT]
				FROM
					[SONDA].[SWIFT_PROMO_SPECIAL_PRICE_LIST_BY_SCALE] [TAD]
				INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO] [TAP]
				ON	([TAP].[PROMO_ID] = [TAD].[PROMO_ID])
				INNER JOIN [SONDA].[SWIFT_PROMO] [P]
				ON	([P].[PROMO_ID] = [TAP].[PROMO_ID])
				INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
				ON	([TAC].[TRADE_AGREEMENT_ID] = [TAP].[TRADE_AGREEMENT_ID])
				LEFT JOIN [SONDA].[SWIFT_SPECIAL_PRICE_LIST_BY_SCALE] [DLS]
				ON	(
						[DLS].[SPECIAL_PRICE_LIST_ID] = @SPECIAL_PRICE_LIST_ID
						AND [DLS].[CODE_SKU] = [TAD].[CODE_SKU]
					)
				WHERE
					[TAC].[CODE_CUSTOMER] = @CODE_CUSTOMER
					AND [DLS].[CODE_SKU] IS NULL;
			END;
			ELSE
			BEGIN
				INSERT	INTO [SONDA].[SWIFT_SPECIAL_PRICE_LIST_BY_SCALE]
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
				SELECT
					@SPECIAL_PRICE_LIST_ID
					,[TAD].[CODE_SKU]
					,[TAD].[PACK_UNIT]
					,[TAD].[LOW_LIMIT]
					,[TAD].[HIGH_LIMIT]
					,[TAD].[PRICE]
					,[P].[PROMO_ID]
					,[P].[PROMO_NAME]
					,[P].[PROMO_TYPE]
					,[TAP].[FREQUENCY]
					,[TAD].[INCLUDE_DISCOUNT]
				FROM
					[SONDA].[SWIFT_PROMO_SPECIAL_PRICE_LIST_BY_SCALE] [TAD]
				INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO] [TAP]
				ON	([TAP].[PROMO_ID] = [TAD].[PROMO_ID])
				INNER JOIN [SONDA].[SWIFT_PROMO] [P]
				ON	([P].[PROMO_ID] = [TAP].[PROMO_ID])
				INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
				ON	([TAC].[TRADE_AGREEMENT_ID] = [TAP].[TRADE_AGREEMENT_ID])
				WHERE
					[TAC].[CODE_CUSTOMER] = @CODE_CUSTOMER;
				--
				INSERT	INTO [SONDA].[SWIFT_SPECIAL_PRICE_LIST_BY_SCALE]
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
				SELECT
					@SPECIAL_PRICE_LIST_ID
					,[TAD].[CODE_SKU]
					,[TAD].[PACK_UNIT]
					,[TAD].[LOW_LIMIT]
					,[TAD].[HIGH_LIMIT]
					,[TAD].[PRICE]
					,[P].[PROMO_ID]
					,[P].[PROMO_NAME]
					,[P].[PROMO_TYPE]
					,[TAP].[FREQUENCY]
					,[TAD].[INCLUDE_DISCOUNT]
				FROM
					[SONDA].[SWIFT_PROMO_SPECIAL_PRICE_LIST_BY_SCALE] [TAD]
				INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO] [TAP]
				ON	([TAP].[PROMO_ID] = [TAD].[PROMO_ID])
				INNER JOIN [SONDA].[SWIFT_PROMO] [P]
				ON	([P].[PROMO_ID] = [TAP].[PROMO_ID])
				INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL] [TAC]
				ON	([TAC].[TRADE_AGREEMENT_ID] = [TAP].[TRADE_AGREEMENT_ID])
				INNER JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC]
				ON	([CC].[CHANNEL_ID] = [TAC].[CHANNEL_ID])
				LEFT JOIN [SONDA].[SWIFT_SPECIAL_PRICE_LIST_BY_SCALE] [DLS]
				ON	(
						[DLS].[SPECIAL_PRICE_LIST_ID] = @SPECIAL_PRICE_LIST_ID
						AND [DLS].[CODE_SKU] = [TAD].[CODE_SKU]
					)
				WHERE
					[CC].[CODE_CUSTOMER] = @CODE_CUSTOMER
					AND [DLS].[CODE_SKU] IS NULL;
			END;

			-- ------------------------------------------------------------------------------------
			-- Elimina el cliente operado
			-- ------------------------------------------------------------------------------------
			DELETE FROM
				@CUSTOMER
			WHERE
				[CODE_CUSTOMER] = @CODE_CUSTOMER;
		END;
	END;
