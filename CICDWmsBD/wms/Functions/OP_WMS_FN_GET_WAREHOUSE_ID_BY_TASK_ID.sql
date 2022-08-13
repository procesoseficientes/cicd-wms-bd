 
-- =============================================
-- Autor:                    Gildardo.Alvarado
-- Fecha de Creacion:         18-Feb-2021 @ProcesosEficientes
-- Description:                Funcion para obtener la bodega a través del SERIAL_NUMBER O TASK_ID
 
/*
-- Ejemplo de Ejecucion:
        SELECT [wms].[OP_WMS_FN_GET_WAREHOUSE_ID_BY_TASK_ID](242210)
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_WAREHOUSE_ID_BY_TASK_ID]
(
    @_TASK_ID INT
)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @LABEL VARCHAR(50)
    --
    SELECT 
        @LABEL = [W].[NAME]
    FROM [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [TH] 
        INNER JOIN [wms].[OP_WMS_TASK_LIST] [TK] 
            ON ([TH].[TRANSFER_REQUEST_ID] = [TK].[TRANSFER_REQUEST_ID])
        INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W]
            ON ([TH].[WAREHOUSE_TO] = [W].[WAREHOUSE_ID])
    WHERE [TK].[SERIAL_NUMBER] = @_TASK_ID
 
    --
    RETURN @LABEL
END