-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	8/18/2017 @ Reborn-TEAM Sprint Bearbeitung 
-- Description:			SP que actualizara el campo POLYGON_ID de un cliente en base a su punto gps

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_ASSOCIATE_CUSTOMER_TO_POLYGON]
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_ASSOCIATE_CUSTOMER_TO_POLYGON
AS
	BEGIN
		SET NOCOUNT ON;

		TRUNCATE TABLE [SONDA].[SWIFT_CUSTOMER_GPS_ASSOCIATE_TO_POLYGON];
		TRUNCATE TABLE [SONDA].[SWIFT_CUSTOMER_ASSOCIATE_TO_POLYGON];
		-- ------------------------------------------------------------------------------------
		-- Declaramos las variables a utilizar
		-- ------------------------------------------------------------------------------------
		DECLARE
			@TOTAL_CUSTOMERS INT = 0
			,@POLYGON_ID INT
			,@POLYGON_NAME VARCHAR(250)
			,@POLYGON_TYPE VARCHAR(250)
			,@GEOMETRY_POLYGON GEOMETRY;

		--
		DECLARE	@POLYGON AS TABLE
			(
				[POLYGON_ID] INT
				,[POLYGON_NAME] VARCHAR(250)
				,[POLYGON_TYPE] VARCHAR(250)
			);

		--
		DECLARE	@CUSTOMER AS TABLE
			(
				[CODE_CUSTOMER] VARCHAR(50)
				,[LATITUDE] VARCHAR(MAX)
				,[LONGITUDE] VARCHAR(MAX)
				,[GPS] VARCHAR(MAX)
				,[POINT] GEOMETRY
			);

		--
		DECLARE	@CUSTOMERS_FILTERED AS TABLE
			(
				[CODE_CUSTOMER] VARCHAR(50)
				,[GPS_CUSTOMER] VARCHAR(MAX)
			);

		-- ------------------------------------------------------------------------------------
		-- Obtenemos todos los poligonos a recorrer
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @POLYGON
				(
					[POLYGON_ID]
					,[POLYGON_NAME]
					,[POLYGON_TYPE]
    			)
		SELECT
			[P].[POLYGON_ID]
			,[P].[POLYGON_NAME]
			,[P].[POLYGON_TYPE]
		FROM
			[SONDA].[SWIFT_POLYGON] [P]
		WHERE
			[P].[POLYGON_TYPE] = 'REGION'
			OR [P].[POLYGON_TYPE] = 'SECTOR'
		ORDER BY
			[P].[POLYGON_ID_PARENT] ASC;
   
		-- ------------------------------------------------------------------------------------
		-- Obtiene los clientes
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @CUSTOMER
				(
					[CODE_CUSTOMER]
					,[LATITUDE]
					,[LONGITUDE]
					,[GPS]
					,[POINT]
				)
		SELECT
			[C].[CODE_CUSTOMER]
			,[C].[LATITUDE]
			,[C].[LONGITUDE]
			,[C].[GPS]
			,[geometry]::[Point]([C].[LATITUDE] ,[C].[LONGITUDE] ,0) [POINT]
		FROM
			[SONDA].[SWIFT_VIEW_ALL_COSTUMER] [C]
		LEFT JOIN [SONDA].[SWIFT_CUSTOMER_GPS_ASSOCIATE_TO_POLYGON] AS [CAP]
		ON	([CAP].[CODE_CUSTOMER] = [C].[CODE_CUSTOMER])
		WHERE
			[C].[GPS] <> '0,0'
			AND (
					[C].[LATITUDE] IS NOT NULL
					AND [C].[LONGITUDE] IS NOT NULL
				)
			AND (
					[CAP].[CODE_CUSTOMER] IS NULL
					OR [CAP].[GPS] != [C].[GPS]
				);
	
		-- ------------------------------------------------------------------------------------
		-- Se borran los registros que hayan sido actualizados o sean nuevos
		-- ------------------------------------------------------------------------------------
		DELETE
			[CAP]
		FROM
			[SONDA].[SWIFT_CUSTOMER_ASSOCIATE_TO_POLYGON] AS [CAP]
		INNER JOIN @CUSTOMER AS [C]
		ON	([C].[CODE_CUSTOMER] = [CAP].[CODE_CUSTOMER]);
		--
		DELETE
			[CAP]
		FROM
			[SONDA].[SWIFT_CUSTOMER_GPS_ASSOCIATE_TO_POLYGON] AS [CAP]
		INNER JOIN @CUSTOMER AS [C]
		ON	([C].[CODE_CUSTOMER] = [CAP].[CODE_CUSTOMER]);
	
		-- ------------------------------------------------------------------------------------
		-- Inicia ciclo para cada poligono obtenido
		-- ------------------------------------------------------------------------------------
		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							@POLYGON )
		BEGIN
			SELECT TOP 1
				@POLYGON_ID = [P].[POLYGON_ID]
				,@POLYGON_NAME = [P].[POLYGON_NAME]
				,@POLYGON_TYPE = [P].[POLYGON_TYPE]
			FROM
				@POLYGON AS [P];

			-- ------------------------------------------------------------------------------------
			-- ObtIene el poligono actual 
			-- ------------------------------------------------------------------------------------
			SET @GEOMETRY_POLYGON = [SONDA].[SWIFT_GET_GEOMETRY_POLYGON_BY_POLIGON_ID](@POLYGON_ID);	  
	  
			-- ------------------------------------------------------------------------------------
			-- INSERTA EL CLIENTE
			-- ------------------------------------------------------------------------------------
			INSERT	INTO [SONDA].[SWIFT_CUSTOMER_ASSOCIATE_TO_POLYGON]
					(
						[POLYGON_ID]
						,[POLYGON_NAME]
						,[POLYGON_TYPE]
						,[CODE_CUSTOMER]
						,[GPS_CUSTOMER]
						,[LAST_UPDATE]
	  				)
			SELECT
				@POLYGON_ID
				,@POLYGON_NAME
				,@POLYGON_TYPE
				,[C].[CODE_CUSTOMER]
				,[C].[GPS]
				,GETDATE()
			FROM
				@CUSTOMER AS [C]
			WHERE
				@GEOMETRY_POLYGON.[MakeValid]().[STContains]([C].[POINT]) = 1;

			-- ------------------------------------------------------------------------------------
			-- Elimina el registro actual
			-- ------------------------------------------------------------------------------------
			DELETE FROM
				@POLYGON
			WHERE
				[POLYGON_ID] = @POLYGON_ID;
		END;
	
		-- ------------------------------------------------------------------------------------
		-- Se obtienen los clientes para guardar el historico
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @CUSTOMERS_FILTERED
				(
					[CODE_CUSTOMER]
					,[GPS_CUSTOMER]
				)
		SELECT DISTINCT
			[VC].[CODE_CUSTOMER]
			,[VC].[GPS_CUSTOMER]
		FROM
			[SONDA].[SWIFT_CUSTOMER_ASSOCIATE_TO_POLYGON] AS [VC];

		-- ------------------------------------------------------------------------------------
		-- Guarda el historico de gps de cliente asociado a poligono
		-- ------------------------------------------------------------------------------------
		INSERT	INTO [SONDA].[SWIFT_CUSTOMER_GPS_ASSOCIATE_TO_POLYGON]
				(
					[CODE_CUSTOMER]
					,[GPS]
				)
		SELECT
			[CF].[CODE_CUSTOMER]
			,[CF].[GPS_CUSTOMER]
		FROM
			@CUSTOMERS_FILTERED AS [CF];
	END;

