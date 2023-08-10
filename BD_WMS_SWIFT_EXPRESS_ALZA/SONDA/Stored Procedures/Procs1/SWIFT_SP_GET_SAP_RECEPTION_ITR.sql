-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	4-2-2016
-- Description:			obtiene una solicitud de recepcion por devolucion 

-- Modificado 26-01-2016
				-- alberto.ruiz
				-- Se agrego validacion de qty mayor a cero

/*
-- Ejemplo de Ejecucion:
        USE SWIFT_EXPRESS
        GO
        
        DECLARE @RC int
        DECLARE @pERP_DOC varchar(50)
        
        SET @pERP_DOC = '1678' 
        
        EXECUTE @RC = [SONDA].SWIFT_SP_GET_SAP_RECEPTION_ITR @pERP_DOC
        GO
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_GET_SAP_RECEPTION_ITR 
	@pERP_DOC VARCHAR(50)
AS
BEGIN
  DECLARE @SQL VARCHAR(8000)
    SELECT
    @SQL = '
	SELECT
		SAP_RECEPTION_ID
		,ERP_DOC
		,PROVIDER_ID
		,PROVIDER_NAME
		,SKU
		,[dbo].[FUNC_REMOVE_SPECIAL_CHARS](SKU_DESCRIPTION) AS SKU_DESCRIPTION
		,QTY
		,QTY_SOURCE
		,SHIPPING_TO
		,SELLER_NAME
		,COMMENTS
		,TARGET_WAREHOUSE
		,SORUCE_WAREHOUSE
		,LINE_NUM
		,COMMENTS
	 FROM openquery ([ERPSERVER],''
		SELECT
			CAST(POD.DocEntry AS VARCHAR) + CAST(POD.LineNum AS VARCHAR) AS SAP_RECEPTION_ID
			 ,PO.DocNum AS ERP_DOC
			 ,POD.WhsCode AS PROVIDER_ID
			 ,o1.WhsName AS PROVIDER_NAME
			 ,POD.ItemCode AS SKU
			 ,POD.Dscription AS SKU_DESCRIPTION
			 ,POD.OpenQty AS QTY
			 ,POD.OpenQty AS QTY_SOURCE
			 ,PO.Address2 AS SHIPPING_TO
			 ,SE.SlpName AS SELLER_NAME			 
			 ,POD.WhsCode TARGET_WAREHOUSE
			 ,POD.FromWhsCod SORUCE_WAREHOUSE
			 ,POD.LineNum AS LINE_NUM
			 ,CASE ISNULL(PO.COMMENTS,'''''''')
				WHEN '''''''' THEN ''''N/A''''
				ELSE PO.COMMENTS
		END AS COMMENTS
		FROM [PRUEBA].dbo.WTQ1 AS POD INNER JOIN [PRUEBA].dbo.OWTQ AS PO ON PO.DocEntry = POD.DocEntry
		INNER JOIN [PRUEBA].dbo.OSLP AS SE ON SE.SlpCode = PO.SlpCode
		INNER JOIN [PRUEBA].dbo.OWHS o1 ON POD.WhsCode = o1.WhsCode
	WHERE  
		po.DocStatus=''''O'''' 
		AND pod.LineStatus=''''O'''' 
		AND (PO.DocType = ''''I'''')   
		AND POD.OpenQty > 0
		AND (PO.DocNum = ' + @pERP_DOC+') 
'')'

	PRINT '@SQL: ' + @SQL
	EXEC (@SQL)
END
