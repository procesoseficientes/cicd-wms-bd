-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Feb-17 @ A-TEAM Sprint Chatuluka 
-- Description:			SP que genera la lista de venta por multiplo por acuerdo comercial de canal

-- Modificacion 27-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se cambio para que obtenga las listas por el codigo de ruta y de las tablas de promo

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-24 @ Team REBORN - Sprint 
-- Description:	   Se agrega Frecuencia a [SWIFT_SKU_SALES_BY_MULTIPLE_LIST_BY_SKU]

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GENERATE_SKU_SALES_BY_MULTIPLE_BY_CHANNEL]
					@CODE_ROUTE = '44'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GENERATE_SKU_SALES_BY_MULTIPLE_BY_CHANNEL] (@CODE_ROUTE VARCHAR(50))
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
  DECLARE @TRADE_AGREEMENT_BY_CHANNEL TABLE (
    [TRADE_AGREEMENT_ID] INT
   ,[CODE_TRADE_AGREEMENT] VARCHAR(50)
   ,[CODE_CUSTOMER] VARCHAR(50)
   ,[LINKED_TO] VARCHAR(250)
   ,[CODE_ROUTE] VARCHAR(50)
   ,[NAME_SALES_BY_MULTIPLE_LIST] VARCHAR(250)
   ,UNIQUE ([TRADE_AGREEMENT_ID], [CODE_CUSTOMER])
   ,UNIQUE ([LINKED_TO], [TRADE_AGREEMENT_ID], [CODE_ROUTE], [NAME_SALES_BY_MULTIPLE_LIST], [CODE_CUSTOMER])
  )
  --
  SELECT
    @SELLER_CODE = [SONDA].SWIFT_FN_GET_SELLER_BY_ROUTE(@CODE_ROUTE)
   ,@LINKED_TO = 'CHANNEL'
   ,@DATETIME = GETDATE()

  -- ------------------------------------------------------------------------------------
  -- Obtiene los acuerdos comerciales
  -- ------------------------------------------------------------------------------------
  INSERT INTO @TRADE_AGREEMENT_BY_CHANNEL ([TRADE_AGREEMENT_ID]
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
    AND [TA].[STATUS] = @ACTIVE_STATUS
    AND @DATETIME BETWEEN [TA].[VALID_START_DATETIME] AND [TA].[VALID_END_DATETIME]
    AND TAC.[TRADE_AGREEMENT_ID] > 0

  -- ------------------------------------------------------------------------------------
  -- Obtiene los acuerdos comerciales de los clientes que esten en el plan de ruta y no esten asociados por vendedor
  -- ------------------------------------------------------------------------------------
  INSERT INTO @TRADE_AGREEMENT_BY_CHANNEL ([TRADE_AGREEMENT_ID]
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
    LEFT JOIN @TRADE_AGREEMENT_BY_CHANNEL [TABC]
      ON (
      [RP].[RELATED_CLIENT_CODE] = [TABC].[CODE_CUSTOMER]
      )
    WHERE [RP].[CODE_ROUTE] = @CODE_ROUTE
    AND [TA].[STATUS] = @ACTIVE_STATUS
    AND @DATETIME BETWEEN [TA].[VALID_START_DATETIME] AND [TA].[VALID_END_DATETIME]
    AND [TABC].[TRADE_AGREEMENT_ID] IS NULL
    AND TAC.[TRADE_AGREEMENT_ID] > 0

  -- ------------------------------------------------------------------------------------
  -- Genera clientes de las listas de venta por multiplo
  -- ------------------------------------------------------------------------------------
  INSERT INTO [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST_BY_CUSTOMER] ([SALES_BY_MULTIPLE_LIST_ID]
  , [CODE_CUSTOMER])
    SELECT DISTINCT
      [SM].[SALES_BY_MULTIPLE_LIST_ID]
     ,[TA].[CODE_CUSTOMER]
    FROM @TRADE_AGREEMENT_BY_CHANNEL [TA]
    INNER JOIN [SONDA].[SWIFT_SKU_SALES_BY_MULTIPLE_LIST] [SM]
      ON (
      [SM].[CODE_ROUTE] = [TA].[CODE_ROUTE]
      AND [TA].[NAME_SALES_BY_MULTIPLE_LIST] = [SM].[NAME_SALES_BY_MULTIPLE_LIST]
      )
    WHERE [TA].[LINKED_TO] = @LINKED_TO

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
    FROM @TRADE_AGREEMENT_BY_CHANNEL [TA]
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
      AND [TA].[NAME_SALES_BY_MULTIPLE_LIST] = [SM].[NAME_SALES_BY_MULTIPLE_LIST]
      )
    INNER JOIN [SONDA].[SONDA_PACK_UNIT] [SPU]
      ON (
      [SPU].[PACK_UNIT] = [TAS].[PACK_UNIT]
      )
    WHERE [TA].[LINKED_TO] = @LINKED_TO
END
