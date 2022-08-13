CREATE VIEW [wms].[OP_WMS_VIEW_CLIENTS_PENDING_TO_REPLICATE]
AS
SELECT     codcliente AS CLIENT_CODE, nomcliente AS CLIENT_NAME
FROM         [wms].OP_WMS_VIEW_ACUERDOS
WHERE     (codcliente NOT IN
                          (SELECT     ISNULL(CLIENT_ERP_CODE, '0') AS Expr1
                            FROM          [wms].OP_WMS_CLIENTS))
GROUP BY codcliente, nomcliente