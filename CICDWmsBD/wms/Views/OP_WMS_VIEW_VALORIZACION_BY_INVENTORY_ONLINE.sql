
/*
Pesona: Gildardo Alvarado
Fecha de creación: 16/02/2021
Descripcion: Query que valida una inner en el inventario en linea
*/

CREATE VIEW [wms].[OP_WMS_VIEW_VALORIZACION_BY_INVENTORY_ONLINE]
AS
SELECT [V].[LICENSE_ID],
[V].[VALOR_UNITARIO],
[V].[TOTAL_VALOR],
[V].[MATERIAL_ID]
FROM [wms].[OP_WMS_VIEW_VALORIZACION] [V]
WHERE [V].[QTY] > 0;
