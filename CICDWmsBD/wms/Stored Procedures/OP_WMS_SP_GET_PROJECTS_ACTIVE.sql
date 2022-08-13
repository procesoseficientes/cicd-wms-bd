-- =============================================
-- Autor:					henry.rodriguez
-- Fecha de Creacion: 		16-JULIO-2019 G-Force@Dublin
-- Description:			    Obtiene los proyectos que estan activos.
/*
Ejemplo de Ejecucion:
	EXECUTE [wms].[OP_WMS_SP_GET_PROJECTS_ACTIVE] @OWNER = '' -- varchar(30)
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_PROJECTS_ACTIVE]
AS
BEGIN
	SELECT
		[P].[ID]
		,[P].[OPPORTUNITY_CODE]
		,[P].[OPPORTUNITY_NAME]
		,[P].[SHORT_NAME]
		,[P].[OBSERVATIONS]
		,[P].[CUSTOMER_CODE]
		,[P].[STATUS]
		,[P].[CREATED_BY]
		,[P].[CREATED_DATE]
		,[P].[LAST_UPDATED_BY]
		,[P].[LAST_UPDATED_DATE]
		,[P].[CUSTOMER_NAME]
		,[P].[CUSTOMER_OWNER]
		,[VC].[CLIENT_NAME]
	FROM
		[wms].[OP_WMS_PROJECT] [P]
	LEFT JOIN [wms].[OP_WMS_VIEW_CLIENTS] [VC] ON ([P].[CUSTOMER_OWNER] = [VC].[CLIENT_CODE])
	WHERE
		[STATUS] IN ('IN_PROCESS');
END;