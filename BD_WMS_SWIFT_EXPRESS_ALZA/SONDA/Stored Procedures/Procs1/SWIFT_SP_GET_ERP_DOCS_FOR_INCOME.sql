-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	3-2-2016
-- Description:			obtiene los documentos bases de erp para basarse una recepcion

-- Modificado Fecha
-- anonymous
-- sin motivo

/*
-- Ejemplo de Ejecucion:
                
        EXECUTE @RC = [SONDA].SWIFT_SP_GET_ERP_DOCS_FOR_INCOME
*/
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ERP_DOCS_FOR_INCOME]
AS
BEGIN	
	
	SET NOCOUNT ON;

    DECLARE @SQL VARCHAR(8000)
	SELECT
	@SQL =
	'SELECT *
	FROM openquery ([ERPSERVER],''
		SELECT
			P.DocEntry SAP_REFERENCE
			,''''PO'''' DOC_TYPE
			,''''Pusher Order'''' DESCRIPTION_TYPE
			,P.CardCode CUSTOMER_ID
			,NULL COD_WAREHOUSE
			,P.CardName CUSTOMER_NAME
			,NULL WAREHOUSE_NAME
		FROM PRUEBA.dbo.OPOR P
		WHERE P.DocStatus = ''''O''''
		UNION ALL
		SELECT 
			o.DocNum SAP_REFERENCE
			,''''IT'''' DOC_TYPE
			,''''Inventory Transfer Request'''' DESCRIPTION_TYPE
			,NULL CUSTOMER_ID
			,w.FromWhsCod COD_WAREHOUSE
			,NULL CUSTOMER_NAME
			,o1.WhsName WAREHOUSE_NAME
		FROM PRUEBA.dbo.OWTQ o
		INNER JOIN PRUEBA.dbo.WTQ1 w ON o.DocEntry = w.DocEntry and w.LineNum =0
		INNER JOIN PRUEBA.dbo.OWHS o1 ON w.FromWhsCod = o1.WhsCode 
		WHERE o.DocStatus = ''''O''''
	'')'
	EXEC (@SQL)
END
