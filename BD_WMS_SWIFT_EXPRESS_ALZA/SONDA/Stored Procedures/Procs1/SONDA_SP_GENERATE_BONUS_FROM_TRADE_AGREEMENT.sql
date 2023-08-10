-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	20-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que genera la lista de bonificaciones por acuerdo comercial

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SONDA_SP_GENERATE_BONUS_FROM_TRADE_AGREEMENT]
					@CODE_ROUTE = 'RUDI@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GENERATE_BONUS_FROM_TRADE_AGREEMENT]
(
	@CODE_ROUTE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;

	-- ------------------------------------------------------------------------------------
	-- Obtiene valores iniciales
	-- ------------------------------------------------------------------------------------
	DECLARE @SELLER_CODE VARCHAR(50)
	--
	SELECT @SELLER_CODE = [SONDA].SWIFT_FN_GET_SELLER_BY_ROUTE(@CODE_ROUTE)

	-- ------------------------------------------------------------------------------------
	-- Obtiene las listas de bonificaciones de la ruta para limpiarlas
	-- ------------------------------------------------------------------------------------
	SELECT DISTINCT
		BL.BONUS_LIST_ID
	INTO #BONUS
	FROM [SONDA].SWIFT_BONUS_LIST BL
	WHERE BL.NAME_BONUS_LIST LIKE ('' + @CODE_ROUTE + '|%')

	-- ------------------------------------------------------------------------------------
	-- Limpia las tablas
	-- ------------------------------------------------------------------------------------	
	DELETE BL
	FROM [SONDA].SWIFT_BONUS_LIST_BY_CUSTOMER BL
	INNER JOIN #BONUS B ON (
		BL.BONUS_LIST_ID = B.BONUS_LIST_ID
	)
	--
	DELETE BL 
	FROM [SONDA].SWIFT_BONUS_LIST_BY_SKU BL
	INNER JOIN #BONUS B ON (
		BL.BONUS_LIST_ID = B.BONUS_LIST_ID
	)
	--
	DELETE BL
	FROM [SONDA].SWIFT_BONUS_LIST BL
	INNER JOIN #BONUS B ON (
		BL.BONUS_LIST_ID = B.BONUS_LIST_ID
	)

  	-- ------------------------------------------------------------------------------------
	-- Obtiene los acuerdos comerciales de clientes
	-- ------------------------------------------------------------------------------------
	SELECT DISTINCT
		@CODE_ROUTE + '|' + TA.CODE_TRADE_AGREEMENT AS NAME_BONUS_LIST
	INTO #BONUS_LIST
	FROM [SONDA].SWIFT_VIEW_ALL_COSTUMER C
	INNER JOIN [SONDA].SWIFT_TRADE_AGREEMENT_BY_CUSTOMER TAC ON(
		C.CODE_CUSTOMER = TAC.CODE_CUSTOMER
	)
	INNER JOIN [SONDA].SWIFT_TRADE_AGREEMENT TA ON (
		TAC.TRADE_AGREEMENT_ID = TA.TRADE_AGREEMENT_ID
	)
	WHERE C.SELLER_DEFAULT_CODE = @SELLER_CODE
		AND TA.[STATUS] = 1
		AND GETDATE() BETWEEN TA.VALID_START_DATETIME AND TA.VALID_END_DATETIME
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene los acuerdos comerciales de canal
	-- ------------------------------------------------------------------------------------
	INSERT INTO #BONUS_LIST
	SELECT
		@CODE_ROUTE + '|' + TA.CODE_TRADE_AGREEMENT AS NAME_BONUS_LIST
	FROM [SONDA].SWIFT_VIEW_ALL_COSTUMER C
	INNER JOIN [SONDA].SWIFT_CHANNEL_X_CUSTOMER CC ON(
		C.CODE_CUSTOMER = CC.CODE_CUSTOMER
	)
	INNER JOIN [SONDA].SWIFT_TRADE_AGREEMENT_BY_CHANNEL TAC ON (
		CC.CHANNEL_ID = TAC.CHANNEL_ID
	)
	INNER JOIN [SONDA].SWIFT_TRADE_AGREEMENT TA ON (
		TAC.TRADE_AGREEMENT_ID = TA.TRADE_AGREEMENT_ID
	)
	WHERE C.SELLER_DEFAULT_CODE = @SELLER_CODE
		AND TA.[STATUS] = 1
		AND GETDATE() BETWEEN TA.VALID_START_DATETIME AND TA.VALID_END_DATETIME

	-- ------------------------------------------------------------------------------------
	-- Obtiene los clientes que esten en el plan de ruta y no esten asociados por vendedor
	-- ------------------------------------------------------------------------------------
	INSERT INTO #BONUS_LIST
	SELECT DISTINCT
		RP.CODE_ROUTE + '|' + TA.CODE_TRADE_AGREEMENT AS NAME_DISCOUNT_LIST
	FROM [SONDA].SONDA_ROUTE_PLAN RP
	INNER JOIN [SONDA].SWIFT_VIEW_ALL_COSTUMER C ON (
		RP.CODE_ROUTE = C.CODE_ROUTE
	)
	INNER JOIN [SONDA].SWIFT_TRADE_AGREEMENT_BY_CUSTOMER TAC ON(
		C.CODE_CUSTOMER = TAC.CODE_CUSTOMER
	)
	INNER JOIN [SONDA].SWIFT_TRADE_AGREEMENT TA ON (
		TAC.TRADE_AGREEMENT_ID = TA.TRADE_AGREEMENT_ID
	)
	WHERE RP.CODE_ROUTE = @CODE_ROUTE
		AND TA.[STATUS] = 1
		AND GETDATE() BETWEEN TA.VALID_START_DATETIME AND TA.VALID_END_DATETIME

	-- ------------------------------------------------------------------------------------
	-- Obtiene los acuerdos comerciales de los clientes que esten en el plan de ruta y no esten asociados por vendedor
	-- ------------------------------------------------------------------------------------
	INSERT INTO #BONUS_LIST
	SELECT DISTINCT
		RP.CODE_ROUTE + '|' + TA.CODE_TRADE_AGREEMENT AS NAME_DISCOUNT_LIST
	FROM [SONDA].SONDA_ROUTE_PLAN RP
	INNER JOIN [SONDA].SWIFT_VIEW_ALL_COSTUMER C ON (
		RP.CODE_ROUTE = C.CODE_ROUTE
	)
	INNER JOIN [SONDA].SWIFT_CHANNEL_X_CUSTOMER CC ON(
		C.CODE_CUSTOMER = CC.CODE_CUSTOMER
	)
	INNER JOIN [SONDA].SWIFT_TRADE_AGREEMENT_BY_CHANNEL TAC ON (
		CC.CHANNEL_ID = TAC.CHANNEL_ID
	)
	INNER JOIN [SONDA].SWIFT_TRADE_AGREEMENT TA ON (
		TAC.TRADE_AGREEMENT_ID = TA.TRADE_AGREEMENT_ID
	)
	WHERE RP.CODE_ROUTE = @CODE_ROUTE
		AND TA.[STATUS] = 1
		AND GETDATE() BETWEEN TA.VALID_START_DATETIME AND TA.VALID_END_DATETIME

	-- ------------------------------------------------------------------------------------
	-- Genera la lista de bonificaciones
	-- ------------------------------------------------------------------------------------
	INSERT INTO [SONDA].SWIFT_BONUS_LIST (NAME_BONUS_LIST)
	SELECT DISTINCT 
		DL.NAME_BONUS_LIST
	FROM #BONUS_LIST DL



	-- ------------------------------------------------------------------------------------
	-- Obtiene los acuerdos comerciales por canal
	-- ------------------------------------------------------------------------------------
	SELECT
		TAC.TRADE_AGREEMENT_ID
		,TA.CODE_TRADE_AGREEMENT
		,C.CODE_CUSTOMER
	INTO #TRADE_AGREEMENT_BY_CHANNEL
	FROM [SONDA].SWIFT_VIEW_ALL_COSTUMER C
	INNER JOIN [SONDA].SWIFT_CHANNEL_X_CUSTOMER CC ON(
		C.CODE_CUSTOMER = CC.CODE_CUSTOMER
	)
	INNER JOIN [SONDA].SWIFT_TRADE_AGREEMENT_BY_CHANNEL TAC ON (
		CC.CHANNEL_ID = TAC.CHANNEL_ID
	)
	INNER JOIN [SONDA].SWIFT_TRADE_AGREEMENT TA ON (
		TAC.TRADE_AGREEMENT_ID = TA.TRADE_AGREEMENT_ID
	)
	WHERE C.SELLER_DEFAULT_CODE = @SELLER_CODE

	-- ------------------------------------------------------------------------------------
	-- Genera clientes de las listas de bonificacion por canal
	-- ------------------------------------------------------------------------------------
	INSERT INTO [SONDA].SWIFT_BONUS_LIST_BY_CUSTOMER
	SELECT DISTINCT
		DL.BONUS_LIST_ID
		,TA.CODE_CUSTOMER
	FROM #TRADE_AGREEMENT_BY_CHANNEL TA
	INNER JOIN [SONDA].SWIFT_BONUS_LIST DL ON (
		(@CODE_ROUTE + '|' + TA.CODE_TRADE_AGREEMENT) = DL.NAME_BONUS_LIST
	)

	-- ------------------------------------------------------------------------------------
	-- Genera SKUs de la lista de descuentos
	-- ------------------------------------------------------------------------------------
	INSERT INTO [SONDA].SWIFT_BONUS_LIST_BY_SKU
	SELECT DISTINCT
		BL.BONUS_LIST_ID
		,TAB.CODE_SKU
		,TAB.PACK_UNIT
		,TAB.LOW_LIMIT
		,TAB.HIGH_LIMIT
		,TAB.CODE_SKU_BONUS
		,TAB.BONUS_QTY
		,TAB.PACK_UNIT_BONUS
	FROM #TRADE_AGREEMENT_BY_CHANNEL TA
	INNER JOIN [SONDA].SWIFT_TRADE_AGREEMENT_BONUS TAB ON (
		TA.TRADE_AGREEMENT_ID = TAB.TRADE_AGREEMENT_ID
	)
	INNER JOIN [SONDA].SWIFT_BONUS_LIST BL ON (
		(@CODE_ROUTE + '|' + TA.CODE_TRADE_AGREEMENT) = BL.NAME_BONUS_LIST
	)



	-- ------------------------------------------------------------------------------------
	-- Obtiene los acuerdos comerciales por cliente
	-- ------------------------------------------------------------------------------------
	SELECT
		TAC.TRADE_AGREEMENT_ID
		,TA.CODE_TRADE_AGREEMENT
		,C.CODE_CUSTOMER
	INTO #TRADE_AGREEMENT_BY_CUSTOMER
	FROM [SONDA].SWIFT_VIEW_ALL_COSTUMER C
	INNER JOIN [SONDA].SWIFT_TRADE_AGREEMENT_BY_CUSTOMER TAC ON(
		C.CODE_CUSTOMER = TAC.CODE_CUSTOMER
	)
	INNER JOIN [SONDA].SWIFT_TRADE_AGREEMENT TA ON (
		TAC.TRADE_AGREEMENT_ID = TA.TRADE_AGREEMENT_ID
	)
	WHERE C.SELLER_DEFAULT_CODE = @SELLER_CODE

	-- ------------------------------------------------------------------------------------
	-- Genera clientes de las listas de bonificaciones por cliente
	-- ------------------------------------------------------------------------------------
	INSERT INTO [SONDA].SWIFT_BONUS_LIST_BY_CUSTOMER
	SELECT DISTINCT
		BL.BONUS_LIST_ID
		,TA.CODE_CUSTOMER
	FROM #TRADE_AGREEMENT_BY_CUSTOMER TA
	INNER JOIN [SONDA].SWIFT_BONUS_LIST BL ON (
		(@CODE_ROUTE + '|' + TA.CODE_TRADE_AGREEMENT) = BL.NAME_BONUS_LIST
	)

	-- ------------------------------------------------------------------------------------
	-- Genera SKUs de la lista de descuentos
	-- ------------------------------------------------------------------------------------
	INSERT INTO [SONDA].SWIFT_BONUS_LIST_BY_SKU
	SELECT DISTINCT
		BL.BONUS_LIST_ID
		,TAB.CODE_SKU
		,PU1.CODE_PACK_UNIT
		,TAB.LOW_LIMIT
		,TAB.HIGH_LIMIT
		,TAB.CODE_SKU_BONUS
		,TAB.BONUS_QTY
		,PU2.CODE_PACK_UNIT
	FROM #TRADE_AGREEMENT_BY_CUSTOMER TA
	INNER JOIN [SONDA].SWIFT_TRADE_AGREEMENT_BONUS TAB ON (
		TA.TRADE_AGREEMENT_ID = TAB.TRADE_AGREEMENT_ID
	)
	INNER JOIN [SONDA].SWIFT_BONUS_LIST BL ON (
		(@CODE_ROUTE + '|' + TA.CODE_TRADE_AGREEMENT) = BL.NAME_BONUS_LIST
	)
	INNER JOIN [SONDA].SONDA_PACK_UNIT PU1 ON (
		TAB.PACK_UNIT = PU1.PACK_UNIT
	)
	INNER JOIN [SONDA].SONDA_PACK_UNIT PU2 ON (
		TAB.PACK_UNIT_BONUS = PU2.PACK_UNIT
	)
END
