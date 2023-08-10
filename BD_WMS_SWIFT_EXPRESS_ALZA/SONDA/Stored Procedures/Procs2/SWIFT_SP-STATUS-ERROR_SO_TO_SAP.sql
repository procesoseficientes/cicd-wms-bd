-- =============================================
  -- MODIFICADO: 04-05-2016
		--hector.gonzalez
		-- Se subio el tamaño al campo POSTED_RESPONSE

-- Modificacion 24-Mar-17 @ A-Team Sprint Fenyang
					-- alberto.ruiz
					-- Cambia de estado el is sendig y la ultima actualizacion del is sending

-- Modificacion 5/29/2017 @ A-Team Sprint Jibade
					-- rodrigo.gomez
					-- Actualiza el detalle y lo marca como errado
/*
-- Ejemplo de Ejecucion:
				-- 	
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP-STATUS-ERROR_SO_TO_SAP] (
	@SALES_ORDER_ID INT
	,@POSTED_RESPONSE VARCHAR(4000)
	,@OWNER VARCHAR(125)
	,@CUSTOMER_OWNER VARCHAR(125)
) AS
BEGIN TRY
	SET NOCOUNT ON;
	--
	DECLARE	@ID NUMERIC(18, 0), @PARAMETER_OWNER VARCHAR(125);
	--
	SELECT @PARAMETER_OWNER = [SONDA].[SWIFT_FN_GET_PARAMETER]('SALES_ORDER_INTERCOMPANY','SEND_ALL_DETAIL')
	-- ------------------------------------------------------------------------------------
	-- Actualiza el detalle y lo marca con error
	-- ------------------------------------------------------------------------------------
	UPDATE [D]
	SET	
		[D].[POSTED_RESPONSE] = @POSTED_RESPONSE
		,[ATTEMPTED_WITH_ERROR] = ISNULL([ATTEMPTED_WITH_ERROR],0) + 1
		,[D].[INTERFACE_OWNER] = @OWNER
	FROM [SONDA].[SONDA_SALES_ORDER_DETAIL] [D]	
		INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [SKU] ON [SKU].[CODE_SKU] = [D].[SKU]
	WHERE [SALES_ORDER_ID] = @SALES_ORDER_ID 
		AND ([SKU].[OWNER] = @OWNER OR (@OWNER = @PARAMETER_OWNER AND @OWNER = @CUSTOMER_OWNER));
	-- ------------------------------------------------------------------------------------
	-- Actualiza el encabezado y lo marca con error
	-- ------------------------------------------------------------------------------------
	UPDATE [SONDA].[SONDA_SALES_ORDER_HEADER]
	SET	
		[ATTEMPTED_WITH_ERROR] = [ATTEMPTED_WITH_ERROR] + 1
		,[POSTED_RESPONSE] = @POSTED_RESPONSE
		,[IS_SENDING] = 0
		,[LAST_UPDATE_IS_SENDING] = GETDATE()
	WHERE [SALES_ORDER_ID] = @SALES_ORDER_ID;
	--
	INSERT	INTO [SONDA].[SWIFT_SEND_SO_ERP_LOG]
			(
				[SALES_ORDER_ID]
				,[ATTEMPTED_WITH_ERROR]
				,[IS_POSTED_ERP]
				,[POSTED_ERP]
				,[POSTED_RESPONSE]
				,[ERP_REFERENCE]
			)
	VALUES
			(
				@SALES_ORDER_ID
				,1
				,0
				,GETDATE()
				,@POSTED_RESPONSE
				,NULL
			);
	--
	SELECT
		1 AS [Resultado]
		,'Proceso Exitoso' [Mensaje]
		,0 [Codigo]
		,CONVERT(VARCHAR(50), @ID) [DbData];
END TRY
BEGIN CATCH     
	SELECT
		-1 AS [Resultado]
		,ERROR_MESSAGE() [Mensaje]
		,@@ERROR [Codigo]; 
END CATCH;
