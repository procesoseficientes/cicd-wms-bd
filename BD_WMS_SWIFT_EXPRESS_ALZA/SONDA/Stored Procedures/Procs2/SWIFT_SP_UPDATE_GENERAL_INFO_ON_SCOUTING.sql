-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/21/2017 @ A-TEAM Sprint Khalid 
-- Description:			Decide que sp ejecutar dependiendo del valor de IS_FROM

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_GENERAL_INFO_ON_SCOUTING]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_GENERAL_INFO_ON_SCOUTING](
	@IS_FROM VARCHAR(50) 
	,@CODE_CUSTOMER VARCHAR(50)
	,@NAME_CUSTOMER VARCHAR(250) = '...'
	,@PHONE_CUSTOMER VARCHAR(250) = '...'
	,@ADRESS_CUSTOMER VARCHAR(250) = '...'
	,@POS_SALE_NAME VARCHAR(250) = '...'
	,@INVOICE_NAME VARCHAR(250) = '...'
	,@INVOICE_ADDRESS VARCHAR(250) = '...'
	,@NIT VARCHAR(250) = '...'
	,@CONTACT_ID VARCHAR(250) = '...'
	,@COMMENTS VARCHAR(250) = '...'
	,@LOGIN VARCHAR(250)
	,@OWNER_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	IF(@IS_FROM = 'SONDA_CORE')
	BEGIN
		EXEC [SONDA].[SWIFT_SP_UPDATE_INFO_GENERAL_FOR_SCOUTING] 
			@CODE_CUSTOMER = @CODE_CUSTOMER, -- varchar(50)
			@NAME_CUSTOMER = @NAME_CUSTOMER, -- varchar(250)
			@PHONE_CUSTOMER = @PHONE_CUSTOMER, -- varchar(250)
			@ADRESS_CUSTOMER = @ADRESS_CUSTOMER, -- varchar(250)
			@POS_SALE_NAME = @POS_SALE_NAME, -- varchar(250)
			@INVOICE_NAME = @INVOICE_NAME, -- varchar(250)
			@INVOICE_ADDRESS = @INVOICE_ADDRESS, -- varchar(250)
			@NIT = @NIT, -- varchar(250)
			@CONTACT_ID = @CONTACT_ID, -- varchar(250)
			@COMMENTS = @COMMENTS, -- varchar(250)
			@LOGIN = @LOGIN, -- varchar(250)
			@OWNER_ID = @OWNER_ID -- int
	END
	ELSE
	BEGIN
		EXEC [SONDA].[SWIFT_SP_UPDATE_SONDA_CUSTOMER_NEW] 
			@CODE_CUSTOMER = @CODE_CUSTOMER, -- varchar(50)
			@NAME_CUSTOMER = @NAME_CUSTOMER, -- varchar(250)
			@PHONE_CUSTOMER = @PHONE_CUSTOMER, -- varchar(250)
			@ADRESS_CUSTOMER = @ADRESS_CUSTOMER, -- varchar(250)
			@INVOICE_NAME = @INVOICE_NAME, -- varchar(250)
			@INVOICE_ADDRESS = @INVOICE_ADDRESS, -- varchar(250)
			@NIT = @NIT, -- varchar(250)
			@CONTACT_ID = @CONTACT_ID, -- varchar(250)
			@LOGIN = @LOGIN, -- varchar(250)
			@OWNER_ID = @OWNER_ID -- int
	END
END
