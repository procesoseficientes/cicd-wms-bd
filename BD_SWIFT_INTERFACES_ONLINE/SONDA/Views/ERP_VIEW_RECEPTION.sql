
-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		09-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- Description:			    Ajuste por intercompany

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].[ERP_VIEW_RECEPTION]
*/
-- =============================================
CREATE VIEW [SONDA].[ERP_VIEW_RECEPTION]
AS 
SELECT 
	  null [SAP_RECEPTION_ID]
	 ,null [ERP_DOC]
	 ,null [PROVIDER_ID]
	 ,null [PROVIDER_NAME]
	 ,null [SKU]
	 ,null [SKU_DESCRIPTION]
	 ,null [QTY]
	 ,null [MASTER_ID_PROVIDER]
	 ,null [OWNER]
--FROM OPENQUERY(ERP_SERVER,'SELECT 
--    CAST( poD.DocEntry as varchar) + CAST(poD.LineNum as varchar)			 AS SAP_RECEPTION_ID,
--    poD.DocEntry				AS ERP_DOC,
--	po.CardCode			AS PROVIDER_ID,
--	po.CardName		AS PROVIDER_NAME,
-- 	pod.ItemCode 					AS SKU ,
--	pod.dscription  		AS SKU_DESCRIPTION,
--	pod.Quantity					AS QTY 
--	,po.CardCode [MASTER_ID_PROVIDER]
--	,''Arium'' [OWNER]
--FROM
--	[Prueba].dbo.por1 POD inner join  
--	[Prueba].DBO.OPOR   PO ON 
--	po.DocEntry = pod.DocEntry
--	where 
----po.DocStatus=''O''  and 
--  po.DocType=''I''	')

