


CREATE VIEW [SONDA].[ERP_VIEW_PURCHASE_ORDER_DETAIL]
AS 

SELECT     
 null ItemCode,
 null DocEntry,
 null ObjType, 
 null Line_Num, 
 '01' Warehouse_Code, 
                      'ST'  Sales_Unit
--SELECT *FROM OPENQUERY (ERP_SERVER,'SELECT     
-- po.ItemCode,
-- po.DocEntry,
-- po.ObjType, 
-- po.LineNum  Line_Num, 
-- ISNULL(po.WhsCode, ''01'') AS Warehouse_Code, 
--                      ''ST'' AS Sales_Unit
--                      FROM         
--                      [Prueba].dbo.POR1 AS po   ')

