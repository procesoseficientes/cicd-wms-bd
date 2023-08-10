-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Feb-17 @ A-TEAM Sprint Chatuluka 
-- Description:			SP que genera limpia los duplicados de las listas de venta por multiplo de la ruta

-- Modificacion 27-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se cambio para que obtenga las listas por el codigo de ruta y de las tablas de promo

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_CLEAN_DUPLICATE_CUSTOMER_IN_SKU_SALES_BY_MULTIPLE_LIST_BY_ROUTE]
					@CODE_ROUTE = '44'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_CLEAN_DUPLICATE_CUSTOMER_IN_SKU_SALES_BY_MULTIPLE_LIST_BY_ROUTE] (@CODE_ROUTE VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;

  -- ------------------------------------------------------------------------------------
  -- Obtiene valores iniciales
  -- ------------------------------------------------------------------------------------
  DECLARE @SELLER_CODE VARCHAR(50)
  --
  DECLARE @CUSTOMER TABLE (
    [CODE_CUSTOMER] VARCHAR(50)
   ,UNIQUE ([CODE_CUSTOMER])
  )
  --
  SELECT
    @SELLER_CODE = [SONDA].SWIFT_FN_GET_SELLER_BY_ROUTE(@CODE_ROUTE)

  -- ------------------------------------------------------------------------------------
  -- Obtiene los clientes a eliminar
  -- ------------------------------------------------------------------------------------
  INSERT INTO @CUSTOMER
    SELECT
      [SMC].[CODE_CUSTOMER]
    FROM [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST_BY_CUSTOMER] [SMC]
    INNER JOIN [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST] [SM]
      ON (
      [SM].[SALES_BY_MULTIPLE_LIST_ID] = [SMC].[SALES_BY_MULTIPLE_LIST_ID]
      )
    WHERE [SM].[CODE_ROUTE] = @CODE_ROUTE
    GROUP BY [SMC].[CODE_CUSTOMER]
    HAVING COUNT([SMC].[CODE_CUSTOMER]) > 1

  -- ------------------------------------------------------------------------------------
  -- Elimina los clientes repetidos
  -- ------------------------------------------------------------------------------------
  DELETE [SMC]
    FROM [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST_BY_CUSTOMER] [SMC]
    INNER JOIN @CUSTOMER [C]
      ON (
      [SMC].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER]
      )  
END
