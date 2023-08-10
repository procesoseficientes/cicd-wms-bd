CREATE VIEW  [SONDA].[SWIFT_VIEW_SBO_PURCHASE_ORDER_DETAIL]  
AS 
SELECT     t.SAP_REFERENCE AS Doc_Entry, t.TXN_QTY AS Quantity, t.TXN_CODE_SKU AS Item_Code, po.ObjType, ISNULL(po.Line_Num, - 1) AS Line_Num, ISNULL(po.Warehouse_Code, '01') AS Warehouse_Code, 
                      'ST' AS Sales_Unit
FROM         [SONDA].SWIFT_TXNS AS t LEFT OUTER JOIN
                      [SWIFT_INTERFACES].[SONDA].[ERP_VIEW_PURCHASE_ORDER_DETAIL] AS po ON t.TXN_CODE_SKU COLLATE SQL_Latin1_General_CP1_CI_AS = po.ItemCode AND t.SAP_REFERENCE = po.DocEntry
WHERE     (t.TXN_CATEGORY = 'PO') AND (ISNULL(t.TXN_IS_POSTED_ERP, 0) = 0) ;
