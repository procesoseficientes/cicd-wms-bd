-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-16 @ Team REBORN - Sprint 
-- Description:	        

/*
-- Ejemplo de Ejecucion:
			EXEC  [SONDA].[SWIFT_SP_VALIDATE_IF_ROUTE_GENERATE_DISCOUNT] @CODE_ROUTE = '136'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_IF_ROUTE_GENERATE_BONUS] (@CODE_ROUTE VARCHAR(50), @GENERATE_BONUS INT OUTPUT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @WATER_MARK DATETIME = '1900-01-01 12:00:00 AM'
         ,@CURRENT_WATER_MARK DATETIME
         ,@LAST_WATER_MARK DATETIME = '1900-01-01 12:00:00 AM'
         ,@MARKED_TABLE NVARCHAR(100)

  SET @GENERATE_BONUS = 0

  SELECT TOP 1
    @WATER_MARK = ISNULL([TAW].[WATER_MARK], '1900-01-01 12:00:00 AM')
  FROM [SONDA].[SWIFT_TRADE_AGREEMENT_WATERMARK] [TAW]
  WHERE [TAW].[CODE_ROUTE] = @CODE_ROUTE

  SET @LAST_WATER_MARK = @WATER_MARK

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_PROMO_BONUS_BY_GENERAL_AMOUNT]
  -- ------------------------------------------------------------------------------------
  SELECT TOP 1
    @CURRENT_WATER_MARK = [BBGA].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_PROMO_BONUS_BY_GENERAL_AMOUNT] [BBGA]
  WHERE [BBGA].[LAST_UPDATE] > 0
  ORDER BY [BBGA].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_BONUS = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_PROMO_BONUS_BY_GENERAL_AMOUNT]'
  END

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_PROMO_BONUS_BY_SCALE]
  -- ------------------------------------------------------------------------------------

  SELECT TOP 1
    @CURRENT_WATER_MARK = [BBS].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_PROMO_BONUS_BY_SCALE] [BBS]
  WHERE [BBS].[LAST_UPDATE] > 0
  ORDER BY [BBS].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_BONUS = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_PROMO_BONUS_BY_SCALE]'
  END

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_PROMO_BONUS_BY_MULTIPLE]
  -- ------------------------------------------------------------------------------------

  SELECT TOP 1
    @CURRENT_WATER_MARK = [BBM].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_PROMO_BONUS_BY_MULTIPLE] [BBM]
  WHERE [BBM].[LAST_UPDATE] > 0
  ORDER BY [BBM].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_BONUS = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_PROMO_BONUS_BY_MULTIPLE]'
  END

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_PROMO_BY_BONUS_RULE]
  -- ------------------------------------------------------------------------------------

  SELECT TOP 1
    @CURRENT_WATER_MARK = [PBR].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_PROMO_BY_BONUS_RULE] [PBR]
  WHERE [PBR].[LAST_UPDATE] > 0
  ORDER BY [PBR].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_BONUS = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_PROMO_BY_BONUS_RULE]'
  END

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_PROMO_BY_COMBO_PROMO_RULE]
  -- ------------------------------------------------------------------------------------

  SELECT TOP 1
    @CURRENT_WATER_MARK = [PCPR].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_PROMO_BY_COMBO_PROMO_RULE] [PCPR]
  WHERE [PCPR].[LAST_UPDATE] > 0
  ORDER BY [PCPR].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_BONUS = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_PROMO_BY_COMBO_PROMO_RULE]'
  END

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_PROMO_SKU_BY_PROMO_RULE]
  -- ------------------------------------------------------------------------------------

  SELECT TOP 1
    @CURRENT_WATER_MARK = [PSPR].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_PROMO_SKU_BY_PROMO_RULE] [PSPR]
  WHERE [PSPR].[LAST_UPDATE] > 0
  ORDER BY [PSPR].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_BONUS = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_PROMO_SKU_BY_PROMO_RULE]'
  END

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_COMBO]
  -- ------------------------------------------------------------------------------------

  SELECT TOP 1
    @CURRENT_WATER_MARK = [C].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_COMBO] [C]
  WHERE [C].[LAST_UPDATE] > 0
  ORDER BY [C].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_BONUS = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_COMBO]'
  END

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_SKU_BY_COMBO]
  -- ------------------------------------------------------------------------------------

  SELECT TOP 1
    @CURRENT_WATER_MARK = [SC].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_SKU_BY_COMBO] [SC]
  WHERE [SC].[LAST_UPDATE] > 0
  ORDER BY [SC].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_BONUS = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_SKU_BY_COMBO]'
  END

  -- ------------------------------------------------------------------------------------
  -- Valido si se genera acuerdo comercial y se le asigna @WATER_MARK a @LAST_WATER_MARK si no genera
  -- ------------------------------------------------------------------------------------
  IF @GENERATE_BONUS = 0
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
