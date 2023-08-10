-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	09-09-2016 @ A-TEAM Sprint 1
-- Description:			SP que obtiene todos los canales o uno en especifico

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].SWIFT_SP_GET_CHANNEL
					@CHANNEL_ID = 1
				--
				EXEC [SONDA].SWIFT_SP_GET_CHANNEL
				-- 
				SELECT * FROM [SONDA].SWIFT_CHANNEL
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_CHANNEL(
	@CHANNEL_ID INT = NULL
)
AS
BEGIN
	SELECT
		CHANNEL_ID
		,CODE_CHANNEL
		,NAME_CHANNEL
		,DESCRIPTION_CHANNEL
		,TYPE_CHANNEL
		,LAST_UPDATE
		,LAST_UPDATE_BY
	FROM [SONDA].SWIFT_CHANNEL
	WHERE @CHANNEL_ID IS NULL
		OR CHANNEL_ID = @CHANNEL_ID
END
