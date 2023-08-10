-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	31-Mar-17 @ A-TEAM Sprint Garai 
-- Description:			SP que rebaja el inventario por una factura

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_DECREASE_INVENTORY_BY_INVOICE]
					@ID = 407
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_DECREASE_INVENTORY_BY_INVOICE](
	@ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @INVOICE_DETAIL TABLE (
		[CODE_SKU] VARCHAR(50) NOT NULL
		,[QTY] NUMERIC(18,2) NOT NULL
		,[SERIE] VARCHAR(50)
		,[REQUERIES_SERIE] INT NOT NULL DEFAULT(0)
		,[ID] INT NOT NULL
	)
	--
	DECLARE @INVENTORY TABLE (
		[INVENTORY] INT
		,[ON_HAND] NUMERIC(18,2)
	)
	--
	DECLARE 
		@LOGIN VARCHAR(50)
		,@CODE_WAREHOUSE VARCHAR(50)
		,@CODE_SKU VARCHAR(50)
		,@QTY NUMERIC(18,2)
		,@INVENTORY_ID INT
		,@ON_HAND NUMERIC(18,2)
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene quien realizo la factura
	-- ------------------------------------------------------------------------------------
	SELECT @LOGIN = [H].[POSTED_BY]
	FROM [SONDA].[SONDA_POS_INVOICE_HEADER] [H]
	WHERE [H].[ID] = @ID

	-- ------------------------------------------------------------------------------------
	-- Obtiene la bodega de venta directa del usuario
	-- ------------------------------------------------------------------------------------
	SELECT @CODE_WAREHOUSE = [U].[DEFAULT_WAREHOUSE]
	FROM [SONDA].[USERS] [U]
	WHERE [U].[LOGIN] = @LOGIN

	-- ------------------------------------------------------------------------------------
	-- Obtiene el detalle de la factura
	-- ------------------------------------------------------------------------------------
	INSERT INTO @INVOICE_DETAIL
			(
				[CODE_SKU]
				,[QTY]
				,[SERIE]
				,[REQUERIES_SERIE]
				,[ID]
			)
	SELECT
		[D].[SKU]
		,[D].[QTY]
		,[D].[SERIE]
		,[D].[REQUERIES_SERIE]
		,[D].[ID]
	FROM [SONDA].[SONDA_POS_INVOICE_DETAIL] [D]
	WHERE [D].[ID] = @ID

	-- ------------------------------------------------------------------------------------
	-- Se rebaja del inventario los productos que manejan serie
	-- ------------------------------------------------------------------------------------
	UPDATE [I]
	SET [I].[ON_HAND] = [I].[ON_HAND] - [D].[QTY]
	FROM [SONDA].[SWIFT_INVENTORY] [I]
	INNER JOIN @INVOICE_DETAIL [D] ON (
		[I].[SKU] = [D].[CODE_SKU]
		AND [I].[SERIAL_NUMBER] = [D].[SERIE]
	)
	WHERE [I].[WAREHOUSE] = @CODE_WAREHOUSE
		AND [D].[REQUERIES_SERIE] = 1

	-- ------------------------------------------------------------------------------------
	-- Se eliminan los productos que manejan serie
	-- ------------------------------------------------------------------------------------
	DELETE FROM @INVOICE_DETAIL WHERE [REQUERIES_SERIE] = 1

	-- ------------------------------------------------------------------------------------
	-- Recorremos los productos que no manejan serie
	-- ------------------------------------------------------------------------------------
	WHILE EXISTS(SELECT TOP 1 1 FROM @INVOICE_DETAIL)
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Obtiene el detalle a operar
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@CODE_SKU = [D].[CODE_SKU]
			,@QTY = [D].[QTY]
		FROM @INVOICE_DETAIL [D]

		-- ------------------------------------------------------------------------------------
		-- Obtiene las lineas del inventario
		-- ------------------------------------------------------------------------------------
		INSERT INTO @INVENTORY
		SELECT
			[I].[INVENTORY]
			,[I].[ON_HAND]
		FROM [SONDA].[SWIFT_INVENTORY] [I]
		WHERE [I].[WAREHOUSE] = @CODE_WAREHOUSE
			AND [I].[SKU] = @CODE_SKU
			AND [I].[ON_HAND] > 0

		WHILE EXISTS(SELECT TOP 1 1 FROM @INVENTORY)
		BEGIN
			-- ------------------------------------------------------------------------------------
			-- Obtiene la linea del invenario a operar
			-- ------------------------------------------------------------------------------------
			SELECT TOP 1
				@INVENTORY_ID = [I].[INVENTORY]
				,@ON_HAND = [I].[ON_HAND]
			FROM @INVENTORY [I]

			-- ------------------------------------------------------------------------------------
			-- Valida si es suficiente la cantidad
			-- ------------------------------------------------------------------------------------
			IF(@ON_HAND >= @QTY)
			BEGIN
				UPDATE [SONDA].[SWIFT_INVENTORY]
				SET [ON_HAND] = (@ON_HAND - @QTY)
				WHERE [INVENTORY] = @INVENTORY_ID
				--
				DELETE FROM @INVENTORY
				--
				SET @QTY = 0
			END
			ELSE
			BEGIN
				UPDATE [SONDA].[SWIFT_INVENTORY]
				SET [ON_HAND] = 0
				WHERE [INVENTORY] = @INVENTORY_ID
				--
				SET @QTY = @QTY - @ON_HAND
				--
				DELETE FROM @INVENTORY WHERE [INVENTORY] = @INVENTORY_ID
			END
		END
		--
		IF (@QTY > 0)
		BEGIN
			PRINT '--> SONDA_SP_COMMIT_INVENTORY_BY_INVOICE: Quedo la cantidad de ' + CAST(@QTY AS VARCHAR) + ' para descontar del SKU ' + @CODE_SKU + ' en la facutra ID ' + CAST(@ID AS VARCHAR)
		END

		-- ------------------------------------------------------------------------------------
		-- Eliminamos el detalle operado
		-- ------------------------------------------------------------------------------------
		DELETE FROM @INVOICE_DETAIL WHERE [CODE_SKU] = @CODE_SKU
	END
END
