-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	28-Sep-16 @ A-TEAM Sprint 2
-- Description:			Obtiene todas las frecuencias o una en especifico

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_POLYGON_BY_ROUTE]
					@CODE_ROUTE = 'RUDI@SONDA'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_POLYGON_BY_ROUTE](
	@CODE_ROUTE VARCHAR(50)
)
AS
BEGIN
	SELECT
		[P].[POLYGON_ID]
		,[P].[POLYGON_NAME]
		,[P].[POLYGON_DESCRIPTION]
		,[P].[COMMENT]
		,[P].[LAST_UPDATE_BY]
		,[P].[LAST_UPDATE_DATETIME]
		,[P].[POLYGON_ID_PARENT]
		,[P].[POLYGON_TYPE]
		,[P].[SUB_TYPE]
		,[P].[OPTIMIZE]
		,[P].[TYPE_TASK]
		,[P].[CODE_WAREHOUSE]
		,[P].[LAST_OPTIMIZATION]
	FROM [SONDA].[SWIFT_POLYGON] [P]
	INNER JOIN [SONDA].[SWIFT_POLYGON_BY_ROUTE] [PBR] ON (
		[PBR].[POLYGON_ID] = [P].[POLYGON_ID]
	)
	INNER JOIN [SONDA].[SWIFT_ROUTES] R ON (
		[R].[ROUTE] = [PBR].[ROUTE]
	)
	WHERE R.[CODE_ROUTE] = @CODE_ROUTE
		AND [PBR].[IS_MULTIPOLYGON] = 1
END
