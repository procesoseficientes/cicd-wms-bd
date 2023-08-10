-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	23-May-17 @ A-TEAM Sprint Anekbah
-- Description:			SP que obtiene los grupos de razones de clasificaciones

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_GET_REASONS]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_GET_REASONS]
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[C].[CLASSIFICATION]
		,[C].[GROUP_CLASSIFICATION]
		,[C].[NAME_CLASSIFICATION]
		,[C].[PRIORITY_CLASSIFICATION]
		,[C].[VALUE_TEXT_CLASSIFICATION]
		,[C].[MPC01]
	FROM [SONDA].[SWIFT_CLASSIFICATION] [C]
	WHERE [GROUP_CLASSIFICATION] LIKE '%REASON%'
	ORDER BY
		[C].[GROUP_CLASSIFICATION]
		,[C].[PRIORITY_CLASSIFICATION]
END
