-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 		06-Jul-2018 @ G-Force-Team Sprint Faisan 
-- Description:			    SP que proccesa la estadisticas de las ventas

/*
-- Ejemplo de Ejecucion:
        EXEC SONDA.SWIFT_SP_INSERT_SALES_STATISTICS_BY_TEAM
        SELECT * FROM [SONDA].[SWIFT_STATISTICS_GOALS_BY_SALES] 
*/
-- =============================================

CREATE PROCEDURE [SONDA].SWIFT_SP_INSERT_SALES_STATISTICS_BY_TEAM
AS
BEGIN
  SET NOCOUNT ON;
  -- ---------------------------
  -- Obtenemos las metas en progreso
  -- ---------------------------

  DECLARE @GOAL_HEADER_IN_PROGRESS AS TABLE (
    [GOAL_HEADER_ID] INT
   ,[GOAL_NAME] VARCHAR(120)
   ,[TEAM_ID] INT
   ,[SUPERVISOR_ID] INT
   ,[GOAL_AMOUNT] NUMERIC(18, 6)
   ,[GOAL_DATE_FROM] DATETIME
   ,[GOAL_DATE_TO] DATETIME
   ,[INCLUDE_SATURDAY] BIT
   ,[SALE_TYPE] VARCHAR(25)
  )

  INSERT INTO @GOAL_HEADER_IN_PROGRESS ([GOAL_HEADER_ID], [GOAL_NAME], [TEAM_ID], [SUPERVISOR_ID], [GOAL_AMOUNT], [GOAL_DATE_FROM], [GOAL_DATE_TO], [INCLUDE_SATURDAY], [SALE_TYPE])
    SELECT
      [GH].[GOAL_HEADER_ID]
     ,[GH].[GOAL_NAME]
     ,[GH].[TEAM_ID]
     ,[GH].[SUPERVISOR_ID]
     ,[GH].[GOAL_AMOUNT]
     ,[GH].[GOAL_DATE_FROM]
     ,[GH].[GOAL_DATE_TO]
     ,[GH].[INCLUDE_SATURDAY]
     ,[GH].[SALE_TYPE]
    FROM [SONDA].[SWIFT_GOAL_HEADER] [GH]
    WHERE [GH].[STATUS] = 'IN_PROGRESS'


  DECLARE @GOAL_DETAIL_IN_PROGRESS AS TABLE (
    [GOAL_DETAIL_ID] INT
   ,[GOAL_HEADER_ID] INT
   ,[SELLER_ID] INT
   ,[GOAL_BY_SELLER] NUMERIC(18, 6)
   ,[DAILY_GOAL_BY_SELLER] NUMERIC(18, 6)
  )

  INSERT INTO @GOAL_DETAIL_IN_PROGRESS ([GOAL_DETAIL_ID], [GOAL_HEADER_ID], [SELLER_ID], [GOAL_BY_SELLER], [DAILY_GOAL_BY_SELLER])
    SELECT
      [GD].[GOAL_DETAIL_ID]
     ,[GD].[GOAL_HEADER_ID]
     ,[GD].[SELLER_ID]
     ,[GD].[GOAL_BY_SELLER]
     ,[GD].[DAILY_GOAL_BY_SELLER]
    FROM [SONDA].[SWIFT_GOAL_DETAIL] [GD]
    INNER JOIN @GOAL_HEADER_IN_PROGRESS [GH]
      ON (
      [GD].[GOAL_HEADER_ID] = [GH].[GOAL_HEADER_ID]
      )
  -- ---------------------------
  -- Recorremos las metas
  -- ---------------------------
  WHILE EXISTS (SELECT TOP 1
        1
      FROM @GOAL_HEADER_IN_PROGRESS)
  BEGIN

    -- ---------------------------
    -- Variables a utilizar
    -- ---------------------------
    DECLARE @GOAL_HEADER_ID INT
           ,@GOAL_NAME VARCHAR(120)
           ,@TEAM_ID INT
           ,@SUPERVISOR_ID INT
           ,@GOAL_AMOUNT NUMERIC(18, 6)
           ,@GOAL_DATE_FROM DATE
           ,@GOAL_DATE_TO DATE
           ,@INCLUDE_SATURDAY BIT
           ,@SALE_TYPE VARCHAR(25)
            ---//
           ,@SALES_DATE DATE

    -- ---------------------------
    -- Obtenemos la meta
    -- ---------------------------

    SELECT TOP 1
      @GOAL_HEADER_ID = [GOAL_HEADER_ID]
     ,@GOAL_NAME = [GOAL_NAME]
     ,@TEAM_ID = [TEAM_ID]
     ,@SUPERVISOR_ID = [SUPERVISOR_ID]
     ,@GOAL_AMOUNT = [GOAL_AMOUNT]
     ,@GOAL_DATE_FROM = [GOAL_DATE_FROM]
     ,@GOAL_DATE_TO = [GOAL_DATE_TO]
     ,@INCLUDE_SATURDAY = [INCLUDE_SATURDAY]
     ,@SALE_TYPE = [SALE_TYPE]
    FROM @GOAL_HEADER_IN_PROGRESS


    DECLARE @STATISTICS_GOALS_BY_SALES AS TABLE (
      STATISTICS_GOAL_BY_SALE_ID INT
     ,GOAL_HEADER_ID INT
     ,USER_ID INT
     ,RANKING INT
     ,DAILY_GOAL NUMERIC(18, 6)
     ,ACCUMULATED_BY_PERIOD NUMERIC(18, 6)
     ,PERCENTAGE_GOAL_DAILY NUMERIC(18, 2)
     ,DAYS_OF_SALE INT
     ,REMAINING_DAYS INT
     ,PERCENTAGE_OF_DAYS NUMERIC(18, 2)
     ,GENERAL_GOAL NUMERIC(18, 2)
     ,DIFFERENCE_FROM_THE_GOAL NUMERIC(18, 2)
     ,NEXT_SALE_GOAL NUMERIC(18, 6)
     ,PERCENTAGE_OF_GENERAL_GOAL NUMERIC(18, 2)
     ,SALE_OF_THE_DAY NUMERIC(18, 6)
     ,SALES_DATE DATETIME
    )
    -- ---------------------------
    -- Obtenemos las estadisticas
    -- ---------------------------

    INSERT INTO @STATISTICS_GOALS_BY_SALES ([STATISTICS_GOAL_BY_SALE_ID], [GOAL_HEADER_ID], [USER_ID], [RANKING], [DAILY_GOAL], [ACCUMULATED_BY_PERIOD], [PERCENTAGE_GOAL_DAILY], [DAYS_OF_SALE], [REMAINING_DAYS], [PERCENTAGE_OF_DAYS], [GENERAL_GOAL], [DIFFERENCE_FROM_THE_GOAL], [NEXT_SALE_GOAL], [PERCENTAGE_OF_GENERAL_GOAL], [SALE_OF_THE_DAY], [SALES_DATE])
      SELECT
        [SGS].[STATISTICS_GOAL_BY_SALE_ID]
       ,[SGS].[GOAL_HEADER_ID]
       ,[SGS].[USER_ID]
       ,[SGS].[RANKING]
       ,[SGS].[DAILY_GOAL]
       ,[SGS].[ACCUMULATED_BY_PERIOD]
       ,[SGS].[PERCENTAGE_GOAL_DAILY]
       ,[SGS].[DAYS_OF_SALE]
       ,[SGS].[REMAINING_DAYS]
       ,[SGS].[PERCENTAGE_OF_DAYS]
       ,[SGS].[GENERAL_GOAL]
       ,[SGS].[DIFFERENCE_FROM_THE_GOAL]
       ,[SGS].[NEXT_SALE_GOAL]
       ,[SGS].[PERCENTAGE_OF_GENERAL_GOAL]
       ,[SGS].[SALE_OF_THE_DAY]
       ,[SGS].[SALES_DATE]
      FROM [SONDA].[SWIFT_STATISTICS_GOALS_BY_SALES] [SGS]
      WHERE [SGS].[LAST_CREATED] = 1
      AND [SGS].[GOAL_HEADER_ID] = @GOAL_HEADER_ID

    -- ---------------------------
    -- Establecemos la fecha a empezar si no hay ninguna fecha posteada en las estadisticas, se toma la de la meta
    -- ---------------------------
    SET @SALES_DATE = CAST(@GOAL_DATE_FROM AS DATE)

    -- ---------------------------
    -- Obtenemos la ultima fecha de la estadistica ingresada
    -- ---------------------------

    SELECT TOP 1
      @SALES_DATE = CAST(DATEADD(DAY, 1, [SALES_DATE]) AS DATE)
    FROM @STATISTICS_GOALS_BY_SALES
    WHERE [GOAL_HEADER_ID] = @GOAL_HEADER_ID


    WHILE @SALES_DATE <> CAST(GETDATE() AS DATE)--'03/Jul/2018'
    BEGIN

      DELETE FROM @STATISTICS_GOALS_BY_SALES

      INSERT INTO @STATISTICS_GOALS_BY_SALES ([STATISTICS_GOAL_BY_SALE_ID], [GOAL_HEADER_ID], [USER_ID], [RANKING], [DAILY_GOAL], [ACCUMULATED_BY_PERIOD], [PERCENTAGE_GOAL_DAILY], [DAYS_OF_SALE], [REMAINING_DAYS], [PERCENTAGE_OF_DAYS], [GENERAL_GOAL], [DIFFERENCE_FROM_THE_GOAL], [NEXT_SALE_GOAL], [PERCENTAGE_OF_GENERAL_GOAL], [SALE_OF_THE_DAY], [SALES_DATE])
        SELECT
          [SGS].[STATISTICS_GOAL_BY_SALE_ID]
         ,[SGS].[GOAL_HEADER_ID]
         ,[SGS].[USER_ID]
         ,[SGS].[RANKING]
         ,[SGS].[DAILY_GOAL]
         ,[SGS].[ACCUMULATED_BY_PERIOD]
         ,[SGS].[PERCENTAGE_GOAL_DAILY]
         ,[SGS].[DAYS_OF_SALE]
         ,[SGS].[REMAINING_DAYS]
         ,[SGS].[PERCENTAGE_OF_DAYS]
         ,[SGS].[GENERAL_GOAL]
         ,[SGS].[DIFFERENCE_FROM_THE_GOAL]
         ,[SGS].[NEXT_SALE_GOAL]
         ,[SGS].[PERCENTAGE_OF_GENERAL_GOAL]
         ,[SGS].[SALE_OF_THE_DAY]
         ,[SGS].[SALES_DATE]
        FROM [SONDA].[SWIFT_STATISTICS_GOALS_BY_SALES] [SGS]
        WHERE [SGS].[LAST_CREATED] = 1
        AND [SGS].[GOAL_HEADER_ID] = @GOAL_HEADER_ID


      -- ---------------------------
      -- Validamos el dia
      -- ---------------------------
      IF ((SELECT
            DATEPART(dw, @SALES_DATE))
        >= 2
        AND (SELECT
            DATEPART(dw, @SALES_DATE))
        <= 6)
        OR (@INCLUDE_SATURDAY = 1
        AND (SELECT
            DATEPART(dw, @SALES_DATE))
        = 7)
      BEGIN

        PRINT 'RD-00'
        PRINT @SALES_DATE
        IF @SALES_DATE = DATEADD(DAY, -1, GETDATE())
        BEGIN
          PRINT 'RD-01'
          DELETE FROM [SONDA].[SWIFT_STATISTICS_GOALS_BY_SALES]
          WHERE [GOAL_HEADER_ID] = @GOAL_HEADER_ID
            AND [SALES_DATE] = @SALES_DATE
        END

        DECLARE @SALES_ORDER AS TABLE (
          RANKING INT
         ,USER_ID INT
         ,SELLER_CODE VARCHAR(50)
         ,SELLER_NAME VARCHAR(100)
         ,CODE_ROUTE VARCHAR(50)
         ,NAME_ROUTE VARCHAR(50)
         ,TOTAL_AMOUNT NUMERIC(18, 6)
         ,COUNT_SALES_ORDERS INT
        )

        -- ---------------------------
        -- Validamos de que tipo es
        -- ---------------------------
        IF @SALE_TYPE = 'PRE'
        BEGIN

          DELETE FROM @SALES_ORDER
          -- ---------------------------
          -- Obtenemos las ventas del dia
          -- ---------------------------
          INSERT INTO @SALES_ORDER ([RANKING], [USER_ID], [SELLER_CODE], [SELLER_NAME], [CODE_ROUTE], [NAME_ROUTE], [TOTAL_AMOUNT], [COUNT_SALES_ORDERS])
            SELECT
              ROW_NUMBER() OVER (ORDER BY SUM([SONDA].[SWIFT_FN_GET_SALES_ORDER_TOTAL]([SH].[SALES_ORDER_ID])) DESC) AS RANKING
             ,[DT].[SELLER_ID] AS [USER_ID]
             ,MAX([S].[SELLER_CODE]) AS [SELLER_CODE]
             ,MAX([S].[SELLER_NAME]) AS [SELLER_NAME]
             ,MAX([R].[CODE_ROUTE]) AS [CODE_ROUTE]
             ,MAX([R].[NAME_ROUTE]) AS [NAME_ROUTE]
             ,ISNULL(SUM([SONDA].[SWIFT_FN_GET_SALES_ORDER_TOTAL]([SH].[SALES_ORDER_ID])), 0) AS [TOTAL_AMOUNT]
             ,COUNT([SH].[SALES_ORDER_ID]) AS [COUNT_SALES_ORDERS]
            FROM [SONDA].[SWIFT_GOAL_DETAIL] [DT]
            INNER JOIN [SONDA].[USERS] [U]
              ON (
              [DT].[SELLER_ID] = [U].[CORRELATIVE]
              )
            INNER JOIN [SONDA].[SWIFT_USER_BY_TEAM] [UT]
              ON (
              [U].[CORRELATIVE] = [UT].[USER_ID]
              )
            LEFT JOIN [SONDA].[SWIFT_SELLER] [S]
              ON (
              [U].[RELATED_SELLER] = [S].[SELLER_CODE]
              )
            LEFT JOIN [SONDA].[SWIFT_ROUTES] [R]
              ON (
              [U].[SELLER_ROUTE] = [R].[CODE_ROUTE]
              )
            LEFT JOIN [SONDA].[SONDA_SALES_ORDER_HEADER] [SH]
              ON (
              [U].[LOGIN] = [SH].[POSTED_BY]
              AND [SH].[IS_READY_TO_SEND] = 1
              AND CAST([SH].[POSTED_DATETIME] AS DATE) = @SALES_DATE
              AND [SH].[IS_VOID] = 0
              )
            WHERE [UT].[TEAM_ID] = @TEAM_ID
            AND [DT].[GOAL_HEADER_ID] = @GOAL_HEADER_ID
            GROUP BY [DT].[SELLER_ID]

        END
        ELSE
        IF @SALE_TYPE = 'VEN'
        BEGIN
          INSERT INTO @SALES_ORDER ([RANKING], [USER_ID], [SELLER_CODE], [SELLER_NAME], [CODE_ROUTE], [NAME_ROUTE], [TOTAL_AMOUNT], [COUNT_SALES_ORDERS])
            SELECT
              ROW_NUMBER() OVER (ORDER BY ISNULL(SUM([IH].[TOTAL_AMOUNT]), 0) DESC) AS RANKING
             ,[DT].[SELLER_ID] AS [USER_ID]
             ,MAX([S].[SELLER_CODE]) AS [SELLER_CODE]
             ,MAX([S].[SELLER_NAME]) AS [SELLER_NAME]
             ,MAX([R].[CODE_ROUTE]) AS [CODE_ROUTE]
             ,MAX([R].[NAME_ROUTE]) AS [NAME_ROUTE]
             ,ISNULL(SUM([IH].[TOTAL_AMOUNT]), 0) AS [TOTAL_AMOUNT]
             ,COUNT([IH].[INVOICE_ID]) AS [COUNT_SALES_ORDERS]

            FROM [SONDA].[SWIFT_GOAL_DETAIL] [DT]
            INNER JOIN [SONDA].[USERS] [U]
              ON (
              [DT].[SELLER_ID] = [U].[CORRELATIVE]
              )
            INNER JOIN [SONDA].[SWIFT_USER_BY_TEAM] [UT]
              ON (
              [U].[CORRELATIVE] = [UT].[USER_ID]
              )
            LEFT JOIN [SONDA].[SWIFT_SELLER] [S]
              ON (
              [U].[RELATED_SELLER] = [S].[SELLER_CODE]
              )
            LEFT JOIN [SONDA].[SWIFT_ROUTES] [R]
              ON (
              [U].[SELLER_ROUTE] = [R].[CODE_ROUTE]
              )
            LEFT JOIN [SONDA].[SONDA_POS_INVOICE_HEADER] [IH]
              ON (
              [U].[LOGIN] = [IH].[POSTED_BY]
              AND [IH].[IS_READY_TO_SEND] = 1
              AND CAST([IH].[POSTED_DATETIME] AS DATE) = @SALES_DATE
              AND [IH].[STATUS] <> 0
              )
            WHERE [UT].[TEAM_ID] = @TEAM_ID
            AND [DT].[GOAL_HEADER_ID] = @GOAL_HEADER_ID
            GROUP BY [DT].[SELLER_ID]

        END

        -- ---------------------------
        -- Actualizamos las estadisticas anteriores
        -- ---------------------------
        UPDATE [SGS]
        SET [SGS].[LAST_CREATED] = 0
        FROM [SONDA].[SWIFT_STATISTICS_GOALS_BY_SALES] [SGS]
        WHERE [SGS].[GOAL_HEADER_ID] = @GOAL_HEADER_ID

        -- ---------------------------
        -- Insertamos la estadistica de la meta
        -- ---------------------------
        INSERT INTO [SONDA].[SWIFT_STATISTICS_GOALS_BY_SALES] ([GOAL_HEADER_ID]
        , [TEAM_ID]
        , [USER_ID]
        , [SELLER_CODE]
        , [SELLER_NAME]
        , [CODE_ROUTE]
        , [NAME_ROUTE]
        , [RANKING]
        , [DAILY_GOAL]
        , [ACCUMULATED_BY_PERIOD]
        , [PERCENTAGE_GOAL_DAILY]
        , [DAYS_OF_SALE]
        , [REMAINING_DAYS]
        , [PERCENTAGE_OF_DAYS]
        , [GENERAL_GOAL]
        , [DIFFERENCE_FROM_THE_GOAL]
        , [NEXT_SALE_GOAL]
        , [PERCENTAGE_OF_GENERAL_GOAL]
        , [SALE_OF_THE_DAY]
        , [SALES_DATE]
        , [CREATED_DATE]
        , [LAST_CREATED], [SALE_TYPE])
          SELECT
            @GOAL_HEADER_ID
           ,@TEAM_ID
           ,[SO].[USER_ID]
           ,[SO].[SELLER_CODE]
           ,[SO].[SELLER_NAME]
           ,[SO].[CODE_ROUTE]
           ,[SO].[NAME_ROUTE]
           ,[SO].[RANKING]
           ,CASE
              WHEN [SGS].[NEXT_SALE_GOAL] IS NULL THEN [GD].[DAILY_GOAL_BY_SELLER]
              ELSE [SGS].[NEXT_SALE_GOAL]
            END
           ,ISNULL([SGS].[ACCUMULATED_BY_PERIOD], 0) + [SO].[TOTAL_AMOUNT]
           ,(100 / [DAILY_GOAL_BY_SELLER] * [SO].[TOTAL_AMOUNT])
           ,ISNULL([SGS].[DAYS_OF_SALE], 0) + 1
           ,CASE
              WHEN [SGS].[REMAINING_DAYS] IS NULL THEN ([SONDA].[SWIFT_FN_GET_LABOR_DAYS](@GOAL_DATE_FROM, @GOAL_DATE_TO, @INCLUDE_SATURDAY)) - 1
              ELSE [SGS].[REMAINING_DAYS] - 1
            END
           ,(100 / [SONDA].[SWIFT_FN_GET_LABOR_DAYS](@GOAL_DATE_FROM, @GOAL_DATE_TO, @INCLUDE_SATURDAY) * (CASE
              WHEN [SGS].[REMAINING_DAYS] IS NULL THEN ([SONDA].[SWIFT_FN_GET_LABOR_DAYS](@GOAL_DATE_FROM, @GOAL_DATE_TO, @INCLUDE_SATURDAY)) - 1
              ELSE [SGS].[REMAINING_DAYS] - 1
            END))
           ,CASE
              WHEN [SGS].[GENERAL_GOAL] IS NULL THEN ([GD].[GOAL_BY_SELLER] - [SO].[TOTAL_AMOUNT])
              ELSE [SGS].[GENERAL_GOAL] - [SO].[TOTAL_AMOUNT]
            END
           ,[GD].[DAILY_GOAL_BY_SELLER] - [SO].[TOTAL_AMOUNT]
           ,CASE
              WHEN [SGS].[DAILY_GOAL] IS NULL THEN (CASE
                  WHEN [SO].[TOTAL_AMOUNT] > [GD].[DAILY_GOAL_BY_SELLER] THEN [GD].[DAILY_GOAL_BY_SELLER]
                  ELSE [GD].[DAILY_GOAL_BY_SELLER] + ([GD].[DAILY_GOAL_BY_SELLER] - [SO].[TOTAL_AMOUNT])
                END)
              ELSE (CASE
                  WHEN [SO].[TOTAL_AMOUNT] > [SGS].[NEXT_SALE_GOAL] THEN [GD].[DAILY_GOAL_BY_SELLER]
                  ELSE [GD].[DAILY_GOAL_BY_SELLER] + ([SGS].[NEXT_SALE_GOAL] - [SO].[TOTAL_AMOUNT])
                END)
            END
           ,(100 / [GD].[GOAL_BY_SELLER] * (ISNULL([SGS].[ACCUMULATED_BY_PERIOD], 0) + ISNULL([SO].[TOTAL_AMOUNT], 0)))
           ,[SO].[TOTAL_AMOUNT]
           ,@SALES_DATE
           ,GETDATE()
           ,1
           ,@SALE_TYPE
          FROM @SALES_ORDER [SO]
          INNER JOIN @GOAL_DETAIL_IN_PROGRESS [GD]
            ON ([SO].[USER_ID] = [GD].[SELLER_ID])
          LEFT JOIN @STATISTICS_GOALS_BY_SALES [SGS]
            ON (
            [SO].[USER_ID] = [SGS].[USER_ID]
            AND [GD].[SELLER_ID] = [SGS].[USER_ID]
            )
          WHERE [GD].[GOAL_HEADER_ID] = @GOAL_HEADER_ID

      END
      SET @SALES_DATE = DATEADD(DAY, 1, @SALES_DATE)
    END
    DELETE FROM @GOAL_HEADER_IN_PROGRESS
    WHERE [GOAL_HEADER_ID] = @GOAL_HEADER_ID
  END

  -- ---------------------------
  -- Se actualiza el estado de las meteas que entran en progreso hoy.
  -- ---------------------------
  UPDATE [GH]
  SET [GH].[STATUS] =
                     CASE
                       WHEN (CAST([GH].[GOAL_DATE_FROM] AS DATE) <= CAST(GETDATE() AS DATE) AND
                         CAST([GH].[GOAL_DATE_TO] AS DATE) >= CAST(GETDATE() AS DATE)) THEN 'IN_PROGRESS'
                       WHEN CAST([GH].[GOAL_DATE_TO] AS DATE) < CAST(GETDATE() AS DATE) THEN 'FINISHED'
                     END
     ,[GH].[LAST_UPDATE] = GETDATE()
     ,[GH].[LAST_UPDATE_BY] = 'SYSTEM'
  FROM [SONDA].[SWIFT_GOAL_HEADER] [GH]
  WHERE [GH].[STATUS] IN ('CREATED','IN_PROGRESS')
  AND (CAST([GH].[GOAL_DATE_FROM] AS DATE) <= CAST(GETDATE() AS DATE)
  AND CAST([GH].[GOAL_DATE_TO] AS DATE) >= CAST(GETDATE() AS DATE)
  OR CAST([GH].[GOAL_DATE_TO] AS DATE) < DATEADD(DAY, -1, CAST(GETDATE() AS DATE)))

END

