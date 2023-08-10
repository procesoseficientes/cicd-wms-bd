
-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		10/10/2017 @ NEXUS-Team Sprint eNave 
-- Description:			    Vista para ver el detalle de las facturas de ERP

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].[ERP_VIEW_INVOICE_DETAIL]
*/
-- =============================================
CREATE VIEW [SONDA].[ERP_VIEW_INVOICE_DETAIL]
AS (

SELECT 
			 null DocEntry
			,null LineNum
			,null ItemCode
			,null  ItemName
			,null Quantity
			,null OpenQty
			,null Price
			,null  DiscPercent
			,null LineTotal
			,'Sonda' Owner
	--SELECT * FROM OPENQUERY([ERP_SERVER],'
	--	SELECT 
	--		DocEntry
	--		,LineNum
	--		,ItemCode
	--		,Dscription ItemName
	--		,Quantity
	--		,OpenQty
	--		,Price
	--		,DiscPrcnt DiscPercent
	--		,LineTotal
	--		,''Arium'' Owner
	--	FROM ME_LLEGA_DB.dbo.INV1
	--')
)

