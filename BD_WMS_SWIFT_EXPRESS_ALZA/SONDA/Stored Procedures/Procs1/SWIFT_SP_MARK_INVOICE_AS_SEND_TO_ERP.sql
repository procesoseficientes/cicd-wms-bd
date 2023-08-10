-- =============================================
-- Autor:				joel.delcompare
-- Fecha de Creacion: 	01-15-2016
-- Description:			marca una factura como envida resultado del proceso exitoso de envio hacia el ERP

-- Modificado 2016-07-14
		-- joel.delcompare
		-- Se agrego el parametro erp_reference 

-- Modificacion 04-Apr-17 @ A-Team Sprint Garai
					-- alberto.ruiz
					-- Se agrego log

/*
-- Ejemplo de Ejecucion:
        USE SWIFT_EXPRESS
        GO
        
        DECLARE @RC int
        DECLARE @INVOICE_ID int
        DECLARE @IS_CREDIT_NOTE int
        DECLARE @POSTED_RESPONSE varchar(150)
        DECLARE @ERP_REFERENCE varchar(256)
        
        SET @INVOICE_ID = 0 
        SET @POSTED_RESPONSE = '' 
        SET @ERP_REFERENCE ='0'
        
        EXECUTE @RC = [SONDA].SWIFT_SP_MARK_INVOICE_AS_SEND_TO_ERP @INVOICE_ID
                                                                ,@POSTED_RESPONSE
                                                                ,@ERP_REFERENCE
        GO
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_MARK_INVOICE_AS_SEND_TO_ERP] (
		@INVOICE_ID INT
		,@CDF_SERIE VARCHAR(50)
		,@CDF_RESOLUCION NVARCHAR(50)
		,@IS_CREDIT_NOTE INT
		,@POSTED_RESPONSE VARCHAR(150)
		,@ERP_REFERENCE VARCHAR(256)
	)
AS
BEGIN
	BEGIN TRY
		DECLARE
			@ID INT
			,@ATTEMPTED_WITH_ERROR INT;
		--
		UPDATE [SONDA_POS_INVOICE_HEADER]
		SET	
			[IS_POSTED_ERP] = 1
			,[POSTED_ERP] = GETDATE()
			,[POSTED_RESPONSE] = @POSTED_RESPONSE
			,[ERP_REFERENCE] = @ERP_REFERENCE
			,[IS_SENDING] = 0
			,[LAST_UPDATE_IS_SENDING] = GETDATE()
		WHERE [ID] > 0
			AND [INVOICE_ID] = @INVOICE_ID
			AND [CDF_SERIE] = @CDF_SERIE
			AND [CDF_RESOLUCION] = @CDF_RESOLUCION
			AND [IS_CREDIT_NOTE] = @IS_CREDIT_NOTE
			AND [IS_READY_TO_SEND] = 1;
		--
		SELECT TOP 1
			@ID = [ID]
			,@ATTEMPTED_WITH_ERROR = [ATTEMPTED_WITH_ERROR]
		FROM [SONDA].[SONDA_POS_INVOICE_HEADER]
		WHERE
			[ID] > 0
			AND [INVOICE_ID] = @INVOICE_ID
			AND [CDF_SERIE] = @CDF_SERIE
			AND [CDF_RESOLUCION] = @CDF_RESOLUCION
			AND [IS_CREDIT_NOTE] = @IS_CREDIT_NOTE
			AND [IS_READY_TO_SEND] = 1;
		--
		EXEC [SONDA].[SWIFT_SP_INSERT_INVOICE_ERP_LOG] 
			@ID = @ID, -- int
			@ATTEMPTED_WITH_ERROR = @ATTEMPTED_WITH_ERROR, -- int
			@IS_POSTED_ERP = 1, -- int
			@POSTED_RESPONSE = @POSTED_RESPONSE, -- varchar(150)
			@ERP_REFERENCE = @ERP_REFERENCE; -- varchar(256)
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
END;
