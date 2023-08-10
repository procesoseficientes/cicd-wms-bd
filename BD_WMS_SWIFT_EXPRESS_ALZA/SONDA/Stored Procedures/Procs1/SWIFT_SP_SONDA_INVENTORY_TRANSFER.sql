-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	24-01-2016
-- Description:			Transfiere inventario a la bodega de sonda

/*
-- Ejemplo de Ejecucion:
				-- 
				EXEC [SONDA].[SWIFT_SP_SONDA_INVENTORY_TRANSFER] @PICKING_HEADER = 4
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_SONDA_INVENTORY_TRANSFER]
(	
	@PICKING_HEADER INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	CREATE TABLE #TEMP_TXN (
		TXN_ID INT
		,CODE_SKU VARCHAR(25)
		,SKU_DESCRIPTION VARCHAR(250)
		,QTY INT
		,LAST_UPDATE_BY VARCHAR(50)
		,WAREHOUSE VARCHAR(50)
		,LOCATION VARCHAR(50)
	)
	--
	DECLARE
		@WAREHOUSE VARCHAR(50)
		,@TXN_ID INT
		,@LAST_UPDATE_BY VARCHAR(50)
		,@LAST_UPDATE_BY_NAME VARCHAR(50)
		,@TASK_ID INT
		,@TXN_TYPE VARCHAR(50)

	BEGIN TRAN
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene la bodega --que se esta en el campo CODE_CLIENT
		-- ------------------------------------------------------------------------------------
		SELECT 
			@WAREHOUSE = P.CODE_CLIENT
		FROM [SONDA].[SWIFT_PICKING_HEADER] P
		WHERE P.PICKING_HEADER = @PICKING_HEADER

		-- ------------------------------------------------------------------------------------
		-- Obtiene la tarea y usuario
		-- ------------------------------------------------------------------------------------
		SELECT 
			@TASK_ID = T.TASK_ID
			,@LAST_UPDATE_BY = T.ASSIGEND_TO
		FROM [SONDA].[SWIFT_TASKS] T
		WHERE T.PICKING_NUMBER = @PICKING_HEADER
		
		-- ------------------------------------------------------------------------------------
		-- Obtiene el nombre del usuario
		-- ------------------------------------------------------------------------------------
		SELECT @LAST_UPDATE_BY = U.NAME_USER
		FROM [SONDA].USERS U
		WHERE U.LOGIN = @LAST_UPDATE_BY

		-- ------------------------------------------------------------------------------------
		-- Inserta en TXN
		-- ------------------------------------------------------------------------------------
		PRINT 'Insert en TXN'
		--
		INSERT INTO [SONDA].[SWIFT_TXNS] (
			[TXN_TYPE]
			,[TXN_DESCRIPTION]
			,[TXN_CATEGORY]
			,[TXN_CREATED_STAMP]
			,[TXN_OPERATOR_ID]
			,[TXN_OPERATOR_NAME]
			,[TXN_CODE_SKU]
			,[TXN_DESCRIPTION_SKU]
			,[TXN_QTY]
			,[TXN_SOURCE_CODE_WAREHOUSE]
			,[TXN_TARGET_CODE_WAREHOUSE]
			,[TXN_SOURCE_CODE_LOCATION]
			,[TXN_TARGET_CODE_LOCATION]
			,[TXN_SOURCE_PALLET_ID]
			,[TXN_BARCODE_SKU]
			,[TXN_COSTUMER_CODE]
			,[TXN_COSTUMER_NAME]
		)
		OUTPUT 
			INSERTED.TXN_ID
			,INSERTED.TXN_CODE_SKU
			,INSERTED.TXN_DESCRIPTION_SKU
			,INSERTED.TXN_QTY
			,INSERTED.TXN_OPERATOR_ID
			,INSERTED.TXN_TARGET_CODE_WAREHOUSE
			,INSERTED.TXN_TARGET_CODE_LOCATION
			INTO #TEMP_TXN
		SELECT
			'WAREHOUSE TRANSFER' TXN_TYPE
			,'WAREHOUSE TRANSFER' TXN_DESCRIPTION
			,'WT' TXN_CATEGORY
			,GETDATE() TXN_CREATED_STAMP
			,@LAST_UPDATE_BY TXN_OPERATOR_ID
			,@LAST_UPDATE_BY_NAME TXN_OPERATOR_NAME
			,T.TXN_CODE_SKU
			,T.TXN_DESCRIPTION_SKU
			,T.TXN_QTY
			,T.TXN_SOURCE_CODE_WAREHOUSE
			,@WAREHOUSE TXN_TARGET_CODE_WAREHOUSE
			,T.TXN_SOURCE_CODE_LOCATION
			,@WAREHOUSE TXN_TARGET_CODE_LOCATION
			,TXN_SOURCE_PALLET_ID
			,T.TXN_BARCODE_SKU
			,T.TXN_COSTUMER_CODE
			,T.TXN_COSTUMER_NAME
		FROM [SONDA].[SWIFT_TXNS] T
		WHERE T.TASK_SOURCE_ID = @TASK_ID

		-- ------------------------------------------------------------------------------------
		-- Realiza merge en el inventario
		-- ------------------------------------------------------------------------------------
		PRINT 'Merge inventario'
		--
		MERGE [SONDA].[SWIFT_INVENTORY] I
		USING (
			SELECT 
				T.CODE_SKU
				,MAX(T.SKU_DESCRIPTION) AS SKU_DESCRIPTION
				,MAX(T.WAREHOUSE) AS WAREHOUSE
				,MAX(T.LOCATION) AS LOCATION
				,MAX(LAST_UPDATE_BY) AS LAST_UPDATE_BY
				,MAX(TXN_ID) AS TXN_ID
				,SUM(T.QTY) AS QTY
			FROM #TEMP_TXN T
			GROUP BY T.CODE_SKU
		) T 
		ON (
			I.[WAREHOUSE] = T.[WAREHOUSE]
			AND I.[LOCATION] = T.[LOCATION]
			AND I.[SKU] = T.CODE_SKU
		) 
		WHEN MATCHED THEN 
			UPDATE 
			SET   
			   I.[ON_HAND] = (I.[ON_HAND] + T.QTY)
			  ,I.[LAST_UPDATE] = GETDATE()
			  ,I.[LAST_UPDATE_BY] = T.LAST_UPDATE_BY
			  ,I.[TXN_ID] = T.TXN_ID
			  ,I.[RELOCATED_DATE] = GETDATE()
		WHEN NOT MATCHED THEN 
		INSERT (      
			[WAREHOUSE]
			,[LOCATION]
			,[SKU]
			,[SKU_DESCRIPTION]
			,[ON_HAND]
			,[LAST_UPDATE]
			,[LAST_UPDATE_BY]
			,[TXN_ID]
			,[IS_SCANNED]
			,[RELOCATED_DATE] ) 
		VALUES (
			   T.WAREHOUSE
			  ,T.LOCATION
			  ,T.CODE_SKU
			  ,T.SKU_DESCRIPTION
			  ,T.QTY
			  ,GETDATE()
			  ,T.LAST_UPDATE_BY
			  ,T.TXN_ID
			  ,1
			  ,GETDATE()
		);

		PRINT 'COMMIT'
		--
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
		PRINT 'CATCH: ' + @ERROR
		RAISERROR (@ERROR,16,1)
	END CATCH
END
