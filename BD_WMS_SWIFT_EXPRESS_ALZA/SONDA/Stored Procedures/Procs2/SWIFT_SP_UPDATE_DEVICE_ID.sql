-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	3/7/2017 @ A-TEAM Sprint Ebonne 
-- Description:			SP que añade el DEVICE_ID y VALIDATION_TYPE a las tablas de usuario

-- Modificacion 04-Jun-17 @ A-Team Sprint 
					-- alberto.ruiz
					-- Se agregan los campos de sonda core version y las login datetime

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_UPDATE_DEVICE_ID]
					@DEVICE_ID = '2b9cd997e9ffcd98',
					@VALIDATION_TYPE = '',
					@ROUTE_ID = 'GUA0032@ARIUM',
					@SONDA_CORE_VERSION = '4.0.8'
				-- 
				SELECT * FROM [SONDA].[USERS] WHERE [SELLER_ROUTE] = 'GUA0032@ARIUM'
				SELECT * FROM [dbo].[SWIFT_USER] WHERE [SELLER_ROUTE] = 'GUA0032@ARIUM'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_UPDATE_DEVICE_ID](
	@DEVICE_ID VARCHAR(50),
	@VALIDATION_TYPE VARCHAR(50),
	@ROUTE_ID VARCHAR(50),
	@SONDA_CORE_VERSION VARCHAR(50) = NULL
)
AS
BEGIN
	BEGIN TRY
		--
		UPDATE [SONDA].[USERS]
		SET	
			[DEVICE_ID] = @DEVICE_ID
			, [VALIDATION_TYPE] = @VALIDATION_TYPE
			, [SONDA_CORE_VERSION] = @SONDA_CORE_VERSION
			, [LAST_LOGIN_DATETIME] = GETDATE()
		WHERE @ROUTE_ID = [SELLER_ROUTE]
		--
		UPDATE [dbo].[SWIFT_USER]
		SET	
			[DEVICE_ID] = @DEVICE_ID
			, [VALIDATION_TYPE] = @VALIDATION_TYPE
			, [SONDA_CORE_VERSION] = @SONDA_CORE_VERSION
			, [LAST_LOGIN_DATETIME] = GETDATE()
		WHERE @ROUTE_ID = [SELLER_ROUTE]
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Error al actualizar la tabla de Usuarios'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
