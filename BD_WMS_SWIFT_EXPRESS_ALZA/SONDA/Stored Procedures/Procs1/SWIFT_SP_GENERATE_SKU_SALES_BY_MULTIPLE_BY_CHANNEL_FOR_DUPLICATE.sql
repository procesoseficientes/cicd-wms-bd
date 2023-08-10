-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Feb-17 @ A-TEAM Sprint Chatuluka 
-- Description:			SP que genera las ventas por multiplo desde acuerdo comercial de canal para los clientes asociados a un canla que tambien esten en un acuerdo comercial de cliente

-- Modificacion 27-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se cambio para que obtenga las listas por el codigo de ruta y de las tablas de promo

-- Modificacion 17-Aug-2017 @Reborn Team Sprint Bearbeitung
-- rudi.garcia
-- Se agrego la columna de "FREQUENCY"

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GENERATE_SKU_SALES_BY_MULTIPLE_BY_CHANNEL_FOR_DUPLICATE]
					@CODE_ROUTE = '44'
					,@ORDER = 2
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GENERATE_SKU_SALES_BY_MULTIPLE_BY_CHANNEL_FOR_DUPLICATE (@CODE_ROUTE VARCHAR(50)
, @ORDER INT)
AS
BEGIN
  SET NOCOUNT ON;

  -- ------------------------------------------------------------------------------------
  -- Obtiene valores iniciales
  -- ------------------------------------------------------------------------------------
  DECLARE @SELLER_CODE VARCHAR(50)
         ,@ACTIVE_STATUS INT = 1
         ,@NOW DATETIME = GETDATE()
         ,@LINKED_TO VARCHAR(250) = 'CHANNEL'
  --
  DECLARE @CUSTOMER TABLE (
    [CODE_CUSTOMER] VARCHAR(50)
   ,UNIQUE ([CODE_CUSTOMER])
  )
  --
  DECLARE @TRADE_AGREEMENT TABLE (
    [TRADE_AGREEMENT_ID] INT
   ,[CODE_TRADE_AGREEMENT] VARCHAR(50)
   ,[CODE_CUSTOMER] VARCHAR(50)
   ,[LINKED_TO] VARCHAR(250)
   ,[CODE_ROUTE] VARCHAR(50)
   ,[NAME_SALES_BY_MULTIPLE_LIST] VARCHAR(250)
   ,UNIQUE ([TRADE_AGREEMENT_ID], [CODE_CUSTOMER])
   ,UNIQUE ([TRADE_AGREEMENT_ID], [CODE_CUSTOMER], [CODE_ROUTE], [NAME_SALES_BY_MULTIPLE_LIST])
  )
  --
  SELECT
    @SELLER_CODE = [SONDA].SWIFT_FN_GET_SELLER_BY_ROUTE(@CODE_ROUTE)

  -- ------------------------------------------------------------------------------------
  -- Obtiene los clientes a repetidos
  -- ------------------------------------------------------------------------------------
  INSERT INTO @CUSTOMER ([CODE_CUSTOMER])
    SELECT DISTINCT
      [C].[CODE_CUSTOMER]
    FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
      ON (
      [C].[CODE_CUSTOMER] = [TAC].[CODE_CUSTOMER]
      )
    INNER JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC]
      ON (
      [C].[CODE_CUSTOMER] = [CC].[CODE_CUSTOMER]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA1]
      ON (
      [TA1].[TRADE_AGREEMENT_ID] = [TAC].[TRADE_AGREEMENT_ID]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL] [TACH]
      ON (
      [CC].[CHANNEL_ID] = [TACH].[CHANNEL_ID]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA2]
      ON (
      [TA2].[TRADE_AGREEMENT_ID] = [TACH].[TRADE_AGREEMENT_ID]
      )
    WHERE [C].[SELLER_DEFAULT_CODE] = @SELLER_CODE
    AND [TA1].[STATUS] = @ACTIVE_STATUS
    AND [TA2].[STATUS] = @ACTIVE_STATUS
    AND @NOW BETWEEN [TA1].[VALID_START_DATETIME] AND [TA1].[VALID_END_DATETIME]
    AND @NOW BETWEEN [TA2].[VALID_START_DATETIME] AND [TA2].[VALID_END_DATETIME]
    AND [TACH].[TRADE_AGREEMENT_ID] > 0

  -- ------------------------------------------------------------------------------------
  -- Obtiene los clientes que esten en el plan de ruta y no esten asociados por vendedor
  -- ------------------------------------------------------------------------------------
  INSERT INTO @CUSTOMER ([CODE_CUSTOMER])
    SELECT DISTINCT
      [C].[CODE_CUSTOMER]
    FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
    INNER JOIN [SONDA].[SONDA_ROUTE_PLAN] [RP]
      ON (
      [C].[CODE_CUSTOMER] = [RP].[RELATED_CLIENT_CODE]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
      ON (
      [C].[CODE_CUSTOMER] = [TAC].[CODE_CUSTOMER]
      )
    INNER JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC]
      ON (
      [C].[CODE_CUSTOMER] = [CC].[CODE_CUSTOMER]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA1]
      ON (
      [TA1].[TRADE_AGREEMENT_ID] = [TAC].[TRADE_AGREEMENT_ID]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL] [TACH]
      ON (
      [CC].[CHANNEL_ID] = [TACH].[CHANNEL_ID]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA2]
      ON (
      [TA2].[TRADE_AGREEMENT_ID] = [TACH].[TRADE_AGREEMENT_ID]
      )
    LEFT JOIN @CUSTOMER [C2]
      ON (
      [C].[CODE_CUSTOMER] = [C2].[CODE_CUSTOMER]
      )
    WHERE [RP].[CODE_ROUTE] = @CODE_ROUTE
    AND [TA1].[STATUS] = @ACTIVE_STATUS
    AND [TA2].[STATUS] = @ACTIVE_STATUS
    AND @NOW BETWEEN [TA1].[VALID_START_DATETIME] AND [TA1].[VALID_END_DATETIME]
    AND @NOW BETWEEN [TA2].[VALID_START_DATETIME] AND [TA2].[VALID_END_DATETIME]
    AND [C2].[CODE_CUSTOMER] IS NULL

  -- ------------------------------------------------------------------------------------
  -- Obtiene los acuerdos comerciales
  -- ------------------------------------------------------------------------------------
  INSERT INTO @TRADE_AGREEMENT ([TRADE_AGREEMENT_ID]
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
     ,@CODE_ROUTE + '|' + [C].[CODE_CUSTOMER]
    FROM @CUSTOMER [C]
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
    WHERE [TA].[STATUS] = @ACTIVE_STATUS
    AND [TA].[LINKED_TO] = @LINKED_TO
    AND @NOW BETWEEN [TA].[VALID_START_DATETIME] AND [TA].[VALID_END_DATETIME]
    AND [TAC].[TRADE_AGREEMENT_ID] > 0

  -- ------------------------------------------------------------------------------------
  -- Valida si es el primero en ejecutar para generar el listado de bonificaciones y de clientes por bonificacion
  -- ------------------------------------------------------------------------------------
  IF @ORDER = 1
  BEGIN
    -- ------------------------------------------------------------------------------------
    -- Genera las listas de bonificaciones
    -- ------------------------------------------------------------------------------------
    INSERT INTO [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST] ([NAME_SALES_BY_MULTIPLE_LIST]
    , [CODE_ROUTE])
      SELECT DISTINCT
        (@CODE_ROUTE + '|' + [TA].[CODE_CUSTOMER])
       ,@CODE_ROUTE
      FROM @TRADE_AGREEMENT [TA]
      WHERE [TA].TRADE_AGREEMENT_ID > 0

    -- ------------------------------------------------------------------------------------
    -- Asocia el cliente con la lista de bonificaciones
    -- ------------------------------------------------------------------------------------
    INSERT INTO [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST_BY_CUSTOMER] ([SALES_BY_MULTIPLE_LIST_ID]
    , [CODE_CUSTOMER])
      SELECT DISTINCT
        [SM].[SALES_BY_MULTIPLE_LIST_ID]
       ,[TA].[CODE_CUSTOMER]
      FROM @TRADE_AGREEMENT [TA]
      INNER JOIN [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST] [SM]
        ON (
        [SM].[CODE_ROUTE] = [TA].[CODE_ROUTE]
        AND [SM].[NAME_SALES_BY_MULTIPLE_LIST] = [TA].[NAME_SALES_BY_MULTIPLE_LIST]
        )
      WHERE [TA].[TRADE_AGREEMENT_ID] > 0
  END

  -- ------------------------------------------------------------------------------------
  -- Genera las venta por multiplo por canal
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
    FROM @TRADE_AGREEMENT [TA]
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO] [TAP]
      ON (
      [TAP].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID]
      )
    INNER JOIN [SONDA].[SWIFT_PROMO] [P]
      ON (
      [P].[PROMO_ID] = [TAP].[PROMO_ID]
      )
    INNER JOIN [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST] [SM]
      ON (
      [SM].[CODE_ROUTE] = [TA].[CODE_ROUTE]
      AND [SM].[NAME_SALES_BY_MULTIPLE_LIST] = [TA].[NAME_SALES_BY_MULTIPLE_LIST]
      )
    INNER JOIN [SONDA].[SWIFT_PROMO_SKU_SALES_BY_MULTIPLE] [TAS]
      ON (
      [TAS].[PROMO_ID] = [P].[PROMO_ID]
      )
    INNER JOIN [SONDA].[SONDA_PACK_UNIT] [SPU]
      ON (
      [SPU].[PACK_UNIT] = [TAS].[PACK_UNIT]
      )
    LEFT JOIN [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST_BY_SKU] [SMLS]
      ON (
      [SMLS].[SALES_BY_MULTIPLE_LIST_ID] = [SM].[SALES_BY_MULTIPLE_LIST_ID]
      AND [SMLS].[CODE_SKU] = [TAS].[CODE_SKU]
      AND [SMLS].[CODE_PACK_UNIT] = [SPU].[CODE_PACK_UNIT]
      )
    WHERE [SMLS].[CODE_SKU] IS NULL
    AND [TA].[LINKED_TO] = @LINKED_TO
    AND [TA].[TRADE_AGREEMENT_ID] > 0
END
