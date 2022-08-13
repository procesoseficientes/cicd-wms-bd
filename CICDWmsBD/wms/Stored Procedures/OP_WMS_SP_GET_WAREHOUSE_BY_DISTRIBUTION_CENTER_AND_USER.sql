-- =============================================
-- Autor:	rodrigo.gomez
-- Fecha de Creacion: 	2017-08-16 @ Team Nexus - Sprint Banjo-Kazooie
-- Description:	 Obtiene todas las bodegas asociadas a un centro de distribución que esten ya asociadas al usuario

-- Modificacion 9/1/2017 @ NEXUS-Team Sprint CommandAndConquer
					-- rodrigo.gomez
					-- Se puede filtrar por mas de un centro de distribucion

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_WAREHOUSE_BY_DISTRIBUTION_CENTER_AND_USER] @DISTRIBUTION_CENTER = 'CTR_SUR', @LOGIN_ID = 'ADMIN', @IS_WAREHOUSE_FROM = 1
			EXEC [wms].[OP_WMS_SP_GET_WAREHOUSE_BY_DISTRIBUTION_CENTER_AND_USER] @DISTRIBUTION_CENTER = 'CTR_SUR', @LOGIN_ID = 'BASC_OPER', @IS_WAREHOUSE_FROM = 1
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_WAREHOUSE_BY_DISTRIBUTION_CENTER_AND_USER] (
		@DISTRIBUTION_CENTER VARCHAR(MAX)
		,@LOGIN_ID VARCHAR(25)
		,@IS_WAREHOUSE_FROM INT
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@HAS_PERMISSION INT = 0
		,@CHECK_ID VARCHAR(25) = 'TCD001'
		,@QUERY NVARCHAR(2000);

	-- ------------------------------------------------------------------------------------
	-- Inserta los centros de distribucion
	-- ------------------------------------------------------------------------------------
	SELECT [VALUE] [DISTRIBUTION_CENTER_ID]
	INTO [#DISTRIBUTION_CENTER]
	FROM [wms].[OP_WMS_FN_SPLIT](@DISTRIBUTION_CENTER,'|')
	-- ------------------------------------------------------------------------------------
	-- Obtiene el permiso
	-- ------------------------------------------------------------------------------------
	SELECT TOP 1 @HAS_PERMISSION = 1
		FROM [wms].[OP_WMS_ROLES_JOIN_CHECKPOINTS] [C]
		INNER JOIN [wms].[OP_WMS_LOGINS] [L] ON ([L].[ROLE_ID] = [C].[ROLE_ID])
		WHERE [C].[CHECK_ID] = @CHECK_ID
			AND [L].[LOGIN_ID] = @LOGIN_ID
	
	SELECT @QUERY = N'
		SELECT
			[W].[WAREHOUSE_ID]
			,[W].[NAME]
			,[W].[COMMENTS]
			,[W].[ERP_WAREHOUSE]
			,[W].[ALLOW_PICKING]
			,[W].[DEFAULT_RECEPTION_LOCATION]
			,[W].[SHUNT_NAME]
			,[W].[WAREHOUSE_WEATHER]
			,[W].[WAREHOUSE_STATUS]
			,[W].[IS_3PL_WAREHUESE]
			,[W].[WAHREHOUSE_ADDRESS]
			,[W].[GPS_URL]
			,[W].[DISTRIBUTION_CENTER_ID]
			,0 [IS_SELECT]
		FROM
			[wms].[OP_WMS_WAREHOUSES] [W]
		' + 
	CASE 
		WHEN @HAS_PERMISSION = 0 AND @IS_WAREHOUSE_FROM = 0 THEN '  INNER JOIN [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU] ON [W].[WAREHOUSE_ID] = [WU].[WAREHOUSE_ID]
												AND [WU].[LOGIN_ID] = ''' + @LOGIN_ID + ''''
		ELSE ''
	END + '
		INNER JOIN [#DISTRIBUTION_CENTER] [DC] ON [DC].[DISTRIBUTION_CENTER_ID] = [W].[DISTRIBUTION_CENTER_ID]
		WHERE [DC].[DISTRIBUTION_CENTER_ID] <> ''''
			 ' +
	+ ' '
	--
	PRINT @QUERY
	--
	EXEC (@QUERY)
END;