


CREATE PROC [SONDA].[SWIFT_SP_GET_SBO_SOD]
@DOC_NUM VARCHAR(50), @DOC_ENTRY VARCHAR(50)
AS
DECLARE @SQL VARCHAR(8000)
SELECT  @SQL = '	
SELECT t.TXN_ID as TransactionId,cast('+@DOC_ENTRY+' as varchar) as DocEntry,
  cast( t.SAP_REFERENCE as int) AS DocNum,
  t.TXN_QTY AS Quantity,
  t.TXN_CODE_SKU COLLATE SQL_Latin1_General_CP1_CI_AS AS ItemCode,
  so.ObjType COLLATE SQL_Latin1_General_CP1_CI_AS AS ObjType,
  ISNULL(so.LineNum, -1) AS LineNum
FROM [SONDA].SWIFT_TXNS AS t
LEFT OUTER JOIN
		(select * from openquery ([ERPSERVER],
		'' SELECT DISTINCT
				so.DocEntry DocEntry,
				so.ItemCode  AS ItemCode,
				so.ObjType  AS ObjType,
				so.LineNum AS LineNum
			FROM  
				[Prueba].dbo.RDR1 AS so  
			WHERE so.ItemCode IS NOT NULL
				AND (so.DocEntry = '+@DOC_ENTRY+')  				
		'')) as so  ON t.TXN_CODE_SKU COLLATE SQL_Latin1_General_CP850_CI_AS = so.ItemCode  
WHERE (t.TXN_TYPE = ''PICKING'')
AND (ISNULL(t.TXN_IS_POSTED_ERP, 0) = 0)
AND t.SAP_REFERENCE = '+@DOC_NUM+'
';
EXEC(@SQL);
