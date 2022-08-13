-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-02-19 @ Team ERGON - Sprint ERGON III
-- Description:	 Consultar productos por bodega, cliente, ubicación y zona. 

-- Modificacion 8/17/2017 @ NEXUS-Team Sprint Banjo-Kazooie
					-- rodrigo.gomez
					-- Se agrego la columna de QTY

-- Modificacion:	Gildardo.Alvarado@ ProcesosEficientes
-- Fecha:			19/02/2021
-- Descripcion:		Se trae el inventario en linea

-- Modificacion:	Elder Lucas
-- Fecha:			30/12/2021
-- Descripcion:		Se cambia la consulta directa a las licencias por la vista OP_WMS_VIEW_INVENTORY_FOR_PICKING_BY_STATUS_MATERIAL para obtener datos mas precisos
/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_MATERIALS_BY_WAREHOUSE_CLIENT_LOCATION_OR_ZONE]   
				@WAREHOUSE = 'BODEGA_01' ,
				@REGIMEN = 'GENERAL', 
				@CLIENT_CODE = 'C00016'  , 
				@LOCATION = 'B04-TB-C02-NU' ,
				@LOGIN_ID = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MATERIALS_BY_WAREHOUSE_CLIENT_LOCATION_OR_ZONE] (
		@WAREHOUSE VARCHAR(MAX)
		,@REGIMEN VARCHAR(50)
		,@ZONE VARCHAR(MAX) = NULL
		,@CLIENT_CODE VARCHAR(MAX) = NULL
		,@LOCATION VARCHAR(MAX) = NULL
		,@LOGIN_ID VARCHAR(50) = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE
		@HAS_PERMISSION INT = 0
		,@CHECK_ID VARCHAR(25) = 'TCD001'
		,@QUERY NVARCHAR(2000);

	-- ------------------------------------------------------------------------------------
	-- Obtiene el permiso
	-- ------------------------------------------------------------------------------------
	SELECT TOP 1 @HAS_PERMISSION = 1
		FROM [wms].[OP_WMS_ROLES_JOIN_CHECKPOINTS] [C]
		INNER JOIN [wms].[OP_WMS_LOGINS] [L] ON ([L].[ROLE_ID] = [C].[ROLE_ID])
		WHERE [C].[CHECK_ID] = @CHECK_ID
			AND [L].[LOGIN_ID] = @LOGIN_ID
 

	SELECT [W].[VALUE] [CODE_WAREHOUSE]
	INTO [#WAREHOUSE]
	FROM [wms].[OP_WMS_FN_SPLIT](@WAREHOUSE, '|') [W];

	SELECT [Z].[VALUE] [CODE_ZONE]
	INTO [#ZONE]
	FROM [wms].[OP_WMS_FN_SPLIT](@ZONE, '|') [Z];

	SELECT [C].[VALUE] [CODE_CLIENT]
	INTO [#CLIENT]
	FROM [wms].[OP_WMS_FN_SPLIT](@CLIENT_CODE, '|') [C];

	SELECT [L].[VALUE] [LOCATION]
	INTO [#LOCATION]
	FROM [wms].[OP_WMS_FN_SPLIT](@LOCATION, '|') [L];

	--
	


	--select  * from #WAREHOUSE
	--select * from #CLIENT
	SELECT 
		VIPSM.MATERIAL_ID,
		VIPSM.MATERIAL_NAME,
		VIPSM.IS_MASTER_PACK,
		VIPSM.QTY,
		VIPSM.AVAILABLE_QTY AS [CURRENTLY_AVAILABLE],
		VIPSM.STATUS_CODE
	FROM [wms].[OP_WMS_VIEW_INVENTORY_FOR_PICKING_BY_STATUS_MATERIAL] VIPSM
		INNER JOIN #WAREHOUSE W ON W.CODE_WAREHOUSE = VIPSM.CURRENT_WAREHOUSE
		LEFT JOIN #CLIENT C ON C.CODE_CLIENT = VIPSM.CLIENT_CODE	
	
	
	--SELECT
	--	[M].[MATERIAL_ID]
	--	,[M].[MATERIAL_NAME]
	--	,[M].[IS_MASTER_PACK]
	--	,SUM(CASE
	--		WHEN ISNULL([IL].[LOCKED_BY_INTERFACES], 0) = 1 AND @HAS_PERMISSION = 0 THEN
	--			0
	--		ELSE
	--			([IL].[QTY] - ISNULL([CIL].[COMMITED_QTY], 0))
	--		END ) [QTY]
	--	,SUM(CASE
	--		WHEN ISNULL([IL].[LOCKED_BY_INTERFACES], 0) = 1 AND @HAS_PERMISSION = 0 THEN
	--			0
	--		ELSE
	--			([IL].[QTY] - ISNULL([CIL].[COMMITED_QTY], 0))
	--		END ) AS [CURRENTLY_AVAILABLE]

	--FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
	--	INNER JOIN [wms].[OP_WMS_LICENSES] [L]
	--		ON [L].[LICENSE_ID] = [IL].[LICENSE_ID]
	--	INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [S]
	--		ON [S].[LOCATION_SPOT] = [L].[CURRENT_LOCATION]
	--	INNER JOIN [#WAREHOUSE] [W]
	--		ON [S].[WAREHOUSE_PARENT] = [W].[CODE_WAREHOUSE]
	--	LEFT JOIN [#ZONE] [Z]
	--		ON [Z].[CODE_ZONE] = [S].[ZONE]
	--	LEFT JOIN [#CLIENT] [C]
	--		ON [C].[CODE_CLIENT] = [L].[CLIENT_OWNER]
	--	INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
	--		ON [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
	--	LEFT JOIN [#LOCATION] [LS]
	--		ON [LS].[LOCATION] = [L].[CURRENT_LOCATION]
	--	LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CIL]
	--		ON [CIL].[MATERIAL_ID] = [IL].[MATERIAL_ID]
	--		AND [CIL].[LICENCE_ID] = [L].[LICENSE_ID]

 -- WHERE 
	--	[IL].[QTY] > 0
	--	  AND (ISNULL([IL].[LOCKED_BY_INTERFACES], 0) = 0 AND @HAS_PERMISSION = 1 AND ([IL].[QTY] - ISNULL([CIL].[COMMITED_QTY], 0)) > 0)
	--	  AND [L].[REGIMEN] = @REGIMEN
	--	  AND (
	--		 @ZONE IS NULL
	--		  OR [Z].[CODE_ZONE] IS NOT NULL
	--	  )
	--	  AND (
	--		  @CLIENT_CODE IS NULL
	--		  OR [C].[CODE_CLIENT] IS NOT NULL
	--	  )
	--	  AND (
	--		  @LOCATION IS NULL
	--		  OR [LS].[LOCATION] IS NOT NULL
	--	  )
 -- GROUP BY [M].[MATERIAL_ID]
 --         ,[M].[MATERIAL_NAME]
 --         ,[M].[IS_MASTER_PACK];
END;