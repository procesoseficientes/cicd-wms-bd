
-- =============================================
-- Autor:				christian.hernandez
-- Fecha de Creacion: 	12/11/2018 @ A-TEAM Sprint Nutria
-- Description:			SP que inserta los skus que no estan insertados en la ruta 

/*
-- Ejemplo de Ejecucion:
		EXEC [SONDA].[SONDA_SP_GET_PRICE_LIST_OUTSIDE_ROUTE]
		@TRANSFER_ID = 177,
		@ROUTE_ID = '46',
		@XML = '<skus>
					<skus>100018</skus>
					<skus>100017</skus>
				</skus>'
*/

CREATE PROCEDURE [SONDA].[SONDA_SP_GET_PRICE_LIST_OUTSIDE_ROUTE]
	(
		@TRANSFER_ID INT
		,@ROUTE_ID VARCHAR(25)
		,@XML XML
	)
AS
	BEGIN
		SET NOCOUNT ON;
		
		-- ------------------------------------------------------
		-- Declara las variables que usaremos
		-- ------------------------------------------------------
		DECLARE
			@ROW_ID INT
			,@WAREHOUSE_CODE VARCHAR(150);

		-- ------------------------------------------------------------------------------------
		-- Obtiene el codigo de la bodega asociada al operador
		-- ------------------------------------------------------------------------------------
		SELECT
			@WAREHOUSE_CODE = [U].[DEFAULT_WAREHOUSE]
		FROM
			[SONDA].[USERS] AS [U]
		WHERE
			[U].[SELLER_ROUTE] = @ROUTE_ID;
					
		-- ------------------------------------------------------
		-- Declara la tabla que usaremos para insertar la informacion 
		-- ------------------------------------------------------
		DECLARE	@TEMP_SKU TABLE ([SKU] VARCHAR(50));

		BEGIN TRY 
			-- ------------------------------------------------------------------------------------
			-- Obtiene los skus enviadas desde el movil
			-- ------------------------------------------------------------------------------------
			INSERT	INTO @TEMP_SKU
					(
						[SKU]
					)
			SELECT
				[x].[Rec].[value]('.' ,'varchar(50)')
			FROM
				@XML.[nodes]('skus/skus') AS [x] ([Rec]);

 
			-- ------------------------------------------------------
			-- Inserta las los datos a la tabla SONDA_POS_SKUS
			-- ------------------------------------------------------
			INSERT	INTO [SONDA].[SONDA_POS_SKUS]
					(
						[SKU]
						,[SKU_NAME]
						,[SKU_PRICE]
						,[REQUERIES_SERIE]
						,[IS_KIT]
						,[ON_HAND]
						,[ROUTE_ID]
						,[IS_PARENT]
						,[PARENT_SKU]
						,[EXPOSURE]
						,[PRIORITY]
						,[QTY_RELATED]
						,[CODE_FAMILY_SKU]
						,[SALES_PACK_UNIT]
						,[INITIAL_QTY]
						,[TAX_CODE]
						,[CODE_PACK_UNIT_STOCK]
					)
			SELECT
				MAX([TD].[SKU_CODE]) [SKU]
				,MAX([SI].[SKU_DESCRIPTION]) AS [SKU_DESCRIPTION]
				,0 AS [PRICE]
				,MAX([s].[HANDLE_SERIAL_NUMBER]) AS [RequiereSerie]
				,0 AS [IS_KIT]
				,MAX([TD].[QTY]) [QTY]
				,@WAREHOUSE_CODE AS [ROUTE_ID]
				,0 AS [IS_PARENT]
				,MAX([TD].[SKU_CODE]) AS [PARENT_SKU]
				,1 AS [EXPOSURE]
				,0 AS [PRIORITY]
				,0 AS [QTY_RELATED]
				,MAX([s].[CODE_FAMILY_SKU]) AS [CODE_FAMILY_SKU]
				,MAX([s].[CODE_PACK_UNIT]) AS [SALES_PACK_UNIT]
				,MAX([TD].[QTY])
				,MAX([s].[VAT_CODE]) [VAT_CODE]
				,'MANUAL' [CODE_PACK_UNIT_STOCK]
			FROM
				[SONDA].[SWIFT_INVENTORY] [SI]
			INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [s]
			ON	([s].[CODE_SKU] = [SI].[SKU])
			INNER JOIN [SONDA].[SWIFT_TRANSFER_DETAIL] AS [TD]
			ON	(
					[TD].[SKU_CODE] = [SI].[SKU]
					AND [TD].[TRANSFER_ID] = @TRANSFER_ID
				)
			INNER JOIN @TEMP_SKU AS [TS]
			ON	([TS].[SKU] = [TD].[SKU_CODE])
			LEFT JOIN [SONDA].[SONDA_POS_SKUS] AS [PS]
			ON	(
					[PS].[SKU] = [TS].[SKU]
					AND [PS].[ROUTE_ID] = @WAREHOUSE_CODE
					AND [PS].[PARENT_SKU] = [TS].[SKU]
				)
			WHERE
				[PS].[SKU] IS NULL
				AND [SI].[WAREHOUSE] = @WAREHOUSE_CODE
			GROUP BY
				[s].[HANDLE_SERIAL_NUMBER]
				,[s].[CODE_FAMILY_SKU]
				,[s].[CODE_PACK_UNIT]
				,[s].[VAT_CODE]
				,[TD].[QTY]
				,[TD].[SKU_CODE];

			-- ------------------------------------------------------
			-- Se obtienen los datos para insertar mas tarde en el movil 
			-- ------------------------------------------------------	
			SELECT
				[PLPS].[CODE_PRICE_LIST]
				,[PLPS].[CODE_SKU]
				,[PLPS].[CODE_PACK_UNIT]
				,[PLPS].[PRIORITY]
				,[PLPS].[LOW_LIMIT]
				,[PLPS].[HIGH_LIMIT]
				,[PLPS].[PRICE]
			FROM
				[SONDA].[SWIFT_PRICE_LIST_BY_SKU_PACK_SCALE] [PLPS]
			WHERE
				[PLPS].[CODE_PRICE_LIST] IN (
				SELECT DISTINCT
					[PL].[CODE_PRICE_LIST]
				FROM
					[SONDA].[SWIFT_PRICE_LIST_BY_CUSTOMER_FOR_ROUTE] AS [PL]
				INNER JOIN [SONDA].[SONDA_ROUTE_PLAN] AS [RP]
				ON	([RP].[RELATED_CLIENT_CODE] = [PL].[CODE_CUSTOMER])
				WHERE
					[RP].[CODE_ROUTE] = @ROUTE_ID)
				AND [PLPS].[CODE_SKU] IN (SELECT
												[SKU]
											FROM
												@TEMP_SKU);

			-- ------------------------------------------------------------------------------------
			-- Se obtienen las unidades de medida de los productos
			-- ------------------------------------------------------------------------------------
			SELECT
				[PC].[PACK_CONVERSION]
				,[PC].[CODE_SKU]
				,[PC].[CODE_PACK_UNIT_FROM]
				,[PC].[CODE_PACK_UNIT_TO]
				,[PC].[CONVERSION_FACTOR]
				,[PC].[LAST_UPDATE]
				,[PC].[LAST_UPDATE_BY]
				,[PC].[ORDER]
			FROM
				[SONDA].[SONDA_PACK_CONVERSION] AS [PC]
			INNER JOIN @TEMP_SKU AS [TS]
			ON	([TS].[SKU] = [PC].[CODE_SKU])
			WHERE
				[PC].[PACK_CONVERSION] > 0;
		
		END TRY
		BEGIN CATCH
			DECLARE	@ERROR VARCHAR(1000) = ERROR_MESSAGE();
			PRINT 'CATCH: ' + @ERROR;
			RAISERROR (@ERROR,16,1);
		END CATCH;
	END;
