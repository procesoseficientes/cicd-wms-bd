-- =============================================
-- Autor:					diego.as
-- Fecha de Creacion: 		11/14/2018 @ G-Force Team Sprint Mamut
-- Historia/Bug:			Product Backlog Item 25662: Precios Especiales en el movil
-- Description:	11/14/2018 - SP que valida si la ruta debe generar los listados de precios especiales por escala		     

/*
-- Ejemplo de Ejecucion:
        DECLARE @MUST_GENERATE_SPECIAL_PRICES INT = 0;
		
		EXEC [SONDA].[SWIFT_SP_VALIDATE_IF_ROUTE_GENERATE_SPECIAL_PRICES_BY_SCALE]
		@CODE_ROUTE = '136',
		@GENERATE_SPECIAL_PRICES_BY_SCALE = @MUST_GENERATE_SPECIAL_PRICES OUT

		SELECT @MUST_GENERATE_SPECIAL_PRICES MUST_GENERATE_SPECIAL_PRICES
*/
-- ==============================================================================================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_IF_ROUTE_GENERATE_SPECIAL_PRICES_BY_SCALE]
	(
		@CODE_ROUTE VARCHAR(50)
		,@GENERATE_SPECIAL_PRICES_BY_SCALE INT OUTPUT
	) WITH RECOMPILE
AS
	BEGIN
		SET NOCOUNT ON;
  --
		DECLARE
			@WATER_MARK DATETIME = '1900-01-01 12:00:00 AM'
			,@CURRENT_WATER_MARK DATETIME
			,@LAST_WATER_MARK DATETIME = '1900-01-01 12:00:00 AM'
			,@MARKED_TABLE NVARCHAR(100);

		SET @GENERATE_SPECIAL_PRICES_BY_SCALE = 0;

		SELECT TOP 1
			@WATER_MARK = ISNULL([TAW].[WATER_MARK] ,'1900-01-01 12:00:00 AM')
		FROM
			[SONDA].[SWIFT_TRADE_AGREEMENT_WATERMARK] [TAW]
		WHERE
			[TAW].[CODE_ROUTE] = @CODE_ROUTE;

		SET @LAST_WATER_MARK = @WATER_MARK;
 
		-- --------------------------------------------------------------------------------------------
		-- Validamos si el Water Mark mas grande esta en la tabla [SWIFT_PROMO_SPECIAL_PRICE_LIST_BY_SCALE]
		-- --------------------------------------------------------------------------------------------

		SELECT TOP 1
			@CURRENT_WATER_MARK = [DBS].[LAST_UPDATE]
		FROM
			[SONDA].[SWIFT_PROMO_SPECIAL_PRICE_LIST_BY_SCALE] [DBS]
		WHERE
			[DBS].[SPECIAL_PRICE_LIST_BY_SCALE_ID] > 0
		ORDER BY
			[DBS].[LAST_UPDATE] DESC;

		IF @CURRENT_WATER_MARK > @WATER_MARK
			AND @CURRENT_WATER_MARK > @LAST_WATER_MARK
		BEGIN
			SELECT
				@GENERATE_SPECIAL_PRICES_BY_SCALE = 1
				,@LAST_WATER_MARK = @CURRENT_WATER_MARK
				,@MARKED_TABLE = '[SWIFT_PROMO_SPECIAL_PRICE_LIST_BY_SCALE]';
		END;

		-- -------------------------------------------------------------------------------------------------
		-- Valido si se genera acuerdo comercial y se le asigna @WATER_MARK a @LAST_WATER_MARK si no genera
		-- -------------------------------------------------------------------------------------------------
		IF @GENERATE_SPECIAL_PRICES_BY_SCALE = 0
		BEGIN
			SET @LAST_WATER_MARK = @WATER_MARK;
		END;

		IF NOT EXISTS ( SELECT
							[WATER_MARK]
						FROM
							[SONDA].[SWIFT_TRADE_AGREEMENT_WATERMARK]
						WHERE
							[CODE_ROUTE] = @CODE_ROUTE )
		BEGIN

			INSERT	INTO [SONDA].[SWIFT_TRADE_AGREEMENT_WATERMARK]
					(
						[WATER_MARK]
						,[CODE_ROUTE]
						,[TIMES_REQUIRE]
						,[LAST_REQUIRE]
						,[MARKED_TABLE]
					)
			VALUES
					(
						@LAST_WATER_MARK
						,@CODE_ROUTE
						,1
						,GETDATE()
						,@MARKED_TABLE
					);
		END;
		ELSE
		BEGIN
			UPDATE
				[SONDA].[SWIFT_TRADE_AGREEMENT_WATERMARK]
			SET	
				[WATER_MARK] = @LAST_WATER_MARK
				,[CODE_ROUTE] = @CODE_ROUTE
				,[TIMES_REQUIRE] = [TIMES_REQUIRE]
				,[LAST_REQUIRE] = GETDATE()
				,[MARKED_TABLE] = ISNULL(@MARKED_TABLE ,[MARKED_TABLE])
			WHERE
				[CODE_ROUTE] = @CODE_ROUTE;
		END;


	END;
