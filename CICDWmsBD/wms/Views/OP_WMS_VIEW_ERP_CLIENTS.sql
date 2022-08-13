CREATE VIEW [wms].OP_WMS_VIEW_ERP_CLIENTS
AS
SELECT     codcliente AS CLIENT_CODE, nomcliente AS CLIENT_NAME
FROM         [wms].OP_WMS_VIEW_ACUERDOS
GROUP BY codcliente, nomcliente