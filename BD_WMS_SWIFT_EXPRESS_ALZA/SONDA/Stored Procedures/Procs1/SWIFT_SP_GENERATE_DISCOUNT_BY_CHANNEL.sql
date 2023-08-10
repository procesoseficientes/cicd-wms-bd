-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que genera la lista de descuentos por acuerdo comercial de canal

-- Modificacion 2/13/2017 @ A-Team Sprint Chatuluka
-- rodrigo.gomez
-- Se agregaron las columnas PACK_UNIT, HIGH_LIMIT y LOW_LIMIT al insertar a SWIFT_DISCOUNT_LIST_BY_SKU

-- Modificacion 16-Feb-17 @ A-Team Sprint Chatuluka
-- alberto.ruiz
-- Se agrego que genere los descuentso generales

-- Modificacion 25-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se cambio para que obtenga las listas por el codigo de ruta y de las tablas de promo

-- Modificacion 17-Aug-2017 @Reborn Team Sprint Bearbeitung
-- rudi.garcia
-- Se agrego la columna de "FREQUENCY"

-- Modificacion 07-May-2018 @G-Force Team Sprint Caribú
-- rudi.garcia
-- Se agrego los insert para la tabla [SWIFT_DISCOUNT_LIST_BY_GENERAL_AMOUNT_AND_FAMILY] y [SWIFT_DISCOUNT_LIST_BY_PAYMENT_TYPE_AND_FAMILY]

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_GENERATE_DISCOUNT_BY_CHANNEL]
					@CODE_ROUTE = '44'
*/
-- =============================================
CREATE PROCEDURE SONDA.SWIFT_SP_GENERATE_DISCOUNT_BY_CHANNEL (@CODE_ROUTE VARCHAR(250))
AS
BEGIN
  SET NOCOUNT ON;

  -- ------------------------------------------------------------------------------------
  -- Obtiene valores iniciales
  -- ------------------------------------------------------------------------------------
  DECLARE @SELLER_CODE VARCHAR(50)
         ,@LINKED_TO VARCHAR(250)
         ,@STATUS INT = 1
         ,@NOW DATETIME = GETDATE()
  --
  DECLARE @TRADE_AGREEMENT_BY_CHANNEL TABLE (
    [TRADE_AGREEMENT_ID] INT
   ,[CODE_TRADE_AGREEMENT] VARCHAR(50)
   ,[CODE_CUSTOMER] VARCHAR(50)
   ,[LINKED_TO] VARCHAR(250)
   ,[CODE_ROUTE] VARCHAR(50)
   ,[NAME_DISCOUNT_LIST] VARCHAR(250)
   ,UNIQUE ([TRADE_AGREEMENT_ID], [CODE_CUSTOMER])
   ,UNIQUE ([LINKED_TO], [CODE_CUSTOMER], [NAME_DISCOUNT_LIST], [CODE_ROUTE], [TRADE_AGREEMENT_ID])
  )
  --
  SELECT
    @SELLER_CODE = [SONDA].[SWIFT_FN_GET_SELLER_BY_ROUTE](@CODE_ROUTE)
   ,@LINKED_TO = 'CHANNEL'

  -- ------------------------------------------------------------------------------------
  -- Obtiene los acuerdos comerciales
  -- ------------------------------------------------------------------------------------
  INSERT INTO @TRADE_AGREEMENT_BY_CHANNEL ([TRADE_AGREEMENT_ID]
  , [CODE_TRADE_AGREEMENT]
  , [CODE_CUSTOMER]
  , [LINKED_TO]
  , [CODE_ROUTE]
  , [NAME_DISCOUNT_LIST])
    SELECT DISTINCT
      [TA].[TRADE_AGREEMENT_ID]
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
    AND @NOW BETWEEN [TA].[VALID_START_DATETIME] AND [TA].[VALID_END_DATETIME]
    AND [TA].[STATUS] = @STATUS
    AND TAC.[TRADE_AGREEMENT_ID] > 0

  -- ------------------------------------------------------------------------------------
  -- Obtiene los acuerdos comerciales de los clientes que esten en el plan de ruta y no esten asociados por vendedor
  -- ------------------------------------------------------------------------------------
  INSERT INTO @TRADE_AGREEMENT_BY_CHANNEL ([TRADE_AGREEMENT_ID]
  , [CODE_TRADE_AGREEMENT]
  , [CODE_CUSTOMER]
  , [LINKED_TO]
  , [CODE_ROUTE]
  , [NAME_DISCOUNT_LIST])
    SELECT DISTINCT
      [TAC].[TRADE_AGREEMENT_ID]
     ,[TA].[CODE_TRADE_AGREEMENT]
     ,[RP].[RELATED_CLIENT_CODE] [CODE_CUSTOMER]
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
    LEFT JOIN @TRADE_AGREEMENT_BY_CHANNEL TABC
      ON (
      [RP].[RELATED_CLIENT_CODE] = [TABC].[CODE_CUSTOMER]
      )
    WHERE [RP].[CODE_ROUTE] = @CODE_ROUTE
    AND [TA].[STATUS] = @STATUS
    AND @NOW BETWEEN [TA].[VALID_START_DATETIME] AND [TA].[VALID_END_DATETIME]
    AND [TABC].[TRADE_AGREEMENT_ID] IS NULL

  -- ------------------------------------------------------------------------------------
  -- Genera clientes de las listas de descuentos
  -- ------------------------------------------------------------------------------------
  INSERT INTO [SONDA].[SWIFT_DISCOUNT_LIST_BY_CUSTOMER] ([DISCOUNT_LIST_ID]
  , [CODE_CUSTOMER])
    SELECT DISTINCT
      [DL].[DISCOUNT_LIST_ID]
     ,[TA].[CODE_CUSTOMER]
    FROM @TRADE_AGREEMENT_BY_CHANNEL [TA]
    INNER JOIN [SONDA].[SWIFT_DISCOUNT_LIST] [DL]
      ON (
      [TA].[CODE_ROUTE] = [DL].[CODE_ROUTE]
      AND [TA].[NAME_DISCOUNT_LIST] = [DL].[NAME_DISCOUNT_LIST]
      )
    WHERE [TA].[LINKED_TO] = @LINKED_TO
    AND [DL].[DISCOUNT_LIST_ID] > 0

  -- ------------------------------------------------------------------------------------
  -- Genera SKUs de la lista de descuentos
  -- ------------------------------------------------------------------------------------
  INSERT INTO [SONDA].[SWIFT_DISCOUNT_LIST_BY_SKU] ([DISCOUNT_LIST_ID]
  , [CODE_SKU]
  , [PACK_UNIT]
  , [LOW_LIMIT]
  , [HIGH_LIMIT]
  , [DISCOUNT]
  , [DISCOUNT_TYPE]
  , [IS_UNIQUE]
  , [PROMO_ID]
  , [PROMO_NAME]
  , [PROMO_TYPE]
  , [FREQUENCY])
    SELECT DISTINCT
      [DL].[DISCOUNT_LIST_ID]
     ,[PDS].[CODE_SKU]
     ,[PDS].[PACK_UNIT]
     ,[PDS].[LOW_LIMIT]
     ,[PDS].[HIGH_LIMIT]
     ,[PDS].[DISCOUNT]
     ,[PDS].[DISCOUNT_TYPE]
     ,[PDS].[IS_UNIQUE]
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
    INNER JOIN [SONDA].[SWIFT_PROMO_DISCOUNT_BY_SCALE] [PDS]
      ON (
      [PDS].[PROMO_ID] = [TAP].[PROMO_ID]
      )
    INNER JOIN [SONDA].[SWIFT_DISCOUNT_LIST] [DL]
      ON (
      [TA].[CODE_ROUTE] = [DL].[CODE_ROUTE]
      AND [TA].[NAME_DISCOUNT_LIST] = [DL].[NAME_DISCOUNT_LIST]
      )
    WHERE [TA].[LINKED_TO] = @LINKED_TO

  -- ------------------------------------------------------------------------------------
  -- Genera los descuentos generales
  -- ------------------------------------------------------------------------------------
  INSERT INTO [SONDA].[SWIFT_DISCOUNT_LIST_BY_GENERAL_AMOUNT] ([DISCOUNT_LIST_ID]
  , [LOW_AMOUNT]
  , [HIGH_AMOUNT]
  , [DISCOUNT]
  , [PROMO_ID]
  , [PROMO_NAME]
  , [PROMO_TYPE]
  , [FREQUENCY])
    SELECT DISTINCT
      [DL].[DISCOUNT_LIST_ID]
     ,[PGA].[LOW_AMOUNT]
     ,[PGA].[HIGH_AMOUNT]
     ,[PGA].[DISCOUNT]
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
    INNER JOIN [SONDA].[SWIFT_PROMO_DISCOUNT_BY_GENERAL_AMOUNT] [PGA]
      ON (
      [PGA].[PROMO_ID] = [TAP].[PROMO_ID]
      )
    INNER JOIN [SONDA].[SWIFT_DISCOUNT_LIST] [DL]
      ON (
      [TA].[CODE_ROUTE] = [DL].[CODE_ROUTE]
      AND [TA].[NAME_DISCOUNT_LIST] = [DL].[NAME_DISCOUNT_LIST]
      )
    WHERE [TA].[LINKED_TO] = @LINKED_TO

  -- ------------------------------------------------------------------------------------
  -- Genera los descuentos generales por familia
  -- ------------------------------------------------------------------------------------
  INSERT INTO [SONDA].[SWIFT_DISCOUNT_LIST_BY_GENERAL_AMOUNT_AND_FAMILY] ([DISCOUNT_LIST_ID]
  , [CODE_FAMILY]
  , [LOW_AMOUNT]
  , [HIGH_AMOUNT]
  , [DISCOUNT_TYPE]
  , [DISCOUNT]
  , [PROMO_ID]
  , [PROMO_NAME]
  , [PROMO_TYPE]
  , [FREQUENCY])
    SELECT DISTINCT
      [DL].[DISCOUNT_LIST_ID]
     ,[PDF].[CODE_FAMILY_SKU]
     ,[PDF].[LOW_AMOUNT]
     ,[PDF].[HIGH_AMOUNT]
     ,[PDF].[DISCOUNT_TYPE]
     ,[PDF].[DISCOUNT]
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
    INNER JOIN [SONDA].[SWIFT_PROMO_DISCOUNT_BY_FAMILY] [PDF]
      ON (
      [PDF].[PROMO_ID] = [TAP].[PROMO_ID]
      )
    INNER JOIN [SONDA].[SWIFT_DISCOUNT_LIST] [DL]
      ON (
      [TA].[CODE_ROUTE] = [DL].[CODE_ROUTE]
      AND [TA].[NAME_DISCOUNT_LIST] = [DL].[NAME_DISCOUNT_LIST]
      )
    WHERE [TA].[LINKED_TO] = @LINKED_TO


  -- ------------------------------------------------------------------------------------
  -- Genera los descuentos por tipo de pago y familia
  -- ------------------------------------------------------------------------------------

  INSERT INTO [SONDA].[SWIFT_DISCOUNT_LIST_BY_PAYMENT_TYPE_AND_FAMILY] ([DISCOUNT_LIST_ID]
  , [PAYMENT_TYPE]
  , [CODE_FAMILY]
  , [DISCOUNT_TYPE]
  , [DISCOUNT]
  , [PROMO_ID]
  , [PROMO_NAME]
  , [PROMO_TYPE]
  , [FREQUENCY])
    SELECT DISTINCT
      [DL].[DISCOUNT_LIST_ID]
     ,[PDPF].[PAYMENT_TYPE]
     ,[PDPF].[CODE_FAMILY_SKU]
     ,[PDPF].[DISCOUNT_TYPE]
     ,[PDPF].[DISCOUNT]
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
    INNER JOIN [SONDA].[SWIFT_PROMO_DISCOUNT_BY_PAYMENT_TYPE_AND_FAMILY] [PDPF]
      ON (
      [PDPF].[PROMO_ID] = [TAP].[PROMO_ID]
      )
    INNER JOIN [SONDA].[SWIFT_DISCOUNT_LIST] [DL]
      ON (
      [TA].[CODE_ROUTE] = [DL].[CODE_ROUTE]
      AND [TA].[NAME_DISCOUNT_LIST] = [DL].[NAME_DISCOUNT_LIST]
      )
    WHERE [TA].[LINKED_TO] = @LINKED_TO

END
