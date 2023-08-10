
-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		10/10/2017 @ NEXUS-Team Sprint eNave 
-- Description:			    Vista para ver el encabezado de las facturas de ERP

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].[ERP_VIEW_INVOICE_HEADER]
*/
-- =============================================
CREATE VIEW [SONDA].[ERP_VIEW_INVOICE_HEADER]
AS (

SELECT 
		    NULL DocEntry
			,null DocNum
			,null CardCode
			,null CardName
			,null Comments
			,null DocDate
			,null DocDueDate
			,null DocStatus
			,null CANCELED
			,null SlpCode 
			,null DocTotal
			,'Alza' Owner

	--SELECT * FROM OPENQUERY([ERP_SERVER],
	--'
	--	SELECT 
	--		DocEntry
	--		,DocNum
	--		,CardCode
	--		,CardName
	--		,Comments
	--		,DocDate
	--		,DocDueDate
	--		,DocStatus
	--		,CANCELED
	--		,SlpCode 
	--		,DocTotal
	--		,''Arium'' Owner
	--	FROM ME_LLEGA_DB.dbo.OINV
	--	WHERE CANCELED = ''N''
	--		AND DocStatus = ''O''
	--		AND DocDate > current_timestamp - 400
	--')
)

