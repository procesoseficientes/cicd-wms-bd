-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	01/17/2018 @ Reborn Team strom  
-- Description:			SP que valida si el usuario tiene una sesion activa.

/*
-- Ejemplo de Ejecucion:
				 EXEC [SONDA].[SWIFT_SP_UPDATE_SESSION_ID_USER] 'GERENTE@SONDA','jzc1vajcv1ouddknng3zror4e78fa2db'
					
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_SESSION_ID_USER] (
		@LOGIN_ID VARCHAR(100)
		,@SESSION_USER_ID VARCHAR(80)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--

	BEGIN TRY
		UPDATE
			[SONDA].[USERS]
		SET	
			SESSION_ID = @SESSION_USER_ID
		WHERE
			[LOGIN] = @LOGIN_ID;

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
