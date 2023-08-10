-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	08-Feb-17 @ A-TEAM Sprint Chatuluka 
-- Description:			Obtiene uno o todos los combos

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_COMBO]
					@COMBO_ID = 6
				--
				EXEC [SONDA].[SWIFT_SP_GET_COMBO]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_COMBO](
	@COMBO_ID INT = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT 
		[C].[COMBO_ID]
		,[C].[NAME_COMBO]
		,[C].[DESCRIPTION_COMBO]
	FROM [SONDA].[SWIFT_COMBO] [C]
	WHERE @COMBO_ID IS NULL
		OR [C].[COMBO_ID] = @COMBO_ID
END
