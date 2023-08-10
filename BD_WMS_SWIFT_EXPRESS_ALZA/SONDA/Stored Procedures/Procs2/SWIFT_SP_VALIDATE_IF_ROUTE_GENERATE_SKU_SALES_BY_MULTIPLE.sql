-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-08-16 @ Team REBORN - Sprint 
-- Description:	        

/*
-- Ejemplo de Ejecucion:
			EXEC  [SONDA].[SWIFT_SP_VALIDATE_IF_ROUTE_GENERATE_DISCOUNT] @CODE_ROUTE = '136'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_IF_ROUTE_GENERATE_SKU_SALES_BY_MULTIPLE] (@CODE_ROUTE VARCHAR(50), @GENERATE_SKU_SALES_BY_MULTIPLE INT OUTPUT)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @WATER_MARK DATETIME = '1900-01-01 12:00:00 AM'
         ,@CURRENT_WATER_MARK DATETIME
         ,@LAST_WATER_MARK DATETIME = '1900-01-01 12:00:00 AM'
         ,@MARKED_TABLE NVARCHAR(100)

  SET @GENERATE_SKU_SALES_BY_MULTIPLE = 0

  SELECT TOP 1
    @WATER_MARK = ISNULL([TAW].[WATER_MARK], '1900-01-01 12:00:00 AM')
  FROM [SONDA].[SWIFT_TRADE_AGREEMENT_WATERMARK] [TAW]
  WHERE [TAW].[CODE_ROUTE] = @CODE_ROUTE

  SET @LAST_WATER_MARK = @WATER_MARK

  -- ------------------------------------------------------------------------------------
  -- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_PROMO_SKU_SALES_BY_MULTIPLE]
  -- ------------------------------------------------------------------------------------
  SELECT TOP 1
    @CURRENT_WATER_MARK = [PSSM].[LAST_UPDATE]
  FROM [SONDA].[SWIFT_PROMO_SKU_SALES_BY_MULTIPLE] [PSSM]
  WHERE [PSSM].[LAST_UPDATE] > 0
  ORDER BY [PSSM].[LAST_UPDATE] DESC

  IF @CURRENT_WATER_MARK > @WATER_MARK
    AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
  BEGIN
    SELECT
      @GENERATE_SKU_SALES_BY_MULTIPLE = 1
     ,@LAST_WATER_MARK = @CURRENT_WATER_MARK
     ,@MARKED_TABLE = '[SWIFT_PROMO_SKU_SALES_BY_MULTIPLE]'
  END

  -- ------------------------------------------------------------------------------------
  -- Valido si se genera acuerdo comercial y se le asigna @WATER_MARK a @LAST_WATER_MARK si no genera
  -- ------------------------------------------------------------------------------------
  IF @GENERATE_SKU_SALES_BY_MULTIPLE = 0
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
