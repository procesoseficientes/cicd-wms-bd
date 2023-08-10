-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	2-Nov-16 @ A-TEAM Sprint 4
-- Description:			SP que obtiene el los productos asignados al portafolio

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_GET_PORTFOLIO_SKU_AVAILABLE]  @CODE_PORTFOLIO = 5
*/
-- =============================================
CREATE PROC [SONDA].SWIFT_SP_GET_PORTFOLIO_SKU_AVAILABLE
	@CODE_PORTFOLIO VARCHAR(50)
AS
	SELECT *
	FROM [SONDA].SWIFT_VIEW_ALL_SKU S
	WHERE NOT EXISTS(SELECT 1
					FROM [SONDA].SWIFT_VIEW_PORTFOLIO_BY_SKU PS
					WHERE S.CODE_SKU = PS.CODE_SKU
					AND PS.CODE_PORTFOLIO = @CODE_PORTFOLIO
	)
