-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	1/19/2018 @ A-TEAM Sprint  
-- Description:			SP	que valida si el identificador del dispositivo del usuario es el mismo que el que se encuentra asociado en la BD

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_VALIDATE_DEVICE_ID_OF_USER_FOR_TRANSACTION]
				@CODE_ROUTE = '46'
				,@DEVICE_ID = '3b396881f40a8de3'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_VALIDATE_DEVICE_ID_OF_USER_FOR_TRANSACTION](
	@CODE_ROUTE VARCHAR(50)
	,@DEVICE_ID VARCHAR(50)	
)
AS
BEGIN
	--
	SET NOCOUNT ON;
	
	--
	DECLARE @VALIDATION_TYPE VARCHAR(50) = NULL, @DEVICE_ID_REGISTERED VARCHAR(50);

	--
	SELECT 
		@VALIDATION_TYPE = U.[VALIDATION_TYPE]
		,@DEVICE_ID_REGISTERED = U.[DEVICE_ID]
	FROM [SONDA].[USERS] U WHERE U.[SELLER_ROUTE] = @CODE_ROUTE;
	--
	IF(@VALIDATION_TYPE IS NOT NULL AND @VALIDATION_TYPE = 'PerDevice') BEGIN
		--
		IF(@DEVICE_ID_REGISTERED IS NULL OR @DEVICE_ID <> @DEVICE_ID_REGISTERED) BEGIN
			RAISERROR('El identificador de dispositivo no corresponde al registrado por el usuario.',16,1)
		END
	END

END
