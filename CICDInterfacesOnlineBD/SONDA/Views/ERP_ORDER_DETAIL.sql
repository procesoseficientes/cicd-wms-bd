﻿


CREATE VIEW [SONDA].[ERP_ORDER_DETAIL]
AS 
SELECT 
  NULL DOC_ENTRY,
  NULL ITEM_CODE,
  NULL OBJ_TYPE,
  NULL LINE_NUM

--SELECT *FROM OPENQUERY (ERP_SERVER,'SELECT
--  so.DocEntry DOC_ENTRY,
--  so.ItemCode ITEM_CODE,
--  so.ObjType AS OBJ_TYPE,
--  so.LineNum AS LINE_NUM
--FROM  [Prueba].dbo.RDR1 AS so ')

