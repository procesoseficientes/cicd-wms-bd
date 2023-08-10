-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	17-Oct-16 @ A-Team Sprint 3
-- Description:			SP que genera la lista de bonificaciones por acuerdo comercial

-- Modificacion 12-Jan-17 @ A-Team Sprint Adeben
					-- alberto.ruiz
					-- Se agrego segmento para agregar lista de clientes nuevos

-- Modificacion 27-Jul-17 @ Nexus Team Sprint AgeOfEmpires
					-- alberto.ruiz
					-- Se cambio para que obtenga las listas por el codigo de ruta

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_GENERATE_BONUS_LIST]
					@CODE_ROUTE = '44'
				--
				SELECT * FROM [SONDA].SWIFT_BONUS_LIST WHERE CODE_ROUTE = '44'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GENERATE_BONUS_LIST] (
	@CODE_ROUTE VARCHAR(250)
)
AS
BEGIN
	SET NOCOUNT ON;
	-- ------------------------------------------------------------------------------------
	-- Obtiene valores iniciales
	-- ------------------------------------------------------------------------------------
	DECLARE @BONUS_LIST TABLE(
		[NAME_BONUS_LIST] VARCHAR(250)
	)
	--
	DECLARE 
		@SELLER_CODE VARCHAR(50)
		,@ACTIVE_STATUS INT = 1
		,@NOW DATETIME = GETDATE()
	--
	SELECT @SELLER_CODE = [SONDA].[SWIFT_FN_GET_SELLER_BY_ROUTE](@CODE_ROUTE)
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene los acuerdos comerciales de clientes
	-- ------------------------------------------------------------------------------------
	INSERT INTO @BONUS_LIST
			([NAME_BONUS_LIST])
	SELECT DISTINCT
		@CODE_ROUTE + '|' + [TA].[CODE_TRADE_AGREEMENT] AS [NAME_BONUS_LIST]
	FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
	INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC] ON(
		[C].[CODE_CUSTOMER] = [TAC].[CODE_CUSTOMER]
	)
	INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA] ON (
		[TAC].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID]
	)
	WHERE [C].[SELLER_DEFAULT_CODE] = @SELLER_CODE
		AND [TA].[STATUS] = @ACTIVE_STATUS
		AND @NOW BETWEEN [TA].[VALID_START_DATETIME] AND [TA].[VALID_END_DATETIME]

	-- ------------------------------------------------------------------------------------
	-- Obtiene los clientes que esten en el plan de ruta y no esten asociados por vendedor
	-- ------------------------------------------------------------------------------------
	INSERT INTO @BONUS_LIST
			([NAME_BONUS_LIST])
	SELECT
		[RP].[CODE_ROUTE] + '|' + [TA].[CODE_TRADE_AGREEMENT] AS [NAME_BONUS_LIST]
	FROM [SONDA].[SONDA_ROUTE_PLAN] [RP]	
	INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC] ON(
		[RP].[RELATED_CLIENT_CODE] = [TAC].[CODE_CUSTOMER]
	)
	INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA] ON (
		[TAC].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID]
	)
	WHERE [RP].[CODE_ROUTE] = @CODE_ROUTE
		AND [TA].[STATUS] = @ACTIVE_STATUS
		AND @NOW BETWEEN [TA].[VALID_START_DATETIME] AND [TA].[VALID_END_DATETIME]
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene los acuerdos comerciales de canal
	-- ------------------------------------------------------------------------------------
	INSERT INTO @BONUS_LIST
			([NAME_BONUS_LIST])
	SELECT
		@CODE_ROUTE + '|' + [TA].[CODE_TRADE_AGREEMENT] AS [NAME_BONUS_LIST]
	FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
	INNER JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC] ON(
		[C].[CODE_CUSTOMER] = [CC].[CODE_CUSTOMER]
	)
	INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL] [TAC] ON (
		[CC].[CHANNEL_ID] = [TAC].[CHANNEL_ID]
	)
	INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA] ON (
		[TAC].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID]
	)
	WHERE [C].[SELLER_DEFAULT_CODE] = @SELLER_CODE
		AND [TA].[STATUS] = @ACTIVE_STATUS
		AND @NOW BETWEEN [TA].[VALID_START_DATETIME] AND [TA].[VALID_END_DATETIME]
		AND TAC.[TRADE_AGREEMENT_ID] > 0

	-- ------------------------------------------------------------------------------------
	-- Obtiene los acuerdos comerciales de los clientes que esten en el plan de ruta y no esten asociados por vendedor
	-- ------------------------------------------------------------------------------------
	INSERT INTO @BONUS_LIST
			([NAME_BONUS_LIST])
	SELECT
		@CODE_ROUTE + '|' + [TA].[CODE_TRADE_AGREEMENT] AS [NAME_BONUS_LIST]
	FROM [SONDA].[SONDA_ROUTE_PLAN] [RP]	
	INNER JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC] ON(
		[RP].[RELATED_CLIENT_CODE] = [CC].[CODE_CUSTOMER]
	)
	INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL] [TAC] ON (
		[CC].[CHANNEL_ID] = [TAC].[CHANNEL_ID]
	)
	INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA] ON (
		[TAC].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID]
	)
	WHERE [RP].[CODE_ROUTE] = @CODE_ROUTE
		AND [TA].[STATUS] = @ACTIVE_STATUS
		AND @NOW BETWEEN [TA].[VALID_START_DATETIME] AND [TA].[VALID_END_DATETIME]
		AND TAC.[TRADE_AGREEMENT_ID] > 0

	-- ------------------------------------------------------------------------------------
	-- Agrega la lista del acuerdo comercial para los nuevos clientes de ser necesario
	-- ------------------------------------------------------------------------------------
	IF (SELECT [SONDA].[SWIFT_FN_VALIDATE_TRADE_AGREEMENT_BY_ROUTE](@CODE_ROUTE)) = 1
	BEGIN
		DECLARE @TRADE_AGREEMENT_ID INT = NULL
		--
		SELECT @TRADE_AGREEMENT_ID = [SONDA].[SWIFT_FN_GET_TRADE_AGREEMENT_BY_ROUTE](@CODE_ROUTE)
		--
		INSERT INTO @BONUS_LIST
				([NAME_BONUS_LIST])
		SELECT (@CODE_ROUTE + '|' + [T].[CODE_TRADE_AGREEMENT])
		FROM [SONDA].[SWIFT_TRADE_AGREEMENT] [T]
		WHERE [T].[TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID
	END

	-- ------------------------------------------------------------------------------------
	-- Genera la lista de descuentos
	-- ------------------------------------------------------------------------------------
	INSERT INTO [SONDA].[SWIFT_BONUS_LIST]
			([NAME_BONUS_LIST]
			,[CODE_ROUTE])
	SELECT DISTINCT 
		[BL].[NAME_BONUS_LIST]
		,@CODE_ROUTE
	FROM @BONUS_LIST [BL]
END
