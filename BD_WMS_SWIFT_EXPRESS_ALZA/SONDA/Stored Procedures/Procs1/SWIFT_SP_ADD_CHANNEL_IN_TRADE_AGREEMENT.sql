-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	09-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que inserta los nuevos canales al acuerdo comercial

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_ADD_CHANNEL_IN_TRADE_AGREEMENT
					@TRADE_AGREEMENT_ID = 1
					,@CHANNEL_ID = 1
				-- 
				SELECT * FROM [SONDA].SWIFT_TRADE_AGREEMENT_BY_CHANNEL
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_ADD_CHANNEL_IN_TRADE_AGREEMENT(
	@TRADE_AGREEMENT_ID INT
	,@CHANNEL_ID INT
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].SWIFT_TRADE_AGREEMENT_BY_CHANNEL (
			TRADE_AGREEMENT_ID
			,CHANNEL_ID
		) VALUES (
			@TRADE_AGREEMENT_ID
			,@CHANNEL_ID
		)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN 'Ya esta el canal relacionado a un acuerdo comercial'
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
