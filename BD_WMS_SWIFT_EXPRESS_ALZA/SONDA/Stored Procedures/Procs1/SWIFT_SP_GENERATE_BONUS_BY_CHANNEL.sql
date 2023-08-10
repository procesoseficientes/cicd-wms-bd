-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	17-Oct-16 @ A-Team Sprint 3
-- Description:			SP que genera la lista de bonificaiones por acuerdo comercial de canal

-- Modificacion 21-Nov-16 @ A-Team Sprint 5
-- alberto.ruiz
-- Se agrego que tambien genere la tabla SWIFT_BONUS_LIST_BY_SKU_MULTIPLE

-- Modificacion 10-Feb-17 @ A-Team Sprint Chatuluka
-- alberto.ruiz
-- Se agrega que genere la configuracion de bonificacion por combo y los productos bonificados

-- Modificacion 27-Mar-17 @ A-Team Sprint Fenyang
-- alberto.ruiz
-- Se Agrego campo IS_MULTIPLE

-- Modificacion 27-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se cambio para que obtenga las listas por el codigo de ruta y de las tablas de promo

-- Modificacion 17-Aug-2017 @Reborn Team Sprint Bearbeitung
-- rudi.garcia
-- Se agrego la columna de "FREQUENCY"

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_GENERATE_BONUS_BY_CHANNEL]
					@CODE_ROUTE = '44'
				--
				SELECT * FROM [SONDA].[SWIFT_BONUS_LIST_BY_SKU]
				SELECT * FROM [SONDA].[SWIFT_BONUS_LIST_BY_SKU_MULTIPLE]
				SELECT * FROM [SONDA].[SWIFT_BONUS_LIST_BY_COMBO]
				SELECT * FROM [SONDA].[SWIFT_BONUS_LIST_BY_COMBO_SKU]
				SELECT * FROM [SONDA].[SWIFT_BONUS_LIST_BY_GENERAL_AMOUNT]

*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GENERATE_BONUS_BY_CHANNEL (@CODE_ROUTE VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;

  -- ------------------------------------------------------------------------------------
  -- Obtiene valores iniciales
  -- ------------------------------------------------------------------------------------
  DECLARE @SELLER_CODE NVARCHAR(155)
         ,@LINKED_TO VARCHAR(250)
         ,@DATETIME DATETIME
         ,@ACTIVE_STATUS INT = 1;
  --
  DECLARE @TRADE_AGREEMENT_BY_CHANNEL TABLE (
    [TRADE_AGREEMENT_ID] INT
   ,[CODE_TRADE_AGREEMENT] VARCHAR(50)
   ,[CODE_CUSTOMER] VARCHAR(50)
   ,[LINKED_TO] VARCHAR(250)
   ,[CODE_ROUTE] VARCHAR(50)
   ,[NAME_BONUS_LIST] VARCHAR(250)
   ,UNIQUE ([TRADE_AGREEMENT_ID], [CODE_CUSTOMER])
   ,UNIQUE ([TRADE_AGREEMENT_ID], [LINKED_TO], [NAME_BONUS_LIST], [CODE_ROUTE], [CODE_CUSTOMER])
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
  , [NAME_BONUS_LIST])
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
  , [NAME_BONUS_LIST])
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
    AND [TAC].[TRADE_AGREEMENT_ID] > 0


  -- ------------------------------------------------------------------------------------
  -- Genera clientes de las listas de bonificaciones
  -- ------------------------------------------------------------------------------------
  INSERT INTO [SONDA].[SWIFT_BONUS_LIST_BY_CUSTOMER] ([BONUS_LIST_ID]
  , [CODE_CUSTOMER])
    SELECT DISTINCT
      [BL].[BONUS_LIST_ID]
     ,[TA].[CODE_CUSTOMER]
    FROM @TRADE_AGREEMENT_BY_CHANNEL [TA]
    INNER JOIN [SONDA].[SWIFT_BONUS_LIST] [BL]
      ON (
      [BL].[CODE_ROUTE] = [TA].[CODE_ROUTE]
      AND [BL].[NAME_BONUS_LIST] = [TA].[NAME_BONUS_LIST]
      )
    WHERE [TA].[LINKED_TO] = @LINKED_TO
    AND [TA].[TRADE_AGREEMENT_ID] > 0

  -- ------------------------------------------------------------------------------------
  -- Genera SKUs de la lista de bonificaciones por escala
  -- ------------------------------------------------------------------------------------
  INSERT INTO [SONDA].[SWIFT_BONUS_LIST_BY_SKU] ([BONUS_LIST_ID]
  , [CODE_SKU]
  , [CODE_PACK_UNIT]
  , [LOW_LIMIT]
  , [HIGH_LIMIT]
  , [CODE_SKU_BONUS]
  , [BONUS_QTY]
  , [CODE_PACK_UNIT_BONUES]
  , [PROMO_ID]
  , [PROMO_NAME]
  , [PROMO_TYPE]
  , [FREQUENCY])
    SELECT DISTINCT
      [BL].[BONUS_LIST_ID]
     ,[TAB].[CODE_SKU]
     ,[SPU1].[CODE_PACK_UNIT]
     ,[TAB].[LOW_LIMIT]
     ,[TAB].[HIGH_LIMIT]
     ,[TAB].[CODE_SKU_BONUS]
     ,[TAB].[BONUS_QTY]
     ,[SPU2].[CODE_PACK_UNIT]
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
    INNER JOIN [SONDA].[SWIFT_PROMO_BONUS_BY_SCALE] [TAB]
      ON (
      [TAB].[PROMO_ID] = [P].[PROMO_ID]
      )
    INNER JOIN [SONDA].[SWIFT_BONUS_LIST] [BL]
      ON (
      [BL].[CODE_ROUTE] = [TA].[CODE_ROUTE]
      AND [BL].[NAME_BONUS_LIST] = [TA].[NAME_BONUS_LIST]
      )
    INNER JOIN [SONDA].[SONDA_PACK_UNIT] [SPU1]
      ON (
      [SPU1].[PACK_UNIT] = [TAB].[PACK_UNIT]
      )
    INNER JOIN [SONDA].[SONDA_PACK_UNIT] [SPU2]
      ON (
      [SPU2].[PACK_UNIT] = [TAB].[PACK_UNIT_BONUS]
      )
    WHERE [TA].[LINKED_TO] = @LINKED_TO
    AND [SPU1].[PACK_UNIT] > 0
    AND [SPU2].[PACK_UNIT] > 0
    AND [TAB].[PROMO_ID] > 0
    AND [TA].[TRADE_AGREEMENT_ID] > 0

  -- ------------------------------------------------------------------------------------
  -- Genera los SKUs de la lista de bonificaciones por multiplo
  -- ------------------------------------------------------------------------------------
  INSERT [SONDA].[SWIFT_BONUS_LIST_BY_SKU_MULTIPLE] ([BONUS_LIST_ID]
  , [CODE_SKU]
  , [CODE_PACK_UNIT]
  , [MULTIPLE]
  , [CODE_SKU_BONUS]
  , [CODE_PACK_UNIT_BONUES]
  , [BONUS_QTY]
  , [PROMO_ID]
  , [PROMO_NAME]
  , [PROMO_TYPE]
  , [FREQUENCY])
    SELECT DISTINCT
      [BL].[BONUS_LIST_ID]
     ,[TAM].[CODE_SKU]
     ,[SPU1].[CODE_PACK_UNIT]
     ,[TAM].[MULTIPLE]
     ,[TAM].[CODE_SKU_BONUS]
     ,[SPU2].[CODE_PACK_UNIT]
     ,[TAM].[BONUS_QTY]
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
    INNER JOIN [SONDA].[SWIFT_PROMO_BONUS_BY_MULTIPLE] [TAM]
      ON (
      [TAM].[PROMO_ID] = [P].[PROMO_ID]
      )
    INNER JOIN [SONDA].[SWIFT_BONUS_LIST] [BL]
      ON (
      [BL].[CODE_ROUTE] = [TA].[CODE_ROUTE]
      AND [BL].[NAME_BONUS_LIST] = [TA].[NAME_BONUS_LIST]
      )
    INNER JOIN [SONDA].[SONDA_PACK_UNIT] [SPU1]
      ON (
      [SPU1].[PACK_UNIT] = [TAM].[PACK_UNIT]
      )
    INNER JOIN [SONDA].[SONDA_PACK_UNIT] [SPU2]
      ON (
      [SPU2].[PACK_UNIT] = [TAM].[PACK_UNIT_BONUS]
      )
    WHERE [TA].[LINKED_TO] = @LINKED_TO
    AND [SPU1].[PACK_UNIT] > 0
    AND [SPU2].[PACK_UNIT] > 0
    AND [TA].[TRADE_AGREEMENT_ID] > 0

  -- ------------------------------------------------------------------------------------
  -- Se agrega la configuracion de bonificaciones por combo
  -- ------------------------------------------------------------------------------------
  INSERT INTO [SONDA].[SWIFT_BONUS_LIST_BY_COMBO] ([BONUS_LIST_ID]
  , [COMBO_ID]
  , [BONUS_TYPE]
  , [BONUS_SUB_TYPE]
  , [IS_BONUS_BY_LOW_PURCHASE]
  , [IS_BONUS_BY_COMBO]
  , [LOW_QTY]
  , [PROMO_ID]
  , [PROMO_NAME]
  , [PROMO_TYPE]
  , [FREQUENCY])
    SELECT DISTINCT
      [BL].[BONUS_LIST_ID]
     ,[TAR].[COMBO_ID]
     ,[TAR].[BONUS_TYPE]
     ,[TAR].[BONUS_SUB_TYPE]
     ,[TAR].[IS_BONUS_BY_LOW_PURCHASE]
     ,[TAR].[IS_BONUS_BY_COMBO]
     ,[TAR].[LOW_QTY]
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
    INNER JOIN [SONDA].[SWIFT_PROMO_BY_BONUS_RULE] [TAB]
      ON (
      [TAB].[PROMO_ID] = [P].[PROMO_ID]
      )
    INNER JOIN [SONDA].[SWIFT_PROMO_BY_COMBO_PROMO_RULE] [TAR]
      ON (
      [TAR].[PROMO_RULE_BY_COMBO_ID] = [TAB].[PROMO_RULE_BY_COMBO_ID]
      )
    INNER JOIN [SONDA].[SWIFT_BONUS_LIST] [BL]
      ON (
      [BL].[CODE_ROUTE] = [TA].[CODE_ROUTE]
      AND [BL].[NAME_BONUS_LIST] = [TA].[NAME_BONUS_LIST]
      )
    WHERE [TA].[LINKED_TO] = @LINKED_TO
    AND [TA].[TRADE_AGREEMENT_ID] > 0

  -- ------------------------------------------------------------------------------------
  -- Se agrega la configuracion de bonificaciones por combo
  -- ------------------------------------------------------------------------------------
  INSERT INTO [SONDA].[SWIFT_BONUS_LIST_BY_COMBO_SKU] ([BONUS_LIST_ID]
  , [COMBO_ID]
  , [CODE_SKU]
  , [CODE_PACK_UNIT]
  , [QTY]
  , [IS_MULTIPLE])
    SELECT DISTINCT
      [BL].[BONUS_LIST_ID]
     ,[TAR].[COMBO_ID]
     ,[TAS].[CODE_SKU]
     ,[SPU].[CODE_PACK_UNIT]
     ,[TAS].[QTY]
     ,[TAS].[IS_MULTIPLE]
    FROM @TRADE_AGREEMENT_BY_CHANNEL [TA]
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO] [TAP]
      ON (
      [TAP].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID]
      )
    INNER JOIN [SONDA].[SWIFT_PROMO] [P]
      ON (
      [P].[PROMO_ID] = [TAP].[PROMO_ID]
      )
    INNER JOIN [SONDA].[SWIFT_PROMO_BY_BONUS_RULE] [TAB]
      ON (
      [TAB].[PROMO_ID] = [P].[PROMO_ID]
      )
    INNER JOIN [SONDA].[SWIFT_PROMO_BY_COMBO_PROMO_RULE] [TAR]
      ON (
      [TAR].[PROMO_RULE_BY_COMBO_ID] = [TAB].[PROMO_RULE_BY_COMBO_ID]
      )
    INNER JOIN [SONDA].[SWIFT_PROMO_SKU_BY_PROMO_RULE] [TAS]
      ON (
      [TAS].[PROMO_RULE_BY_COMBO_ID] = [TAR].[PROMO_RULE_BY_COMBO_ID]
      )
    INNER JOIN [SONDA].[SWIFT_BONUS_LIST] [BL]
      ON (
      [BL].[CODE_ROUTE] = [TA].[CODE_ROUTE]
      AND [BL].[NAME_BONUS_LIST] = [TA].[NAME_BONUS_LIST]
      )
    INNER JOIN [SONDA].[SONDA_PACK_UNIT] [SPU]
      ON (
      [SPU].[PACK_UNIT] = [TAS].[PACK_UNIT]
      )
    WHERE [TA].[LINKED_TO] = @LINKED_TO
    AND [SPU].[PACK_UNIT] > 0
    AND [TA].[TRADE_AGREEMENT_ID] > 0

  -- ------------------------------------------------------------------------------------
  --  Se agrega la bonificacion por monto general
  -- ------------------------------------------------------------------------------------
  INSERT INTO [SONDA].[SWIFT_BONUS_LIST_BY_GENERAL_AMOUNT] ([BONUS_LIST_ID]
  , [LOW_LIMIT]
  , [HIGH_LIMIT]
  , [CODE_SKU_BONUS]
  , [CODE_PACK_UNIT_BONUS]
  , [BONUS_QTY]
  , [PROMO_ID]
  , [PROMO_NAME]
  , [PROMO_TYPE]
  , [FREQUENCY])
    SELECT DISTINCT
      [BL].[BONUS_LIST_ID]
     ,[BGA].[LOW_LIMIT]
     ,[BGA].[HIGH_LIMIT]
     ,[BGA].[CODE_SKU_BONUS]
     ,[SPU].[PACK_UNIT]
     ,[BGA].[BONUS_QTY]
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
    INNER JOIN [SONDA].[SWIFT_PROMO_BONUS_BY_GENERAL_AMOUNT] [BGA]
      ON (
      [BGA].[PROMO_ID] = [P].[PROMO_ID]
      )
    INNER JOIN [SONDA].[SWIFT_BONUS_LIST] [BL]
      ON (
      [BL].[CODE_ROUTE] = [TA].[CODE_ROUTE]
      AND [BL].[NAME_BONUS_LIST] = [TA].[NAME_BONUS_LIST]
      )
    INNER JOIN [SONDA].[SONDA_PACK_UNIT] [SPU]
      ON (
      [SPU].[PACK_UNIT] = [BGA].[PACK_UNIT_BONUS]
      )
    WHERE [TA].[LINKED_TO] = @LINKED_TO
    AND [SPU].[PACK_UNIT] > 0
    AND [TA].[TRADE_AGREEMENT_ID] > 0
END
