

CREATE PROC [SONDA].[SWIFT_SP_GET_SBO_POH]
@DOC_ENTRY VARCHAR(50)
AS

DECLARE @DOC_NUM VARCHAR(50);

SELECT TOP 1 @DOC_NUM = ERP_DOC
FROM [SONDA].SWIFT_TXN_X_DOC_ERP
WHERE DOC_ENTRY = @DOC_ENTRY

DECLARE @SQL VARCHAR(MAX)
SELECT  @SQL = 'SELECT    TOP (1) po.DocNum, '+@DOC_ENTRY+' AS DocEntry, po.CardCode AS CardCode, po.CardName AS CardName, ''N'' AS HandWritten, ISNULL(t.TXN_CREATED_STAMP, GETDATE()) AS DocDate, po.Comments, 
                      po.DocCur AS DocCur, po.DocRate AS DocRate, CAST(NULL AS varchar) AS UFacSerie, CAST(NULL AS varchar) AS UFacNit, CAST(NULL AS varchar) AS UFacNom, CAST(NULL AS varchar) 
                      AS UFacFecha, CAST(NULL AS varchar) AS UTienda, CAST(NULL AS varchar) AS UStatusNc, CAST(NULL AS varchar) AS UnoExencion, CAST(NULL AS varchar) AS UtipoDocumento, 
                      CAST(NULL AS varchar) AS UUsuario, CAST(NULL AS varchar) AS UFacnum, CAST(NULL AS varchar) AS USucursal, CAST(NULL AS varchar) AS U_Total_Flete, CAST(NULL AS varchar) 
                      AS UTipoPago, CAST(NULL AS varchar) AS UCuotas, CAST(NULL AS varchar) AS UTotalTarjeta, CAST(NULL AS varchar) AS UFechap, CAST(NULL AS varchar) AS UTrasladoOC from  [SONDA].SWIFT_TXNS AS t INNER JOIN
   (select * from openquery ([ERPSERVER],''SELECT  po.DocNum as DocNum,    '+ @DOC_ENTRY+ ' AS DocEntry, po.CardCode AS CardCode, po.CardName AS CardName, ''''N'''' AS HandWritten,  po.Comments, 
                      po.DocCur AS DocCur, po.DocRate AS DocRate, CAST(NULL AS varchar) AS UFacSerie, CAST(NULL AS varchar) AS UFacNit, CAST(NULL AS varchar) AS UFacNom, CAST(NULL AS varchar) 
                      AS UFacFecha, CAST(NULL AS varchar) AS UTienda, CAST(NULL AS varchar) AS UStatusNc, CAST(NULL AS varchar) AS UNoExencion, CAST(NULL AS varchar) AS UTipoDocumento, 
                      CAST(NULL AS varchar) AS UUsuario, CAST(NULL AS varchar) AS UFacnum, CAST(NULL AS varchar) AS USucursal, CAST(NULL AS varchar) AS UTotalFlete, CAST(NULL AS varchar) 
                      AS UTipoPago, CAST(NULL AS varchar) AS UCuotas, CAST(NULL AS varchar) AS UTotalTarjeta, CAST(NULL AS varchar) AS UFechap, CAST(NULL AS varchar) AS UTrasladoOc                                            
FROM         [Prueba].dbo.OPOR AS po 
WHERE     (po.DocStatus = ''''O'''') AND (po.DocType = ''''I'''') AND (po.DocNum = '+@DOC_NUM+')  '')) as po ON po.DocEntry = t.SAP_REFERENCE WHERE     (t.TXN_TYPE = ''PUTAWAY'') AND (ISNULL(t.TXN_IS_POSTED_ERP, 0) = 0) ';

EXEC(@SQL);
