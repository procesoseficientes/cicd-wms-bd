-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	13-Oct-16 @ A-TEAM Sprint 
-- Description:			SP que obtiene la frecuencia de uno o varios scouting

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_SCOUNTING_FREQUENCY]
					@CODE_CUSTOMER = 'SO-187'
				--
				EXEC [SONDA].[SWIFT_SP_GET_SCOUNTING_FREQUENCY]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SCOUNTING_FREQUENCY](
	@CODE_CUSTOMER VARCHAR(50) = NULL
)
AS
BEGIN
	SELECT
		[CFN].[CODE_FREQUENCY]
		,[CFN].[CODE_CUSTOMER]
		,[CFN].[SUNDAY]
		,[CFN].[MONDAY]
		,[CFN].[TUESDAY]
		,[CFN].[WEDNESDAY]
		,[CFN].[THURSDAY]
		,[CFN].[FRIDAY]
		,[CFN].[SATURDAY]
		,[CFN].[FREQUENCY_WEEKS]
		,[CFN].[LAST_DATE_VISITED]
		,[CFN].[LAST_UPDATED]
		,[CFN].[LAST_UPDATED_BY]
	FROM [SONDA].[SWIFT_CUSTOMER_FREQUENCY_NEW] [CFN]
	WHERE [CFN].[CODE_CUSTOMER] = @CODE_CUSTOMER
		OR @CODE_CUSTOMER IS NULL
END
