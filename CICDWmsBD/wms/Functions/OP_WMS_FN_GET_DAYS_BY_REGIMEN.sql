-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		18-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- Description:			    Funcion que obtiene los dias para que expire una poliza fiscal

/*
-- Ejemplo de Ejecucion:
        SELECT [wms].[OP_WMS_FN_GET_DAYS_BY_REGIMEN]('23DI')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_DAYS_BY_REGIMEN]
(
	@REGIMEN VARCHAR(50)
)
RETURNS INT
AS
BEGIN
	DECLARE @DAYS INT = 0
	--
	SELECT @DAYS = CONVERT(INT,[C].[NUMERIC_VALUE])
	FROM [wms].[OP_WMS_CONFIGURATIONS] [C]
	WHERE [C].[PARAM_TYPE] = 'WMS3PL'
		AND [C].[PARAM_GROUP] = 'REGIMEN'
		AND [C].[PARAM_NAME] = @REGIMEN
	--
	RETURN @DAYS
END