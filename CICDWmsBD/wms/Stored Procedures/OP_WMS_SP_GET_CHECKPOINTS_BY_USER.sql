-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/12/2017 @ NEXUS-Team Sprint DuckHunt 
-- Description:			Obtiene los permisos por el usuario

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_CHECKPOINTS_BY_USER]
					@LOGIN = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_CHECKPOINTS_BY_USER](
	@LOGIN VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT [RJC].[ROLE_ID] ,
           [RJC].[CHECK_ID] 
	FROM [wms].[OP_WMS_ROLES_JOIN_CHECKPOINTS] [RJC]
	INNER JOIN [wms].[OP_WMS_ROLES] [R] ON [R].[ROLE_ID] = [RJC].[ROLE_ID]
	INNER JOIN [wms].[OP_WMS_LOGINS] [L] ON [L].[ROLE_ID] = [R].[ROLE_ID]
	WHERE [L].[LOGIN_ID] = @LOGIN
END