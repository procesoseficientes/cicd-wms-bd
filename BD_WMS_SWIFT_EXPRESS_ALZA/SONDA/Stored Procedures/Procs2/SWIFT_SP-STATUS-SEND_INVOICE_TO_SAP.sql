-- =============================================
--  Autor:		joel.delcompare
-- Fecha de Creacion: 	2016-03-18 21:37:44
-- Description:		marca como enviadas las ordenes de venta a SBO

-- Modificacion:  hector.gonzalez
-- Fecha:         2016-08-24
-- Descripcion:   Se modifico el tamaño del parametro POSTED_RESPONSE


-- Modificacion 24-Mar-17 @ A-Team Sprint Fenyang
					-- alberto.ruiz
					-- Cambia de estado el is sendig y la ultima actualizacion del is sending

-- Modificacion 5/29/2017 @ A-Team Sprint Jibade
					-- rodrigo.gomez
					-- Solo marca los pedidos como enviados cuando todo el detalle esta como enviado a SAP

/*
-- Ejemplo de Ejecucion:
  USE SWIFT_EXPRESS
GO

DECLARE @RC int
DECLARE @INVOICE_ID int
DECLARE @POSTED_RESPONSE varchar(150)
DECLARE @ERP_REFERENCE VARCHAR(256)

SET @INVOICE_ID = 0 
SET @POSTED_RESPONSE = '' 
SET @ERP_REFERENCE ='0'

EXECUTE @RC = [SONDA].[SWIFT_SP-STATUS-SEND_SO_TO_SAP] @INVOICE_ID
                                                    ,@POSTED_RESPONSE
                                                    ,@ERP_REFERENCE
GO

*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP-STATUS-SEND_INVOICE_TO_SAP]
	@INVOICE_ID INT
	,@POSTED_RESPONSE VARCHAR(4000)
	,@ERP_REFERENCE VARCHAR(256)
	,@OWNER VARCHAR(125) 
	--,@CUSTOMER_OWNER VARCHAR(125)
AS
BEGIN TRY
	SET NOCOUNT ON;
	--
	DECLARE	@ID NUMERIC(18, 0), @UNSENT_DETAIL INT = 0, @PARAMETER_OWNER VARCHAR(125);
	--
	SELECT @PARAMETER_OWNER = [SONDA].[SWIFT_FN_GET_PARAMETER]('SALES_ORDER_INTERCOMPANY','SEND_ALL_DETAIL')
	-- ------------------------------------------------------------------------------------
	-- Actualiza el IS_SENDING A 0
	-- ------------------------------------------------------------------------------------
	UPDATE [SONDA].[SONDA_POS_INVOICE_HEADER]
		SET	
			[IS_SENDING] = 0
			,[LAST_UPDATE_IS_SENDING] = GETDATE()
		WHERE [ID] = @INVOICE_ID;
	-- ------------------------------------------------------------------------------------
	-- Actualiza las lineas del inventario enviadas
	-- ------------------------------------------------------------------------------------
	--UPDATE [D]
	--SET	
	--	[D].[IS_POSTED_ERP] = 1
	--	,[D].[POSTED_ERP] = GETDATE()
	--	,[D].[POSTED_RESPONSE] = @POSTED_RESPONSE
	--	,[D].[ERP_REFERENCE] = @ERP_REFERENCE
	--	,[D].[INTERFACE_OWNER] = @OWNER
	--FROM [SONDA].[SONDA_SALES_ORDER_DETAIL] [D]	
	--	INNER JOIN [SONDA].[SWIFT_VIEW_ALL_SKU] [SKU] ON [SKU].[CODE_SKU] = [D].[SKU]
	--WHERE [INVOICE_ID] = @INVOICE_ID 
	--	AND ([SKU].[OWNER] = @OWNER OR (@OWNER = @PARAMETER_OWNER AND @OWNER = @CUSTOMER_OWNER));
	-- ------------------------------------------------------------------------------------
	-- Obtiene la cantidad de lineas aun no enviadas
	-- ------------------------------------------------------------------------------------
	--SELECT [D].[INVOICE_ID] INTO [#TEMP] FROM [SONDA].[SONDA_SALES_ORDER_DETAIL] [D] WHERE ISNULL([D].[IS_POSTED_ERP], 0) = 0 AND [D].[INVOICE_ID] = @INVOICE_ID
	
	SELECT @UNSENT_DETAIL = 0
	-- ------------------------------------------------------------------------------------
	-- Actualiza el encabezado del pedido si todo el detalle fue enviado a SAP.
	-- ------------------------------------------------------------------------------------
	IF @UNSENT_DETAIL = 0
	BEGIN
		UPDATE [SONDA].[SONDA_POS_INVOICE_HEADER]
		SET	
			[IS_POSTED_ERP] = 1
			,[POSTED_ERP] = GETDATE()
			,[POSTED_RESPONSE] = @POSTED_RESPONSE
			,[ERP_REFERENCE] = @ERP_REFERENCE
		WHERE [ID] = @INVOICE_ID;
	END
	---- ------------------------------------------------------------------------------------
	---- Inserta en el LOG
	---- ------------------------------------------------------------------------------------
	--INSERT	INTO [SONDA].[SWIFT_SEND_SO_ERP_LOG]
	--		(
	--			[INVOICE_ID]
	--			,[ATTEMPTED_WITH_ERROR]
	--			,[IS_POSTED_ERP]
	--			,[POSTED_ERP]
	--			,[POSTED_RESPONSE]
	--			,[ERP_REFERENCE]
	--		)
	--VALUES
	--		(
	--			@INVOICE_ID
	--			,NULL
	--			,1
	--			,GETDATE()
	--			,@POSTED_RESPONSE
	--			,@ERP_REFERENCE
	--		);
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
