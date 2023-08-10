


CREATE VIEW [SONDA].[ERP_VIEW_PICKING]
AS

SELECT      null SAP_PICKING_ID ,
            null ERP_DOC ,
            null CUSTOMER_ID ,
            null CUSTOMER_NAME ,
            null SKU ,
            null SKU_DESCRIPTION ,
            null QTY
--    SELECT  SAP_PICKING_ID ,
--            ERP_DOC ,
--            CUSTOMER_ID ,
--            CUSTOMER_NAME ,
--            SKU ,
--            SKU_DESCRIPTION ,
--            QTY
--    FROM    OPENQUERY(ERP_SERVER,
--                      'SELECT     CAST(POD.DocEntry AS VARCHAR) + CAST(POD.LineNum AS VARCHAR) AS SAP_PICKING_ID, POD.DocEntry AS ERP_DOC, PO.CardCode AS CUSTOMER_ID, PO.CardName AS CUSTOMER_NAME, 
--                      POD.ItemCode AS SKU, POD.Dscription AS SKU_DESCRIPTION, POD.Quantity AS QTY
--FROM         [Prueba].dbo.RDR1 AS POD INNER JOIN
--                      [Prueba].dbo.ORDR AS PO ON PO.DocEntry = POD.DocEntry
--WHERE     (PO.DocType = ''I'') ');

