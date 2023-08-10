-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/21/2017 @ A-TEAM Sprint Khalid 
-- Description:			SP que actualiza la tabla SONDA_CUSTOMER_NEW 

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].SONDA_CUSTOMER_NEW where CODE_CUSTOMER = 'SO-1758'
				--
				EXEC [SONDA].[SWIFT_SP_UPDATE_SONDA_CUSTOMER_NEW]
					@CODE_CUSTOMER = 'SO-1758'
					,@NAME_CUSTOMER = 'Tienda Corazon'
					,@PHONE_CUSTOMER = '22152899'
					,@ADRESS_CUSTOMER = 'Mixco, guatemala'
					,@INVOICE_NAME = 'Tienda corazon 2'
					,@INVOICE_ADDRESS = 'Mixco, guatemala'
					,@NIT = 'C/F'
					,@CONTACT_ID = 'Tienda corazon 2'
					,@LOGIN = 'gerente@SONDA'
					,@OWNER_ID = 1
				-- 
				SELECT * FROM [SONDA].SONDA_CUSTOMER_NEW where CODE_CUSTOMER = 'SO-1758'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_SONDA_CUSTOMER_NEW](
	@CODE_CUSTOMER VARCHAR(50)
	,@NAME_CUSTOMER VARCHAR(250) = '...'
	,@PHONE_CUSTOMER VARCHAR(250) = '...'
	,@ADRESS_CUSTOMER VARCHAR(250) = '...'
	,@INVOICE_NAME VARCHAR(250) = '...'
	,@INVOICE_ADDRESS VARCHAR(250) = '...'
	,@NIT VARCHAR(250) = '...'
	,@CONTACT_ID VARCHAR(250) = '...'
	,@LOGIN VARCHAR(250)
	,@OWNER_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		UPDATE
			[SONDA].[SONDA_CUSTOMER_NEW]
		SET	
			[CUSTOMER_NAME] = @NAME_CUSTOMER
			,[CONTACT_PHONE] = @PHONE_CUSTOMER
			,[CUSTOMER_ADDRESS] = @ADRESS_CUSTOMER
			,[BILLING_NAME] = @INVOICE_NAME
			,[BILLING_ADDRESS] = @INVOICE_ADDRESS
			,[TAX_ID] = @NIT
			,[CONTACT_NAME] = @CONTACT_ID
			,[LAST_UPDATE] = GETDATE()
			,[LAST_UPDATE_BY] = @LOGIN
			,[OWNER] = @OWNER_ID
			,[UPDATED_FROM_BO] = 1
		WHERE
			[CODE_CUSTOMER] = @CODE_CUSTOMER
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN ''
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
