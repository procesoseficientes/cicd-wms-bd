-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	03-May-17 @ A-TEAM Sprint Hondo 
-- Description:			SP que administra la generacion de precios para el movil

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GENERATE_PRICE_LIST_FOR_ROUTE]
					@CODE_ROUTE = 'ES000035'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GENERATE_PRICE_LIST_FOR_ROUTE](
	@CODE_ROUTE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;

	-- ------------------------------------------------------------------------------------
	-- Limpia las listas de la ruta
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_CLEAN_PRICE_LIST_BY_ROUTE]
		@CODE_ROUTE = @CODE_ROUTE

	-- ------------------------------------------------------------------------------------
	-- Genera las listas para la ruta
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_GENERATE_PRICE_LIST]
		@CODE_ROUTE = @CODE_ROUTE

	-- ------------------------------------------------------------------------------------
	-- Genera la lista de precios por defecto de la ruta
	-- ------------------------------------------------------------------------------------
	EXEC [SONDA].[SWIFT_SP_GENERATE_DEFAULT_PRICE_LIST_BY_ROUTE]
		@CODE_ROUTE = @CODE_ROUTE
END

