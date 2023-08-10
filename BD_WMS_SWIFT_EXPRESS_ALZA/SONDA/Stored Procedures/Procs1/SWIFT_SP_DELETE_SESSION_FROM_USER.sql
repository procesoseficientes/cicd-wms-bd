-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	8/29/2017 @ Omikron Team strom  
-- Description:			SP que elimina la sesion activa del usuario.

/*
-- Ejemplo de Ejecucion:
				 EXEC [SONDA].SP_DELETE_SESSION_FROM_USER 'gerente@SONDA'
					
*/
-- =============================================


CREATE PROCEDURE [SONDA].SWIFT_SP_DELETE_SESSION_FROM_USER (@LOGIN VARCHAR(100))
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@SESSION_ID VARCHAR(88)= NULL;

	BEGIN TRY

		SELECT
			@SESSION_ID = [SESSION_ID]
		FROM
			[SONDA].[USERS]
		WHERE LOGIN = @LOGIN;

   

		DELETE
			[ASPState].[dbo].[ASPStateTempSessions]
		WHERE
			[SessionId] LIKE @SESSION_ID + '%';

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
