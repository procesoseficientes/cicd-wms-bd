-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	3/21/2018 @ GFORCE-Team Sprint Anemona
-- Description:			Obtiene la informacion de la ubicacion


-- Modificacion			12-Dic-19 @ G-Force Team Sprint Lima
-- autor:				jonathan.salvador
-- Historia:			Product Backlog Item 33554: Consulta de propiedades de ubicacion
-- Descripcion:			Se agrega la columna para verificar si permite picking rapido

-- Autor:				henry.rodriguez
-- Modificacion			03-Enero-2020 - G-Force@Oklahoma
-- Descripcion:			Se corrige query al momento de obtener el peso y volumen.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_LOCATION_INFO]
					@LOCATION_SPOT = 'B01-R01-C07-ND'

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LOCATION_INFO] (@LOCATION_SPOT VARCHAR(25))
AS
BEGIN
    SET NOCOUNT ON;
    --

    -- ------------------------------------------------------------------------------------
    -- Se obtienen las variables de la ubicacion
    -- ------------------------------------------------------------------------------------
    SELECT TOP (1)
        [SS].[LOCATION_SPOT],
        SUM(ISNULL([IL].[WEIGTH], 0) * [IL].[QTY]) [LOCATION_WEIGHT],
        [SS].[MAX_WEIGHT],
        SUM(ISNULL([IL].[VOLUME_FACTOR], 0) * [IL].[QTY]) [LOCATION_VOLUME],
        [SS].[VOLUME] [MAX_VOLUME],
        [SS].[MAX_MT2_OCCUPANCY],
        ISNULL([L].[USED_MT2], 0) [USED_MT2]
    INTO [#LOCATION]
    FROM [wms].[OP_WMS_LICENSES] [L]
        INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
            ON [IL].[LICENSE_ID] = [L].[LICENSE_ID]
        INNER JOIN [wms].[OP_WMS_SHELF_SPOTS] [SS]
            ON [SS].[LOCATION_SPOT] = [L].[CURRENT_LOCATION]
    WHERE [SS].[LOCATION_SPOT] = @LOCATION_SPOT
    GROUP BY [SS].[MAX_WEIGHT],
             [SS].[VOLUME],
             [SS].[LOCATION_SPOT],
             [SS].[MAX_MT2_OCCUPANCY],
             [L].[USED_MT2];

    -- ------------------------------------------------------------------------------------
    -- Despliega el resultado final
    -- ------------------------------------------------------------------------------------
    SELECT [SS].[LOCATION_SPOT],
           [SS].[WAREHOUSE_PARENT],
           [SS].[SPOT_TYPE],
           [SS].[ZONE],
           [SS].[ALLOW_PICKING],
           [SS].[ALLOW_STORAGE],
           [SS].[ALLOW_REALLOC],
           [SS].[ALLOW_FAST_PICKING],
           CASE
               WHEN [SS].[SPOT_TYPE] = 'PISO' THEN
                   CASE
                       WHEN ([SS].[MAX_MT2_OCCUPANCY] - (ISNULL([L].[USED_MT2], 0))) > 0 THEN
                           [SS].[MAX_MT2_OCCUPANCY] - (ISNULL([L].[USED_MT2], 0))
                       ELSE
                           0
                   END
               ELSE
                   CASE
                       WHEN [L].[LOCATION_VOLUME] > 0 THEN
                           [SS].[VOLUME] - ([L].[LOCATION_VOLUME])
                       ELSE
                           [SS].[VOLUME]
                   END
           END [AVAILABLE_VOLUME],
           CASE
               WHEN [L].[LOCATION_WEIGHT] > 0 THEN
                   [SS].[MAX_WEIGHT] - ([L].[LOCATION_WEIGHT])
               ELSE
                   [SS].[MAX_WEIGHT]
           END [AVAILABLE_WEIGHT]
    FROM [wms].[OP_WMS_SHELF_SPOTS] [SS]
        LEFT JOIN [#LOCATION] [L]
            ON [L].[LOCATION_SPOT] = [SS].[LOCATION_SPOT]
    WHERE [SS].[LOCATION_SPOT] = @LOCATION_SPOT;
END;