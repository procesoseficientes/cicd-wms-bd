-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		24-Jul-17 @ Nexus Team Sprint 
-- Description:			    Funcion que obtiene los parametros de un grupo

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].[OP_WMS_FN_GET_PARAMETER_BY_GROUP]('STATUS')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_PARAMETER_BY_GROUP]
(	
	@GROUP_ID VARCHAR(250)
)
RETURNS TABLE 
AS
RETURN 
(
	SELECT 
		[P].[IDENTITY]
		,[P].[GROUP_ID]
		,[P].[PARAMETER_ID]
		,[P].[VALUE]
		,[P].[LABEL]
	FROM [wms].[OP_WMS_PARAMETER] [P]
	WHERE [P].[GROUP_ID] = @GROUP_ID
)