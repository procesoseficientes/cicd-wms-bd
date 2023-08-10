-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	09-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que inserta los nuevos canales

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_INSERT_CHANNEL
					@CODE_CHANNEL = 'prueba2'
					,@NAME_CHANNEL = 'prueba'
					,@DESCRIPTION_CHANNEL = 'prueba'
					,@TYPE_CHANNEL = 'prueba'
					,@LAST_UPDATE_BY = 'prueba@SONDA'
				-- 
				SELECT * FROM [SONDA].SWIFT_CHANNEL
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_INSERT_CHANNEL(
	@CODE_CHANNEL VARCHAR(50)
	,@NAME_CHANNEL VARCHAR(250)
	,@DESCRIPTION_CHANNEL VARCHAR(250)
	,@TYPE_CHANNEL  VARCHAR(50)
	,@LAST_UPDATE_BY VARCHAR(50)
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].SWIFT_CHANNEL (
			CODE_CHANNEL
			,NAME_CHANNEL
			,DESCRIPTION_CHANNEL
			,TYPE_CHANNEL  
			,LAST_UPDATE
			,LAST_UPDATE_BY
		) VALUES (
			@CODE_CHANNEL
			,@NAME_CHANNEL
			,@DESCRIPTION_CHANNEL
			,@TYPE_CHANNEL  
			,GETDATE()
			,@LAST_UPDATE_BY
		)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
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
