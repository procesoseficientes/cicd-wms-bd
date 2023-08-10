-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		11/14/2018 @ G-Force Team Sprint Mamut
-- Historia/Bug:			Product Backlog Item 25662: Precios Especiales en el movil
-- Description:	11/14/2018 - SP que procesa la informacion de las listas de precios especiales por escala

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].SWIFT_SP_GENERATE_SPECIAL_PRICE_FROM_TRADE_AGREEMENT
		@CODE_ROUTE= '136'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GENERATE_SPECIAL_PRICE_FROM_TRADE_AGREEMENT]
	(
		@CODE_ROUTE VARCHAR(250)
	)
AS
	BEGIN
		SET NOCOUNT ON;
		-- ------------------------------------------------------------------------------------
		-- Limpia los precios especiales para la ruta
		-- ------------------------------------------------------------------------------------
		EXEC [SONDA].[SWIFT_SP_CLEAN_SPECIAL_PRICE_LIST_BY_ROUTE] @CODE_ROUTE = @CODE_ROUTE;

		-- ------------------------------------------------------------------------------------
		-- Genera las listas de precios especiales
		-- ------------------------------------------------------------------------------------
		EXEC [SONDA].[SWIFT_SP_GENERATE_SPECIAL_PRICE_LIST] @CODE_ROUTE = @CODE_ROUTE;

		-- ------------------------------------------------------------------------------------
		-- Genera lista por canal
		-- ------------------------------------------------------------------------------------
		EXEC [SONDA].[SWIFT_SP_GENERATE_SPECIAL_PRICE_LIST_BY_CHANNEL] @CODE_ROUTE = @CODE_ROUTE;

		-- ------------------------------------------------------------------------------------
		-- Genera lista por clientes
		-- ------------------------------------------------------------------------------------
		EXEC [SONDA].[SWIFT_SP_GENERATE_SPECIAL_PRICE_LIST_BY_CUSTOMER] @CODE_ROUTE = @CODE_ROUTE;

		-- ------------------------------------------------------------------------------------
		-- Limpia los repetidos
		-- ------------------------------------------------------------------------------------
		EXEC [SONDA].[SWIFT_SP_CLEAN_DUPLICATE_CUSTOMER_IN_SPECIAL_PRICE_LIST_BY_ROUTE] @CODE_ROUTE = @CODE_ROUTE;

		-- ------------------------------------------------------------------------------------
		-- Genera lista para los clientes repetidos
		-- ------------------------------------------------------------------------------------
		EXEC [SONDA].[SWIFT_SP_GENERATE_SPECIAL_PRICE_LIST_BY_ROUTE_FOR_REPEATED_CUSTOMER] @CODE_ROUTE = @CODE_ROUTE;

	END;
