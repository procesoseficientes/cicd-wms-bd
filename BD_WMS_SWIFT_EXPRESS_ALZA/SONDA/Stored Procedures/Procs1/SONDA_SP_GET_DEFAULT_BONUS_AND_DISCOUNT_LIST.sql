﻿-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	13-Jan-17 @ A-TEAM Sprint Adeben 
-- Description:			SP que obtiene la lista de bonificaciones y descuentos asociada a la ruta

-- Modificacion 6/8/2017 @ A-Team Sprint 
					-- rodrigo.gomez
					-- Se agrego @SALE_BY_MULTIPLE_LIST_ID

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_GET_DEFAULT_BONUS_AND_DISCOUNT_LIST]
					@CODE_ROUTE = '001'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_DEFAULT_BONUS_AND_DISCOUNT_LIST](
	@CODE_ROUTE VARCHAR(250)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@CODE_TRADE_AGREEMENT VARCHAR(50) = NULL
		,@DISCOUNT_LIST_ID INT
		,@BONUS_LIST_ID INT
		,@SALE_BY_MULTIPLE_LIST_ID INT
	--
	SELECT @CODE_TRADE_AGREEMENT = [TA].[CODE_TRADE_AGREEMENT]
	FROM [SONDA].[SWIFT_TRADE_AGREEMENT] [TA]
	WHERE [TA].[TRADE_AGREEMENT_ID] = [SONDA].[SWIFT_FN_GET_TRADE_AGREEMENT_BY_ROUTE](@CODE_ROUTE)
	--
	SELECT TOP 1 @DISCOUNT_LIST_ID = [DL].[DISCOUNT_LIST_ID]
	FROM [SONDA].[SWIFT_DISCOUNT_LIST] [DL] 
	WHERE [DL].[NAME_DISCOUNT_LIST] = (@CODE_ROUTE + '|' + @CODE_TRADE_AGREEMENT)
	--
	SELECT TOP 1 @BONUS_LIST_ID = [BL].[BONUS_LIST_ID]
	FROM [SONDA].[SWIFT_BONUS_LIST] [BL] 
	WHERE [BL].[NAME_BONUS_LIST] = (@CODE_ROUTE + '|' + @CODE_TRADE_AGREEMENT)
	--
	SELECT TOP 1 @SALE_BY_MULTIPLE_LIST_ID = [SSBML].[SALES_BY_MULTIPLE_LIST_ID]
	FROM [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST] [SSBML] 
	WHERE [SSBML].[NAME_SALES_BY_MULTIPLE_LIST] = (@CODE_ROUTE + '|' + @CODE_TRADE_AGREEMENT)
	--
	SELECT
		@DISCOUNT_LIST_ID [DISCOUNT_LIST_ID]
		,@BONUS_LIST_ID [BONUS_LIST_ID]
		,@SALE_BY_MULTIPLE_LIST_ID [SALE_BY_MULTIPLE_LIST_ID]
END
