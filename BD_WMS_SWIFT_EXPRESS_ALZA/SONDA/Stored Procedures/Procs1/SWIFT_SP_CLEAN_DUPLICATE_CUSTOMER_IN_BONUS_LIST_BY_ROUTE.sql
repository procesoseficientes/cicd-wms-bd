-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	17-Oct-16 @ A-Team Sprint 3
-- Description:			SP que genera la lista de bonificaciones por acuerdo comercial de clientes

-- Modificacion 27-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se cambio para que obtenga las listas por el codigo de ruta y de las tablas de promo

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_CLEAN_DUPLICATE_CUSTOMER_IN_BONUS_LIST_BY_ROUTE]
					@CODE_ROUTE = '44'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_CLEAN_DUPLICATE_CUSTOMER_IN_BONUS_LIST_BY_ROUTE] (@CODE_ROUTE VARCHAR(250))
AS
BEGIN
  SET NOCOUNT ON;

  -- ------------------------------------------------------------------------------------
  -- Obtiene valores iniciales
  -- ------------------------------------------------------------------------------------
  DECLARE @SELLER_CODE VARCHAR(50)
  --
  DECLARE @CUSTEMER TABLE (
    [CODE_CUSTOMER] VARCHAR(50)
   ,UNIQUE ([CODE_CUSTOMER])
  )
  --
  SELECT
    @SELLER_CODE = [SONDA].SWIFT_FN_GET_SELLER_BY_ROUTE(@CODE_ROUTE)

  -- ------------------------------------------------------------------------------------
  -- Obtiene los clientes a eliminar
  -- ------------------------------------------------------------------------------------
  INSERT INTO @CUSTEMER
    SELECT
      [BLC].[CODE_CUSTOMER]
    FROM [SONDA].[SWIFT_BONUS_LIST_BY_CUSTOMER] [BLC]
    INNER JOIN [SONDA].[SWIFT_BONUS_LIST] [BL]
      ON (
      [BL].[BONUS_LIST_ID] = [BLC].[BONUS_LIST_ID]
      )
    WHERE [BL].[CODE_ROUTE] = @CODE_ROUTE
    GROUP BY [BLC].[CODE_CUSTOMER]
    HAVING COUNT([BLC].[CODE_CUSTOMER]) > 1

  -- ------------------------------------------------------------------------------------
  -- Elimina los clientes repetidos
  -- ------------------------------------------------------------------------------------
  DELETE [BLC]
    FROM [SONDA].[SWIFT_BONUS_LIST_BY_CUSTOMER] [BLC]
    INNER JOIN @CUSTEMER [C]
      ON (
      [BLC].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER]
      )

END
