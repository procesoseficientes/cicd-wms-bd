-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	01-15-2016
-- Description:			obiene las ultimas 5 facturas creadas que no hayan sido enviadas hacia el ERP

-- Modificado Fecha
		-- anonymous
		-- sin motivo

-- Modificado 20-07-2016 Sprint η
    -- rudi.garcia
    -- Se agrego el centro de costo y el tipo de pago

-- Modificado 23-01-2017 @ TEAM-A Sprint Bankole
    -- diego.as
    -- Se agrego parametro @SHIPPING_ATTEMPTS para obtener unicamente los registros
	-- que no sobrepasen los intentos de envio que estan parametrizados en la BD.
	-- Ademas, se quita del WHERE el campo ATTEMPTED_WITH_ERROR por lo descrito anteriormente.

	-- Modificacion 3/23/2017 @ A-Team Sprint Fenyang
						-- diego.as
						-- Se modifica el campo POS_TERMINAL para que envie el valor del campo RELATED_SELLER de la tabla de usuarios.

	-- Modificacion 4/4/2017 @ A-Team Sprint Garai
						-- rodrigo.gomez
						-- Se agregaron las nuevas validaciones para obtener el top 5 solo de los que esten validados y listos para enviar

/*
-- Ejemplo de Ejecucion:
      USE SWIFT_EXPRESS
      GO
      
      DECLARE @RC int
      
      EXECUTE @RC = [SONDA].SWIFT_SP_GET_TOP5_INVOICE_HEADER
      GO
*/
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_TOP5_INVOICE_HEADER]
AS
BEGIN
	--
	DECLARE @INVOICE TABLE (
		[INVOICE_ID] INT
	)
	--
	DECLARE
		@INTERFACE_PAYMENT_TYPE VARCHAR(100) = '14'
		,@SHIPPING_ATTEMPTS VARCHAR(100);

	-- ------------------------------------------------------------------------------------
	-- Obtiene los parametros necesarios
	-- ------------------------------------------------------------------------------------
	
	SELECT
		@INTERFACE_PAYMENT_TYPE = [SONDA].[SWIFT_FN_GET_PARAMETER]('INVOICE' , 'INTERFACE_PAYMENT_TYPE')
		,@SHIPPING_ATTEMPTS = [SONDA].[SWIFT_FN_GET_PARAMETER]('INVOICE' , 'SHIPPING_ATTEMPTS');

	-- ------------------------------------------------------------------------------------
	-- Obtiene facturas para enviar
	-- ------------------------------------------------------------------------------------
	
	INSERT INTO @INVOICE
	SELECT TOP 5
		[SPIH].[ID]
	FROM [SONDA].[SONDA_POS_INVOICE_HEADER] [SPIH]
	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [SVAC] ON ([SPIH].[CLIENT_ID] = [SVAC].[CODE_CUSTOMER])
	WHERE ISNULL([IS_POSTED_ERP], 0) = 0
		AND ISNULL([SPIH].[VOIDED_INVOICE], 0) = 0
		AND ISNULL([SPIH].[IS_DRAFT], 0) = 0
		AND [SPIH].[IS_READY_TO_SEND] = 1
		AND SPIH.TOTAL_AMOUNT= (SELECT SUM([OD].[TOTAL_LINE]) FROM [SONDA].[SONDA_POS_INVOICE_DETAIL] [OD] WHERE [OD].[ID]=[SPIH].[ID])
		AND [SPIH].[IS_SENDING] = 0
		AND (ISNULL([SPIH].ATTEMPTED_WITH_ERROR,0) < CAST(@SHIPPING_ATTEMPTS AS INT))
		AND [SPIH].[POSTED_DATETIME] >= FORMAT(GETDATE(),'yyyyMMdd')
	ORDER BY 
		[SPIH].[ATTEMPTED_WITH_ERROR] ASC
		,[SPIH].[POSTED_DATETIME] ASC;

	-- ------------------------------------------------------------------------------------
	-- Las coloca como enviando
	-- ------------------------------------------------------------------------------------

	UPDATE [SIH]
	SET
		[SIH].[IS_SENDING] = 1
		,[SIH].[LAST_UPDATE_IS_SENDING] = GETDATE()
	FROM [SONDA].[SONDA_POS_INVOICE_HEADER] [SIH]
		INNER JOIN @INVOICE [IV] ON ([IV].[INVOICE_ID] = [SIH].[ID])
	WHERE [SIH].[ID] > 0

	-- ------------------------------------------------------------------------------------
	-- Obtiene la factura
	-- ------------------------------------------------------------------------------------
	
	SELECT DISTINCT TOP 5
		[spih].[INVOICE_ID]
		,[spih].[TERMS]
		,[spih].[POSTED_DATETIME]
		,[spih].[CLIENT_ID]
		--,spih.POS_TERMINAL
		,[u].[RELATED_SELLER] AS [POS_TERMINAL]
		,[spih].[GPS_URL]
		,CASE [spih].[IS_CREDIT_NOTE]
			WHEN 1 THEN 0
			ELSE CAST([spih].[TOTAL_AMOUNT] AS DECIMAL)
			END AS [TOTAL_AMOUNT]
		,[spih].[STATUS]
		,[spih].[POSTED_BY]
		,'' [IMAGE_1]
		,'' [IMAGE_2]
		,'' [IMAGE_3]
		,[spih].[IS_POSTED_OFFLINE]
		,[spih].[INVOICED_DATETIME]
		,[spih].[DEVICE_BATTERY_FACTOR]
		,[spih].[CDF_INVOICENUM]
		,[spih].[CDF_DOCENTRY]
		,[spih].[CDF_SERIE]
		,[spih].[CDF_NIT]
		,[spih].[CDF_NOMBRECLIENTE]
		,[spih].[CDF_RESOLUCION]
		,[spih].[CDF_POSTED_ERP]
		,[spih].[IS_CREDIT_NOTE]
		,[spih].[VOID_DATETIME]
		,[spih].[CDF_PRINTED_COUNT]
		,[spih].[VOID_REASON]
		,[spih].[VOID_NOTES]
		,[spih].[VOIDED_INVOICE]
		,[spih].[CLOSED_ROUTE_DATETIME]
		,[spih].[CLEARING_DATETIME]
		,[spih].[IS_ACTIVE_ROUTE]
		,[spih].[SOURCE_CODE]
		,[spih].[GPS_EXPECTED]
		,[spih].[ATTEMPTED_WITH_ERROR]
		,[spih].[IS_POSTED_ERP]
		,[spih].[POSTED_ERP]
		,[spih].[POSTED_RESPONSE]
		,[sw].[ERP_WAREHOUSE]
		,[CCW].[WhsCode] COLLATE SQL_Latin1_General_CP1_CI_AS AS [COST_CENTER]
		,@INTERFACE_PAYMENT_TYPE AS [INTERFACE_PAYMENT_TYPE]
		,[spih].[ID]
	FROM
		[SONDA].[SONDA_POS_INVOICE_HEADER] [spih] 
		INNER JOIN @INVOICE [IV] ON [IV].[INVOICE_ID] = [spih].[ID]
		INNER JOIN [SONDA].[SWIFT_ROUTES] [sr] ON	([spih].[POS_TERMINAL] = [sr].[CODE_ROUTE])
		INNER JOIN [SONDA].[USERS] [u] ON	([u].[SELLER_ROUTE] = [sr].[CODE_ROUTE])
		INNER JOIN [SONDA].[SWIFT_WAREHOUSES] [sw] ON	([u].[DEFAULT_WAREHOUSE] = [sw].[CODE_WAREHOUSE])
		INNER JOIN [SONDA].[SWIFT_VIEW_ALL_COSTUMER] [svac] ON	([spih].[CLIENT_ID] = [svac].[CODE_CUSTOMER])
		LEFT JOIN [SONDA].[SWIFT_VIEW_COST_CENTER_BY_WAREHOUSE] [CCW] ON	([sw].[CODE_WAREHOUSE] = [CCW].[Descr] COLLATE SQL_Latin1_General_CP1_CI_AS)
	ORDER BY
		([spih].[ATTEMPTED_WITH_ERROR]) ASC
		,[spih].[POSTED_DATETIME] ASC
END;
