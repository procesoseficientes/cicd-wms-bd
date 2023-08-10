-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	04-04-2016
-- Description:			Obtiene los documentos para un picking

  -- Modificado 2016-05-19
		-- pablo.aguilar
		-- Por motivo de retornar la fecha del documento.

-- Modificacion 11-07-2016 @ Sprint  ζ
					-- alberto.ruiz
					-- Se agrego columna de TOTAL_AMOUNT
  
/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[ERP_VIEW_DOC_FOR_PICKING]
*/
-- =============================================
CREATE VIEW [SONDA].[ERP_VIEW_DOC_FOR_PICKING]
AS
SELECT
		'' [SAP_REFERENCE]
		,'' [DOC_TYPE]  
		,'' [DESCRIPTION_TYPE] 
		,'' [CUSTOMER_ID] 
		,'' [COD_WAREHOUSE] 
		,'' [CUSTOMER_NAME] 
		,'' [WAREHOUSE_NAME]
		,'' [CODE_OPER] 
		,'' [CODE_SELLER]
		,'' [DOC_DATE]
		,'' [TOTAL_AMOUNT]
	/*SELECT
		[SAP_REFERENCE]
		,[DOC_TYPE]  COLLATE DATABASE_DEFAULT [DOC_TYPE]
		,[DESCRIPTION_TYPE] COLLATE DATABASE_DEFAULT [DESCRIPTION_TYPE]
		,[CUSTOMER_ID] COLLATE DATABASE_DEFAULT [CUSTOMER_ID]
		,[COD_WAREHOUSE] COLLATE DATABASE_DEFAULT [COD_WAREHOUSE]
		,[CUSTOMER_NAME] COLLATE DATABASE_DEFAULT [CUSTOMER_NAME]
		,[WAREHOUSE_NAME] COLLATE DATABASE_DEFAULT [WAREHOUSE_NAME]
		,[CODE_OPER] COLLATE DATABASE_DEFAULT [CODE_OPER]
		,[CODE_SELLER]
		,[DOC_DATE]
		,[TOTAL_AMOUNT]
	FROM
		OPENQUERY([ERP_SERVER],
					'
  SELECT
    o.DocNum SAP_REFERENCE
   ,''SO''   DOC_TYPE
   ,''Sales Order''  DESCRIPTION_TYPE
   ,o.CardCode  CUSTOMER_ID
   ,NULL COD_WAREHOUSE
   ,o.CardName CUSTOMER_NAME
   ,NULL WAREHOUSE_NAME
   ,o.U_oper  CODE_OPER
   ,o.SlpCode CODE_SELLER
   ,o.DocDate DOC_DATE
   ,o.DocTotal TOTAL_AMOUNT
  FROM Prueba.dbo.ORDR o
  WHERE o.DocStatus = ''O''
  UNION ALL
  SELECT 
    o.DocNum SAP_REFERENCE
   ,''IT'' DOC_TYPE
   ,''Inventory Transfer Request'' DESCRIPTION_TYPE
   ,NULL CUSTOMER_ID
   ,o1.WhsCode COD_WAREHOUSE
   ,NULL CUSTOMER_NAME
   ,o1.WhsName WAREHOUSE_NAME
   ,NULL CODE_OPER
   ,NULL CODE_SELLER
   ,NULL DOC_DATE
   ,0 TOTAL_AMOUNT
  FROM Prueba.dbo.OWTQ o
  INNER JOIN Prueba.dbo.OWHS o1
    ON o1.WhsCode = (SELECT TOP 1 w1.WhsCode FROM Prueba.dbo.WTQ1 w1 where w1.DocEntry = o.DocEntry)
  WHERE o.DocStatus = ''O''
    ');*/

