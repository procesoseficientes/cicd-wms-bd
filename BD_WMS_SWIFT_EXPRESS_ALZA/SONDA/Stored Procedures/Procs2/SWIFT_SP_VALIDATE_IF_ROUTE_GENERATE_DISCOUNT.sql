-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-16 @ Team REBORN - Sprint 
-- Description:	        

-- Modificacion:	      rudi.garcia
-- Fecha de Creacion: 	07-May-2018 @ Team G-Force - Sprint Caribú
-- Description:	        se agregaron las tablas [SWIFT_PROMO_DISCOUNT_BY_FAMILY] y [SWIFT_PROMO_DISCOUNT_BY_PAYMENT_TYPE_AND_FAMILY]

/*
-- Ejemplo de Ejecucion:
			EXEC  [SONDA].[SWIFT_SP_VALIDATE_IF_ROUTE_GENERATE_DISCOUNT] @CODE_ROUTE = '136'
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_VALIDATE_IF_ROUTE_GENERATE_DISCOUNT (@CODE_ROUTE VARCHAR(50), @GENERATE_DISCOUNT INT OUTPUT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @WATER_MARK DATETIME = '1900-01-01 12:00:00 AM'
         ,@CURRENT_WATER_MARK DATETIME
         ,@LAST_WATER_MARK DATETIME = '1900-01-01 12:00:00 AM'
         ,@MARKED_TABLE NVARCHAR(100)

  SET @GENERATE_DISCOUNT = 0

  SELECT TOP 1
    @WATER_MARK = ISNULL([TAW].[WATER_MARK], '1900-01-01 12:00:00 AM')
  FROM [SONDA].[SWIFT_TRADE_AGREEMENT_WATERMARK] [TAW]
  WHERE [TAW].[CODE_ROUTE] = @CODE_ROUTE

  SET @LAST_WATER_MARK = @WATER_MARK

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_PROMO_DISCOUNT_BY_GENERAL_AMOUNT]
  -- ------------------------------------------------------------------------------------
  SELECT TOP 1
    @CURRENT_WATER_MARK = [DBGA].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_GENERAL_AMOUNT] [DBGA]
  WHERE [DBGA].[LAST_UPDATE] > 0
  ORDER BY [DBGA].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_DISCOUNT = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_PROMO_DISCOUNT_BY_GENERAL_AMOUNT]'
  END

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_PROMO_DISCOUNT_BY_SCALE]
  -- ------------------------------------------------------------------------------------

  SELECT TOP 1
    @CURRENT_WATER_MARK = [DBS].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_SCALE] [DBS]
  WHERE [DBS].[LAST_UPDATE] > 0
  ORDER BY [DBS].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_DISCOUNT = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_PROMO_DISCOUNT_BY_SCALE]'
  END

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_PROMO_DISCOUNT_BY_FAMILY]
  -- ------------------------------------------------------------------------------------

  SELECT TOP 1
    @CURRENT_WATER_MARK = [DBF].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_FAMILY] [DBF]
  WHERE [DBF].[LAST_UPDATE] > 0
  ORDER BY [DBF].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_DISCOUNT = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_PROMO_DISCOUNT_BY_FAMILY]'
  END

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_PROMO_DISCOUNT_BY_TYPE_PAYMENT_AND_FAMILY]
  -- ------------------------------------------------------------------------------------

  SELECT TOP 1
    @CURRENT_WATER_MARK = [DTF].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_PROMO_DISCOUNT_BY_PAYMENT_TYPE_AND_FAMILY] [DTF]
  WHERE [DTF].[LAST_UPDATE] > 0
  ORDER BY [DTF].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_DISCOUNT = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_PROMO_DISCOUNT_BY_PAYMENT_TYPE_AND_FAMILY]'
  END

  -- ------------------------------------------------------------------------------------
  -- Valido si se genera acuerdo comercial y se le asigna @WATER_MARK a @LAST_WATER_MARK si no genera
  -- ------------------------------------------------------------------------------------
  IF @GENERATE_DISCOUNT = 0
  BEGIN
    SET @LAST_WATER_MARK = @WATER_MARK
  END

  IF NOT EXISTS (SELECT
        WATER_MARK
      FROM [SONDA].[SWIFT_TRADE_AGREEMENT_WATERMARK]
      WHERE [CODE_ROUTE] = @CODE_ROUTE)
  BEGIN

    INSERT INTO [SONDA].[SWIFT_TRADE_AGREEMENT_WATERMARK] ([WATER_MARK], [CODE_ROUTE], [TIMES_REQUIRE], [LAST_REQUIRE], [MARKED_TABLE])
      VALUES (@LAST_WATER_MARK, @CODE_ROUTE, 1, GETDATE(), @MARKED_TABLE);

  END
  ELSE
  BEGIN
    UPDATE [SONDA].[SWIFT_TRADE_AGREEMENT_WATERMARK]
    SET [WATER_MARK] = @LAST_WATER_MARK
       ,[CODE_ROUTE] = @CODE_ROUTE
       ,[TIMES_REQUIRE] = [TIMES_REQUIRE]
       ,[LAST_REQUIRE] = GETDATE()
       ,[MARKED_TABLE] = ISNULL(@MARKED_TABLE, [MARKED_TABLE])
    WHERE [CODE_ROUTE] = @CODE_ROUTE;
  END


END
