-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-Aug-17 @ Nexus Team Sprint Banjo-Kazooie 
-- Description:			SP que obtiene los centros de distribucion por los permisos del usuario
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_DISTRIBUTION_CENTER_ASSOCIATED_TO_USER]
					@LOGIN = 'ADMIN'
				--
				EXEC [wms].[OP_WMS_SP_GET_DISTRIBUTION_CENTER_ASSOCIATED_TO_USER]
					@LOGIN = 'AREYES'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_DISTRIBUTION_CENTER_ASSOCIATED_TO_USER](
	@LOGIN VARCHAR(25)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@HAS_PERMISSION INT = 0
		,@CHECK_ID VARCHAR(25) = 'TCD001'
		,@QUERY NVARCHAR(2000)

	-- ------------------------------------------------------------------------------------
	-- 
	-- ------------------------------------------------------------------------------------
	SELECT TOP 1 @HAS_PERMISSION = 1
	FROM [wms].[OP_WMS_ROLES_JOIN_CHECKPOINTS] [C]
	INNER JOIN [wms].[OP_WMS_LOGINS] [L] ON ([L].[ROLE_ID] = [C].[ROLE_ID])
	WHERE [C].[CHECK_ID] = @CHECK_ID
		AND [L].[LOGIN_ID] = @LOGIN
	--
	SELECT @QUERY = N'SELECT 
		[C].[PARAM_TYPE]
		,[C].[PARAM_GROUP]
		,[C].[PARAM_GROUP_CAPTION]
		,[C].[PARAM_NAME]
		,[C].[PARAM_CAPTION]
		,[C].[NUMERIC_VALUE]
		,[C].[MONEY_VALUE]
		,[C].[TEXT_VALUE]
		,[C].[DATE_VALUE]
		,[C].[RANGE_NUM_START]
		,[C].[RANGE_NUM_END]
		,[C].[RANGE_DATE_START]
		,[C].[RANGE_DATE_END]
		,[C].[SPARE1]
		,[C].[SPARE2]
		,[C].[DECIMAL_VALUE]
	FROM [wms].[OP_WMS_CONFIGURATIONS] [C]'
	+ CASE 
		WHEN @HAS_PERMISSION = 0 THEN ' WITH(INDEX ([IN_OP_WMS_CONFIGURATIONS_PARAM_GROUP])) INNER JOIN [wms].[OP_WMS_LOGINS] [L] ON ([L].[DISTRIBUTION_CENTER_ID] = [C].[PARAM_NAME])'
		ELSE ''
	END
	+ ' WHERE [C].[PARAM_GROUP] = ''DISTRIBUTION_CENTER'''
	+ CASE 
		WHEN @HAS_PERMISSION = 0 THEN ' AND [L].[LOGIN_ID] = ''' + @LOGIN + ''''
		ELSE ''
	END
	--
	PRINT @QUERY
	--
	EXEC (@QUERY)
END