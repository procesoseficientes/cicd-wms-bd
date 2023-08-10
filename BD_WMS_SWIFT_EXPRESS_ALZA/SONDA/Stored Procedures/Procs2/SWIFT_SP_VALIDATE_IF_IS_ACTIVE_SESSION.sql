-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	19-Jan-18 @ Nexus Team Sprint Strom
-- Description:			SP que valida si la sesion enviada es la activa del usuario
/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_VALIDATE_IF_IS_ACTIVE_SESSION]
					@LOGIN = 'gerente@SONDA'
					,@SESSION_ID = 'oe3hojf5ysmuryp3ba2gczzk'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_VALIDATE_IF_IS_ACTIVE_SESSION](
	@LOGIN VARCHAR(50)
	,@SESSION_ID VARCHAR(88)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@RESULT INT = -1
		,@MESSAGE VARCHAR(250) = 'No es la session activa del usuario'
	--
	BEGIN TRY
		SELECT TOP 1
			@RESULT = 1
			,@MESSAGE = ''
		FROM [SONDA].[USERS] [U]
		WHERE [U].[LOGIN] = @LOGIN
		AND [U].[SESSION_ID] = @SESSION_ID
		--
		SELECT  
			@RESULT as [Resultado]
			,@MESSAGE [Mensaje] 
			,0 [Codigo] 
			,@SESSION_ID [DbData]
	END TRY
	BEGIN CATCH
		SELECT  
			-1 as [Resultado]
			,ERROR_MESSAGE() [Mensaje] 
			,@@ERROR [Codigo] 
			,'' [DbData]
	END CATCH
END
