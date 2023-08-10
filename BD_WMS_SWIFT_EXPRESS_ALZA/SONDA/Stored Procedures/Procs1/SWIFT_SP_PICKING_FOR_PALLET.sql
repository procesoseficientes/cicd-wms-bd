
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	21-01-2016
-- Description:			Realiza accion del picking

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_PICKING_FOR_PALLET]
					@TASK_ID = 7449
					,@BATCH_ID = 1220
					,@PALLET_ID = 1299
					,@CODE_SKU = '20GM'
					,@DESCRIPTION_SKU = 'DESCRIPCION'
					,@BARCODE_SKU = 'BARCODE'
					,@QTY = 1
					,@LAST_UPDATE_BY = 'OPER1@SONDA'
					,@LAST_UPDATE_BY_NAME = 'FREE'
					,@WAREHOUSE = 'WAREHOUSE'
					,@LOCATION = 'LOCATION'
					,@CATEGORY = 'PO'
					,@CATEGORY_DESCRIPTION = 'PICKING'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_PICKING_FOR_PALLET]
	@TASK_ID INT
	,@BATCH_ID INT
	,@PALLET_ID INT
	,@CODE_SKU VARCHAR(50)
	,@DESCRIPTION_SKU VARCHAR(MAX)
	,@BARCODE_SKU VARCHAR(50)
	,@QTY INT
	,@LAST_UPDATE_BY VARCHAR(50)
	,@LAST_UPDATE_BY_NAME VARCHAR(50)
	,@WAREHOUSE VARCHAR(50)
	,@LOCATION VARCHAR(50)
	,@CATEGORY VARCHAR(50)
	,@CATEGORY_DESCRIPTION VARCHAR(50)
AS
BEGIN 
	SET NOCOUNT ON
	--
	DECLARE 
		@TXN_ID INT
		,@COSTUMER_CODE VARCHAR(50)
		,@COSTUMER_NAME VARCHAR(250)
		,@PICKING_NUMBER INT
		,@IS_PALLET_OK INT = 0
		,@ERROR VARCHAR(1000)

	BEGIN TRAN
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Valida si el pallet sigue siendo correcto
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1 @IS_PALLET_OK = 1
		FROM [SONDA].SWIFT_PALLET P
		INNER JOIN [SONDA].SWIFT_LOCATIONS L ON (P.LOCATION = L.CODE_LOCATION)
		WHERE P.PALLET_ID = @PALLET_ID
			AND P.LOCATION = @LOCATION
			AND P.QTY >= @QTY
			AND L.ALLOW_PICKING = 'SI'
		--
		IF @IS_PALLET_OK = 0
		BEGIN
			SET @ERROR = 'El pallet ya no cumple las condiciones necesarias'
			RAISERROR (@ERROR,16,1)
		END
		
		-- ------------------------------------------------------------------------------------
		-- Obtiene datos de la tarea
		-- ------------------------------------------------------------------------------------
		SELECT
			@COSTUMER_CODE = T.COSTUMER_CODE
			,@COSTUMER_NAME = T.COSTUMER_NAME
			,@PICKING_NUMBER = T.PICKING_NUMBER
		FROM [SONDA].[SWIFT_TASKS] T
		WHERE TASK_ID = @TASK_ID
		
		-- ------------------------------------------------------------------------------------
		-- Se descuenta la cantidad en el lote original
		-- ------------------------------------------------------------------------------------
		PRINT '--> [SONDA].[SWIFT_SP_BATCH_QTY_UPDATE] --> @IS_SUM = 0'
		--
		EXEC [SONDA].[SWIFT_SP_BATCH_QTY_UPDATE]
			@BATCH_ID = @BATCH_ID
			,@QTY = @QTY
			,@LAST_UPDATE_BY = @LAST_UPDATE_BY
			,@IS_SUM = 0

		-- ------------------------------------------------------------------------------------
		-- Se descuenta la cantidad en el pallet original
		-- ------------------------------------------------------------------------------------
		PRINT '--> [SONDA].[SWIFT_SP_PALLET_QTY_UPDATE] --> @IS_SUM = 0'
		--
		EXEC [SONDA].[SWIFT_SP_PALLET_QTY_UPDATE]
			@PALLET_ID = @PALLET_ID
			,@QTY = @QTY
			,@LAST_UPDATE_BY = @LAST_UPDATE_BY
			,@IS_SUM = 0

		-- ------------------------------------------------------------------------------------
		-- Inserta la transaccion
		-- ------------------------------------------------------------------------------------
		PRINT '--> [SONDA].[SWIFT_SP_ADD_TXN_FOR_PIKING]'
		--
		EXEC [SONDA].[SWIFT_SP_ADD_TXN_FOR_PIKING]
			@PALLET_ID = @PALLET_ID
			,@TASK_ID = @TASK_ID
			,@LAST_UPDATE_BY = @LAST_UPDATE_BY
			,@LAST_UPDATE_BY_NAME = @LAST_UPDATE_BY_NAME
			,@CODE_SKU = @CODE_SKU
			,@DESCRIPTION_SKU = @DESCRIPTION_SKU
			,@BATCH_ID = @BATCH_ID
			,@QTY = @QTY
			,@WAREHOUSE = @WAREHOUSE
			,@LOCATION = @LOCATION
			,@BARCODE_SKU = @BARCODE_SKU
			,@CATEGORY = @CATEGORY
			,@CATEGORY_DESCRIPTION = @CATEGORY_DESCRIPTION
			,@COSTUMER_CODE = @COSTUMER_CODE
			,@COSTUMER_NAME = @COSTUMER_NAME
			,@ID = @TXN_ID OUTPUT
		
		-- ------------------------------------------------------------------------------------
		-- Actualiza el inventario
		-- ------------------------------------------------------------------------------------
		PRINT '--> [SONDA].[SWIFT_SP_INVENTORY_QTY_UPDATE_BY_ADJUSTMENT] --> @IS_SUM = 0'
		--
		EXEC [SONDA].[SWIFT_SP_INVENTORY_QTY_UPDATE_BY_ADJUSTMENT]
			@PALLET_ID = @PALLET_ID
			,@QTY = @QTY
			,@LAST_UPDATE_BY = @LAST_UPDATE_BY
			,@TXN_ID = @TXN_ID
			,@IS_SUM = 0

		-- ------------------------------------------------------------------------------------
		-- Actualiza el detalle del picking
		-- ------------------------------------------------------------------------------------
		PRINT '--> [SONDA].[SWIFT_SP_INVENTORY_QTY_UPDATE_BY_ADJUSTMENT] --> @IS_SUM = 0'
		--
		EXEC [SONDA].[SWIFT_SP_PICKING_DETAIL_QTY_UPDATE]
			@PICKING_NUMBER = @PICKING_NUMBER
			,@CODE_SKU = @CODE_SKU
			,@QTY = @QTY
			,@LAST_UPDATE_BY = @LAST_UPDATE_BY

		-- ------------------------------------------------------------------------------------
		-- Retorna los ids
		-- ------------------------------------------------------------------------------------
		PRINT '--> Muestra Resultado'
		--
		SELECT 
			@TXN_ID AS TXN_ID

		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		SET @ERROR = ERROR_MESSAGE()
		RAISERROR (@ERROR,16,1)
	END CATCH
END
