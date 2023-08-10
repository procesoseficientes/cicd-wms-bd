-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	28-Sep-16 @ A-TEAM Sprint 2
-- Description:			Obtiene todas las frecuencias o una en especifico

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_FREQUENCY]
					@ID_FREQUENCY = 26
				--
				EXEC [SONDA].[SWIFT_SP_GET_FREQUENCY]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_FREQUENCY](
	@ID_FREQUENCY INT = NULL
)
AS
BEGIN
	SELECT
		[F].[ID_FREQUENCY]
		,[F].[CODE_FREQUENCY]
		,[F].[SUNDAY]
		,[F].[MONDAY]
		,[F].[TUESDAY]
		,[F].[WEDNESDAY]
		,[F].[THURSDAY]
		,[F].[FRIDAY]
		,[F].[SATURDAY]
		,[F].[FREQUENCY_WEEKS]
		,[F].[LAST_WEEK_VISITED]
		,[F].[LAST_UPDATED]
		,[F].[LAST_UPDATED_BY]
		,[F].[CODE_ROUTE]
		,[F].[TYPE_TASK]
		,[F].[REFERENCE_SOURCE]
	FROM [SONDA].[SWIFT_FREQUENCY] F
	WHERE [F].[ID_FREQUENCY] = @ID_FREQUENCY
		OR @ID_FREQUENCY IS NULL 
END
