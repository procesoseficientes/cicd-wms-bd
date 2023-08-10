-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	17-Nov-16 @ A-TEAM Sprint 5 
-- Description:			SP para colocar el id de la liquidacion

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_SET_LIQUIDATION_TO_ACTIVE_ROUTE]
					@CODE_ROUTE = '4'
					,@LOGIN = 'RUDI@SONDA'
				--
				SELECT * FROM [SONDA].[SONDA_LIQUIDATION]
				SELECT TOP 25 * FROM [SONDA].[SONDA_POS_SKU_HISTORICAL]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_SET_LIQUIDATION_TO_ACTIVE_ROUTE](
	@CODE_ROUTE VARCHAR(50)
	,@LOGIN VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@STATUS VARCHAR(10) = 'PENDING'
		,@LIQUIDATION_ID BIGINT
		,@CODE_WAREHOUSE VARCHAR(500)
	--
	SELECT
		@STATUS = 'PENDING'
		,@LIQUIDATION_ID = NEXT VALUE FOR [SONDA].[SONDA_SQ_LIQUIDATION]
	--
	SELECT TOP 1
		@CODE_WAREHOUSE = [U].[DEFAULT_WAREHOUSE]
	FROM [SONDA].[USERS] [U]
	WHERE [U].[LOGIN] = @LOGIN

	BEGIN TRAN
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Crea la liquidacion
		-- ------------------------------------------------------------------------------------
		INSERT INTO [SONDA].[SONDA_LIQUIDATION]
				(
					[LIQUIDATION_ID]
					,[CODE_ROUTE]
					,[LOGIN]
					,[LIQUIDATION_DATE]
					,[LAST_UPDATE]
					,[LAST_UPDATE_BY]
					,[LIQUIDATION_STATUS]
					,[STATUS]
					,[TYPE_ROUTE]
					,[LIQUIDATION_COMMENT]
				)
		VALUES
				(
					@LIQUIDATION_ID  -- LIQUIDATION_ID - bigint
					,@CODE_ROUTE  -- CODE_ROUTE - varchar(50)
					,@LOGIN  -- LOGIN - varchar(50)
					,GETDATE()  -- LIQUIDATION_DATE - datetime
					,GETDATE()  -- LAST_UPDATE - datetime
					,@LOGIN  -- LAST_UPDATE_BY - varchar(50)
					,NULL  -- LIQUIDATION_STATUS - varchar(10)
					,@STATUS  -- STATUS - varchar(10)
					,NULL  -- TYPE_ROUTE - varchar(10)
					,NULL  -- LIQUIDATION_COMMENT - varchar(250)
				)

		-- ------------------------------------------------------------------------------------
		-- Transfiere el inventario al historico
		-- ------------------------------------------------------------------------------------
		INSERT INTO [SONDA].[SONDA_POS_SKU_HISTORICAL]
				(
					[CODE_SKU]
					,[DESCRIPTION_SKU]
					,[SKU_PRICE]
					,[REQUERIES_SERIE]
					,[IS_KIT]
					,[ON_HAND]
					,[CODE_WAREHOUSE]
					,[IS_PARENT]
					,[PARENT_SKU]
					,[EXPOSURE]
					,[PRIORITY]
					,[QTY_RELATED]
					,[CODE_FAMILY_SKU]
					,[SALES_PACK_UNIT]
					,[INITIAL_QTY]
					,[TRANSFER_DATETIME]
					,[LIQUIDATION_ID]
				)
		SELECT
			[S].[SKU]
			,[S].[SKU_NAME]
			,[S].[SKU_PRICE]
			,[S].[REQUERIES_SERIE]
			,[S].[IS_KIT]
			,[S].[ON_HAND]
			,[S].[ROUTE_ID]
			,[S].[IS_PARENT]
			,[S].[PARENT_SKU]
			,[S].[EXPOSURE]
			,[S].[PRIORITY]
			,[S].[QTY_RELATED]
			,[S].[CODE_FAMILY_SKU]
			,[S].[SALES_PACK_UNIT]
			,[S].[INITIAL_QTY]
			,GETDATE()
			,@LIQUIDATION_ID
		FROM [SONDA].[SONDA_POS_SKUS] [S]
		WHERE [S].[ROUTE_ID] = @CODE_WAREHOUSE
	
		-- ------------------------------------------------------------------------------------
		-- Coloca el numero de liquidacion a los documentos de la ruta
		-- ------------------------------------------------------------------------------------
		UPDATE [SONDA].[SONDA_POS_INVOICE_HEADER]
		SET 
			[LIQUIDATION_ID] = @LIQUIDATION_ID
			,[IS_ACTIVE_ROUTE] = 0
		WHERE [POS_TERMINAL] = @CODE_ROUTE
			AND [POSTED_BY] = @LOGIN
			AND [IS_ACTIVE_ROUTE] = 1
		--
		UPDATE [SONDA].[SWIFT_CONSIGNMENT_HEADER]
		SET 
			[LIQUIDATION_ID] = @LIQUIDATION_ID
			,[IS_ACTIVE_ROUTE] = 0
		WHERE [CONSIGNMENT_ID] > 0 
			AND [POS_TERMINAL] = @CODE_ROUTE
			AND [POSTED_BY] = @LOGIN
			AND [IS_ACTIVE_ROUTE] = 1
		--
		UPDATE [SONDA].[SONDA_PAYMENT_HEADER]
		SET 
			[LIQUIDATION_ID] = @LIQUIDATION_ID
			,[IS_ACTIVE_ROUTE] = 0
		WHERE [PAYMENT_NUM] > 0 
			AND [POS_TERMINAL] = @CODE_ROUTE
			AND [IS_ACTIVE_ROUTE] = 1
		--
		UPDATE [SONDA].[SONDA_DEVOLUTION_INVENTORY_HEADER]
		SET 
			[LIQUIDATION_ID] = @LIQUIDATION_ID
			,[IS_ACTIVE_ROUTE] = 0
		WHERE [DEVOLUTION_ID] > 0
			AND [CODE_ROUTE] = @CODE_ROUTE
			AND [IS_ACTIVE_ROUTE] = 1 
		--
		UPDATE [SONDA].[SONDA_DEPOSITS]
		SET 
			[LIQUIDATION_ID] = @LIQUIDATION_ID
		WHERE [TRANS_ID] > 0
			AND [POS_TERMINAL] = @CODE_ROUTE
			AND [POSTED_DATETIME] > CAST(CONVERT(DATE,GETDATE()) AS DATETIME)
			AND [LIQUIDATION_ID] IS NULL
		--
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		--
		DECLARE @MESSAGE VARCHAR(250) = ERROR_MESSAGE()
		RAISERROR(@MESSAGE,16,1)
	END CATCH
END
