-- =============================================
-- Author:		rudi.garcia
-- Create date: 20-02-2016
-- Description:	Obtiene la cuenta corriente del cliente

/*
-- Ejemplo de Ejecucion:
		--
        EXEC [SONDA].SONDA_SP_GET_CURRENT_ACCOUNT_BY_CUSTOMER @CODE_COSTUMER = '1', @CURRENT_AMOUT_PAYMENT = 1500, @CODE_ROUTE = 'rudi@SONDA'
*/

-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_CURRENT_ACCOUNT_BY_CUSTOMER]	
	@CODE_COSTUMER VARCHAR(50)	
	,@CURRENT_AMOUT_PAYMENT FLOAT
	,@SALES_ORDER_TYPE VARCHAR(250) = 'CREDIT'
	,@CODE_ROUTE VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	--
	CREATE TABLE #CURRENT_ACCOUNT(
		CODE_RULE VARCHAR(20)
		, DESCRIPTION_RULE VARCHAR(200)
	)

	CREATE TABLE #INVOICE(		
		DOC_TOTAL FLOAT
		,PAID_TO_DATE FLOAT
		,DOC_DUE_DATE DATETIME
		,CARD_CODE VARCHAR(50)
		,DOC_DATE DATETIME
	)
	--
	DECLARE 
		@CURRENT_TOTAL_AMOUNT_INVOICE FLOAT = 0.00
		,@CREDIT_LIMIT FLOAT = 0
		,@EXTRA_DAYS INT = 0
		,@IS_CASH INT = 0

	-- ------------------------------------------------------------------------------------
	-- Verifica si esta activa la regla de antiguedad de saldos
	-- ------------------------------------------------------------------------------------
	IF ([SONDA].[SWIFT_FN_VALIDATE_EVENT_FOR_ROUTE]('NoValidarAntiguedadDeSaldos',@CODE_ROUTE) = 1)
	BEGIN
		GOTO ENDSP
	END
	
	-- ----------------------------------------------------------------------------------
	-- Se verifica si @SALES_TYPE es igual al parametro CASH de la tabla PARAMETERS 
	-- ----------------------------------------------------------------------------------
	IF(@SALES_ORDER_TYPE = 'CREDIT')
	BEGIN
		SET @IS_CASH = 0
	END
	ELSE
	BEGIN
		IF (@SALES_ORDER_TYPE = (SELECT [SONDA].[SWIFT_FN_GET_PARAMETER]('SALES_ORDER_TYPE','CASH' )))
		BEGIN
			SET @IS_CASH = 1
		END
	END

	-- ----------------------------------------------------------------------------------
	-- Se obtiene el limite de credito del cliente
	-- ----------------------------------------------------------------------------------	
	PRINT('Se obtiene el limite de credito del cliente');
	--
	SELECT TOP 1 
		@CREDIT_LIMIT = ISNULL([CREDIT_LIMIT],0)
		,@EXTRA_DAYS = ISNULL([EXTRA_DAYS],0)
	FROM [SONDA].[SWIFT_VIEW_ALL_COSTUMER]
	WHERE [CODE_CUSTOMER] = @CODE_COSTUMER

	-- ----------------------------------------------------------------------------------
	-- Se inserta en una tabla temporal las facturas activas del cliente
	-- ----------------------------------------------------------------------------------
	PRINT('Se inserta en una tabla temporal las facturas activas del cliente');
	INSERT INTO #INVOICE
	EXEC [SONDA].SONDA_SP_GET_INVOICE_ACTIVE_BY_COSTUMER @CODE_COSTUMER

	-- ----------------------------------------------------------------------------------
	-- Se obtiene el total de las facturas activas
	-- ----------------------------------------------------------------------------------
	PRINT('Se obtiene el total de las facturas activas');
	PRINT(@CURRENT_TOTAL_AMOUNT_INVOICE)
	SELECT @CURRENT_TOTAL_AMOUNT_INVOICE = ISNULL(SUM(I.DOC_TOTAL),0)
	FROM #INVOICE I
	PRINT(@CURRENT_TOTAL_AMOUNT_INVOICE)

	-- -----------------------------------------------------------------------------------------
	-- Si @IS_CASH es 1 (Venta al Contado) no se valida el limite de credito ni sus dependencias
	-- De lo Contrario si @IS_CASH es 0 (Venta al Credito) se valida el limite de credito
	-- -----------------------------------------------------------------------------------------	
	IF @IS_CASH = 0
	BEGIN
		-- ------------------------------------------------------------------------------
		-- Se valida si el limite de credito es 0
		-- ------------------------------------------------------------------------------
		PRINT('Se valida si el limite de credito es 0 y los dias de credito')	
		IF @CREDIT_LIMIT = 0 
		BEGIN
			INSERT INTO #CURRENT_ACCOUNT
			VALUES('1', 'El cliente no tiene configurado el límite de crédito')
		END	

		-- ----------------------------------------------------------------------------------
		-- Se valida si los dias de credito es 0
		-- ----------------------------------------------------------------------------------		
		ELSE IF @EXTRA_DAYS = 0
		BEGIN
			INSERT INTO #CURRENT_ACCOUNT
			VALUES('2', 'El cliente no tiene configurado la cantidad de días de crédito')
		END
		ELSE BEGIN
		
			-- ----------------------------------------------------------------------------------
			-- Se valida si tiene una factura emitida que ya vencieron los dias de credito
			-- ----------------------------------------------------------------------------------
			PRINT('Se valida si el limite de credito es 0 y los dias de credito')	
			IF GETDATE() >= (SELECT TOP 1 DATEADD(day, @EXTRA_DAYS, DOC_DATE) FROM #INVOICE ORDER BY DOC_DATE)
			BEGIN
				INSERT INTO #CURRENT_ACCOUNT
				VALUES('3', 'Tiene una factura emitida que ya vencieron los días de crédito')
			END		
		
			-- ----------------------------------------------------------------------------------
			-- Se valida si total de la venta no sobrepase el limite de credito  junto al total de las facturas activas
			-- ----------------------------------------------------------------------------------	
			PRINT('Se valida si total de la venta no sobrepase el limite de credito  junto al total de las facturas activas')				
			IF @CREDIT_LIMIT >= (@CURRENT_AMOUT_PAYMENT + @CURRENT_TOTAL_AMOUNT_INVOICE) 
			BEGIN
				-- ----------------------------------------------------------------------------------
				-- Se valida si tiene facturas vencidas 
				-- ----------------------------------------------------------------------------------
				PRINT('Se valida si tiene facturas vencidas ');
				IF 0 <> (SELECT COUNT(*) FROM #INVOICE WHERE GETdATE() > DOC_DUE_DATE) 
				BEGIN 			
					INSERT INTO #CURRENT_ACCOUNT
					VALUES('4', 'Tiene Facturas Vencidas')
				END
			END
			ELSE BEGIN			
				INSERT INTO #CURRENT_ACCOUNT
				VALUES('5', 'El Crédito es insuficiente')
			END
		END	

	END

	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	ENDSP:
	--
	SELECT 
		[CODE_RULE]
		,[DESCRIPTION_RULE]
	FROM [#CURRENT_ACCOUNT]
END
