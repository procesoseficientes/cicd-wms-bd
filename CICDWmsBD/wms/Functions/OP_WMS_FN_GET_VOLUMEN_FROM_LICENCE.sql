-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	31-Jan-2018 Reborn@Trotzdem
-- Description:			Obtiene el volumen de la licencia

/*
-- Ejemplo de Ejecucion:
				SELECT [wms].[OP_WMS_FN_GET_VOLUMEN_FROM_LICENCE](418563)
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_VOLUMEN_FROM_LICENCE]
    (      
      @LICENSE_ID INT
    )
RETURNS FLOAT
AS
    BEGIN
        DECLARE @VOLUME NUMERIC(18,4) = 0;
	
        
        SELECT @VOLUME = ISNULL(SUM([IL].[QTY] * [IL].[VOLUME_FACTOR]), 0)
        FROM [wms].[OP_WMS_INV_X_LICENSE] [IL] 
        INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON(
          [M].[MATERIAL_ID] = [IL].[MATERIAL_ID]
        )
        WHERE [IL].[LICENSE_ID] = @LICENSE_ID

        RETURN @VOLUME;
    END;