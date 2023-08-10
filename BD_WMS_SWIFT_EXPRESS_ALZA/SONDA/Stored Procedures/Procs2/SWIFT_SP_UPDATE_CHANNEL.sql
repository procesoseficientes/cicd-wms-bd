-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	09-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que actualoza el canal

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_UPDATE_CHANNEL
					@CHANNEL_ID = 5
					,@CODE_CHANNEL = 'prueba3'
					,@NAME_CHANNEL = 'prueba'
					,@DESCRIPTION_CHANNEL = 'prueba'
					,@TYPE_CHANNEL = 'prueba'
					,@LAST_UPDATE_BY = 'prueba@SONDA'
				-- 
				SELECT * FROM [SONDA].SWIFT_CHANNEL
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_UPDATE_CHANNEL(
	@CHANNEL_ID INT
	,@CODE_CHANNEL VARCHAR(50)
	,@NAME_CHANNEL VARCHAR(250)
	,@DESCRIPTION_CHANNEL VARCHAR(250)
	,@TYPE_CHANNEL  VARCHAR(50)
	,@LAST_UPDATE_BY VARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		UPDATE [SONDA].SWIFT_CHANNEL
		SET
			CODE_CHANNEL = @CODE_CHANNEL
			,NAME_CHANNEL = @NAME_CHANNEL
			,DESCRIPTION_CHANNEL = @DESCRIPTION_CHANNEL
			,TYPE_CHANNEL = @TYPE_CHANNEL
			,LAST_UPDATE = GETDATE()
			,LAST_UPDATE_BY = @LAST_UPDATE_BY
		WHERE CHANNEL_ID = @CHANNEL_ID
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, '0' DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Ya existe un canal con el mismo codigo de canal'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
