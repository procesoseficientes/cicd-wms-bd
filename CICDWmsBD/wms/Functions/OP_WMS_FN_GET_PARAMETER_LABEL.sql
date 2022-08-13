-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		20-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- Description:			    Funcion para obtener la etiqueta del parametro

/*
-- Ejemplo de Ejecucion:
        SELECT [wms].[OP_WMS_FN_GET_PARAMETER_LABEL]('STATUS','FULL_BLOCK')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_PARAMETER_LABEL]
(
	@GROUP_ID VARCHAR(250)
	,@PARAMETER_ID VARCHAR(250)
)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @LABEL VARCHAR(250)
	--
	SELECT 
		@LABEL = [P].[LABEL] 
	FROM [wms].[OP_WMS_PARAMETER] [P]
	WHERE [P].[GROUP_ID] = @GROUP_ID
		AND [P].[PARAMETER_ID] = @PARAMETER_ID
	--
	RETURN @LABEL
END