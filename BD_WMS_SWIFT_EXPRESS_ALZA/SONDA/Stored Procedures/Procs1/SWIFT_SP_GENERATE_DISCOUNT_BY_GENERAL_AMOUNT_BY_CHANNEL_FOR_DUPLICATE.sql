-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		16-Feb-17 @ A-Team Sprint Chatuluka
-- Description:			    SP que genera los descuentos generales por canal de los clientes en acuerdo comercial por cliente y canal

-- Modificacion 25-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se cambio para que obtenga las listas por el codigo de ruta y de las tablas de promo

-- Modificacion 17-Aug-2017 @Reborn Team Sprint Bearbeitung
-- rudi.garcia
-- Se agrego la columna de "FREQUENCY"


/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GENERATE_DISCOUNT_BY_GENERAL_AMOUNT_BY_CHANNEL_FOR_DUPLICATE]
					@CODE_ROUTE = '44'
					,@ORDER = 2
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GENERATE_DISCOUNT_BY_GENERAL_AMOUNT_BY_CHANNEL_FOR_DUPLICATE (@CODE_ROUTE VARCHAR(250)
, @ORDER INT) WITH RECOMPILE
AS
BEGIN
  SET NOCOUNT ON;

  -- ------------------------------------------------------------------------------------
  -- Obtiene valores iniciales
  -- ------------------------------------------------------------------------------------
  DECLARE @SELLER_CODE VARCHAR(50)
         ,@NOW DATETIME = GETDATE()
         ,@STATUS INT = 1
         ,@LINKED_TO VARCHAR(250) = 'CHANNEL'
  --
  DECLARE @CUSTOMER TABLE (
    [CODE_CUSTOMER] VARCHAR(50)
   ,UNIQUE ([CODE_CUSTOMER])
  )
  --
  DECLARE @TRADE_AGREEMENT TABLE (
    [TRADE_AGREEMENT_ID] INT
   ,[CODE_CUSTOMER] VARCHAR(50)
   ,[CODE_ROUTE] VARCHAR(50)
   ,[NAME_DISCOUNT_LIST] VARCHAR(250)
   ,UNIQUE ([TRADE_AGREEMENT_ID], [CODE_CUSTOMER])
   ,UNIQUE ([CODE_ROUTE], [NAME_DISCOUNT_LIST], [TRADE_AGREEMENT_ID])
  )
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
    AND [TA1].[STATUS] = @STATUS
    AND [TA2].[STATUS] = @STATUS
    AND @NOW BETWEEN [TA1].[VALID_START_DATETIME] AND [TA1].[VALID_END_DATETIME]
    AND @NOW BETWEEN [TA2].[VALID_START_DATETIME] AND [TA2].[VALID_END_DATETIME]
	AND [TACH].[TRADE_AGREEMENT_ID] > 0

  -- ------------------------------------------------------------------------------------
  -- Obtiene los clientes que esten en el plan de ruta y no esten asociados por vendedor
  -- ------------------------------------------------------------------------------------
  INSERT INTO @CUSTOMER ([CODE_CUSTOMER])
    SELECT DISTINCT
      [RP].[RELATED_CLIENT_CODE]
    FROM  [SONDA].[SONDA_ROUTE_PLAN] [RP]      
    INNER JOIN [SONDA].SWIFT_TRADE_AGREEMENT_BY_CUSTOMER TAC
      ON (
      [RP].[RELATED_CLIENT_CODE] = TAC.CODE_CUSTOMER
      )
    INNER JOIN [SONDA].SWIFT_CHANNEL_X_CUSTOMER CC
      ON (
      [RP].[RELATED_CLIENT_CODE] = CC.CODE_CUSTOMER
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] TA1
      ON (
      [TA1].[TRADE_AGREEMENT_ID] = [TAC].[TRADE_AGREEMENT_ID]
      )
    INNER JOIN [SONDA].SWIFT_TRADE_AGREEMENT_BY_CHANNEL TACH
      ON (
      CC.[CHANNEL_ID] = [TACH].[CHANNEL_ID]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] TA2
      ON (
      [TA2].[TRADE_AGREEMENT_ID] = [TACH].[TRADE_AGREEMENT_ID]
      )
    LEFT JOIN @CUSTOMER [C2]
      ON (
      [RP].[RELATED_CLIENT_CODE] = [C2].[CODE_CUSTOMER]
      )
    WHERE [RP].[CODE_ROUTE] = @CODE_ROUTE
    AND [TA1].[STATUS] = @STATUS
    AND [TA2].[STATUS] = @STATUS
    AND @NOW BETWEEN TA1.VALID_START_DATETIME AND TA1.VALID_END_DATETIME
    AND @NOW BETWEEN TA2.VALID_START_DATETIME AND TA2.VALID_END_DATETIME
    AND [C2].[CODE_CUSTOMER] IS NULL
	AND [TACH].[TRADE_AGREEMENT_ID] > 0

  -- ------------------------------------------------------------------------------------
  -- Obtiene los acuerdos comerciales
  -- ------------------------------------------------------------------------------------
  INSERT INTO @TRADE_AGREEMENT ([TRADE_AGREEMENT_ID]
  , [CODE_CUSTOMER]
  , [CODE_ROUTE]
  , [NAME_DISCOUNT_LIST])
    SELECT DISTINCT
      [TAC].[TRADE_AGREEMENT_ID]
     ,[C].[CODE_CUSTOMER]
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
    WHERE [TA].[STATUS] = @STATUS
    AND [TA].[LINKED_TO] = @LINKED_TO
    AND GETDATE() BETWEEN [TA].[VALID_START_DATETIME] AND [TA].[VALID_END_DATETIME]
    AND [TAC].[TRADE_AGREEMENT_ID] > 0

  -- ------------------------------------------------------------------------------------
  -- Valida si es el primero en ejecutar para generar el listado de descuentos y de clientes
  -- ------------------------------------------------------------------------------------
  -- Se comento este segmento debido que se corre primero el SP que genera los descuentos para escalas --
  /*IF @ORDER = 1
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Genera las listas de bonificaciones
		-- ------------------------------------------------------------------------------------
		INSERT INTO [SONDA].[SWIFT_DISCOUNT_LIST]
				([NAME_DISCOUNT_LIST])
		SELECT DISTINCT (@CODE_ROUTE + '|' + [TA].[CODE_CUSTOMER])
		FROM @TRADE_AGREEMENT [TA]

		-- ------------------------------------------------------------------------------------
		-- Asocia el cliente con la lista de bonificaciones
		-- ------------------------------------------------------------------------------------
		INSERT INTO [SONDA].[SWIFT_DISCOUNT_LIST_BY_CUSTOMER]
				(
					[DISCOUNT_LIST_ID]
					,[CODE_CUSTOMER]
				)
		SELECT DISTINCT 
			[DL].[DISCOUNT_LIST_ID]
			,[TA].[CODE_CUSTOMER]
		FROM @TRADE_AGREEMENT [TA]
		INNER JOIN [SONDA].[SWIFT_DISCOUNT_LIST] [DL] ON (
			[DL].[NAME_DISCOUNT_LIST] = (@CODE_ROUTE + '|' + [TA].[CODE_CUSTOMER])
		)
	END*/

  -- ------------------------------------------------------------------------------------
  -- Se agrega la configuracion de bonificaciones por combo
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
     ,[TAG].[LOW_AMOUNT]
     ,[TAG].[HIGH_AMOUNT]
     ,[TAG].[DISCOUNT]
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
    INNER JOIN [SONDA].[SWIFT_PROMO_DISCOUNT_BY_GENERAL_AMOUNT] [TAG]
      ON (
      [TAG].[PROMO_ID] = [P].[PROMO_ID]
      )
    INNER JOIN [SONDA].[SWIFT_DISCOUNT_LIST] [DL]
      ON (
      [DL].[CODE_ROUTE] = [TA].[CODE_ROUTE]
      AND [DL].[NAME_DISCOUNT_LIST] = [TA].[NAME_DISCOUNT_LIST]
      )
    LEFT JOIN [SONDA].[SWIFT_DISCOUNT_LIST_BY_GENERAL_AMOUNT] [DLG]
      ON (
      [DLG].[DISCOUNT_LIST_ID] = [DL].[DISCOUNT_LIST_ID]
      )
    WHERE [DLG].[DISCOUNT] IS NULL
END
