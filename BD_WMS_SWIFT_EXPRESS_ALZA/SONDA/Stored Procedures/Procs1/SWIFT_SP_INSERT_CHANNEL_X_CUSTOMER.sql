-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	09-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que inserta los nuevos clientes al canales

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_INSERT_CHANNEL_X_CUSTOMER
					@CHANNEL_ID = 1
					,@CODE_CUSTOMER = 'SO-005'
				-- 
				SELECT * FROM [SONDA].SWIFT_CHANNEL_X_CUSTOMER
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_INSERT_CHANNEL_X_CUSTOMER(
	@CHANNEL_ID INT
	,@CODE_CUSTOMER VARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].SWIFT_CHANNEL_X_CUSTOMER (
			CHANNEL_ID
			,CODE_CUSTOMER
		) VALUES (
			@CHANNEL_ID
			,@CODE_CUSTOMER
		)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Ya esta el cliente relacionado a un canal'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
