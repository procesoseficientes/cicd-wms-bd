
-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	26-01-2016
-- Description:			Obtiene una recepcion

/*
-- Ejemplo de Ejecucion:
        EXEC [SONDA].[SWIFT_SP_GET_SAP_RECEPTION] @pERP_DOC = 8
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_SAP_RECEPTION]
	@pERP_DOC VARCHAR(50)
AS
BEGIN
	DECLARE @SQL VARCHAR(8000)
	SELECT @SQL = 'select * from openquery ([ERPSERVER],''SELECT 
		CAST( poD.DocEntry as varchar) + CAST(poD.LineNum as varchar) AS SAP_RECEPTION_ID
		,po.DocNum AS ERP_DOC
		,po.CardCode AS PROVIDER_ID
		,po.CardName AS PROVIDER_NAME
 		,pod.ItemCode AS SKU
		,pod.dscription AS SKU_DESCRIPTION
		,pod.OpenQty AS QTY
		,pod.LineNum AS LINE_NUM
		,CASE ISNULL(PO.COMMENTS,'''''''')
			WHEN '''''''' THEN ''''N/A''''
			ELSE PO.COMMENTS
		END AS COMMENTS
	FROM
	[Prueba].dbo.por1 POD
	inner join [Prueba].DBO.OPOR PO ON (po.DocEntry = pod.DocEntry)
	where 
		po.DocStatus=''''O''''
		AND po.DocType=''''I''''
		AND pod.OpenQty > 0
		AND (po.DocNum = '+@pERP_DOC +')  '')'

	PRINT '@SQL: ' + @SQL
	EXEC (@SQL)
END
