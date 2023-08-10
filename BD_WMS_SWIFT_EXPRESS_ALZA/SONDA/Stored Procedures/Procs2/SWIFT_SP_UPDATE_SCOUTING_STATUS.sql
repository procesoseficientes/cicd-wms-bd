-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/21/2017 @ A-TEAM Sprint Khalid 
-- Description:			Decide que sp ejecutar dependiendo del valor de IS_FROM

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_SCOUTING_STATUS]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_SCOUTING_STATUS](
	@IS_FROM VARCHAR(50)
	,@STATUS VARCHAR(20)
	,@LOGIN VARCHAR(50)
	,@COMMENTS VARCHAR(250)
	,@CUSTOMER_ID VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	IF(@IS_FROM = 'SONDA_CORE')
	BEGIN
		EXEC [SONDA].[SWIFT_SP_UPDATE_SCOUTING] @STATUS = @STATUS, -- varchar(20)
			@USER = @LOGIN, -- varchar(50)
			@COMMENTS = @COMMENTS, -- varchar(250)
			@CUSTOMER = @CUSTOMER_ID -- varchar(250)
	END
	ELSE	
	BEGIN
		DECLARE @ID INT 
		SELECT TOP 1 @ID = [CUSTOMER_ID] FROM [SONDA].[SONDA_CUSTOMER_NEW] WHERE [CODE_CUSTOMER] = @CUSTOMER_ID
		
		EXEC [SONDA].[SWIFT_SP_UPDATE_SONDA_CUSTOMER_NEW_STATUS] 
			@STATUS = @STATUS, -- varchar(20)
			@LOGIN = @LOGIN, -- varchar(50)
			@CUSTOMER_ID = @ID -- int
	END
END
