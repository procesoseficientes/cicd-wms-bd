

-- =============================================
-- Autor:				alejandro.ochoa
-- Fecha de Creacion: 	21-07-2016
-- Description:			Obtiene el Nombre del KPI respecto de los valores ingresados

/*
-- Ejemplo de Ejecucion:
	SELECT [SONDA].[SWIFT_FN_GET_KPI] (5.5,'RUDI@SONDA','SALES_DISTANCE','SALE') AS VALUE
*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_FN_GET_KPI]
(
	@EVALUATE_VALUE FLOAT
	,@CODEROUTE VARCHAR(250)
	,@KPITPYPE VARCHAR(50)
	,@PARAMETER VARCHAR(250)
)
RETURNS VARCHAR(MAX) 
AS
BEGIN
	DECLARE @VALUE VARCHAR(MAX)
	--
	SELECT
		@VALUE = NAME
	FROM [SONDA].SWIFT_KPI kpi
		LEFT JOIN [SONDA].SWIFT_KPI_X_ROUTE kxr on kpi.KPI = kxr.KPI
	WHERE KPI_TYPE = @KPITPYPE 
		AND CODE_ROUTE = @CODEROUTE
		AND POSITION = (CASE WHEN @EVALUATE_VALUE BETWEEN VALUE_FROM AND VALUE_TO THEN 'IN' ELSE 'OUT' END )
		AND PARAMETER = @PARAMETER
	--
	RETURN @VALUE
END
