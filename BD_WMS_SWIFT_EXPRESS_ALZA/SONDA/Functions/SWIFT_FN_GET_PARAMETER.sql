
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	16-12-2015
-- Description:			Obtiene el valor de los parametros 

-- Modificacion 14-04-2016
			-- alberto.ruiz
			-- Se arreglaron los nombres de las columnas
/*
-- Ejemplo de Ejecucion:
	SELECT [SONDA].[SWIFT_FN_GET_PARAMETER] ('ERP_HARDCODE_VALUES','PRICE_LIST') AS VALUE

*/
-- =============================================
CREATE FUNCTION [SONDA].[SWIFT_FN_GET_PARAMETER]
(
	@GROUP_ID VARCHAR(250)
	,@PARAMETER_ID VARCHAR(250)
)
RETURNS VARCHAR(MAX) 
AS
BEGIN
	DECLARE @VALUE VARCHAR(MAX)
	--
	SELECT @VALUE = [VALUE] 
	FROM [SONDA].[SWIFT_PARAMETER] 
	WHERE [GROUP_ID] = @GROUP_ID
	AND [PARAMETER_ID] = @PARAMETER_ID
	--
	RETURN @VALUE
END
