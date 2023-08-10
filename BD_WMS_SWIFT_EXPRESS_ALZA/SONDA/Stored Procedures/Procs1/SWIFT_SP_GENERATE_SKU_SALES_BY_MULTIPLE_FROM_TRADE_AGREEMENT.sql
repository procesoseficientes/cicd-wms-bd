-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Feb-17 @ A-TEAM Sprint Chatuluka 
-- Description:			SP que genera la lista de Venta por multiplo y lista de clientes por lista de venta por multiplo

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GENERATE_SKU_SALES_BY_MULTIPLE_FROM_TRADE_AGREEMENT]
					@CODE_ROUTE = '4'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GENERATE_SKU_SALES_BY_MULTIPLE_FROM_TRADE_AGREEMENT](
	@CODE_ROUTE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	-- ------------------------------------------------------------------------------------
	-- Limpia las listas de venta por multiplo
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_CLEAN_SKU_SALES_BY_MULTIPLE_LIST_BY_ROUTE]
		@CODE_ROUTE = @CODE_ROUTE

	-- ------------------------------------------------------------------------------------
	-- Genera las listas de venta por multiplo
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_GENERATE_SKU_SALES_BY_MULTIPLE_LIST]
		@CODE_ROUTE = @CODE_ROUTE

	-- ------------------------------------------------------------------------------------
	-- Genera lista por canal
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_GENERATE_SKU_SALES_BY_MULTIPLE_BY_CHANNEL]
		@CODE_ROUTE = @CODE_ROUTE

	-- ------------------------------------------------------------------------------------
	-- Genera lista por clientes
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_GENERATE_SKU_SALES_BY_MULTIPLE_BY_TRADE_AGREEMENT]
		@CODE_ROUTE = @CODE_ROUTE

	-- ------------------------------------------------------------------------------------
	-- Limpia los repetidos
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_CLEAN_DUPLICATE_CUSTOMER_IN_SKU_SALES_BY_MULTIPLE_LIST_BY_ROUTE]
		@CODE_ROUTE = @CODE_ROUTE

	-- ------------------------------------------------------------------------------------
	-- Genera lista para los clientes repetidos
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_GENERATE_SKU_SALES_BY_MULTIPLE_LIST_BY_ROUTE_FOR_REPEATED_CUSTOMER]
		@CODE_ROUTE = @CODE_ROUTE
END
