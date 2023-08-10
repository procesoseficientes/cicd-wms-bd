-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	17-Oct-16 @ A-Team Sprint 3
-- Description:			SP que genera la lista de bonificaciones y lista de clientes por lista de bonificaciones

-- Modificacion 21-Nov-16 @ A-Team Sprint 5
					-- alberto.ruiz
					-- Se agrego que tambien genere la bonificaciones por multiplos

-- Modificacion 10-Feb-17 @ A-Team Sprint Chatuluka
					-- alberto.ruiz
					-- Se agrego que genere las bonificaciones por combo

-- Modificacion 31-Jul-17 @ Nexus Team Sprint AgeOfEmpires
					-- alberto.ruiz
					-- Se agrega segmento de BMG

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_GENERATE_BONUS_FROM_TRADE_AGREEMENT]
					@CODE_ROUTE = '44'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GENERATE_BONUS_FROM_TRADE_AGREEMENT] (
	@CODE_ROUTE VARCHAR(250)
)
AS
BEGIN
	SET NOCOUNT ON;
	-- ------------------------------------------------------------------------------------
	-- Limpia los bonificaciones para la ruta
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_CLEAN_BONUS_LIST_BY_ROUTE]
		@CODE_ROUTE = @CODE_ROUTE

	-- ------------------------------------------------------------------------------------
	-- Genera las listas de precios
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_GENERATE_BONUS_LIST]
		@CODE_ROUTE = @CODE_ROUTE

	-- ------------------------------------------------------------------------------------
	-- Genera lista por canal
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_GENERATE_BONUS_BY_CHANNEL]
		@CODE_ROUTE = @CODE_ROUTE

	-- ------------------------------------------------------------------------------------
	-- Genera lista por clientes
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_GENERATE_BONUS_BY_TRADE_AGREEMENT]
		@CODE_ROUTE = @CODE_ROUTE

	-- ------------------------------------------------------------------------------------
	-- Limpia los repetidos
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_CLEAN_DUPLICATE_CUSTOMER_IN_BONUS_LIST_BY_ROUTE]
		@CODE_ROUTE = @CODE_ROUTE

	-- ------------------------------------------------------------------------------------
	-- Genera lista para los clientes repetidos
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_GENERATE_BONUS_FOR_DUPLICATE_CUSTOMER]
		@CODE_ROUTE = @CODE_ROUTE
		,@TYPE = 'SCALE'

	-- ------------------------------------------------------------------------------------
	-- Genera lista de multiplos para los clientes repetidos 
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_GENERATE_BONUS_FOR_DUPLICATE_CUSTOMER]
		@CODE_ROUTE = @CODE_ROUTE
		,@TYPE = 'MULTIPLE'

	-- ------------------------------------------------------------------------------------
	-- Genera lista de combos para los clientes repetidos 
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_GENERATE_BONUS_FOR_DUPLICATE_CUSTOMER]
		@CODE_ROUTE = @CODE_ROUTE
		,@TYPE = 'COMBO'

	-- ------------------------------------------------------------------------------------
	-- Genera lista de BMG para los clientes repetidos 
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_GENERATE_BONUS_FOR_DUPLICATE_CUSTOMER]
		@CODE_ROUTE = @CODE_ROUTE
		,@TYPE = 'GENERAL_AMOUNT'
END
