-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que genera la lista de descuentos por acuerdo comercial de clientes

-- Modificacion 13-Dec-16 @ A-Team Sprint 6
-- alberto.ruiz
-- Se ajusto el join que obtiene los clientes para que se unan correctamente y se valido vigencia de los acuerdos comerciales

-- Modificacion 2/13/2017 @ A-Team Sprint Chatuluka
-- rodrigo.gomez
-- Se agrego la insercion de las columnas PACK_UNIT, HIGH_LIMIT y LOW_LIMIT a la tabla SWIFT_DISCOUNT_LIST_BY_SKU

-- Modificacion 25-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se cambio para que obtenga las listas por el codigo de ruta y de las tablas de promo

-- Modificacion 17-Aug-2017 @Reborn Team Sprint Bearbeitung
-- rudi.garcia
-- Se agrego la columna de "FREQUENCY"

-- Modificacion 17-Aug-2017 @Reborn Team Sprint Bearbeitung
-- rudi.garcia
-- Se agrego la columna de "FREQUENCY"

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_GENERATE_DISCOUNT_LIST_BY_ROUTE_FOR_REPEATED_CUSTOMER]
					@CODE_ROUTE = 'RUDI@SONDA'
*/
-- =============================================
CREATE PROCEDURE SONDA.SWIFT_SP_GENERATE_DISCOUNT_LIST_BY_ROUTE_FOR_REPEATED_CUSTOMER (@CODE_ROUTE VARCHAR(250))
AS
BEGIN
  SET NOCOUNT ON;

  -- ------------------------------------------------------------------------------------
  -- Obtiene valores iniciales
  -- ------------------------------------------------------------------------------------
  DECLARE @CUSTOMER TABLE (
    [CODE_CUSTOMER] VARCHAR(50)
   ,UNIQUE ([CODE_CUSTOMER])
  )
  --
  DECLARE @SELLER_CODE VARCHAR(50)
         ,@CODE_CUSTOMER VARCHAR(50)
         ,@DISCOUNT_LIST_ID INT
         ,@LINKED_TO VARCHAR(50)
         ,@NOW DATETIME = GETDATE()
         ,@STATUS INT = 1
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
    INNER JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC]
      ON (
      [C].[CODE_CUSTOMER] = [CC].[CODE_CUSTOMER]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
      ON (
      [C].[CODE_CUSTOMER] = [TAC].[CODE_CUSTOMER]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA1]
      ON (
      [TA1].[TRADE_AGREEMENT_ID] = [TAC].[TRADE_AGREEMENT_ID]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL] [TA]
      ON (
      [TA].[CHANNEL_ID] = [CC].[CHANNEL_ID]
      )
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT] [TA2]
      ON (
      [TA2].[TRADE_AGREEMENT_ID] = [TA].[TRADE_AGREEMENT_ID]
      )
    WHERE [C].[SELLER_DEFAULT_CODE] = @SELLER_CODE
    AND TAC.[TRADE_AGREEMENT_ID] > 0
    AND [TA1].[STATUS] = @STATUS
    AND @NOW BETWEEN [TA1].[VALID_START_DATETIME] AND [TA1].[VALID_END_DATETIME]
    AND [TA2].[STATUS] = @STATUS
    AND @NOW BETWEEN [TA2].[VALID_START_DATETIME] AND [TA2].[VALID_END_DATETIME]
    AND [TA].[TRADE_AGREEMENT_ID] > 0


  -- ------------------------------------------------------------------------------------
  -- Obtiene los clientes que esten en el plan de ruta y no esten asociados por vendedor
  -- ------------------------------------------------------------------------------------
  INSERT INTO @CUSTOMER ([CODE_CUSTOMER])
    SELECT DISTINCT
      [RP].[RELATED_CLIENT_CODE]
    FROM [SONDA].[SONDA_ROUTE_PLAN] [RP]
    INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
      ON (
      [RP].[RELATED_CLIENT_CODE] = [TAC].[CODE_CUSTOMER]
      )
    INNER JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC]
      ON (
      [RP].[RELATED_CLIENT_CODE] = [CC].[CODE_CUSTOMER]
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
      [RP].[RELATED_CLIENT_CODE] = [C2].[CODE_CUSTOMER]
      )
    WHERE [RP].[CODE_ROUTE] = @CODE_ROUTE
    AND [TA1].[STATUS] = @STATUS
    AND [TA2].[STATUS] = @STATUS
    AND @NOW BETWEEN [TA1].[VALID_START_DATETIME] AND [TA1].[VALID_END_DATETIME]
    AND @NOW BETWEEN [TA2].[VALID_START_DATETIME] AND [TA2].[VALID_END_DATETIME]
    AND [C2].[CODE_CUSTOMER] IS NULL

  -- ------------------------------------------------------------------------------------
  -- Obtiene la prioridad
  -- ------------------------------------------------------------------------------------
  SELECT TOP 1
    @LINKED_TO = [LINKED_TO]
  FROM [SONDA].[SWIFT_DISCOUNT_PRIORITY]
  WHERE [ORDER] > 0
  AND [ACTIVE_SWIFT_EXPRESS] = @STATUS
  ORDER BY [ORDER]

  -- ------------------------------------------------------------------------------------
  -- Genera descuento para cada cliente repetido
  -- ------------------------------------------------------------------------------------
  WHILE EXISTS (SELECT TOP 1
        1
      FROM @CUSTOMER)
  BEGIN
    -- ------------------------------------------------------------------------------------
    -- Obtiene cliente a generar la lista
    -- ------------------------------------------------------------------------------------
    SELECT TOP 1
      @CODE_CUSTOMER = [C].[CODE_CUSTOMER]
     ,@DISCOUNT_LIST_ID = NULL
    FROM @CUSTOMER [C]

    -- ------------------------------------------------------------------------------------
    -- Crea la lista de descuento
    -- ------------------------------------------------------------------------------------
    INSERT INTO [SONDA].[SWIFT_DISCOUNT_LIST] ([NAME_DISCOUNT_LIST]
    , [CODE_ROUTE])
      VALUES ((@CODE_ROUTE + '|' + @CODE_CUSTOMER)  -- NAME_DISCOUNT_LIST - varchar(250)
      , @CODE_ROUTE  -- CODE_ROUTE - varchar(50)
      )
    --
    SET @DISCOUNT_LIST_ID = SCOPE_IDENTITY()

    -- ------------------------------------------------------------------------------------
    -- Asocia el cliente a la lista de descuento
    -- ------------------------------------------------------------------------------------
    INSERT INTO [SONDA].[SWIFT_DISCOUNT_LIST_BY_CUSTOMER]
      VALUES (@DISCOUNT_LIST_ID, @CODE_CUSTOMER)

    -- ------------------------------------------------------------------------------------
    -- Valida si es primero canal o cliente produto
    -- ------------------------------------------------------------------------------------
    IF @LINKED_TO = 'CHANNEL'
    BEGIN
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
        SELECT
          @DISCOUNT_LIST_ID
         ,[TAD].[CODE_SKU]
         ,[TAD].[PACK_UNIT]
         ,[TAD].[LOW_LIMIT]
         ,[TAD].[HIGH_LIMIT]
         ,[TAD].[DISCOUNT]
         ,[TAD].[DISCOUNT_TYPE]
         ,[TAD].[IS_UNIQUE]
         ,[P].[PROMO_ID]
         ,[P].[PROMO_NAME]
         ,[P].[PROMO_TYPE]
         ,[TAP].[FREQUENCY]
        FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_SCALE] [TAD]
        INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO] [TAP]
          ON (
          [TAP].[PROMO_ID] = [TAD].[PROMO_ID]
          )
        INNER JOIN [SONDA].[SWIFT_PROMO] [P]
          ON (
          [P].[PROMO_ID] = [TAP].[PROMO_ID]
          )
        INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL] [TAC]
          ON (
          [TAC].[TRADE_AGREEMENT_ID] = [TAP].[TRADE_AGREEMENT_ID]
          )
        INNER JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC]
          ON (
          [CC].[CHANNEL_ID] = [TAC].[CHANNEL_ID]
          )
        WHERE [CC].[CODE_CUSTOMER] = @CODE_CUSTOMER
      --
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
        SELECT
          @DISCOUNT_LIST_ID
         ,[TAD].[CODE_SKU]
         ,[TAD].[PACK_UNIT]
         ,[TAD].[LOW_LIMIT]
         ,[TAD].[HIGH_LIMIT]
         ,[TAD].[DISCOUNT]
         ,[TAD].[DISCOUNT_TYPE]
         ,[TAD].[IS_UNIQUE]
         ,[P].[PROMO_ID]
         ,[P].[PROMO_NAME]
         ,[P].[PROMO_TYPE]
         ,[TAP].[FREQUENCY]
        FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_SCALE] [TAD]
        INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO] [TAP]
          ON (
          [TAP].[PROMO_ID] = [TAD].[PROMO_ID]
          )
        INNER JOIN [SONDA].[SWIFT_PROMO] [P]
          ON (
          [P].[PROMO_ID] = [TAP].[PROMO_ID]
          )
        INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
          ON (
          [TAC].[TRADE_AGREEMENT_ID] = [TAP].[TRADE_AGREEMENT_ID]
          )
        LEFT JOIN [SONDA].[SWIFT_DISCOUNT_LIST_BY_SKU] [DLS]
          ON (
          [DLS].[DISCOUNT_LIST_ID] = @DISCOUNT_LIST_ID
          AND [DLS].[CODE_SKU] = [TAD].[CODE_SKU]
          )
        WHERE [TAC].[CODE_CUSTOMER] = @CODE_CUSTOMER
        AND [DLS].[CODE_SKU] IS NULL
    END
    ELSE
    BEGIN
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
        SELECT
          @DISCOUNT_LIST_ID
         ,[TAD].[CODE_SKU]
         ,[TAD].[PACK_UNIT]
         ,[TAD].[LOW_LIMIT]
         ,[TAD].[HIGH_LIMIT]
         ,[TAD].[DISCOUNT]
         ,[TAD].[DISCOUNT_TYPE]
         ,[TAD].[IS_UNIQUE]
         ,[P].[PROMO_ID]
         ,[P].[PROMO_NAME]
         ,[P].[PROMO_TYPE]
         ,[TAP].[FREQUENCY]
        FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_SCALE] [TAD]
        INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO] [TAP]
          ON (
          [TAP].[PROMO_ID] = [TAD].[PROMO_ID]
          )
        INNER JOIN [SONDA].[SWIFT_PROMO] [P]
          ON (
          [P].[PROMO_ID] = [TAP].[PROMO_ID]
          )
        INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
          ON (
          [TAC].[TRADE_AGREEMENT_ID] = [TAP].[TRADE_AGREEMENT_ID]
          )
        WHERE [TAC].[CODE_CUSTOMER] = @CODE_CUSTOMER
      --
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
        SELECT
          @DISCOUNT_LIST_ID
         ,[TAD].[CODE_SKU]
         ,[TAD].[PACK_UNIT]
         ,[TAD].[LOW_LIMIT]
         ,[TAD].[HIGH_LIMIT]
         ,[TAD].[DISCOUNT]
         ,[TAD].[DISCOUNT_TYPE]
         ,[TAD].[IS_UNIQUE]
         ,[P].[PROMO_ID]
         ,[P].[PROMO_NAME]
         ,[P].[PROMO_TYPE]
         ,[TAP].[FREQUENCY]
        FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_SCALE] [TAD]
        INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO] [TAP]
          ON (
          [TAP].[PROMO_ID] = [TAD].[PROMO_ID]
          )
        INNER JOIN [SONDA].[SWIFT_PROMO] [P]
          ON (
          [P].[PROMO_ID] = [TAP].[PROMO_ID]
          )
        INNER JOIN [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL] [TAC]
          ON (
          [TAC].[TRADE_AGREEMENT_ID] = [TAP].[TRADE_AGREEMENT_ID]
          )
        INNER JOIN [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CC]
          ON (
          [CC].[CHANNEL_ID] = [TAC].[CHANNEL_ID]
          )
        LEFT JOIN [SONDA].[SWIFT_DISCOUNT_LIST_BY_SKU] [DLS]
          ON (
          [DLS].[DISCOUNT_LIST_ID] = @DISCOUNT_LIST_ID
          AND [DLS].[CODE_SKU] = [TAD].[CODE_SKU]
          )
        WHERE [CC].[CODE_CUSTOMER] = @CODE_CUSTOMER
        AND [DLS].[CODE_SKU] IS NULL
    END

    -- ------------------------------------------------------------------------------------
    -- Elimina el cliente operado
    -- ------------------------------------------------------------------------------------
    DELETE FROM @CUSTOMER
    WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER
  END
END
