
CREATE PROC [SONDA].[SWIFT_SP_GET_SBO_POD]
@DOC_ENTRY VARCHAR(50)
AS
DECLARE @DocNum VARCHAR(MAX) 

SELECT @DocNum = COALESCE(@DocNum + ', ', '') +   CAST(ERP_DOC AS VARCHAR(50))
FROM [SONDA].SWIFT_TXN_X_DOC_ERP
WHERE DOC_ENTRY = @DOC_ENTRY

DECLARE @SQL VARCHAR(8000)
SELECT  @SQL = 'SELECT   t.TXN_ID as TransactionId,  ISNULL(po.DocNum,-1) AS DocNum, cast(t.SAP_REFERENCE as varchar) AS DocEntry, t.TXN_QTY AS Quantity, t.TXN_CODE_SKU AS ItemCode, po.ObjType, ISNULL(po.LineNum, - 1)  AS LineNum, ISNULL(po.WarehouseCode, ''01'') AS WarehouseCode, 
                      ''ST'' AS SalesUnit , po.Quantity AS QuantityErp, po.DocEntry as DocEntryErp
FROM
(
	select  
		t.TXN_ID,
		h.DOC_SAP_RECEPTION SAP_REFERENCE ,
		d.ALLOCATED TXN_QTY ,
		d.CODE_SKU TXN_CODE_SKU ,
		t.TXN_IS_POSTED_ERP,
		t.TXN_TYPE 
	from [SONDA].SWIFT_RECEPTION_HEADER h
		inner join [SONDA].SWIFT_RECEPTION_DETAIL d
		on  h.RECEPTION_HEADER = d.RECEPTION_HEADER 
		inner join (
			select top 1  t.TASK_SOURCE_id TXN_ID, t.TXN_TYPE, t.TXN_IS_POSTED_ERP, tsk.RECEPTION_NUMBER  from [SONDA].SWIFT_TXNS t 
				inner join [SONDA].SWIFT_TASKS  tsk 
				on t.TASK_SOURCE_id = tsk.TASK_ID
				where t.SAP_REFERENCE='+@DOC_ENTRY+'
				and  (t.TXN_TYPE = ''PUTAWAY'') AND (ISNULL(t.TXN_IS_POSTED_ERP, 0) = 0)
		) as t 
		on t.RECEPTION_NUMBER = h.RECEPTION_HEADER 
	where DOC_SAP_RECEPTION ='+@DOC_ENTRY+' 


) AS t INNER JOIN
   (select * from openquery ([ERPSERVER],'' SELECT  po.ItemCode, po.DocEntry, po.ObjType,  po.LineNum  LineNum
											, ISNULL(po.WhsCode, ''''01'''') AS WarehouseCode
											, ''''ST'''' AS SalesUnit , po.Quantity, op.DocNum	
											FROM  [Prueba].dbo.POR1 AS po  
												INNER JOIN [Prueba].dbo.opor op ON po.DocEntry = op.DocEntry
											WHERE  op.DocNum IN ( '+@DocNum+')  '')) as po 
   ON t.TXN_CODE_SKU COLLATE SQL_Latin1_General_CP850_CI_AS = po.ItemCode 
WHERE     (t.TXN_TYPE = ''PUTAWAY'') AND (ISNULL(t.TXN_IS_POSTED_ERP, 0) = 0) 
AND t.SAP_REFERENCE = '+@DOC_ENTRY+'
   ';
EXEC(@SQL);
