-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	5/19/2017 @ A-TEAM Sprint  
-- Description:			Valida si el documento de factura a insertar existe en el BO

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_VALIDATE_IF_EXISTS_INVOICE_DOCUMENT]
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_VALIDATE_IF_EXISTS_INVOICE_DOCUMENT(
	@CODE_ROUTE VARCHAR(50)
	,@CODE_CUSTOMER VARCHAR(50)
	,@DOC_RESOLUTION VARCHAR(100)
	,@DOC_SERIE VARCHAR(100)
	,@DOC_NUM INT
	,@POSTED_DATETIME DATETIME
	,@DETAIL_QTY INT
	,@DECREASE_INVENTORY INT
	,@ID_BO INT = NULL	
	,@XML XML
	,@JSON VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
	--
	DECLARE 
		@EXISTS INT = 0
		,@ID INT
		,@INSERT INT = 0
		,@DETAIL_QTY_IN_DB INT = 0
	--
	SELECT TOP 1
		@EXISTS = 1
		,@ID = H.[ID]
	FROM [SONDA].[SONDA_POS_INVOICE_HEADER] [H] WITH(ROWLOCK,XLOCK,HOLDLOCK)
	WHERE [H].[POS_TERMINAL] = @CODE_ROUTE
		AND [H].[CLIENT_ID] = @CODE_CUSTOMER
		AND [H].[CDF_RESOLUCION] = @DOC_RESOLUTION
		AND [H].[CDF_SERIE] = @DOC_SERIE
		AND [H].[INVOICE_ID] = @DOC_NUM
		AND [H].[IS_READY_TO_SEND] = 1
	GROUP BY [H].[ID];

	IF @EXISTS = 1
	BEGIN
		GOTO EXISTE;
	END
	ELSE
	BEGIN
		SELECT TOP 1
			@EXISTS = 1
			,@ID = [H].[ID]
			,@DETAIL_QTY_IN_DB = COUNT([D].[ID])
		FROM [SONDA].[SONDA_POS_INVOICE_HEADER] [H] WITH(ROWLOCK,XLOCK,HOLDLOCK)
		INNER JOIN [SONDA].[SONDA_POS_INVOICE_DETAIL] [D] ON ([H].[ID] = [D].[ID])
		WHERE [H].[ID] = @ID_BO
		GROUP BY [H].[ID];
	END
	-- ------------------------------------------------------------------------------------
	-- Valida el resultado
	-- ------------------------------------------------------------------------------------
	IF @EXISTS = 1 AND @DETAIL_QTY != @DETAIL_QTY_IN_DB
	BEGIN
		PRINT 'No Existe'
		--
		SET @EXISTS = 0
		--
		GOTO EXISTE;
	END

	-- ------------------------------------------------------------------------------------
	-- Valida si debe de reservar el inventario y colocar como lisa la orden de venta
	-- ------------------------------------------------------------------------------------
	IF (@DECREASE_INVENTORY = 1)
	BEGIN
		BEGIN TRY
			BEGIN TRAN
			--
			EXEC [SONDA].[SONDA_SP_DECREASE_INVENTORY_BY_INVOICE] @ID = @ID
			--
			UPDATE [SONDA].[SONDA_POS_INVOICE_HEADER]
			SET [IS_READY_TO_SEND] = 1
			WHERE [ID] = @ID
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

	EXISTE:
--	-- ------------------------------------------------------------------------------------
--	-- Inserta el log
--	-- ------------------------------------------------------------------------------------
--	EXEC [SONDA].[SONDA_SP_INSERT_INVOICE_LOG_EXISTS]		
--		@EXISTS_INVOICE = @EXISTS, -- int
--		@DOC_RESOLUTION = @DOC_RESOLUTION, -- varchar(100)
--		@DOC_SERIE = @DOC_SERIE, -- varchar(100)
--		@DOC_NUM = @DOC_NUM, -- int
--		@CODE_ROUTE = @CODE_ROUTE, -- varchar(50)
--		@CODE_CUSTOMER = @CODE_CUSTOMER, -- varchar(50)
--		@POSTED_DATETIME = @POSTED_DATETIME, -- datetime
--		@XML = @XML, -- xml
--		@JSON = @JSON -- varchar(max)



	-- ------------------------------------------------------------------------------------
	-- Muestra resultado
	-- ------------------------------------------------------------------------------------
	SELECT 
		@EXISTS AS [EXISTS]
		,@ID AS [ID]
		,@DOC_RESOLUTION [DOC_RESOLUTION]
		,@DOC_SERIE [DOC_SERIE]
		,@DOC_NUM [DOC_NUM]
END
