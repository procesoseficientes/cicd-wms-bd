-- =============================================
-- Autor:				pablo.aguilar
-- Fecha de Creacion: 	16-Apr-18 @ G-FORCE Team Sprint buho 
-- Description:			SP que obtiene el proyecto  y orden de venta de una reubicación parcial
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_GET_INFO_OF_NO_INMEDIATE_PICKING] @WAVE_PICKING_ID = 4974
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_INFO_OF_NO_INMEDIATE_PICKING] (@WAVE_PICKING_ID INT)
AS
BEGIN
	SET NOCOUNT ON;
	--	
	SELECT
		ISNULL([PROJECT], '') [PROJECT]
		,ISNULL([CLIENT_CODE], '') [CLIENT_CODE]
		,ISNULL([DOC_NUM], '') [DOC_NUM]
	FROM
		[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
	WHERE
		[WAVE_PICKING_ID] = @WAVE_PICKING_ID;


END;