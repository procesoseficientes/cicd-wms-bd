-- =============================================
-- Autor:		alberto.ruiz
-- Fecha de Creacion:   02-11-2015
-- Description:	  Transfiere todos los SKUs de transferencia al inventario y actualiza el status

-- Modificado 02-11-2015
	-- alberto.ruiz
	-- Correccion para que funcione en el nuevo servidor

-- Modificacion 22-Nov-16 @ A-Team Sprint 5
		  -- alberto.ruiz
		  -- Se agrego que inserte la columna de serie

-- Modificacion 27-Jan-17 @ A-Team Sprint Bankole
					-- alberto.ruiz
					-- Se agrego parametro para ver si la transferencia es en linea
/*
-- Ejemplo de Ejecucion:
		declare @pRESULT varchar(MAX)
		--
		exec [SONDA].[SONDA_TRANSFER_SKU]
		  @Login = 'oper3_fl@SONDA'
		  ,@Route = 'fl_ventas03'
		  ,@pRESULT = @pRESULT OUTPUT
		--
		select @pRESULT
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_TRANSFER_SKU] (
	@Login VARCHAR(50)
	,@Route VARCHAR(50)
	,@pRESULT VARCHAR(MAX) = '' OUTPUT
	,@IS_ONLINE INT = 0
	,@TRANSFER_ID INT = NULL
) AS
BEGIN  
	SET NOCOUNT ON;
	--
	DECLARE
		@tmpResult VARCHAR(MAX) = ''
	--
	DECLARE	@TRANSFER TABLE
		(
			[SKU_CODE] VARCHAR(50)
			,[DESCRIPTION_SKU] VARCHAR(MAX)
			,[CODE_WAREHOUSE_TARGET] VARCHAR(50)
			,[QTY] FLOAT
			,[TRANSFER_ID] NUMERIC(18 ,0)
			,[SERIAL_NUMBER] VARCHAR(150)
			,[LOCATION] VARCHAR(50)
		);
	
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene las trasferencias
		-- ------------------------------------------------------------------------------------
		INSERT	INTO @TRANSFER
				(
					[SKU_CODE]
					,[DESCRIPTION_SKU]
					,[CODE_WAREHOUSE_TARGET]
					,[QTY]
					,[TRANSFER_ID]
					,[SERIAL_NUMBER]
					,[LOCATION]
				)
		SELECT
			[SKU_CODE]
			,[DESCRIPTION_SKU]
			,[CODE_WAREHOUSE_TARGET]
			,[QTY]
			,[TH].[TRANSFER_ID]
			,[TD].[SERIE]
			,(
				SELECT TOP 1 [CODE_LOCATION]
				FROM [SONDA].[SWIFT_VIEW_LOCATIONS]
				WHERE [CODE_WAREHOUSE] = [TH].[CODE_WAREHOUSE_TARGET]
			)
		FROM
			[SONDA].[SWIFT_VIEW_TRANSFER_HEADER] [TH]
		INNER JOIN [SONDA].[SWIFT_VIEW_TRANSFER_DETAIL] [TD]
		ON	(
				[TH].[TRANSFER_ID] = [TD].[TRANSFER_ID]
			)
		WHERE [TH].[STATUS] = 'COMPLETADO'
			AND [TH].[SELLER_ROUTE] = @Route
			AND [TH].[IS_ONLINE] = @IS_ONLINE
			AND (
				@TRANSFER_ID IS NULL
				OR [TH].[TRANSFER_ID] = @TRANSFER_ID
			)

		-------------------------------------------------------------------------------
		-- Actualiza el registro del sku para agregar inventario
		-------------------------------------------------------------------------------
		MERGE [SONDA].[SWIFT_INVENTORY] [I]
		USING (
			SELECT
				[T].[SKU_CODE]
				,[T].[DESCRIPTION_SKU]
				,[T].[CODE_WAREHOUSE_TARGET]
				,[T].[QTY]
				,[T].[TRANSFER_ID]
				,[T].[SERIAL_NUMBER]
				,[T].[LOCATION]
			FROM @TRANSFER [T]
		) [T]
		ON (
			[I].[WAREHOUSE] = [T].[CODE_WAREHOUSE_TARGET]
			AND [I].[SKU] = [T].[SKU_CODE]
			AND [I].[LOCATION] = [T].[LOCATION]
			AND ISNULL([I].[SERIAL_NUMBER],'NA') = ISNULL([T].[SERIAL_NUMBER],'NA')
		)
		WHEN MATCHED THEN
		UPDATE
			SET
				[I].[ON_HAND] = [I].[ON_HAND] + [T].[QTY]
				,[I].[LAST_UPDATE] = GETDATE()
				,[I].[LAST_UPDATE_BY] = @Login
		WHEN NOT MATCHED THEN 
		INSERT (
			[SERIAL_NUMBER]
			,[WAREHOUSE]
			,[LOCATION]
			,[SKU]
			,[SKU_DESCRIPTION]
			,[ON_HAND]
			,[LAST_UPDATE]
			,[LAST_UPDATE_BY]
			,[TXN_ID]
			,[IS_SCANNED]
			,[RELOCATED_DATE]
			,[PALLET_ID]
		)
		VALUES (
			 [T].[SERIAL_NUMBER]
			 ,[T].[CODE_WAREHOUSE_TARGET]
			 ,[T].[LOCATION]
			 ,[T].[SKU_CODE]
			 ,[T].[DESCRIPTION_SKU]
			 ,[T].[QTY]
			 ,GETDATE()
			 ,@Login
			 ,NULL
			 ,0
			 ,GETDATE()
			 ,NULL
		);

		-------------------------------------------------------------------------------
		-- Descuenta inventario de la bodega origen
		-------------------------------------------------------------------------------
		UPDATE [I]
		SET [I].[ON_HAND] = [I].[ON_HAND] - [T].[QTY]
		FROM @TRANSFER [T]
		INNER JOIN [SONDA].[SWIFT_TRANSFER_HEADER] [TH] ON (
			[TH].[TRANSFER_ID] = [T].[TRANSFER_ID]
			AND [TH].[CODE_WAREHOUSE_TARGET] = [T].[CODE_WAREHOUSE_TARGET]
		)
		INNER JOIN [SONDA].[SWIFT_INVENTORY] [I] ON (
			[I].[WAREHOUSE] = [TH].[CODE_WAREHOUSE_SOURCE]
			--AND [T].[LOCATION] = [I].[LOCATION]
			AND [I].[SKU] = [T].[SKU_CODE]
			AND ISNULL([I].[SERIAL_NUMBER],'NA') = ISNULL([T].[SERIAL_NUMBER],'NA')
		)

		-- ------------------------------------------------------------------------------------
		-- Marca las transferencias
		-- ------------------------------------------------------------------------------------
		UPDATE [D]
		SET	[STATUS] = 'TRANSFERIDO'
		FROM [SONDA].[SWIFT_TRANSFER_DETAIL] [D]
		INNER JOIN @TRANSFER [T] ON (
			[T].[TRANSFER_ID] = [D].[TRANSFER_ID]
		)
		--
		UPDATE [H]
		SET	[STATUS] = 'TRANSFERIDO'
		FROM [SONDA].[SWIFT_TRANSFER_HEADER] [H]
		INNER JOIN @TRANSFER [T] ON (
			[T].[TRANSFER_ID] = [H].[TRANSFER_ID]
		)
		--
		SET @tmpResult = 'OK';
	END TRY
	BEGIN CATCH
		DECLARE @ERR VARCHAR(1000)
		--
		SET @ERR =  ERROR_MESSAGE() 
		--
		PRINT 'ERROR: ' + @ERR

		SELECT @tmpResult = 'No se pudo transferir los sku: ' + @ERR;
	END CATCH
	--
	SELECT @pRESULT = @tmpResult;
END;
