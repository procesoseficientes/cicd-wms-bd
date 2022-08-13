-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Dec-17 @ Nexus Team Sprint HeyYouPikachu!
-- Description:			SP que obtiene la caja indicada
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_BOX_BY_ID]
					@BOX_ID = 'PC-4905-9/13'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_BOX_BY_ID](
	@BOX_ID VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @MATERIAL TABLE (
		[MATERIAL_ID] VARCHAR(50) NOT NULL PRIMARY KEY
		,[WAS_IMPLODED] INT NOT NULL
	)
	--
	DECLARE 
		@ERP_DOC VARCHAR(25) = ''
		,@WAVE_PICKING_ID INT
		,@SOURCE_TYPE VARCHAR(50) = '';
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene el documento de la caja
	-- ------------------------------------------------------------------------------------
	SELECT TOP 1 @ERP_DOC = [DT].[ERP_DOC]
	FROM [dbo].[OP_WMS_DISTRIBUTED_TASK] [DT]
	WHERE [DT].[BOX_ID] = @BOX_ID
		AND [DT].[STATUS] != 'PICKED'
	ORDER BY [DT].[CREATED_ON] DESC
	--
	PRINT '--> @ERP_DOC: ' + @ERP_DOC

	-- ------------------------------------------------------------------------------------
	-- Valida que encuentre la caja
	-- ------------------------------------------------------------------------------------
	IF @ERP_DOC = ''
	BEGIN
	    RAISERROR('Canasta no está asignada a un picking activo',16,1);
		RETURN;
	END

	-- ------------------------------------------------------------------------------------
	-- Obtiene la ola
	-- ------------------------------------------------------------------------------------
	SELECT @WAVE_PICKING_ID = [wms].[OP_WMS_FN_SPLIT_COLUMNS](@ERP_DOC,2,'-')
	--
	PRINT '------> @WAVE_PICKING_ID: ' + CAST(@WAVE_PICKING_ID AS VARCHAR)

	-- ------------------------------------------------------------------------------------
	-- Obtiene los materiales que implosionaron
	-- ------------------------------------------------------------------------------------
	INSERT INTO @MATERIAL
			([MATERIAL_ID], [WAS_IMPLODED])
	SELECT DISTINCT
		[CMP].[COMPONENT_MATERIAL]
		,1
	FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD]
	INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PH] ON ([PH].[PICKING_DEMAND_HEADER_ID] = [PDD].[PICKING_DEMAND_HEADER_ID])
	INNER JOIN [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [CMP] ON ([CMP].[MASTER_PACK_CODE] = [PDD].[MATERIAL_ID])
	WHERE [PDD].[PICKING_DEMAND_DETAIL_ID] > 0
		AND [PH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
		AND [PDD].[WAS_IMPLODED] = 1

	-- ------------------------------------------------------------------------------------
	-- Obtiene la fuente de la demanda
	-- ------------------------------------------------------------------------------------
	SELECT TOP 1 @SOURCE_TYPE = [PD].[SOURCE_TYPE]
	FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PD]
	WHERE [PD].[PICKING_DEMAND_HEADER_ID] > 0
		AND [PD].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
	
	-- ------------------------------------------------------------------------------------
	-- Muestra el resultado
	-- ------------------------------------------------------------------------------------
	SELECT DISTINCT
		[DT].[ERP_DOC]
		,CAST([DP].[WAVE_PICKING_ID_3PL] AS VARCHAR) [WAVE_PICKING_ID]
		,[DT].[BOX_ID]
		,[DT].[MATERIAL_ID]
		,[DT].[MATERIAL_NAME]
		,[DT].[QUANTITY]
		,[DT].[QUANTITY] [QUANTITY_ORIGINAL]
		,[DP].[ERP_DOC_DATE] [PICKED_DATETIME]
		,[DT].[STATUS]
		,CASE [DT].[STATUS]
			WHEN 'PICKED' THEN 'Despachado'
			ELSE 'Pendiente'
		END [STATUS_DESCRIPTION]
		,[DT].[LOGIN_ID]
		,[DT].[LOCATION_SPOT]
		,[DT].[BOX_ASSIGNED]
		,CASE
			WHEN [DT].[BOX_ASSIGNED] = 1 THEN 'Asignada'
			ELSE 'Pendiente'
		END [BOX_ASSIGNED_DESCRIPTION]
		,[DT].[BOX_NUMBER]
		,[DT].[TOTAL_BOXES]
		,[DP].[GATE]
		,[DP].[CLIENT_ID]
		,[DP].[CLIENT_NAME]
		,[DP].[CLIENT_ROUTE]
		,@SOURCE_TYPE [SOURCE_TYPE]
		,ISNULL(CAST([PD].[DOC_NUM] AS VARCHAR),'CONSOLIDADO') [SALE_ORDER]
		,ISNULL([M].[WAS_IMPLODED],0) [WAS_IMPLODED]
		,[DP].[ASSIGNED_TO_LINE] [PICKING_LINE]
	FROM [dbo].[OP_WMS_DISTRIBUTED_TASK] [DT]
	INNER JOIN [dbo].[OP_WMS_DEMAND_TO_PICK] [DP] ON (
		[DP].[ERP_DOCUMENT] = [DT].[ERP_DOC]
		AND [DP].[MATERIAL_ID] = [DT].[MATERIAL_ID]
	)
	LEFT JOIN @MATERIAL [M] ON ([M].[MATERIAL_ID] = [DT].[MATERIAL_ID])
	LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PD] ON (
		[PD].[WAVE_PICKING_ID] = [DP].[WAVE_PICKING_ID_3PL]
		AND [PD].[IS_CONSOLIDATED] = 0
	)
	WHERE [DT].[ERP_DOC] = @ERP_DOC
	AND [DT].[BOX_ID] = @BOX_ID
END