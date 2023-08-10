-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que genera la lista de descuentos y lista de clientes por lista de descuentos

-- Modificacion 16-Feb-17 @ A-Team Sprint Chatuluka
-- alberto.ruiz
-- Se agrega seccion para generar los descuentos generales duplicados

-- Modificacion 09-May-2018 @ G-Force Sprint Caribú
-- rudi.garcia
-- Se agrego la generacion de descuentos para (monto general y familia) y (familia y tipo de pago)

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_GENERATE_DISCOUNT_FROM_TRADE_AGREEMENT]
					@CODE_ROUTE = '4'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GENERATE_DISCOUNT_FROM_TRADE_AGREEMENT (@CODE_ROUTE VARCHAR(250))
AS
BEGIN
  SET NOCOUNT ON;
  -- ------------------------------------------------------------------------------------
  -- Limpia los descuentos para la ruta
  -- ------------------------------------------------------------------------------------
  EXEC [SONDA].[SWIFT_SP_CLEAN_DISCOUNT_LIST_BY_ROUTE] @CODE_ROUTE = @CODE_ROUTE

  -- ------------------------------------------------------------------------------------
  -- Genera las listas de precios
  -- ------------------------------------------------------------------------------------
  EXEC [SONDA].[SWIFT_SP_GENERATE_DISCOUNT_LIST] @CODE_ROUTE = @CODE_ROUTE

  -- ------------------------------------------------------------------------------------
  -- Genera lista por canal
  -- ------------------------------------------------------------------------------------
  EXEC [SONDA].[SWIFT_SP_GENERATE_DISCOUNT_BY_CHANNEL] @CODE_ROUTE = @CODE_ROUTE

  -- ------------------------------------------------------------------------------------
  -- Genera lista por clientes
  -- ------------------------------------------------------------------------------------
  EXEC [SONDA].[SWIFT_SP_GENERATE_DISCOUNT_BY_TRADE_AGREEMENT] @CODE_ROUTE = @CODE_ROUTE

  -- ------------------------------------------------------------------------------------
  -- Limpia los repetidos
  -- ------------------------------------------------------------------------------------
  EXEC [SONDA].[SWIFT_SP_CLEAN_DUPLICATE_CUSTOMER_IN_DISCOUNT_LIST_BY_ROUTE] @CODE_ROUTE = @CODE_ROUTE

  -- ------------------------------------------------------------------------------------
  -- Genera lista para los clientes repetidos
  -- ------------------------------------------------------------------------------------
  EXEC [SONDA].[SWIFT_SP_GENERATE_DISCOUNT_LIST_BY_ROUTE_FOR_REPEATED_CUSTOMER] @CODE_ROUTE = @CODE_ROUTE

  -- ------------------------------------------------------------------------------------
  -- Genera los descuentos generales para los clientes repetidos
  -- ------------------------------------------------------------------------------------
  EXEC [SONDA].[SWIFT_SP_GENERATE_DISCOUNT_FOR_DUPLICATE_CUSTOMER] @CODE_ROUTE = @CODE_ROUTE
                                                                  ,@TYPE = 'GENERAL_AMOUNT'

  -- ------------------------------------------------------------------------------------
  -- Genera los descuentos generales y familias para los clientes repetidos
  -- ------------------------------------------------------------------------------------
  EXEC [SONDA].[SWIFT_SP_GENERATE_DISCOUNT_FOR_DUPLICATE_CUSTOMER] @CODE_ROUTE = @CODE_ROUTE
                                                                  ,@TYPE = 'GENERAL_AMOUNT_AND_FAMILY'

  -- ------------------------------------------------------------------------------------
  -- Genera los descuentos por familia y tipo de pago para los clientes repetidos
  -- ------------------------------------------------------------------------------------
  EXEC [SONDA].[SWIFT_SP_GENERATE_DISCOUNT_FOR_DUPLICATE_CUSTOMER] @CODE_ROUTE = @CODE_ROUTE
                                                                  ,@TYPE = 'FAMILY_AND_PAYMENT_TYPE'
END
