-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Feb-17 @ A-TEAM Sprint Chatuluka 
-- Description:			SP que limpia la lista de venta por multiplo

-- Modificacion 26-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se cambio para que obtenga las listas por el codigo de ruta

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_CLEAN_SKU_SALES_BY_MULTIPLE_LIST_BY_ROUTE]
					@CODE_ROUTE = '44'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_CLEAN_SKU_SALES_BY_MULTIPLE_LIST_BY_ROUTE] (@CODE_ROUTE VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @SALES_BY_MULTIPLE TABLE (
    [SALES_BY_MULTIPLE_LIST_ID] INT
   ,UNIQUE ([SALES_BY_MULTIPLE_LIST_ID])
  )

  -- ------------------------------------------------------------------------------------
  -- Obtiene las listas de descuentos
  -- ------------------------------------------------------------------------------------
  INSERT INTO @SALES_BY_MULTIPLE
    SELECT DISTINCT
      [S].[SALES_BY_MULTIPLE_LIST_ID]
    FROM [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST] [S]
    WHERE [S].[CODE_ROUTE] = @CODE_ROUTE

  -- ------------------------------------------------------------------------------------
  -- Limpia las tablas
  -- ------------------------------------------------------------------------------------	
  DELETE [S]
    FROM [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST_BY_CUSTOMER] [S]
    INNER JOIN @SALES_BY_MULTIPLE [SL]
      ON (
      [S].[SALES_BY_MULTIPLE_LIST_ID] = [SL].[SALES_BY_MULTIPLE_LIST_ID]
      )
  WHERE [SL].[SALES_BY_MULTIPLE_LIST_ID] > 0
  --
  DELETE [S]
    FROM [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST_BY_SKU] [S]
    INNER JOIN @SALES_BY_MULTIPLE [SL]
      ON (
      [S].[SALES_BY_MULTIPLE_LIST_ID] = [SL].[SALES_BY_MULTIPLE_LIST_ID]
      )
  WHERE [SL].[SALES_BY_MULTIPLE_LIST_ID] > 0
  --
  DELETE [S]
    FROM [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST] [S]
    INNER JOIN @SALES_BY_MULTIPLE [SL]
      ON (
      [S].[SALES_BY_MULTIPLE_LIST_ID] = [SL].[SALES_BY_MULTIPLE_LIST_ID]
      )
  WHERE [SL].[SALES_BY_MULTIPLE_LIST_ID] > 0
END
