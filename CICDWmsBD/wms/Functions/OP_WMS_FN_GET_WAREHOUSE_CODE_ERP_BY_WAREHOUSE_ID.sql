



-- =============================================
-- Autor: Gildardo.Alvarado
-- Fecha de Creacion: 18-Feb-2021 @ProcesosEficientes
-- Description: Funcion para obtener el codigo ERP de la bodega a través del del ID



/*
-- Ejemplo de Ejecucion:
SELECT [wms].[OP_WMS_FN_GET_WAREHOUSE_CODE_ERP_BY_WAREHOUSE_ID]('BODEGA_SPS')
*/
-- =============================================
CREATE FUNCTION [wms].[OP_WMS_FN_GET_WAREHOUSE_CODE_ERP_BY_WAREHOUSE_ID]
(
@_WAREHOUSE_CODE_ERP VARCHAR(50)
)
RETURNS VARCHAR(50)
AS
BEGIN
DECLARE @LABEL VARCHAR(50)
--
SELECT
@LABEL = [W].[ERP_WAREHOUSE]
FROM [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [TH]
INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W]
ON ([TH].[WAREHOUSE_TO] = [W].[WAREHOUSE_ID])
WHERE W.WAREHOUSE_ID = @_WAREHOUSE_CODE_ERP



--
RETURN @LABEL
END