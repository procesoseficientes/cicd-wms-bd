-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que genera la lista de descuentos por acuerdo comercial de clientes

-- Modificacion 12-Jan-17 @ A-Team Sprint Adeben
-- alberto.ruiz
-- Se agrego segmento para agregar lista de clientes nuevos

-- Modificacion 25-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se cambio para que guarde las listas con el codigo de ruta

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_GENERATE_DISCOUNT_LIST]
					@CODE_ROUTE = '44'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GENERATE_DISCOUNT_LIST] (@CODE_ROUTE VARCHAR(250)) WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT ON;
  -- ------------------------------------------------------------------------------------
  -- Obtiene valores iniciales
  -- ------------------------------------------------------------------------------------
  DECLARE @DISCOUNT_LIST TABLE (
    [NAME_DISCOUNT_LIST] VARCHAR(101)
  )
  --
  DECLARE @SELLER_CODE NVARCHAR(155)
         ,@NOW DATETIME = GETDATE()
  --
  SELECT
    @SELLER_CODE = [SONDA].[SWIFT_FN_GET_SELLER_BY_ROUTE](@CODE_ROUTE)

  -- ------------------------------------------------------------------------------------
  -- Obtiene los acuerdos comerciales de clientes
  -- ------------------------------------------------------------------------------------
  INSERT INTO @DISCOUNT_LIST ([NAME_DISCOUNT_LIST])
    SELECT DISTINCT
      @CODE_ROUTE + '|' + [TA].[CODE_TRADE_AGREEMENT] AS [NAME_DISCOUNT_LIST]
    FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
      ON (
      [C].[CODE_CUSTOMER] = [TAC].[CODE_CUSTOMER]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA]
      ON (
      [TAC].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID]
      )
    WHERE [C].[SELLER_DEFAULT_CODE] = @SELLER_CODE
    AND [TA].[STATUS] = 1
    AND @NOW BETWEEN [TA].[VALID_START_DATETIME] AND [TA].[VALID_END_DATETIME]

  -- ------------------------------------------------------------------------------------
  -- Obtiene los clientes que esten en el plan de ruta y no esten asociados por vendedor
  -- ------------------------------------------------------------------------------------
  INSERT INTO @DISCOUNT_LIST ([NAME_DISCOUNT_LIST])
    SELECT
      [RP].[CODE_ROUTE] + '|' + [TA].[CODE_TRADE_AGREEMENT] AS [NAME_DISCOUNT_LIST]
    FROM [SONDA].[SONDA_ROUTE_PLAN] [RP]
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
      ON (
      [RP].[RELATED_CLIENT_CODE] = [TAC].[CODE_CUSTOMER]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA]
      ON (
      [TAC].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID]
      )
    WHERE [RP].[CODE_ROUTE] = @CODE_ROUTE
    AND [TA].[STATUS] = 1
    AND @NOW BETWEEN [TA].[VALID_START_DATETIME] AND [TA].[VALID_END_DATETIME]

  -- ------------------------------------------------------------------------------------
  -- Obtiene los acuerdos comerciales de canal
  -- ------------------------------------------------------------------------------------
  INSERT INTO @DISCOUNT_LIST ([NAME_DISCOUNT_LIST])
    SELECT
      @CODE_ROUTE + '|' + [TA].[CODE_TRADE_AGREEMENT] AS [NAME_DISCOUNT_LIST]
    FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
    INNER JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC]
      ON (
      [C].[CODE_CUSTOMER] = [CC].[CODE_CUSTOMER]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL] [TAC]
      ON (
      [CC].[CHANNEL_ID] = [TAC].[CHANNEL_ID]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA]
      ON (
      [TAC].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID]
      )
    WHERE [C].[SELLER_DEFAULT_CODE] = @SELLER_CODE
    AND [TA].[STATUS] = 1
    AND @NOW BETWEEN [TA].[VALID_START_DATETIME] AND [TA].[VALID_END_DATETIME]

  -- ------------------------------------------------------------------------------------
  -- Obtiene los acuerdos comerciales de los clientes que esten en el plan de ruta y no esten asociados por vendedor
  -- ------------------------------------------------------------------------------------
  INSERT INTO @DISCOUNT_LIST ([NAME_DISCOUNT_LIST])
    SELECT
      @CODE_ROUTE + '|' + [TA].[CODE_TRADE_AGREEMENT] AS [NAME_DISCOUNT_LIST]
    FROM [SONDA].[SONDA_ROUTE_PLAN] [RP]
    INNER JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC]
      ON (
      [RP].[RELATED_CLIENT_CODE] = [CC].[CODE_CUSTOMER]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL] [TAC]
      ON (
      [CC].[CHANNEL_ID] = [TAC].[CHANNEL_ID]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA]
      ON (
      [TAC].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID]
      )
    WHERE [RP].[CODE_ROUTE] = @CODE_ROUTE
    AND [TA].[STATUS] = 1
    AND @NOW BETWEEN [TA].[VALID_START_DATETIME] AND [TA].[VALID_END_DATETIME]

  -- ------------------------------------------------------------------------------------
  -- Agrega la lista del acuerdo comercial para los nuevos clientes de ser necesario
  -- ------------------------------------------------------------------------------------
  IF (SELECT
        [SONDA].[SWIFT_FN_VALIDATE_TRADE_AGREEMENT_BY_ROUTE](@CODE_ROUTE))
    = 1
  BEGIN
    DECLARE @TRADE_AGREEMENT_ID INT = NULL
    --
    SELECT
      @TRADE_AGREEMENT_ID = [SONDA].[SWIFT_FN_GET_TRADE_AGREEMENT_BY_ROUTE](@CODE_ROUTE)
    --
    INSERT INTO @DISCOUNT_LIST ([NAME_DISCOUNT_LIST])
      SELECT
        (@CODE_ROUTE + '|' + [T].[CODE_TRADE_AGREEMENT])
      FROM [SONDA].[SWIFT_TRADE_AGREEMENT] [T]
      WHERE [T].[TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID
  END

  -- ------------------------------------------------------------------------------------
  -- Genera la lista de descuentos
  -- ------------------------------------------------------------------------------------
  INSERT INTO [SONDA].[SWIFT_DISCOUNT_LIST] ([NAME_DISCOUNT_LIST]
  , [CODE_ROUTE])
    SELECT DISTINCT
      [DL].[NAME_DISCOUNT_LIST]
     ,@CODE_ROUTE
    FROM @DISCOUNT_LIST [DL]
END
