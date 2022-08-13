-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	31-Jan-2018 Reborn@Trotzdem
-- Description:			Obtiene el volumen ocupado de la ubicacion.

/*
-- Ejemplo de Ejecucion:
				SELECT [wms].[OP_WMS_FN_GET_VOLUMEN_FROM_LOCATION]('B0-RD-01')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_VOLUMEN_FROM_LOCATION]
    (      
      @LOCATION VARCHAR(25)
    )
RETURNS FLOAT
AS
    BEGIN
        DECLARE @VOLUME NUMERIC(18,4) = 0;
	
        
        SELECT @VOLUME = ISNULL(SUM([IL].[QTY] * [IL].[VOLUME_FACTOR]),0)
        FROM [wms].[OP_WMS_INV_X_LICENSE] [IL] 
        INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON(
          [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
        )
        INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON(
          [L].[LICENSE_ID] = [IL].[LICENSE_ID]
        )
        WHERE [L].[CURRENT_LOCATION] = @LOCATION

        RETURN @VOLUME;
    END;