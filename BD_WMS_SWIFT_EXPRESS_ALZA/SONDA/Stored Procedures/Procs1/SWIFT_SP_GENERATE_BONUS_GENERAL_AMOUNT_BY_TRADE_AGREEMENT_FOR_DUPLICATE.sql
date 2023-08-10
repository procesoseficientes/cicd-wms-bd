-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	31-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- Description:			SP que genera las bonificaciones por monto general desde acuerdo comercial para los clientes que tambien esten en un canal

-- Modificacion 17-Aug-2017 @Reborn Team Sprint Bearbeitung
-- rudi.garcia
-- Se agrego la columna de "FREQUENCY"

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GENERATE_BONUS_GENERAL_AMOUNT_BY_TRADE_AGREEMENT_FOR_DUPLICATE]
					@CODE_ROUTE = '44'
					,@ORDER = 1
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GENERATE_BONUS_GENERAL_AMOUNT_BY_TRADE_AGREEMENT_FOR_DUPLICATE (@CODE_ROUTE VARCHAR(250)
, @ORDER INT)
AS
BEGIN
  SET NOCOUNT ON;
IF @ORDER != 1
  BEGIN
    RETURN;
  END
  -- ------------------------------------------------------------------------------------
  -- Obtiene valores iniciales
  -- ------------------------------------------------------------------------------------
  DECLARE @CUSTOMER TABLE (
    [CODE_CUSTOMER] VARCHAR(50)
    UNIQUE ([CODE_CUSTOMER])
  )
  --
  DECLARE @TRADE_AGREEMENT TABLE (
    [TRADE_AGREEMENT_ID] INT
   ,[CODE_TRADE_AGREEMENT] VARCHAR(50)
   ,[CODE_CUSTOMER] VARCHAR(50)
   ,[LINKED_TO] VARCHAR(250)
   ,[CODE_ROUTE] VARCHAR(50)
   ,[NAME_BONUS_LIST] VARCHAR(250)
   ,UNIQUE ([TRADE_AGREEMENT_ID], [CODE_CUSTOMER])
   ,UNIQUE ([LINKED_TO], [TRADE_AGREEMENT_ID], [CODE_ROUTE], [NAME_BONUS_LIST], [CODE_CUSTOMER])
  )
  --
  DECLARE @SELLER_CODE VARCHAR(50)
         ,@NOW DATETIME = GETDATE()
         ,@ACTIVE_STATUS INT = 1
         ,@LINKED_TO VARCHAR(250) = 'CUSTOMER';
  --
  SELECT
    @SELLER_CODE = [SONDA].[SWIFT_FN_GET_SELLER_BY_ROUTE](@CODE_ROUTE)

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
  , [NAME_BONUS_LIST])
    SELECT DISTINCT
      [TAC].[TRADE_AGREEMENT_ID]
     ,[TA].[CODE_TRADE_AGREEMENT]
     ,[C].[CODE_CUSTOMER]
     ,[TA].[LINKED_TO]
     ,@CODE_ROUTE
     ,@CODE_ROUTE + '|' + [C].[CODE_CUSTOMER]
    FROM @CUSTOMER [C]
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
      ON (
      [C].[CODE_CUSTOMER] = [TAC].[CODE_CUSTOMER]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA]
      ON (
      [TAC].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID]
      )
    WHERE [TA].[STATUS] = @ACTIVE_STATUS
    AND [TA].[LINKED_TO] = @LINKED_TO
    AND @NOW BETWEEN [TA].[VALID_START_DATETIME] AND [TA].[VALID_END_DATETIME]

  -- ------------------------------------------------------------------------------------
  -- Valida si es el primero en ejecutar para generar el listado de bonificaciones y de clientes por bonificacion
  -- ------------------------------------------------------------------------------------
  -- Se comento esta parte por que ya se hace en la de escala [SWIFT_SP_GENERATE_BONUS_BY_TRADE_AGREEMENT_FOR_DUPLICATE] ó [SWIFT_SP_GENERATE_BONUS_BY_CHANNEL_FOR_DUPLICATE]
  --  IF @ORDER = 1
  --  BEGIN
  --    -- ------------------------------------------------------------------------------------
  --    -- Genera las listas de bonificaciones
  --    -- ------------------------------------------------------------------------------------
  --    INSERT INTO [SONDA].[SWIFT_BONUS_LIST] ([NAME_BONUS_LIST]
  --    , [CODE_ROUTE])
  --      SELECT DISTINCT
  --        (@CODE_ROUTE + '|' + [TA].[CODE_CUSTOMER])
  --       ,@CODE_ROUTE
  --      FROM @TRADE_AGREEMENT [TA]
  --
  --    -- ------------------------------------------------------------------------------------
  --    -- Asocia el cliente con la lista de bonificaciones
  --    -- ------------------------------------------------------------------------------------
  --    INSERT INTO [SONDA].[SWIFT_BONUS_LIST_BY_CUSTOMER] ([BONUS_LIST_ID]
  --    , [CODE_CUSTOMER])
  --      SELECT DISTINCT
  --        [BL].[BONUS_LIST_ID]
  --       ,[TA].[CODE_CUSTOMER]
  --      FROM @TRADE_AGREEMENT [TA]
  --      INNER JOIN [SONDA].[SWIFT_BONUS_LIST] [BL]
  --        ON (
  --        [BL].[CODE_ROUTE] = [TA].[CODE_ROUTE]
  --        AND [BL].[NAME_BONUS_LIST] = [TA].[NAME_BONUS_LIST]
  --        )
  --  END

  -- ------------------------------------------------------------------------------------
  -- Genera las bonificaciones por acuerdo comercial
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
     ,[TAB].[LOW_LIMIT]
     ,[TAB].[HIGH_LIMIT]
     ,[TAB].[CODE_SKU_BONUS]
     ,[TAB].[PACK_UNIT_BONUS]
     ,[TAB].[BONUS_QTY]
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
    INNER JOIN [SONDA].[SWIFT_BONUS_LIST] [BL]
      ON (
      [BL].[CODE_ROUTE] = [TA].[CODE_ROUTE]
      AND [BL].[NAME_BONUS_LIST] = [TA].[NAME_BONUS_LIST]
      )
    INNER JOIN [SONDA].[SWIFT_PROMO_BONUS_BY_GENERAL_AMOUNT] [TAB]
      ON (
      [TAB].[PROMO_ID] = [P].[PROMO_ID]
      )
    INNER JOIN [SONDA].[SONDA_PACK_UNIT] [SPU]
      ON (
      [SPU].[PACK_UNIT] = [TAB].[PACK_UNIT_BONUS]
      )
    LEFT JOIN [SONDA].[SWIFT_BONUS_LIST_BY_GENERAL_AMOUNT] [BLBS]
      ON (
      [BLBS].[BONUS_LIST_ID] = [BL].[BONUS_LIST_ID]
      AND [BLBS].[CODE_SKU_BONUS] = [TAB].[CODE_SKU_BONUS]
      AND [BLBS].[CODE_SKU_BONUS] = [TAB].[CODE_SKU_BONUS]
      )
    WHERE [BLBS].[CODE_SKU_BONUS] IS NULL
    AND [TA].[LINKED_TO] = @LINKED_TO
    AND [SPU].[PACK_UNIT] > 0
END
