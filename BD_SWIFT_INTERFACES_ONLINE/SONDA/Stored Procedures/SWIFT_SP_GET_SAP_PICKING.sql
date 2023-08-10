
CREATE PROC [SONDA].[SWIFT_SP_GET_SAP_PICKING]
@pERP_DOC VARCHAR(50)
AS
DECLARE @SQL VARCHAR(8000)
SELECT @SQL = 

 'select * from openquery (ERP_SERVER,''SELECT     CAST(POD.DocEntry AS VARCHAR) + CAST(POD.LineNum AS VARCHAR) AS SAP_PICKING_ID, POD.DocEntry AS ERP_DOC, PO.CardCode AS CUSTOMER_ID, PO.CardName AS CUSTOMER_NAME, 
                      POD.ItemCode AS SKU, POD.Dscription AS SKU_DESCRIPTION, POD.Quantity AS QTY
FROM         [Prueba].dbo.RDR1 AS POD INNER JOIN
                      [Prueba].dbo.ORDR AS PO ON PO.DocEntry = POD.DocEntry
WHERE     (PO.DocType = ''''I'''') AND (POD.DocEntry = '+@pERP_DOC+')  '')'

EXEC (@SQL)

