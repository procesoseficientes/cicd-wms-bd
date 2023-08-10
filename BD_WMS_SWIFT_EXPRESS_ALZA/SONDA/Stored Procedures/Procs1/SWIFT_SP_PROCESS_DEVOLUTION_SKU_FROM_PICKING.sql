-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	15-01-2016
-- Description:			Realiza el ajuste de un pallet cuando se crea un nuevo lote y pallet

-- MODIFICADO :	12-02-2016
	-- AUTOR:	diego.as
	-- POR MOTIVO DE: Adecuación al proceso de Devolución desde una Tarea de Picking 			

/*
-- Ejemplo de Ejecucion:


					-- Ejemplo de ajuste de nuevo batch y pallet
				EXEC [SONDA].[SWIFT_SP_PROCESS_DEVOLUTION_SKU_FROM_PICKING]
						@TASK_ID = 14169
						,@QTY = 2
						,@CODE_SKU = '100018'
						,@PICKING_HEADER = 1008
						,@DESCRIPTION_SKU = 'DESCRIPCION'
						,@BARCODE_SKU = 'BARCODE_SKU'
						,@WAREHOUSE_NEW  = NULL
						,@LOCATION_NEW  = NULL
						,@BATCH_ID_NEW = NULL
						,@PALLET_ID_NEW = NULL
						,@BATCH_ID_OLD = 40									
						,@PALLET_ID_OLD = 41
						,@BATCH_SUPPLIER = 'BATCH_SUPPLIER'
						,@BATCH_SUPPLIER_EXPIRATION_DATE = '20160115'
						,@STATUS_PALLET = 'LOCATED' --,@STATUS_PALLET = 'PENDING'
						,@LAST_UPDATE_BY = 'OPER1@SONDA'
						,@LAST_UPDATE_BY_NAME = 'FREE'
						,@WAREHOUSE_OLD  = NULL
						,@LOCATION_OLD  = NULL
			
				

				-- Ejemplo de ajuste a un batch existente con nuevo pallet
				EXEC [SONDA].[SWIFT_SP_PROCESS_DEVOLUTION_SKU_FROM_PICKING]
						@TASK_ID = 14169
						,@QTY = 1
						,@CODE_SKU = '100018'
						,@PICKING_HEADER = 1008
						,@DESCRIPTION_SKU = 'DESCRIPCION'
						,@BARCODE_SKU = 'BARCODE_SKU'
						,@WAREHOUSE_NEW  = 'BODEGA_CENTRAL'
						,@LOCATION_NEW  = 'A3'
						,@BATCH_ID_NEW = 3238
						,@PALLET_ID_NEW = NULL
						,@BATCH_ID_OLD = 3238												
						,@PALLET_ID_OLD = 3330
						,@BATCH_SUPPLIER = 'BATCH_SUPPLIER'
						,@BATCH_SUPPLIER_EXPIRATION_DATE = '20160115'
						,@STATUS_PALLET = 'LOCATED' --,@STATUS_PALLET = 'PENDING'
						,@LAST_UPDATE_BY = 'OPER1@SONDA'
						,@LAST_UPDATE_BY_NAME = 'FREE'
						,@WAREHOUSE_OLD  = 'BODEGA_CENTRAL'
						,@LOCATION_OLD  = 'A3'


				
				-- Ejemplo de ajuste a un batch existente con pallet existente
				EXEC [SONDA].[SWIFT_SP_PROCESS_DEVOLUTION_SKU_FROM_PICKING]
						@TASK_ID = 14169
						,@QTY = 1
						,@CODE_SKU = '100018'
						,@PICKING_HEADER = 1008
						,@DESCRIPTION_SKU = 'DESCRIPCION'
						,@BARCODE_SKU = 'BARCODE_SKU'
						,@WAREHOUSE_NEW  = 'BODEGA_CENTRAL'
						,@LOCATION_NEW  = 'A3'
						,@BATCH_ID_NEW = 3238
						,@PALLET_ID_NEW = 3329
						,@BATCH_ID_OLD = 3238
						,@PALLET_ID_OLD = 3330
						,@BATCH_SUPPLIER = 'BATCH_SUPPLIER'
						,@BATCH_SUPPLIER_EXPIRATION_DATE = '20160115'
						,@STATUS_PALLET = 'LOCATED' --,@STATUS_PALLET = 'PENDING'
						,@LAST_UPDATE_BY = 'OPER1@SONDA'
						,@LAST_UPDATE_BY_NAME = 'FREE'
						,@WAREHOUSE_OLD  = 'BODEGA_CENTRAL'
						,@LOCATION_OLD  = 'A3'


				
*/
-- =============================================

CREATE PROCEDURE [SONDA].[SWIFT_SP_PROCESS_DEVOLUTION_SKU_FROM_PICKING]
(
	@TASK_ID INT
	,@QTY INT
	,@CODE_SKU VARCHAR(50)
	,@PICKING_HEADER INT
	,@DESCRIPTION_SKU VARCHAR(MAX)
	,@BARCODE_SKU VARCHAR(50)
	,@WAREHOUSE_NEW VARCHAR(50)
	,@LOCATION_NEW VARCHAR(50)
	,@BATCH_ID_NEW INT = NULL
	,@PALLET_ID_NEW INT = NULL
	,@BATCH_ID_OLD INT
	,@PALLET_ID_OLD INT
	,@BATCH_SUPPLIER VARCHAR(250)
	,@BATCH_SUPPLIER_EXPIRATION_DATE DATE
	,@STATUS_PALLET VARCHAR(20)
	,@LAST_UPDATE_BY VARCHAR(50)
	,@LAST_UPDATE_BY_NAME VARCHAR(50)
	,@WAREHOUSE_OLD VARCHAR(50)
	,@LOCATION_OLD VARCHAR(50)
)
AS
BEGIN 
	SET NOCOUNT ON;
	--
	DECLARE
		@TXN_ID INT = -1
		,@BATCH_STATUS_CLOSE VARCHAR(250)
		,@PALLET_STATUS_LOCATE VARCHAR(250)
		,@IS_NEW_PALLET INT

	SET @IS_NEW_PALLET = 
		CASE 
			WHEN @PALLET_ID_NEW IS NULL THEN 1
			ELSE 0
		END

	BEGIN TRAN
	BEGIN TRY

		-- ------------------------------------------------------------------------------------
		-- Obtiene parametros generales
		-- ------------------------------------------------------------------------------------
		SELECT @BATCH_STATUS_CLOSE = P.[VALUE] FROM [SONDA].[SWIFT_PARAMETER] P WHERE P.[GROUP_ID] = 'RECEPCTION_BATCH' AND P.[PARAMETER_ID] = 'BATCH_STATUS_CLOSE' ---ESTARA CON VALOR "CLOSED"
		SELECT @PALLET_STATUS_LOCATE = P.[VALUE] FROM [SONDA].[SWIFT_PARAMETER] P WHERE P.[GROUP_ID] = 'RECEPCTION_BATCH' AND P.[PARAMETER_ID] = 'PALLET_STATUS_LOCATE' ---ESTARA CON VALOR "LOCATED"
		----------------------------------------------------------------------------------------------------------------------------------------------------------------

			-- ------------------------------------------------------------------------------------
			-- Inserta el lote y toma el ID
			-- ------------------------------------------------------------------------------------
		
			IF @BATCH_ID_NEW IS NULL
			BEGIN
			PRINT '--> [SONDA].[SWIFT_SP_ADD_BATCH]'
			--
				EXEC [SONDA].[SWIFT_SP_ADD_BATCH]
					@BATCH_SUPPLIER = @BATCH_SUPPLIER
					,@BATCH_SUPPLIER_EXPIRATION_DATE = @BATCH_SUPPLIER_EXPIRATION_DATE
					,@STATUS = @BATCH_STATUS_CLOSE
					,@SKU = @CODE_SKU
					,@QTY = @QTY
					,@QTY_LEFT= 0				
					,@LAST_UPDATE_BY = @LAST_UPDATE_BY
					,@TASK_ID = @TASK_ID
					,@BATCH_ID = NULL
					,@ID = @BATCH_ID_NEW OUTPUT
			END
			ELSE
			BEGIN
			PRINT '--> [SONDA].[SWIFT_SP_BATCH_QTY_UPDATE] --> @IS_SUM = 1'
			--
				EXEC [SONDA].[SWIFT_SP_BATCH_QTY_UPDATE]
					@BATCH_ID = @BATCH_ID_NEW
					,@QTY = @QTY
					,@LAST_UPDATE_BY = @LAST_UPDATE_BY
					,@IS_SUM = 1
			END

			--------------------------------------------------------------------------------------
			-- Inserta el pallet y toma el ID
			--------------------------------------------------------------------------------------
			IF @PALLET_ID_NEW IS NULL
			BEGIN
			PRINT '--> [SONDA].[SWIFT_SP_INSERT_PALLET]'
			--
				EXEC [SONDA].[SWIFT_SP_INSERT_PALLET]
					@BATCH_ID = @BATCH_ID_NEW
					,@STATUS = @STATUS_PALLET
					,@QTY = @QTY
					,@LAST_UPDATE_BY = @LAST_UPDATE_BY
					,@WAREHOUSE = @WAREHOUSE_NEW
					,@LOCATION = @LOCATION_NEW
					,@TASK_ID = @TASK_ID
					,@IS_ADJUSTMENT = 1
					,@ID = @PALLET_ID_NEW OUTPUT
			END
			ELSE
			BEGIN
			PRINT '--> [SONDA].[SWIFT_SP_PALLET_QTY_UPDATE] --> @IS_SUM = 1'
			--
				EXEC [SONDA].[SWIFT_SP_PALLET_QTY_UPDATE]
					@PALLET_ID = @PALLET_ID_NEW
					,@QTY = @QTY
					,@LAST_UPDATE_BY = @LAST_UPDATE_BY
					,@IS_SUM = 1
			END

			-- ------------------------------------------------------------------------------------
			-- Inserta la transaccion
			-- ------------------------------------------------------------------------------------
			PRINT '--> [SONDA].[SWIFT_SP_ADD_TXN_FOR_ADJUSTMENT]'
			--
				EXEC [SONDA].[SWIFT_SP_ADD_TXN_FOR_ADJUSTMENT]
					@PALLET_ID_OLD = @PALLET_ID_OLD
					,@PALLET_ID_NEW = @PALLET_ID_NEW
					,@TASK_ID = @TASK_ID
					,@LAST_UPDATE_BY = @LAST_UPDATE_BY
					,@LAST_UPDATE_BY_NAME = @LAST_UPDATE_BY_NAME
					,@CODE_SKU = @CODE_SKU
					,@DESCRIPTION_SKU = @DESCRIPTION_SKU
					,@BATCH_ID = @BATCH_ID_NEW
					,@QTY = @QTY
					,@WAREHOUSE_OLD = @WAREHOUSE_OLD
					,@LOCATION_OLD = @LOCATION_OLD
					,@WAREHOUSE_NEW = @WAREHOUSE_NEW
					,@LOCATION_NEW = @LOCATION_NEW
					,@BARCODE_SKU = @BARCODE_SKU
					,@ID = @TXN_ID OUTPUT

			-- ------------------------------------------------------------------------------------
			-- Verifica si esta ubicado el pallet
			-- ------------------------------------------------------------------------------------
			PRINT '----> @STATUS_PALLET: ' + @STATUS_PALLET
			--
			IF @STATUS_PALLET = @PALLET_STATUS_LOCATE ---SI TIENE ESTADO (LOCATED)
			BEGIN		
				-- ------------------------------------------------------------------------------------
				-- Se descuenta la cantidad en el inventario original
				-- ------------------------------------------------------------------------------------
				PRINT '--> [SONDA].[SWIFT_SP_INVENTORY_QTY_UPDATE_BY_ADJUSTMENT]'
				--
					EXEC [SONDA].[SWIFT_SP_INVENTORY_QTY_UPDATE_BY_ADJUSTMENT]
						@PALLET_ID = @PALLET_ID_OLD
						,@QTY = @QTY
						,@LAST_UPDATE_BY = @LAST_UPDATE_BY
						,@TXN_ID = @TXN_ID
						,@IS_SUM = 0

				-- ------------------------------------------------------------------------------------
				-- Se inserta un nuevo registro en el inventario o se agreaga a un existente
				-- ------------------------------------------------------------------------------------
				IF @IS_NEW_PALLET = 1
				BEGIN
				PRINT '--> [SONDA].[SWIFT_SP_INVENTORY_INSERT_BY_ADJUSTMENT]'
				--
					EXEC [SONDA].[SWIFT_SP_INVENTORY_INSERT_BY_ADJUSTMENT]
						@PALLET_ID_OLD = @PALLET_ID_OLD
						,@PALLET_ID_NEW = @PALLET_ID_NEW
						,@BATCH_ID_NEW = @BATCH_ID_NEW
						,@QTY = @QTY
						,@LAST_UPDATE_BY = @LAST_UPDATE_BY
						,@TXN_ID = @TXN_ID
				END
				ELSE
				BEGIN
				-- ------------------------------------------------------------------------------------
				-- Se aumenta la cantidad en el pallet destino
				-- ------------------------------------------------------------------------------------
				PRINT '--> [SONDA].[SWIFT_SP_INVENTORY_QTY_UPDATE_BY_ADJUSTMENT] --> @IS_SUM = 1'
				--
					EXEC [SONDA].[SWIFT_SP_INVENTORY_QTY_UPDATE_BY_ADJUSTMENT]
						@PALLET_ID = @PALLET_ID_NEW
						,@QTY = @QTY
						,@LAST_UPDATE_BY = @LAST_UPDATE_BY
						,@TXN_ID = @TXN_ID
						,@IS_SUM = 1
				END
			END

			------------------------------------------------------------------------------------------
			-- Actualiza la Tabla PICKING_DETAIL
			------------------------------------------------------------------------------------------
			UPDATE [SONDA].[SWIFT_PICKING_DETAIL] 
			SET [SCANNED] = ([SCANNED] - @QTY)
				,[DIFFERENCE] = ([DIFFERENCE] + @QTY)
			WHERE PICKING_HEADER = @PICKING_HEADER AND CODE_SKU = @CODE_SKU

			--------------------------------------------------------------------------------------
			-- Retorna los ids
			-- ------------------------------------------------------------------------------------
			PRINT '--> Muestra Resultado'
			--
			SELECT
				@BATCH_ID_NEW AS BATCH_ID
				,@PALLET_ID_NEW AS PALLET_ID
				,@TXN_ID AS TXN_ID

		COMMIT
		END TRY

		BEGIN CATCH
			ROLLBACK
			DECLARE @ERROR VARCHAR(MAX) = ERROR_MESSAGE()
			RAISERROR (@ERROR,16,1)
		END CATCH
END
