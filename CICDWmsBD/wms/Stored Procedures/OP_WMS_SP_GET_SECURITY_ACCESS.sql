-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	20-Jul-17 @ Nexus TEAM Sprint AgeOfEmpires
-- Description:			SP que obtiene los permisos

-- Modificacion 25-Aug-17 @ Nexus Team Sprint CommandAndConquer
					-- alberto.ruiz
					-- Se agrega filtro por login

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_SECURITY_ACCESS]
					@PARENT = 'POLIZAS_EXPIRADAS'
					,@CATEGORY = 'SCREEN_SECURITY'
					,@LOGIN = 'BETO'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_SECURITY_ACCESS](
	@PARENT VARCHAR(25)
	,@CATEGORY VARCHAR(25)
	,@LOGIN VARCHAR(25)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT
		[C].[CHECK_ID]
		,[C].[CATEGORY]
		,[C].[DESCRIPTION]
		,[C].[PARENT]
		,[C].[ACCESS]
		,[C].[MPC_1]
		,[C].[MPC_2]
		,[C].[MPC_3]
		,[C].[MPC_4]
		,[C].[MPC_5]
	FROM [wms].[OP_WMS_CHECKPOINTS] [C]
	INNER JOIN [wms].[OP_WMS_ROLES_JOIN_CHECKPOINTS] [JC] ON ([JC].[CHECK_ID] = [C].[CHECK_ID])
	INNER JOIN [wms].[OP_WMS_LOGINS] [L] ON ([L].[ROLE_ID] = [JC].[ROLE_ID])
	WHERE [C].[PARENT] = @PARENT
		AND [C].[CATEGORY] = @CATEGORY
		AND [L].[LOGIN_ID] = @LOGIN
END