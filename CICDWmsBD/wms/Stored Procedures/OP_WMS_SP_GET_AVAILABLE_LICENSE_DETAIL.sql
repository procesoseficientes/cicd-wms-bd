-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	5/3/2018 @ NEXUS-Team Sprint Capibara 
-- Description:			Obtiene el inventario disponible de la licencia tomando en cuenta el inventario comprometido

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_AVAILABLE_LICENSE_DETAIL]
					@LICENSE_ID = 317851
*/
-- =============================================
CREATE PROCEDURE [wms].OP_WMS_SP_GET_AVAILABLE_LICENSE_DETAIL (@LICENSE_ID INT)
AS
BEGIN
    SET NOCOUNT ON;
	--
    SELECT
        [IL].[LICENSE_ID]
       ,[M].[MATERIAL_ID]
       ,[IL].[MATERIAL_NAME]
       ,[IL].[QTY]
       ,ISNULL([CIL].[COMMITED_QTY], 0) [COMMITED_QTY]
       ,([IL].[QTY] - ISNULL([CIL].[COMMITED_QTY], 0)) [AVAILABLE_QTY]
       ,[M].[SERIAL_NUMBER_REQUESTS]
	   ,[M].[IS_CAR]
	   ,[IL].[VIN]
	   ,[M].[BATCH_REQUESTED]
       ,[IL].[BATCH]
       ,[IL].[DATE_EXPIRATION]
       ,[IL].[STATUS_ID]
	   ,[M].[HANDLE_TONE]
       ,[TCM].[TONE]
	   ,[M].[HANDLE_CALIBER]
       ,[TCM].[CALIBER]
      ,[SML].[STATUS_CODE]
      ,[SML].[STATUS_NAME]
    FROM
        [wms].[OP_WMS_INV_X_LICENSE] [IL]
    INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
    INNER JOIN [wms].[OP_WMS_STATUS_OF_MATERIAL_BY_LICENSE] [SML] ON([IL].[STATUS_ID] = [SML].[STATUS_ID])
    LEFT JOIN [wms].[OP_WMS_TONE_AND_CALIBER_BY_MATERIAL] [TCM] ON [TCM].[TONE_AND_CALIBER_ID] = [IL].[TONE_AND_CALIBER_ID]
    LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CIL] ON [CIL].[MATERIAL_ID] = [IL].[MATERIAL_ID]
                                                              AND [IL].[LICENSE_ID] = [CIL].[LICENCE_ID]
    WHERE
        [IL].[LICENSE_ID] = @LICENSE_ID;

END;
