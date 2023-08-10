-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	28-Apr-17 @ A-TEAM Sprint Hondo 
-- Description:			SP que limpia las tablas de precios para el movil de una ruta

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_CLEAN_PRICE_LIST_BY_ROUTE]
					@CODE_ROUTE = 'GUA0032@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_CLEAN_PRICE_LIST_BY_ROUTE](
	@CODE_ROUTE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DELETE FROM [SONDA].[SWIFT_PRICE_LIST_BY_CUSTOMER_FOR_ROUTE] WHERE [CODE_ROUTE] = @CODE_ROUTE
	--
	DELETE FROM [SWIFT_EXPRESS].[SONDA].[SWIFT_PRICE_LIST_BY_SKU_PACK_SCALE_FOR_ROUTE] WHERE [CODE_ROUTE] = @CODE_ROUTE
END
