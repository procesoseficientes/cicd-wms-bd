--CREATE SYNONYM [SONDA].[ERP_VIEW_DOC_FOR_PICKING] FOR [SWIFT_INTERFACES_ONLINE].[SONDA].[ERP_VIEW_DOC_FOR_PICKING];
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
	FROM [SWIFT_INTERFACES_ONLINE].[SONDA].[ERP_VIEW_DOC_FOR_PICKING];