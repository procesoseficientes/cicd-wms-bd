
-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		20-Jun-17 @ A-Team Sprint Khalid
-- Description:			    Vista para la consulta de invetario por zonas en linea

-- Modificacion 6/23/2017 @ A-Team Sprint Khalid
					-- rodrigo.gomez
					-- Se ajusto la vista para SAP BO

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].[ERP_VIEW_INVENTORY_ONLINE]
*/
-- =============================================
CREATE VIEW [SONDA].[ERP_VIEW_INVENTORY_ONLINE]
AS (

SELECT  WAREHOUSE CENTER
		,WAREHOUSE CODE_WAREHOUSE
		,SKU CODE_SKU
		,ON_HAND
		,CODE_PACK_UNIT_STOCK CODE_PACK_UNIT
	 FROM (SELECT   
			NULL             AS SERIAL_NUMBER
			,CAST([INV].[CVE_ALM] AS VARCHAR) COLLATE database_default  AS WAREHOUSE
			,CAST([INV].[CVE_ALM] AS VARCHAR) COLLATE database_default  AS LOCATION
			,CAST([INV].[CVE_ART] AS VARCHAR) COLLATE database_default AS SKU
			,[I].[DESCR] COLLATE database_default  AS SKU_DESCRIPTION
			,CAST(SUM([INV].[EXIST]) AS NUMERIC(18,6))     AS ON_HAND
			,NULL             AS BATCH_ID
			,GETDATE()        AS LAST_UPDATE
			,'BULK_DATA'   AS LAST_UPDATE_BY
			,9999             AS TXN_ID
			,0                AS IS_SCANNED
			,NULL             AS RELOCATED_DATE
			,UPPER([I].[UNI_MED])	  AS CODE_PACK_UNIT_STOCK
		FROM [SAE70EMPRESA01].[dbo].[MULT01] INV
		INNER JOIN [SAE70EMPRESA01].[dbo].[INVE01] I ON [I].[CVE_ART] = [INV].[CVE_ART]
		WHERE [I].[STATUS]<>'B' AND [I].[TIPO_ELE]='P'
		GROUP BY [INV].[CVE_ART],[I].[DESCR],[INV].[CVE_ALM],[I].[UNI_MED] ) AS ID


)
