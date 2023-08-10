-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	09-May-17 @ A-TEAM Sprint Issa 
-- Description:			SP para agregar o quitar inventario de los productos seleccionados en las bodegas asociadas al centro de distribucion del usuario

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SET_INVENTORY_BY_DISTRIBUTION_CENTER]
					@LOGIN = 'KEVIN OSORIO@SONDA'
					,@SKU = N'<SKU>
								<CODE_SKU>100001</CODE_SKU>
								<CODE_SKU>100002</CODE_SKU>
								<CODE_SKU>100003</CODE_SKU>
								<CODE_SKU>SERIE001</CODE_SKU>
								<CODE_SKU>SERIE002</CODE_SKU>
							</SKU>'
					,@ACTIVATING = 1
				--
				EXEC [SONDA].[SWIFT_SET_INVENTORY_BY_DISTRIBUTION_CENTER]
					@LOGIN = 'KEVIN OSORIO@SONDA'
					,@SKU = N'<SKU>
								<CODE_SKU>100001</CODE_SKU>
								<CODE_SKU>100002</CODE_SKU>
								<CODE_SKU>100003</CODE_SKU>
								<CODE_SKU>SERIE001</CODE_SKU>
								<CODE_SKU>SERIE002</CODE_SKU>
							</SKU>'
					,@ACTIVATING = 0
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SET_INVENTORY_BY_DISTRIBUTION_CENTER](
	@LOGIN VARCHAR(50)
	,@SKU XML
	,@ACTIVATING INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @WAREHOSE TABLE ([CODE_WAREHOUSE] VARCHAR(50))
	--
	DECLARE @SKU_LIST TABLE (
		[CODE_SKU] VARCHAR(50)
		,[DESCRIPTION_SKU] VARCHAR(250)
		,[HANDLE_BATCH] INT
	)
	--
	DECLARE 
		@DISTRIBUTION_CENTER_ID INT
		,@ON_HAND INT
	
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene las bodegas del centro de distribucion asociado al usuario
		-- ------------------------------------------------------------------------------------
		SELECT @DISTRIBUTION_CENTER_ID = [SONDA].[SWIFT_FN_GET_DISTRIBUTION_CENTER_BY_LOGIN](@LOGIN)
		--
		INSERT INTO @WAREHOSE
		SELECT [WDC].[CODE_WAREHOUSE]
		FROM [SONDA].[SWIFT_WAREHOUSE_X_DISTRIBUTION_CENTER] [WDC]
		WHERE [WDC].[DISTRIBUTION_CENTER_ID] = @DISTRIBUTION_CENTER_ID

		-- ------------------------------------------------------------------------------------
		-- Obtiene los productos utilizados
		-- ------------------------------------------------------------------------------------
		INSERT INTO @SKU_LIST
		(
			[CODE_SKU]
			,[DESCRIPTION_SKU]
			,[HANDLE_BATCH]
		)
		SELECT
			x.Rec.query('.').value('.', 'varchar(50)')
			,[S].[DESCRIPTION_SKU]
			,[S].[HANDLE_BATCH]
		FROM @SKU.nodes('/SKU/CODE_SKU') as x(Rec)
		INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [S] ON (
			[S].[CODE_SKU] = x.Rec.query('.').value('.', 'varchar(50)')
		)

		-- ------------------------------------------------------------------------------------
		-- Valida accion a realizar
		-- ------------------------------------------------------------------------------------
		BEGIN TRAN
		--
		IF @ACTIVATING = 1
		BEGIN
			SELECT @ON_HAND = CAST([SONDA].[SWIFT_FN_GET_PARAMETER]('INVENTORY','SET_INVENTORY') AS INT)
			--
			SELECT DISTINCT
				CAST(NULL AS VARCHAR(50)) [SERIAL_NUMBER]
				,[W].[CODE_WAREHOUSE] [WAREHOUSE]
				,[W].[CODE_WAREHOUSE] [LOCATION]
				,[S].[CODE_SKU] [SKU]
				,[S].[DESCRIPTION_SKU] [SKU_DESCRIPTION]
				,@ON_HAND [ON_HAND]
				,NULL [BATCH_ID]
				,GETDATE() [LAST_UPDATE]
				,@LOGIN [LAST_UPDATE_BY]
				,NULL [TXN_ID]
				,0 [IS_SCANNED]
				,GETDATE() [RELOCATED_DATE]
				,NULL [PALLET_ID]
				,[S].[HANDLE_BATCH]
			INTO #INVENTORY
			FROM @SKU_LIST [S], @WAREHOSE [W]
			ORDER BY
				[W].[CODE_WAREHOUSE]
				,[S].[CODE_SKU]

			-- ------------------------------------------------------------------------------------
			-- Opera los productos sin lote
			-- ------------------------------------------------------------------------------------
			MERGE [SONDA].[SWIFT_INVENTORY] SIV
			USING (SELECT DISTINCT * FROM #INVENTORY [I] WHERE [I].[HANDLE_BATCH] = 0) EVI 
			ON (
				ISNULL(SIV.[SERIAL_NUMBER],'') = ISNULL(EVI.[SERIAL_NUMBER],'')
				AND SIV.[SKU] = EVI.[SKU]
				AND EVI.LOCATION = SIV.LOCATION
				AND EVI.WAREHOUSE = SIV.WAREHOUSE
			) 
			WHEN MATCHED THEN 
			UPDATE 
				SET
					SIV.[SKU_DESCRIPTION]	= EVI.[SKU_DESCRIPTION]
					,SIV.[ON_HAND]			= EVI.[ON_HAND]
					,SIV.[BATCH_ID]			= EVI.[BATCH_ID]
					,SIV.[LAST_UPDATE]		= EVI.[LAST_UPDATE]
					,SIV.[LAST_UPDATE_BY]		= EVI.[LAST_UPDATE_BY]
			WHEN NOT MATCHED THEN 
			INSERT (
				[SERIAL_NUMBER]
				,[WAREHOUSE]
				,[LOCATION]
				,[SKU]
				,[SKU_DESCRIPTION]
				,[ON_HAND]
				,[BATCH_ID]
				,[LAST_UPDATE]
				,[LAST_UPDATE_BY]
				,[TXN_ID]
				,[IS_SCANNED]
				,[RELOCATED_DATE]
			) 
			VALUES (
				EVI.[SERIAL_NUMBER]
				,EVI.[WAREHOUSE]
				,EVI.[LOCATION]
				,EVI.[SKU]
				,EVI.[SKU_DESCRIPTION]
				,EVI.[ON_HAND]
				,EVI.[BATCH_ID]
				,EVI.[LAST_UPDATE]
				,EVI.[LAST_UPDATE_BY]
				,EVI.[TXN_ID]
				,EVI.[IS_SCANNED]
				,EVI.[RELOCATED_DATE]
			);

			-- ------------------------------------------------------------------------------------
			-- Opera los productos con lote
			-- ------------------------------------------------------------------------------------
			DELETE [I]
			FROM [SONDA].[SWIFT_INVENTORY] [I]
			INNER JOIN @WAREHOSE [W] ON ([I].[WAREHOUSE] = [W].[CODE_WAREHOUSE])
			INNER JOIN @SKU_LIST [S] ON (
				[S].[CODE_SKU] = [I].[SKU]
				AND [S].[HANDLE_BATCH] = 1
			)
			WHERE [I].[BATCH_ID] IS NULL

			INSERT INTO [SONDA].[SWIFT_INVENTORY]
					(
						[SERIAL_NUMBER]
						,[WAREHOUSE]
						,[LOCATION]
						,[SKU]
						,[SKU_DESCRIPTION]
						,[ON_HAND]
						,[BATCH_ID]
						,[LAST_UPDATE]
						,[LAST_UPDATE_BY]
						,[TXN_ID]
						,[IS_SCANNED]
						,[RELOCATED_DATE]
						,[PALLET_ID]
					)
			SELECT DISTINCT
				[I].[SERIAL_NUMBER]
				,[I].[WAREHOUSE]
				,[I].[LOCATION]
				,[I].[SKU]
				,[I].[SKU_DESCRIPTION]
				,[I].[ON_HAND]
				,[I].[BATCH_ID]
				,[I].[LAST_UPDATE]
				,[I].[LAST_UPDATE_BY]
				,[I].[TXN_ID]
				,[I].[IS_SCANNED]
				,[I].[RELOCATED_DATE]
				,[I].[PALLET_ID]
			FROM #INVENTORY [I]
			WHERE [I].[HANDLE_BATCH] = 1
		END
		ELSE
		BEGIN
			-- ------------------------------------------------------------------------------------
			-- Opera los productos sin lote
			-- ------------------------------------------------------------------------------------
			UPDATE [I]
			SET [I].[ON_HAND] = 0
			FROM [SONDA].[SWIFT_INVENTORY] [I]
			INNER JOIN @WAREHOSE [W] ON ([I].[WAREHOUSE] = [W].[CODE_WAREHOUSE])
			INNER JOIN @SKU_LIST [S] ON (
				[S].[CODE_SKU] = [I].[SKU]
				AND [S].[HANDLE_BATCH] = 0
			)

			-- ------------------------------------------------------------------------------------
			-- Opera los productos con lote
			-- ------------------------------------------------------------------------------------
			DELETE [I]
			FROM [SONDA].[SWIFT_INVENTORY] [I]
			INNER JOIN @WAREHOSE [W] ON ([I].[WAREHOUSE] = [W].[CODE_WAREHOUSE])
			INNER JOIN @SKU_LIST [S] ON (
				[S].[CODE_SKU] = [I].[SKU]
				AND [S].[HANDLE_BATCH] = 1
			)
			WHERE [I].[BATCH_ID] IS NULL
		END
		--
		COMMIT
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		ROLLBACK
		--
		DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
		--
		SELECT  
			-1 as Resultado
			,@ERROR Mensaje 
			,@@ERROR Codigo 
		--
		PRINT 'CATCH: ' + @ERROR
	END CATCH
	
END
