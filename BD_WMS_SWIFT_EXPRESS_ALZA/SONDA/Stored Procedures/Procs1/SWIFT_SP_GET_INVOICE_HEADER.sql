-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	01-15-2016
-- Description:			Obtiene el encabezado de una factura

-- Modificado Fecha
		-- anonymous
		-- sin motivo

-- Modificado 20-07-2016 Sprint η
    -- rudi.garcia
    -- Se agrego el centro de costo y el tipo de pago

-- Modificacion 08-Nov-16 @ A-Team Sprint 4
					-- alberto.ruiz
					-- Se agregaron campos de las imagenes

/*
-- Ejemplo de Ejecucion:
    USE SWIFT_EXPRESS
    GO
    
    DECLARE @RC int
    DECLARE @idFactura int
    
    SET @idFactura = 0 
    
    EXECUTE @RC = [SONDA].SWIFT_SP_GET_INVOICE_HEADER @idFactura
    GO
*/
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_INVOICE_HEADER]
	(
		@INVOICE_ID INT
		,@CDF_SERIE VARCHAR(50)
		,@CDF_RESOLUCION NVARCHAR(50)
		,@IS_CREDIT_NOTE INT 
	)
AS
	BEGIN
  -- ------------------------------------------------------------------------------------
  -- 
  -- ------------------------------------------------------------------------------------
		DECLARE	@INTERFACE_PAYMENT_TYPE VARCHAR(100) = '14';

  -- ------------------------------------------------------------------------------------
  -- Obtiene los parametros necesarios
  -- ------------------------------------------------------------------------------------
		SELECT
			@INTERFACE_PAYMENT_TYPE = [SONDA].[SWIFT_FN_GET_PARAMETER]('INVOICE' ,
																'INTERFACE_PAYMENT_TYPE');

		SELECT
			[spih].[INVOICE_ID]
			,[spih].[TERMS]
			,[spih].[POSTED_DATETIME]
			,[spih].[CLIENT_ID]
			,[spih].[POS_TERMINAL]
			,[spih].[GPS_URL]
			,CASE [spih].[IS_CREDIT_NOTE]
				WHEN 1 THEN 0
				ELSE CAST([spih].[TOTAL_AMOUNT] AS DECIMAL)
				END AS [TOTAL_AMOUNT]
			,[spih].[STATUS]
			,[spih].[POSTED_BY]
			,[spih].[IMAGE_1]
			,[spih].[IMAGE_2]
			,[spih].[IMAGE_3]
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
			,[CCW].[WhsCode] /*COLLATE SQL_Latin1_General_CP1_CI_AS AS */[COST_CENTER]
			,@INTERFACE_PAYMENT_TYPE AS [INTERFACE_PAYMENT_TYPE]
		FROM [SONDA].[SONDA_POS_INVOICE_HEADER] [spih]
		INNER JOIN [SONDA].[SWIFT_ROUTES] [sr]
		ON	([spih].[POS_TERMINAL] = [sr].[CODE_ROUTE])
		INNER JOIN [SONDA].[USERS] [u]
		ON	([u].[SELLER_ROUTE] = [sr].[CODE_ROUTE])
		INNER JOIN [SONDA].[SWIFT_WAREHOUSES] [sw]
		ON	([u].[DEFAULT_WAREHOUSE] = [sw].[CODE_WAREHOUSE])
		INNER JOIN [SONDA].[SWIFT_VIEW_COST_CENTER_BY_WAREHOUSE] [CCW]
		ON	([sw].[CODE_WAREHOUSE] = [CCW].[Descr] COLLATE SQL_Latin1_General_CP1_CI_AS)
		WHERE [spih].[INVOICE_ID] = @INVOICE_ID
			AND [spih].[CDF_SERIE] = @CDF_SERIE
			AND [spih].[CDF_RESOLUCION] = @CDF_RESOLUCION
			AND [spih].[IS_CREDIT_NOTE] = @IS_CREDIT_NOTE
		ORDER BY ([POSTED_DATETIME]) ASC;
	END;
