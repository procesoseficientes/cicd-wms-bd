-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Feb-17 @ A-TEAM Sprint Chatulika 
-- Description:			SP que genera la lista de bonificaciones por acuerdo comercial de clientes

-- Modificacion 27-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se cambio para que obtenga las listas por el codigo de ruta y de las tablas de promo

-- Modificacion 17-Aug-2017 @Reborn Team Sprint Bearbeitung
-- rudi.garcia
-- Se agrego la columna de "FREQUENCY"


/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GENERATE_SKU_SALES_BY_MULTIPLE_BY_TRADE_AGREEMENT]
					@CODE_ROUTE = '44'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GENERATE_SKU_SALES_BY_MULTIPLE_BY_TRADE_AGREEMENT (@CODE_ROUTE VARCHAR(50)) WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT ON;

  -- ------------------------------------------------------------------------------------
  -- Obtiene valores iniciales
  -- ------------------------------------------------------------------------------------
  DECLARE @SELLER_CODE VARCHAR(50)
         ,@LINKED_TO VARCHAR(250)
         ,@DATETIME DATETIME
         ,@ACTIVE_STATUS INT = 1
  --
  DECLARE @TRADE_AGREEMENT_BY_CUSTOMER TABLE (
    [TRADE_AGREEMENT_ID] INT
   ,[CODE_TRADE_AGREEMENT] VARCHAR(50)
   ,[CODE_CUSTOMER] VARCHAR(50)
   ,[LINKED_TO] VARCHAR(250)
   ,[CODE_ROUTE] VARCHAR(50)
   ,[NAME_SALES_BY_MULTIPLE_LIST] VARCHAR(250)
   ,UNIQUE ([TRADE_AGREEMENT_ID], [CODE_CUSTOMER])
   ,UNIQUE ([CODE_ROUTE], [NAME_SALES_BY_MULTIPLE_LIST], [LINKED_TO], [TRADE_AGREEMENT_ID], [CODE_CUSTOMER])
  )
  --
  SELECT
    @SELLER_CODE = [SONDA].SWIFT_FN_GET_SELLER_BY_ROUTE(@CODE_ROUTE)
   ,@LINKED_TO = 'CUSTOMER'
   ,@DATETIME = GETDATE()

  -- ------------------------------------------------------------------------------------
  -- Obtiene los acuerdos comerciales
  -- ------------------------------------------------------------------------------------
  INSERT INTO @TRADE_AGREEMENT_BY_CUSTOMER ([TRADE_AGREEMENT_ID]
  , [CODE_TRADE_AGREEMENT]
  , [CODE_CUSTOMER]
  , [LINKED_TO]
  , [CODE_ROUTE]
  , [NAME_SALES_BY_MULTIPLE_LIST])
    SELECT DISTINCT
      [TAC].[TRADE_AGREEMENT_ID]
     ,[TA].[CODE_TRADE_AGREEMENT]
     ,[C].[CODE_CUSTOMER]
     ,[TA].[LINKED_TO]
     ,@CODE_ROUTE
     ,@CODE_ROUTE + '|' + [TA].[CODE_TRADE_AGREEMENT]
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
    AND [TA].[STATUS] = @ACTIVE_STATUS
    AND @DATETIME BETWEEN [TA].[VALID_START_DATETIME] AND [TA].[VALID_END_DATETIME]

  -- ------------------------------------------------------------------------------------
  -- Obtiene los acuerdos comerciales de los clientes que esten en el plan de ruta y no esten asociados por vendedor
  -- ------------------------------------------------------------------------------------
  INSERT INTO @TRADE_AGREEMENT_BY_CUSTOMER ([TRADE_AGREEMENT_ID]
  , [CODE_TRADE_AGREEMENT]
  , [CODE_CUSTOMER]
  , [LINKED_TO]
  , [CODE_ROUTE]
  , [NAME_SALES_BY_MULTIPLE_LIST])
    SELECT DISTINCT
      [TAC].[TRADE_AGREEMENT_ID]
     ,[TA].[CODE_TRADE_AGREEMENT]
     ,[RP].[RELATED_CLIENT_CODE]
     ,[TA].[LINKED_TO]
     ,@CODE_ROUTE
     ,@CODE_ROUTE + '|' + [TA].[CODE_TRADE_AGREEMENT]
    FROM [SONDA].[SONDA_ROUTE_PLAN] [RP]
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
      ON (
      [RP].[RELATED_CLIENT_CODE] = [TAC].[CODE_CUSTOMER]
      )
    LEFT JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA]
      ON (
      [TAC].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID]
      )
    LEFT JOIN @TRADE_AGREEMENT_BY_CUSTOMER [TABC]
      ON (
      [RP].[RELATED_CLIENT_CODE] = [TABC].[CODE_CUSTOMER]
      )
    WHERE [RP].[CODE_ROUTE] = @CODE_ROUTE
    AND [TA].[STATUS] = @ACTIVE_STATUS
    AND @DATETIME BETWEEN [TA].[VALID_START_DATETIME] AND [TA].[VALID_END_DATETIME]
    AND [TABC].[TRADE_AGREEMENT_ID] IS NULL

  -- ------------------------------------------------------------------------------------
  -- Genera clientes de las listas de venta por multiplo
  -- ------------------------------------------------------------------------------------
  INSERT INTO [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST_BY_CUSTOMER] ([SALES_BY_MULTIPLE_LIST_ID]
  , [CODE_CUSTOMER])
    SELECT DISTINCT
      [S].[SALES_BY_MULTIPLE_LIST_ID]
     ,[TA].[CODE_CUSTOMER]
    FROM @TRADE_AGREEMENT_BY_CUSTOMER [TA]
    INNER JOIN [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST] [S]
      ON (
      [S].[CODE_ROUTE] = [TA].[CODE_ROUTE]
      AND [S].[NAME_SALES_BY_MULTIPLE_LIST] = [TA].[NAME_SALES_BY_MULTIPLE_LIST]
      )
    WHERE [TA].[LINKED_TO] = @LINKED_TO

  -- ------------------------------------------------------------------------------------
  -- Agrega la lista del acuerdo comercial para los nuevos clientes de ser necesario
  -- ------------------------------------------------------------------------------------
  IF (SELECT
        [SONDA].[SWIFT_FN_VALIDATE_TRADE_AGREEMENT_BY_ROUTE](@CODE_ROUTE))
    = 1
  BEGIN
    DECLARE @TRADE_AGREEMENT_ID INT = NULL
           ,@CODE_TRADE_AGREEMENT VARCHAR(50) = NULL
           ,@IS_ALREADY INT = 0
    --
    SELECT
      @TRADE_AGREEMENT_ID = [SONDA].[SWIFT_FN_GET_TRADE_AGREEMENT_BY_ROUTE](@CODE_ROUTE)
    --
    SELECT
      @CODE_TRADE_AGREEMENT = [TA].[CODE_TRADE_AGREEMENT]
    FROM [SONDA].[SWIFT_TRADE_AGREEMENT] [TA]
    WHERE [TA].[TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID

    -- ------------------------------------------------------------------------------------
    -- Se valida si ya se tomo en cuenta el acuerdo comercial
    -- ------------------------------------------------------------------------------------
    IF @TRADE_AGREEMENT_ID IS NOT NULL
    BEGIN
      SELECT TOP 1
        @IS_ALREADY = 1
      FROM [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST_BY_CUSTOMER] [SLC]
      INNER JOIN [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST] [SL]
        ON (
        [SL].[SALES_BY_MULTIPLE_LIST_ID] = [SLC].[SALES_BY_MULTIPLE_LIST_ID]
        )
      WHERE [SL].[CODE_ROUTE] = @CODE_ROUTE
      AND [SL].[NAME_SALES_BY_MULTIPLE_LIST] = (@CODE_ROUTE + '|' + @CODE_TRADE_AGREEMENT)
    END
    --
    IF @IS_ALREADY = 0
    BEGIN
      INSERT INTO @TRADE_AGREEMENT_BY_CUSTOMER ([TRADE_AGREEMENT_ID]
      , [CODE_TRADE_AGREEMENT]
      , [CODE_CUSTOMER]
      , [LINKED_TO]
      , [CODE_ROUTE]
      , [NAME_SALES_BY_MULTIPLE_LIST])
        SELECT
          @TRADE_AGREEMENT_ID
         ,@CODE_TRADE_AGREEMENT
         ,'-1'
         ,@LINKED_TO
         ,@CODE_ROUTE
         ,@CODE_ROUTE + '|' + [T].[CODE_TRADE_AGREEMENT]
        FROM [SONDA].[SWIFT_TRADE_AGREEMENT] [T]
        WHERE [T].[TRADE_AGREEMENT_ID] = @TRADE_AGREEMENT_ID
    END
  END

  -- ------------------------------------------------------------------------------------
  -- Genera SKUs de la lista de venta por multiplo
  -- ------------------------------------------------------------------------------------
  INSERT INTO [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST_BY_SKU] ([SALES_BY_MULTIPLE_LIST_ID]
  , [CODE_SKU]
  , [CODE_PACK_UNIT]
  , [MULTIPLE]
  , [PROMO_ID]
  , [PROMO_NAME]
  , [PROMO_TYPE]
  , [FREQUENCY])
    SELECT DISTINCT
      [SM].[SALES_BY_MULTIPLE_LIST_ID]
     ,[TAS].[CODE_SKU]
     ,[SPU].[CODE_PACK_UNIT]
     ,[TAS].[MULTIPLE]
     ,[P].[PROMO_ID]
     ,[P].[PROMO_NAME]
     ,[P].[PROMO_TYPE]
     ,[TAP].[FREQUENCY]
    FROM @TRADE_AGREEMENT_BY_CUSTOMER [TA]
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO] [TAP]
      ON (
      [TAP].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID]
      )
    INNER JOIN [SONDA].[SWIFT_PROMO] [P]
      ON (
      [P].[PROMO_ID] = [TAP].[PROMO_ID]
      )
    INNER JOIN [SONDA].[SWIFT_PROMO_SKU_SALES_BY_MULTIPLE] [TAS]
      ON (
      [TAS].[PROMO_ID] = [P].[PROMO_ID]
      )
    INNER JOIN [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST] [SM]
      ON (
      [SM].[CODE_ROUTE] = [TA].[CODE_ROUTE]
      AND [SM].[NAME_SALES_BY_MULTIPLE_LIST] = [TA].[NAME_SALES_BY_MULTIPLE_LIST]
      )
    INNER JOIN [SONDA].[SONDA_PACK_UNIT] [SPU]
      ON (
      [SPU].[PACK_UNIT] = [TAS].[PACK_UNIT]
      )
    WHERE [TA].[LINKED_TO] = @LINKED_TO
    AND [SPU].[PACK_UNIT] > 0

END
