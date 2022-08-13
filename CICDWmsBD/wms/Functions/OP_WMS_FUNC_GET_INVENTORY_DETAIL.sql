-- =============================================
-- Autor:	 --
-- Fecha de Creación: 	--
-- Description:	  --

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-05-30 ErgonTeam@Sheik
-- Description:	 Se agrega el peso de las ubicaciones

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-08 @ Team REBORN - Sprint 
-- Description:	   Se agrega STATUS_NAME, BLOCKS_INVENTORY y COLOR

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-09-16 @ Team REBORN - Sprint 
-- Description:	   Se agrega tono y calibre

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20190725 GForce@Dublin
-- Descripcion:			Se agrega la informacion del proyecto en el que la licencia esta asignada

/*
-- Ejemplo de Ejecucion:
			SELECT * FROM [wms].[OP_WMS_FUNC_GET_INVENTORY_DETAIL]('C00030/LECHEHAPRO') 

*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FUNC_GET_INVENTORY_DETAIL] (
		@pMATERIAL_ID VARCHAR(50)
	)
RETURNS TABLE
	AS
  RETURN
	(SELECT
			[I].[CURRENT_WAREHOUSE]
			,[I].[CURRENT_LOCATION]
			,[I].[LICENSE_ID]
			,[I].[QTY]
			,[I].[CODIGO_POLIZA]
			,[I].[REGIMEN]
			,CAST(ISNULL([W].[WEIGHT_PERCENT], 0) AS DECIMAL(18,
											4)) [WEIGHT_PERCENT]
			,CASE ISNULL([W].[IS_OVERWEIGHT], 0)
				WHEN 0 THEN 'No'
				ELSE 'Si'
				END [IS_OVERWEIGHT]
			,[W].[MAX_WEIGHT]
			,[W].[WEIGHT_IN_TONS]
			,[I].[STATUS_NAME]
			,[I].[BLOCKS_INVENTORY]
			,[I].[COLOR]
			,[I].[TONE]
			,[I].[CALIBER]
			,[I].[PROJECT_CODE]
			,[I].[PROJECT_SHORT_NAME]
		FROM
			[wms].[OP_WMS_VIEW_INVENTORY_DETAIL] [I]
		LEFT JOIN [wms].[OP_WMS_VW_GET_LOCATIONS_WITH_WEIGHT] [W] ON [CURRENT_LOCATION] = [W].[LOCATION_SPOT]
		WHERE
			[MATERIAL_ID] = @pMATERIAL_ID
			AND [QTY] > 0);