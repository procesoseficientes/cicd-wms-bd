
-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-22 @ Team REBORN - Sprint 
-- Description:	        SP que genera los pricelist por ruta si no es intercompany

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[BULK_DATA_SP_GENERATE_PRICE_LIST_FOR_ROUTE]
*/
-- =============================================
CREATE PROCEDURE [wms].[BULK_DATA_SP_GENERATE_PRICE_LIST_FOR_ROUTE]
AS
BEGIN
  SET NOCOUNT ON;
  --

  ------------------------------------------------------------------------------------
  -- Se valida si la implementacion es INTERCOMPANY
  -- ------------------------------------------------------------------------------------
  IF EXISTS (SELECT
        *
      FROM [SWIFT_EXPRESS].[wms].[SWIFT_PARAMETER] [SP]
      WHERE [SP].[GROUP_ID] = 'IMPLEMENTATION'
      AND [SP].[PARAMETER_ID] = 'IS_INTERCOMPANY'
      AND [SP].[VALUE] = '0')
  BEGIN

    ------------------------------------------------------------------------------------
    -- Se optienen todas las rutas de SWIFT_EXPRESS y se trunquea talba [SWIFT_PRICE_LIST_BY_CUSTOMER_FOR_ROUTE]
    -- ------------------------------------------------------------------------------------
    TRUNCATE TABLE [SWIFT_EXPRESS].[wms].[SWIFT_PRICE_LIST_BY_CUSTOMER_FOR_ROUTE]

    DECLARE @CODE_ROUTE VARCHAR(50)

    DECLARE @ROUTES TABLE (
      [CODE_ROUTE] VARCHAR(50) NOT NULL PRIMARY KEY
    )

    INSERT INTO @ROUTES ([CODE_ROUTE])
      SELECT DISTINCT
        [SR].[CODE_ROUTE]
      FROM [SWIFT_EXPRESS].[wms].[SWIFT_ROUTES] [SR]
      INNER JOIN [SWIFT_EXPRESS].[wms].[USERS] [U]
        ON [SR].[CODE_ROUTE] = [U].[SELLER_ROUTE]
      WHERE [U].[RELATED_SELLER] IS NOT NULL;

    ------------------------------------------------------------------------------------
    -- Se recorren las rutas para insertarlas a [SWIFT_PRICE_LIST_BY_CUSTOMER_FOR_ROUTE]
    -- ------------------------------------------------------------------------------------
    WHILE (EXISTS (SELECT TOP 1
        1
      FROM @ROUTES)
    )
    BEGIN
    SELECT TOP 1
      @CODE_ROUTE = [CODE_ROUTE]
    FROM @ROUTES
    ORDER BY [CODE_ROUTE]

    EXEC [SWIFT_EXPRESS].[wms].[SWIFT_SP_GENERATE_PRICE_LIST_FOR_ROUTE] @CODE_ROUTE = @CODE_ROUTE

    DELETE FROM @ROUTES
    WHERE [CODE_ROUTE] = @CODE_ROUTE;

    END


  END

END


