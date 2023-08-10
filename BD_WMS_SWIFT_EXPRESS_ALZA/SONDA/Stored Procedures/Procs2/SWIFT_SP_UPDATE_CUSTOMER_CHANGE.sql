-- =======================================================
-- Author:         hector.gonzalez
-- Create date:    11-07-2016
-- Description:    Modifica un registro de la tabla [SWIFT_CUSTOMER_CHANGE] 

-- Modificacion 22-Mar-17 @ A-Team Sprint Fenyang
					-- eder.chamale
					-- Se agregaron los parametros NIT y INVOICE_NAME.

-- Modificacion 10-May-17 @ A-Team Sprint Issa
					-- alberto.ruiz
					-- Se agrega la columna de NEW_CUSTOMER_NAME

/*
-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_UPDATE_CUSTOMER_CHANGE]
			@CUSTOMER = 2
			,@PHONE_CUSTOMER = '56875468'
			,@ADRESS_CUSTOMER = 'Coatepeque'
			,@CONTACT_CUSTOMER = 'Jose'
			,@LOGIN = 'oper1@SONDA'
			,@TAX_ID = '123456-5' 
			,@INVOICE_NAME = 'CLIENTE'
			,@NEW_CUSTOMER_NAME = 'nuevo nombre'
		--
		SELECT * FROM [SONDA].[SWIFT_CUSTOMER_CHANGE] WHERE CUSTOMER = 2
*/
-- =========================================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_CUSTOMER_CHANGE] (
	@CUSTOMER INT
	,@PHONE_CUSTOMER VARCHAR(50)
	,@ADRESS_CUSTOMER VARCHAR(50)
	,@CONTACT_CUSTOMER VARCHAR(50)
	,@LOGIN VARCHAR(50)
	,@TAX_ID VARCHAR(50)
	,@INVOICE_NAME VARCHAR(100)
	,@NEW_CUSTOMER_NAME VARCHAR(250)
) AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Actualiza el cliente
		-- ------------------------------------------------------------------------------------
		UPDATE [SONDA].[SWIFT_CUSTOMER_CHANGE]
		SET
			[PHONE_CUSTOMER] = @PHONE_CUSTOMER
			,[ADRESS_CUSTOMER] = @ADRESS_CUSTOMER
			,[CONTACT_CUSTOMER] = @CONTACT_CUSTOMER
			,[LAST_UPDATE] = GETDATE()			
			,[LAST_UPDATE_BY] = @LOGIN
			,[TAX_ID] = @TAX_ID
			,[INVOICE_NAME] = @INVOICE_NAME
			,[NEW_CUSTOMER_NAME] = @NEW_CUSTOMER_NAME
		WHERE CUSTOMER = @CUSTOMER
		--
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'0' [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH
END
