-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	3/9/2017 @ A-TEAM Sprint Ebonne 
-- Description:			Obtiene el DEVICE_ID y VALIDATION_TYPE asignado al usuario.

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_DEVICE_ID_FROM_USER]
					@LOGIN = 'rudi@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_DEVICE_ID_FROM_USER](
	@LOGIN VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT [DEVICE_ID]
			,[VALIDATION_TYPE] 
	FROM [SONDA].[USERS]
	WHERE [LOGIN] = @LOGIN
END
