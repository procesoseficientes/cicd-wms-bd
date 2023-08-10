-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-16 @ Team REBORN - Sprint 
-- Description:	        

/*
-- Ejemplo de Ejecucion:
			EXEC  
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_IF_ROUTE_GENERATE_TRADE_AGREEMENT] (@CODE_ROUTE VARCHAR(50), @GENERATE_TRADE_AGREEMENT INT OUTPUT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @WATER_MARK DATETIME = '1900-01-01 12:00:00 AM'
         ,@CURRENT_WATER_MARK DATETIME
         ,@LAST_WATER_MARK DATETIME = '1900-01-01 12:00:00 AM'
         ,@MARKED_TABLE NVARCHAR(100)

  SET @GENERATE_TRADE_AGREEMENT = 0

  SELECT TOP 1
    @WATER_MARK = ISNULL([TAW].[WATER_MARK], '1900-01-01 12:00:00 AM')
  FROM [SONDA].[SWIFT_TRADE_AGREEMENT_WATERMARK] [TAW]
  WHERE [TAW].[CODE_ROUTE] = @CODE_ROUTE

  SET @LAST_WATER_MARK = @WATER_MARK

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_PROMO]
  -- ------------------------------------------------------------------------------------
  SELECT TOP 1
    @CURRENT_WATER_MARK = [P].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_PROMO] [P]
  WHERE [P].[LAST_UPDATE] > 0
  ORDER BY [P].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_TRADE_AGREEMENT = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_PROMO]'
  END

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_TRADE_AGREEMENT_BY_PROMO]
  -- ------------------------------------------------------------------------------------
  SELECT TOP 1
    @CURRENT_WATER_MARK = [TAP].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BY_PROMO] [TAP]
  WHERE [TAP].[LAST_UPDATE] > 0
  ORDER BY [TAP].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_TRADE_AGREEMENT = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_TRADE_AGREEMENT_BY_PROMO]'
  END

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_TRADE_AGREEMENT]
  -- ------------------------------------------------------------------------------------
  SELECT TOP 1
    @CURRENT_WATER_MARK = [TA].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_TRADE_AGREEMENT] [TA]
  WHERE [TA].[LAST_UPDATE] > 0
  ORDER BY [TA].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_TRADE_AGREEMENT = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_TRADE_AGREEMENT]'
  END

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_TRADE_AGREEMENT_BY_CHANNEL]
  -- ------------------------------------------------------------------------------------
  SELECT TOP 1
    @CURRENT_WATER_MARK = [TAC].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CHANNEL] [TAC]
  WHERE [TAC].[LAST_UPDATE] > 0
  ORDER BY [TAC].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_TRADE_AGREEMENT = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_TRADE_AGREEMENT_BY_CHANNEL]'
  END

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_TRADE_AGREEMENT_BY_CUSTOMER]
  -- ------------------------------------------------------------------------------------


  SELECT TOP 1
    @CURRENT_WATER_MARK = [TAC].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER] [TAC]
  WHERE [TAC].[LAST_UPDATE] > 0
  ORDER BY [TAC].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_TRADE_AGREEMENT = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_TRADE_AGREEMENT_BY_CUSTOMER]'
  END

 -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_CHANNEL_X_CUSTOMER]
  -- ------------------------------------------------------------------------------------


  SELECT TOP 1
    @CURRENT_WATER_MARK = [CXC].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_CHANNEL_X_CUSTOMER] [CXC]
  WHERE [CXC].[LAST_UPDATE] > 0
  ORDER BY [CXC].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_TRADE_AGREEMENT = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_CHANNEL_X_CUSTOMER]'
  END



  -- ------------------------------------------------------------------------------------
  -- Valido si se genera acuerdo comercial y se le asigna @WATER_MARK a @LAST_WATER_MARK si no genera
  -- ------------------------------------------------------------------------------------
  IF @GENERATE_TRADE_AGREEMENT = 0
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
       ,[TIMES_REQUIRE] = [TIMES_REQUIRE] + 1
       ,[LAST_REQUIRE] = GETDATE()
       ,[MARKED_TABLE] = ISNULL(@MARKED_TABLE, [MARKED_TABLE])
    WHERE [CODE_ROUTE] = @CODE_ROUTE;
  END

END
