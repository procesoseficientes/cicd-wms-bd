-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	8/29/2017 @ Omikron Team strom  
-- Description:			SP que elimina la sesion activa del usuario.

/*
-- Ejemplo de Ejecucion:
				 EXEC [SONDA].SWIFT_DELETE_SESSION_FROM_USER 'gerente@SONDA'
					
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_DELETE_SESSION_FROM_USER] (
		@SESSION_ID VARCHAR(100)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--

	BEGIN TRY
		delete
			[ASPState].[dbo].[ASPStateTempSessions]
		WHERE
			[SessionId] like @SESSION_ID +'%';

		SELECT
			1 AS [STATUS]
			,'Proceso Exitoso' [MESSAGE]
			,0 [ERROR_CODE];


	END TRY
	BEGIN CATCH
		SELECT
			0 AS [STATUS]
			,ERROR_MESSAGE() [MESSAGE]
			,@@ERROR [ERROR_CODE];
		
	END CATCH;
END;
