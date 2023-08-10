


CREATE PROC [SONDA].[SWIFT_SP_GET_SBO_SOSS]
@DOC_NUM VARCHAR(50), @DOC_ENTRY VARCHAR(50)
AS
DECLARE @SQL VARCHAR(8000)
SELECT  @SQL = 'SELECT     t.TXN_ID AS TransactionId, '''+@DOC_ENTRY+''' AS DocEntry, t.TXN_CODE_SKU AS ItemCode, ISNULL(po.LineNum, - 1) AS LineNum, t.TXN_SERIE,Txn_Serie  as TxnSerie
FROM         (SELECT     t.TXN_ID, t.MANIFEST_SOURCE, t.SAP_REFERENCE, t.TASK_SOURCE_ID, t.TXN_TYPE, t.TXN_DESCRIPTION, t.TXN_CATEGORY, t.TXN_CREATED_STAMP, t.TXN_OPERATOR_ID, 
                                              t.TXN_OPERATOR_NAME, t.TXN_CODE_SKU, t.TXN_DESCRIPTION_SKU, t.TXN_QTY, t.HEADER_REFERENCE, t.TXN_ATTEMPTED_WITH_ERROR, t.TXN_IS_POSTED_ERP, 
                                              t.TXN_POSTED_ERP, t.TXN_POSTED_RESPONSE, T.TXN_SERIE
                       FROM          [SONDA].SWIFT_TXNS AS t ) AS t LEFT OUTER JOIN	
		(select * from openquery ([ERPSERVER],
		'' 
			SELECT      
				po.LineNum AS LineNum 
				,po.ItemCode ItemCode
				,po.DocEntry DocEntry
			FROM          
				[Prueba].dbo.RDR1 AS po  
			WHERE 
				(po.DocEntry = '+@DOC_ENTRY+')  
		'')) as po  ON t.TXN_CODE_SKU COLLATE SQL_Latin1_General_CP850_CI_AS = po.ItemCode 
WHERE     (t.TXN_TYPE = ''PICKING'') AND (ISNULL(t.TXN_IS_POSTED_ERP, 0) = 0)   
AND t.SAP_REFERENCE = '+@DOC_NUM+'
';
EXEC(@SQL);
