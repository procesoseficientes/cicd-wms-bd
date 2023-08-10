-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	6/21/2017 @ A-TEAM Sprint Khalid 
-- Description:			Decide que sp ejecutar dependiendo del valor de IS_FROM

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_DELETE_TAGS_ON_SCOUTING]
					@IS_FROM = 'SONDA_ROUTE'
					,@TAG_COLOR = '#133A23'
					,@CUSTOMER_ID = 'SO-1432'
					,@LOGIN  = 'gerente@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_DELETE_TAGS_ON_SCOUTING](
	@IS_FROM VARCHAR(50)
	,@TAG_COLOR VARCHAR(250)
	,@CUSTOMER_ID VARCHAR(50)
	,@LOGIN VARCHAR(250)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	IF(@IS_FROM = 'SONDA_CORE')
	BEGIN
		EXEC [SONDA].[SWIFT_SP_DELETE_TAGS_BY_SCOUTING] 
			@TAG_COLOR = @TAG_COLOR, -- varchar(250)
			@CUSTOMER_ID = @CUSTOMER_ID, -- varchar(250)
			@LOGIN = @LOGIN -- varchar(250)	
	END
	ELSE	
	BEGIN
		DECLARE @ID INT 
		SELECT TOP 1 @ID = [CUSTOMER_ID] FROM [SONDA].[SONDA_CUSTOMER_NEW] WHERE [CODE_CUSTOMER] = @CUSTOMER_ID
		
		EXEC [SONDA].[SWIFT_SP_DELETE_TAG_SONDA_CUSTOMER_NEW] 
			@TAG_COLOR = @TAG_COLOR, -- varchar(50)
			@CUSTOMER_ID = @ID, -- int
			@LOGIN = @LOGIN -- varchar(250)
		
	END
	
END
