-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/8/2017 @ NEXUS-Team Sprint HeyYouPikachu 
-- Description:			Obtiene las lineas de picking de las bodegas asociadas al usuario

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_PICKING_LINE_BY_LOGIN]
					@LOGIN = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_PICKING_LINE_BY_LOGIN](
	@LOGIN VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	SELECT DISTINCT [C].[PARAM_TYPE] ,
						[C].[PARAM_GROUP] ,
						[C].[PARAM_GROUP_CAPTION] ,
						[C].[PARAM_NAME] ,
						[C].[PARAM_CAPTION] ,
						[C].[NUMERIC_VALUE] ,
						[C].[MONEY_VALUE] ,
						[C].[TEXT_VALUE] ,
						[C].[DATE_VALUE] ,
						[C].[RANGE_NUM_START] ,
						[C].[RANGE_NUM_END] ,
						[C].[RANGE_DATE_START] ,
						[C].[RANGE_DATE_END] ,
						[C].[SPARE1] ,
						[C].[SPARE2] ,
						[C].[DECIMAL_VALUE] ,
						[C].[SPARE3] ,
						[C].[SPARE4] ,
						[C].[SPARE5] ,
						[C].[COLOR]
	FROM [wms].[OP_WMS_WAREHOUSES] [W]
	INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [SS] ON [SS].[WAREHOUSE_PARENT] = [W].[WAREHOUSE_ID]
	INNER JOIN [wms].[OP_WMS_CONFIGURATIONS] [C] ON [C].[PARAM_NAME] = [SS].[LINE_ID] AND [C].[PARAM_GROUP] = 'LINEAS_PICKING'
	INNER JOIN [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU] ON [WU].[WAREHOUSE_ID] = [W].[WAREHOUSE_ID]
	WHERE [USE_PICKING_LINE] = 1
		AND [WU].[LOGIN_ID] = @LOGIN
		AND [C].[PARAM_NAME] <> 'N/A'
		AND [C].[PARAM_NAME] <> 'GENERAL'
END