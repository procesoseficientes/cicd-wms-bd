-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	28-Apr-17 @ A-TEAM Sprint Hondo 
-- Description:			SP que genera lista de precios por cliente

-- Modificacion 5/30/2017 @ A-Team Sprint Jibade
					-- rodrigo.gomez
					-- Se resolvio bug al insertar en la tabla SWIFT_PRICE_LIST_BY_CUSTOMER_FOR_ROUTE se generaba conflicto de llaves primarias, se coloco DISTINCT al select que insertaba en tal

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GENERATE_PRICE_LIST]
					@CODE_ROUTE = 'ES000007'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GENERATE_PRICE_LIST](
	@CODE_ROUTE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @CUSTOMER TABLE (
		[CODE_CUSTOMER] VARCHAR(50)
		,[OWNER] VARCHAR(50)
	)
	--
	DECLARE @CUSTOMER_JUST_ONCE  TABLE ([CODE_CUSTOMER] VARCHAR(50))
	--
	DECLARE @PRICE_LIST TABLE (
		[OWNER] VARCHAR(50)
		,[CODE_ROUTE] VARCHAR(50)
		,[CODE_PRICE_LIST] VARCHAR(50)
		,[CODE_CUSTOMER] VARCHAR(50)
		,[ORIGINAL_CODE_PRICE_LIST] VARCHAR(50)
		,[CUSTOMER_OWNER] VARCHAR(50)
	)
	--
	DECLARE @PRICE_LIST_BY_CUSTOMER TABLE (
		[CODE_ROUTE] VARCHAR(50)
		,[CODE_PRICE_LIST] VARCHAR(50)
		,[CODE_CUSTOMER] VARCHAR(50)
	)
	--
	DECLARE @PRICE_LIST_BY_SKU_PACK_SCALE TABLE (
		[CODE_ROUTE] VARCHAR(50)
		,[CODE_PRICE_LIST] VARCHAR(50)
		,[CODE_SKU] VARCHAR(50)
		,[CODE_PACK_UNIT] VARCHAR(50)
		,[PRIORITY] NUMERIC (18, 0)
		,[LOW_LIMIT] NUMERIC (18, 0)
		,[HIGH_LIMIT] NUMERIC (18, 0)
		,[PRICE] NUMERIC (18, 6)
	)
	--
	DECLARE @PRICE_LIST_TEMP TABLE (
		[OWNER] VARCHAR(50)
		,[CODE_ROUTE] VARCHAR(50)
		,[CODE_PRICE_LIST] VARCHAR(50)
		,[CODE_CUSTOMER] VARCHAR(50)
		,[ORIGINAL_CODE_PRICE_LIST] VARCHAR(50)
	)
	--
	DECLARE @PRICE_LIST_BY_SKU_PACK_SCALE_TEMP TABLE (
		[CODE_ROUTE] VARCHAR(50)
		,[CODE_PRICE_LIST] VARCHAR(50)
		,[CODE_SKU] VARCHAR(50)
		,[CODE_PACK_UNIT] VARCHAR(50)
		,[PRIORITY] NUMERIC (18, 0)
		,[LOW_LIMIT] NUMERIC (18, 0)
		,[HIGH_LIMIT] NUMERIC (18, 0)
		,[PRICE] NUMERIC (18, 6)
		,[OWNER] VARCHAR(50)
	)
	--
	DECLARE @SKU_JUST_ONCE TABLE (
		[CODE_SKU] VARCHAR(50)
		,[CODE_PACK_UNIT] VARCHAR(50)
	)
	--
	DECLARE 
		@SELLER_CODE VARCHAR(50)
		,@SELLER_OWNER VARCHAR(50)
		,@CODE_CUSTOMER VARCHAR(50)
		,@CODE_PRICE_LIST VARCHAR(50)
		,@ORIGINAL_CODE_PRICE_LIST VARCHAR(50)
		,@USER_TYPE  VARCHAR(50)
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene valores iniciales
	-- ------------------------------------------------------------------------------------
	SELECT @SELLER_CODE = [SONDA].[SWIFT_FN_GET_SELLER_BY_ROUTE](@CODE_ROUTE)
	--
	SELECT @SELLER_OWNER = [S].[OWNER]
	FROM [SONDA].[SWIFT_SELLER] [S]
	WHERE [S].[SELLER_CODE] = @SELLER_CODE
	
	-- -------------------------------------------------------------------------------------
	-- sI SON DE TIPO VENTA SE LE ASIGNAN TODOS LOS CLIENTES POR LA MODALIDAD QUE SOLICITA alza 
	-- DE UTILIZAR CAMINIONES CON VENTA YA QUE USABAN SOLO PREVENTA. POR CUARENTENA.
	---------------------------------------------------------------------------------------
	
	SELECT @USER_TYPE=USER_TYPE FROM  [SONDA].[USERS] WHERE SELLER_ROUTE = @CODE_ROUTE;
	IF (@USER_TYPE='VEN') BEGIN
			INSERT INTO @CUSTOMER
			SELECT
				DISTINCT [C].[CODE_CUSTOMER]
				,[C].[OWNER]
			FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
	END;

	-- ------------------------------------------------------------------------------------
	-- Obtiene los clientes relacionados al vendedor
	-- ------------------------------------------------------------------------------------
	INSERT INTO @CUSTOMER
	SELECT
		[C].[CODE_CUSTOMER]
		,[C].[OWNER]
	FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
	WHERE [C].[SELLER_DEFAULT_CODE] = @SELLER_CODE

	-- ------------------------------------------------------------------------------------
	-- Obtiene los clientes que estan en el plan de ruta del vendedor
	-- ------------------------------------------------------------------------------------
	/*INSERT INTO @CUSTOMER
	SELECT 
		[RP].[RELATED_CLIENT_CODE]
		,[VC].[OWNER]
	FROM [SONDA].[SONDA_ROUTE_PLAN] [RP]
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [VC] ON ([VC].[CODE_CUSTOMER] = [RP].[RELATED_CLIENT_CODE])
	LEFT JOIN @CUSTOMER [C] ON ([C].[CODE_CUSTOMER] = [RP].[RELATED_CLIENT_CODE])	
	WHERE [RP].[CODE_ROUTE] = @CODE_ROUTE
		AND [C].[CODE_CUSTOMER] IS NULL*/
	--Temporal
	INSERT INTO @CUSTOMER
	SELECT 
		[RP].[RELATED_CLIENT_CODE]
		,[VC].[OWNER]
	FROM [SONDA].[SONDA_ROUTE_PLAN] [RP]
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [VC] ON ([VC].[CODE_CUSTOMER] = [RP].[RELATED_CLIENT_CODE])
	WHERE [RP].[CODE_ROUTE] = @CODE_ROUTE
		AND [RP].[RELATED_CLIENT_CODE] NOT IN (SELECT [CODE_CUSTOMER] FROM @CUSTOMER)

	-- ------------------------------------------------------------------------------------
	-- Obtiene las listas de precios relacionadas a los clientes de la ruta
	-- ------------------------------------------------------------------------------------
	INSERT INTO @PRICE_LIST
		(
			[OWNER]
			,[CODE_ROUTE]
			,[CODE_PRICE_LIST]
			,[CODE_CUSTOMER]
			,[ORIGINAL_CODE_PRICE_LIST]
			,[CUSTOMER_OWNER]
		)
	SELECT
		[PLC].[OWNER]
		,@CODE_ROUTE [CODE_ROUTE]
		,'PL|' + CAST(ROW_NUMBER() OVER (ORDER BY [PLC].[CODE_PRICE_LIST]) AS VARCHAR)
		,[PLC].[CODE_CUSTOMER]
		,[PLC].[CODE_PRICE_LIST]
		,[C].[OWNER]
	FROM [SONDA].[SWIFT_PRICE_LIST_BY_CUSTOMER] [PLC]
	INNER JOIN @CUSTOMER [C] ON ([C].[CODE_CUSTOMER] = [PLC].[CODE_CUSTOMER])
	WHERE (@SELLER_OWNER IS NULL OR @SELLER_OWNER = '')
		OR [PLC].[OWNER] = @SELLER_OWNER
	ORDER BY [PLC].[CODE_CUSTOMER]

	IF (@SELLER_OWNER IS NOT NULL OR @SELLER_OWNER != '')
	BEGIN
		PRINT '--> @SELLER_OWNER: ' + @SELLER_OWNER
		--
		INSERT INTO @PRICE_LIST_BY_CUSTOMER
			(
				[CODE_ROUTE]
				,[CODE_PRICE_LIST]
				,[CODE_CUSTOMER]
			)
		SELECT 
			 [CODE_ROUTE]
			,[ORIGINAL_CODE_PRICE_LIST]
			,[CODE_CUSTOMER]
		FROM @PRICE_LIST
		--
		INSERT INTO @PRICE_LIST_BY_SKU_PACK_SCALE
			(
				[CODE_ROUTE]
				,[CODE_PRICE_LIST]
				,[CODE_SKU]
				,[CODE_PACK_UNIT]
				,[PRIORITY]
				,[LOW_LIMIT]
				,[HIGH_LIMIT]
				,[PRICE]
			)
		SELECT DISTINCT
			[PL].[CODE_ROUTE]
			,[PL].[ORIGINAL_CODE_PRICE_LIST]
			,[PLS].[CODE_SKU]
			,[PLS].[CODE_PACK_UNIT]
			,[PLS].[PRIORITY]
			,[PLS].[LOW_LIMIT]
			,[PLS].[HIGH_LIMIT]
			,[PLS].[PRICE]
		FROM [SONDA].[SWIFT_PRICE_LIST_BY_SKU_PACK_SCALE] [PLS]
		INNER JOIN @PRICE_LIST [PL] ON (
			[PL].[OWNER] = [PLS].[OWNER]
			AND [PL].[ORIGINAL_CODE_PRICE_LIST] = [PLS].[CODE_PRICE_LIST]
		)
	END
	ELSE
	BEGIN
		PRINT '--> @SELLER_OWNER: No tiene'

		-- ------------------------------------------------------------------------------------
		-- Obtiene los clientes que solo estan una vez
		-- ------------------------------------------------------------------------------------
		INSERT INTO @CUSTOMER_JUST_ONCE
		SELECT
			[PL].[CODE_CUSTOMER]
		FROM @PRICE_LIST [PL]
		GROUP BY
			[PL].[CODE_CUSTOMER]
		HAVING COUNT([PL].[CODE_PRICE_LIST]) = 1

		-- ------------------------------------------------------------------------------------
		-- Agrega los clientes que solo estan una vez
		-- ------------------------------------------------------------------------------------
		INSERT INTO @PRICE_LIST_BY_CUSTOMER
				(
					[CODE_ROUTE]
					,[CODE_PRICE_LIST]
					,[CODE_CUSTOMER]
				)
		SELECT 
			 [PL].[CODE_ROUTE]
			,[PL].[ORIGINAL_CODE_PRICE_LIST]
			,[PL].[CODE_CUSTOMER]
		FROM @PRICE_LIST [PL]
		INNER JOIN @CUSTOMER_JUST_ONCE [C] ON ([C].[CODE_CUSTOMER] = [PL].[CODE_CUSTOMER])
		--
		INSERT INTO @PRICE_LIST_BY_SKU_PACK_SCALE
			(
				[CODE_ROUTE]
				,[CODE_PRICE_LIST]
				,[CODE_SKU]
				,[CODE_PACK_UNIT]
				,[PRIORITY]
				,[LOW_LIMIT]
				,[HIGH_LIMIT]
				,[PRICE]
			)
		SELECT DISTINCT
			[PL].[CODE_ROUTE]
			,[PL].[ORIGINAL_CODE_PRICE_LIST]
			,[PLS].[CODE_SKU]
			,[PLS].[CODE_PACK_UNIT]
			,[PLS].[PRIORITY]
			,[PLS].[LOW_LIMIT]
			,[PLS].[HIGH_LIMIT]
			,[PLS].[PRICE]
		FROM [SONDA].[SWIFT_PRICE_LIST_BY_SKU_PACK_SCALE] [PLS]
		INNER JOIN @PRICE_LIST [PL] ON (
			[PL].[OWNER] = [PLS].[OWNER]
			AND [PL].[ORIGINAL_CODE_PRICE_LIST] = [PLS].[CODE_PRICE_LIST]
		)
		INNER JOIN @CUSTOMER_JUST_ONCE [C] ON ([C].[CODE_CUSTOMER] = [PL].[CODE_CUSTOMER])

		-- ------------------------------------------------------------------------------------
		-- Elimina los clientes que solo estan una vez
		-- ------------------------------------------------------------------------------------
		DELETE [PL]
		FROM @PRICE_LIST [PL]
		INNER JOIN @CUSTOMER_JUST_ONCE [C] ON ([C].[CODE_CUSTOMER] = [PL].[CODE_CUSTOMER])

		-- ------------------------------------------------------------------------------------
		-- Ciclo para clientes que estan en mas de una lista
		-- ------------------------------------------------------------------------------------
		WHILE EXISTS(SELECT TOP 1 1 FROM @PRICE_LIST)
		BEGIN
			-- ------------------------------------------------------------------------------------
			-- Obtiene las listas a las que pertenece el cliente
			-- ------------------------------------------------------------------------------------
			SELECT TOP 1
				@CODE_CUSTOMER = [PL].[CODE_CUSTOMER]
				,@CODE_PRICE_LIST = [PL].[CODE_PRICE_LIST]
				,@ORIGINAL_CODE_PRICE_LIST = [PL].[ORIGINAL_CODE_PRICE_LIST]
			FROM @PRICE_LIST [PL]
			WHERE [PL].[OWNER] = [PL].[CUSTOMER_OWNER]
			--
			PRINT '@CODE_CUSTOMER: ' + @CODE_CUSTOMER
			PRINT '@CODE_PRICE_LIST: ' + @CODE_PRICE_LIST
			PRINT '@ORIGINAL_CODE_PRICE_LIST: ' + @ORIGINAL_CODE_PRICE_LIST
			--
			INSERT INTO @PRICE_LIST_TEMP
					(
						[OWNER]
						,[CODE_ROUTE]
						,[CODE_PRICE_LIST]
						,[CODE_CUSTOMER]
						,[ORIGINAL_CODE_PRICE_LIST]
					)
			SELECT
				[PL].[OWNER]
				,[PL].[CODE_ROUTE]
				,[PL].[CODE_PRICE_LIST]
				,[PL].[CODE_CUSTOMER]
				,[PL].[ORIGINAL_CODE_PRICE_LIST]
			FROM @PRICE_LIST [PL]
			WHERE [PL].[CODE_CUSTOMER] = @CODE_CUSTOMER

			-- ------------------------------------------------------------------------------------
			-- Coloca la lista de precios por cliente
			-- ------------------------------------------------------------------------------------
			INSERT INTO @PRICE_LIST_BY_CUSTOMER
					(
						[CODE_ROUTE]
						,[CODE_PRICE_LIST]
						,[CODE_CUSTOMER]
					)
			VALUES
					(
						@CODE_ROUTE  -- CODE_ROUTE - varchar(50)
						,@CODE_PRICE_LIST  -- CODE_PRICE_LIST - varchar(50)
						,@CODE_CUSTOMER  -- CODE_CUSTOMER - varchar(50)
					)
			
			-- ------------------------------------------------------------------------------------
			-- Se agregan precios del dueño
			-- ------------------------------------------------------------------------------------
			INSERT INTO @PRICE_LIST_BY_SKU_PACK_SCALE
					(
						[CODE_ROUTE]
						,[CODE_PRICE_LIST]
						,[CODE_SKU]
						,[CODE_PACK_UNIT]
						,[PRIORITY]
						,[LOW_LIMIT]
						,[HIGH_LIMIT]
						,[PRICE]
					)
			SELECT
				[PLT].[CODE_ROUTE]
				,@CODE_PRICE_LIST
				,[SPS].[CODE_SKU]
				,[SPS].[CODE_PACK_UNIT]
				,[SPS].[PRIORITY]
				,[SPS].[LOW_LIMIT]
				,[SPS].[HIGH_LIMIT]
				,[SPS].[PRICE]
			FROM [SONDA].[SWIFT_PRICE_LIST_BY_SKU_PACK_SCALE] [SPS]
			INNER JOIN @PRICE_LIST_TEMP [PLT] ON (
				[PLT].[OWNER] = [SPS].[OWNER]
				AND [PLT].[ORIGINAL_CODE_PRICE_LIST] = [SPS].[CODE_PRICE_LIST]
			)
			INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S] ON (
				[S].[CODE_SKU] = [SPS].[CODE_SKU]
			)
			WHERE [PLT].[CODE_CUSTOMER] = @CODE_CUSTOMER
				AND [PLT].[ORIGINAL_CODE_PRICE_LIST] = @ORIGINAL_CODE_PRICE_LIST
			--
			DELETE FROM @PRICE_LIST_TEMP WHERE [ORIGINAL_CODE_PRICE_LIST] = @ORIGINAL_CODE_PRICE_LIST

			-- ------------------------------------------------------------------------------------
			-- Se obtiene los productos restantes
			-- ------------------------------------------------------------------------------------
			INSERT INTO @PRICE_LIST_BY_SKU_PACK_SCALE_TEMP
					(
						[CODE_ROUTE]
						,[CODE_PRICE_LIST]
						,[CODE_SKU]
						,[CODE_PACK_UNIT]
						,[PRIORITY]
						,[LOW_LIMIT]
						,[HIGH_LIMIT]
						,[PRICE]
						,[OWNER]
					)
			SELECT
				[PLT].[CODE_ROUTE]
				,[PLT].[ORIGINAL_CODE_PRICE_LIST]
				,[SPS].[CODE_SKU]
				,[SPS].[CODE_PACK_UNIT]
				,[SPS].[PRIORITY]
				,[SPS].[LOW_LIMIT]
				,[SPS].[HIGH_LIMIT]
				,[SPS].[PRICE]
				,[SPS].[OWNER]
			FROM [SONDA].[SWIFT_PRICE_LIST_BY_SKU_PACK_SCALE] [SPS]
			INNER JOIN @PRICE_LIST_TEMP [PLT] ON (
				[PLT].[OWNER] = [SPS].[OWNER]
				AND [PLT].[ORIGINAL_CODE_PRICE_LIST] = [SPS].[CODE_PRICE_LIST]
			)
			LEFT JOIN @PRICE_LIST_BY_SKU_PACK_SCALE [SPST] ON (
				[SPST].[CODE_SKU] = [SPS].[CODE_SKU]
				AND [SPST].[CODE_PACK_UNIT] = [SPS].[CODE_PACK_UNIT]
				AND [SPST].[CODE_PRICE_LIST] = @CODE_PRICE_LIST
			)
			INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S] ON (
				[S].[CODE_SKU] = [SPS].[CODE_SKU]
			)
			WHERE [PLT].[CODE_CUSTOMER] = @CODE_CUSTOMER
				AND [SPST].[PRICE] IS NULL

			-- ------------------------------------------------------------------------------------
			-- Coloca la lista de precios por producto del resto de listas a las que pertenece el cliente y que solo esten una vez
			-- ------------------------------------------------------------------------------------
			INSERT INTO @SKU_JUST_ONCE
			(
				[CODE_SKU]
				,[CODE_PACK_UNIT]
			)
			SELECT
				[SPS].[CODE_SKU]
				,[SPS].[CODE_PACK_UNIT]
			FROM @PRICE_LIST_BY_SKU_PACK_SCALE_TEMP [SPS]
			GROUP BY 
				[SPS].[CODE_SKU]
				,[SPS].[CODE_PACK_UNIT]
			HAVING COUNT(*) = 1
			--
			INSERT INTO @PRICE_LIST_BY_SKU_PACK_SCALE
					(
						[CODE_ROUTE]
						,[CODE_PRICE_LIST]
						,[CODE_SKU]
						,[CODE_PACK_UNIT]
						,[PRIORITY]
						,[LOW_LIMIT]
						,[HIGH_LIMIT]
						,[PRICE]
					)
			SELECT
				[PLT].[CODE_ROUTE]
				,@CODE_PRICE_LIST
				,[SPS].[CODE_SKU]
				,[SPS].[CODE_PACK_UNIT]
				,[SPS].[PRIORITY]
				,[SPS].[LOW_LIMIT]
				,[SPS].[HIGH_LIMIT]
				,[SPS].[PRICE]
			FROM @PRICE_LIST_BY_SKU_PACK_SCALE_TEMP [SPS]
			INNER JOIN @PRICE_LIST_TEMP [PLT] ON (
				[PLT].[OWNER] = [SPS].[OWNER]
				AND [PLT].[ORIGINAL_CODE_PRICE_LIST] = [SPS].[CODE_PRICE_LIST]
			)
			INNER JOIN @SKU_JUST_ONCE [SJO] ON (
				[SJO].[CODE_SKU] = [SPS].[CODE_SKU]
				AND [SJO].[CODE_PACK_UNIT] = [SPS].[CODE_PACK_UNIT]
			)
			WHERE [PLT].[CODE_CUSTOMER] = @CODE_CUSTOMER
			--
			DELETE [SPST]
			FROM @PRICE_LIST_BY_SKU_PACK_SCALE_TEMP [SPST]
			INNER JOIN @SKU_JUST_ONCE [S] ON (
				[S].[CODE_SKU] = [SPST].[CODE_SKU]
				AND [S].[CODE_PACK_UNIT] = [SPST].[CODE_PACK_UNIT]
			)

			-- ------------------------------------------------------------------------------------
			-- Coloca la lista de precios por producto del resto de listas a las que pertenece el cliente
			-- ------------------------------------------------------------------------------------
			INSERT INTO @PRICE_LIST_BY_SKU_PACK_SCALE
					(
						[CODE_ROUTE]
						,[CODE_PRICE_LIST]
						,[CODE_SKU]
						,[CODE_PACK_UNIT]
						,[PRIORITY]
						,[LOW_LIMIT]
						,[HIGH_LIMIT]
						,[PRICE]
					)
			SELECT
				[PLT].[CODE_ROUTE]
				,@CODE_PRICE_LIST
				,[SPS].[CODE_SKU]
				,[SPS].[CODE_PACK_UNIT]
				,[SPS].[PRIORITY]
				,[SPS].[LOW_LIMIT]
				,[SPS].[HIGH_LIMIT]
				,[SPS].[PRICE]
			FROM @PRICE_LIST_BY_SKU_PACK_SCALE_TEMP [SPS]
			INNER JOIN @PRICE_LIST_TEMP [PLT] ON (
				[PLT].[OWNER] = [SPS].[OWNER]
				AND [PLT].[ORIGINAL_CODE_PRICE_LIST] = [SPS].[CODE_PRICE_LIST]
			)
			INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S] ON (
				[S].[OWNER] = [SPS].[OWNER]
				AND [S].[CODE_SKU] = [SPS].[CODE_SKU]
			)
			WHERE [PLT].[CODE_CUSTOMER] = @CODE_CUSTOMER

			-- ------------------------------------------------------------------------------------
			-- Elimina el cliente operado
			-- ------------------------------------------------------------------------------------
			DELETE FROM @PRICE_LIST WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER
			--
			DELETE FROM @PRICE_LIST_TEMP
			--
			DELETE FROM @PRICE_LIST_BY_SKU_PACK_SCALE_TEMP
			--
			DELETE FROM @SKU_JUST_ONCE
		END
	END

	-- ------------------------------------------------------------------------------------
	-- Inserta el resultado final
	-- ------------------------------------------------------------------------------------
	INSERT INTO [SONDA].[SWIFT_PRICE_LIST_BY_CUSTOMER_FOR_ROUTE]
	(
		[CODE_ROUTE]
		,[CODE_PRICE_LIST]
		,[CODE_CUSTOMER]
	)
	SELECT DISTINCT	
		[CODE_ROUTE]
		,[CODE_PRICE_LIST]
		,[CODE_CUSTOMER]
	FROM @PRICE_LIST_BY_CUSTOMER
	--
	INSERT INTO [SONDA].[SWIFT_PRICE_LIST_BY_SKU_PACK_SCALE_FOR_ROUTE]
			(
				[CODE_ROUTE]
				,[CODE_PRICE_LIST]
				,[CODE_SKU]
				,[CODE_PACK_UNIT]
				,[PRIORITY]
				,[LOW_LIMIT]
				,[HIGH_LIMIT]
				,[PRICE]
			)
	SELECT DISTINCT
		[PLS].[CODE_ROUTE]
		,[PLS].[CODE_PRICE_LIST]
		,[PLS].[CODE_SKU]
		,[PLS].[CODE_PACK_UNIT]
		,[PLS].[PRIORITY]
		,[PLS].[LOW_LIMIT]
		,[PLS].[HIGH_LIMIT]
		,[PLS].[PRICE]
	FROM @PRICE_LIST_BY_SKU_PACK_SCALE [PLS]
END
