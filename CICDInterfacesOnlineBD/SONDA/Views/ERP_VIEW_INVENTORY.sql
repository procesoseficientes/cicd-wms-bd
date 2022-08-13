
-- =============================================
-- Autor:				ppablo.loukota
-- Fecha de Creacion: 	16-12-2015
-- Description:			Vista que obtiene detalles de bodegas 

/*
-- Ejemplo de Ejecucion:
				CREATE VIEW [SONDA].[ERP_VIEW_INVENTORY]
*/
-- =============================================

CREATE VIEW [SONDA].[ERP_VIEW_INVENTORY]
AS 

	SELECT   
          SERIAL_NUMBER
         ,WAREHOUSE
		 ,LOCATION
		 ,SKU
		 ,[SWIFT_INTERFACES].[dbo].[FUNC_REMOVE_SPECIAL_CHARS](SKU_DESCRIPTION) SKU_DESCRIPTION
		 ,ON_HAND
         ,BATCH_ID
		 ,LAST_UPDATE
		 ,LAST_UPDATE_BY
         ,TXN_ID
		 ,IS_SCANNED
         ,RELOCATED_DATE
		 ,CODE_PACK_UNIT_STOCK
	 FROM OPENQUERY(ERP_SERVER,'
		SELECT   
			NULL             AS SERIAL_NUMBER
			,CAST([INV].[CVE_ALM] AS VARCHAR) COLLATE database_default  AS WAREHOUSE
			,CAST([INV].[CVE_ALM] AS VARCHAR) COLLATE database_default  AS LOCATION
			,CAST([INV].[CVE_ART] AS VARCHAR) COLLATE database_default AS SKU
			,[I].[DESCR] COLLATE database_default  AS SKU_DESCRIPTION
			,CAST(SUM([INV].[EXIST]) AS NUMERIC(18,6))     AS ON_HAND
			,NULL             AS BATCH_ID
			,GETDATE()        AS LAST_UPDATE
			,''BULK_DATA''    AS LAST_UPDATE_BY
			,9999             AS TXN_ID
			,0                AS IS_SCANNED
			,NULL             AS RELOCATED_DATE
			,UPPER([I].[UNI_MED])	  AS CODE_PACK_UNIT_STOCK
		FROM [SAE70EMPRESA01].[dbo].[MULT01] INV
		INNER JOIN [SAE70EMPRESA01].[dbo].[INVE01] I ON [I].[CVE_ART] = [INV].[CVE_ART]
		WHERE [I].[STATUS]<>''B'' AND [I].[TIPO_ELE]=''P''
		GROUP BY [INV].[CVE_ART],[I].[DESCR],[INV].[CVE_ALM],[I].[UNI_MED]
   ')







