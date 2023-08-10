-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	2017-01-13 TeamErgon Sprint 1
-- Description:			    Vista que trae el detalle de las recepciones de sap


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-01-18 Team ERGON - Sprint ERGON 1
-- Description:	 Se agrega al select el campo OBJECT_TYPE

-- Modificacion 09-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
					-- alberto.ruiz
					-- Ajuste por intercompany
 
-- Modificacion 12-Jan-18 @ Nexus Team Sprint Ransey
					-- alberto.ruiz
					-- Se agrega columna [WhsCode]


/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[ERP_VIEW_RECEPTION_DOCUMENT_DETAIL]
					
*/
-- =============================================
CREATE VIEW [SONDA].[ERP_VIEW_RECEPTION_DOCUMENT_DETAIL]
AS


SELECT 
NULL   AS SAP_RECEPTION_ID --DOC_ENTRY
, null  ERP_DOC --DOC_NUM
, null AS PROVIDER_ID
, null AS PROVIDER_NAME
, null  AS SKU
, null  AS SKU_DESCRIPTION
, null AS QTY
, null as OBJECT_TYPE
, null AS LINE_NUM
,NULL COMMENTS
,null [MASTER_ID_SKU]
,'Alzahn' [OWNER_SKU]
,'Alzahn' [OWNER]
,null [ERP_WAREHOUSE_CODE]
--SELECT
--  *
--FROM OPENQUERY([ERP_SERVER], 'SELECT 
--		CAST( poD.DocEntry as varchar)  AS SAP_RECEPTION_ID --DOC_ENTRY
--		,po.DocNum AS ERP_DOC --DOC_NUM
--		,po.CardCode AS PROVIDER_ID
--		,po.CardName AS PROVIDER_NAME
-- 		,pod.ItemCode AS SKU
--		,pod.dscription AS SKU_DESCRIPTION
--		,pod.OpenQty AS QTY
--    ,pod.ObjType as OBJECT_TYPE
--		,pod.LineNum AS LINE_NUM
--		,CASE ISNULL(PO.COMMENTS,'''')
--			WHEN '''' THEN ''N/A''
--			ELSE PO.COMMENTS
--		END AS COMMENTS
--		,pod.ItemCode [MASTER_ID_SKU]
--		,''Arium'' [OWNER_SKU]
--		,''Arium'' [OWNER]
--		,POD.[WhsCode] [ERP_WAREHOUSE_CODE]
--	FROM [Me_Llega_DB].dbo.por1 POD
--	inner join [Me_Llega_DB].DBO.OPOR PO ON (po.DocEntry = pod.DocEntry)
--	where 
--		po.DocStatus=''O''
--		AND po.DocType=''I''
--		AND pod.OpenQty > 0 ')