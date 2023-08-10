-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-18 @ Team REBORN - Sprint 
-- Description:	        SP  que preprocesa la data para que el inicio de ruta no sea tan pesado para el [SONDA_SP_GET_READY_TO_START_ROUTE]

/*
-- Ejemplo de Ejecucion:
			EXEC  [SONDA].[SWIFT_SP_PREPROCESS_DATA_FOR_INITAL_ROUTE]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_PREPROCESS_DATA_FOR_INITAL_ROUTE]
AS
BEGIN
  SET NOCOUNT ON;
  --

  ------------------------------------------------------------------------------------
  -- Se optienen todas las rutas de SWIFT_EXPRESS y se trunquea talba [SWIFT_PRICE_LIST_BY_CUSTOMER_FOR_ROUTE]
  -- ------------------------------------------------------------------------------------
  DECLARE @CODE_ROUTE VARCHAR(50)
         ,@LOG_MESSAGE NVARCHAR(2048);

  DECLARE @ROUTES TABLE (
    [CODE_ROUTE] VARCHAR(50) NOT NULL PRIMARY KEY
  )

  INSERT INTO @ROUTES ([CODE_ROUTE])
    SELECT DISTINCT
      [SR].[CODE_ROUTE]
    FROM [SWIFT_EXPRESS].[SONDA].[SWIFT_ROUTES] [SR]
    INNER JOIN [SWIFT_EXPRESS].[SONDA].[USERS] [U]
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

  BEGIN TRY

    EXEC [SWIFT_EXPRESS].[SONDA].[SONDA_SP_GET_READY_TO_START_ROUTE] @CODE_ROUTE = @CODE_ROUTE
                                                                    ,@CALLED_FROM_PREPROCESS = 1

  END TRY
  BEGIN CATCH

    SELECT
      @CODE_ROUTE AS RUTA
     ,@@error AS ERROR
     ,ERROR_MESSAGE() AS MENSAJE

    SET @LOG_MESSAGE = ERROR_MESSAGE()
    EXEC [SWIFT_EXPRESS].[SONDA].[SONDA_SP_INSERT_SONDA_SERVER_ERROR_LOG] @CODE_ROUTE = @CODE_ROUTE
                                                         ,@LOGIN = 'Preprocess'
                                                         ,@SOURCE_ERROR = '[SWIFT_SP_PREPROCESS_DATA_FOR_INITAL_ROUTE]'
                                                         ,@DOC_RESOLUTION = NULL
                                                         ,@DOC_SERIE = NULL
                                                         ,@DOC_NUM = NULL
                                                         ,@MESSAGE_ERROR = @LOG_MESSAGE
                                                         ,@SEVERITY_CODE = 10

  END CATCH
    DELETE FROM @ROUTES
    WHERE [CODE_ROUTE] = @CODE_ROUTE;

  END


END