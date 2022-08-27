﻿


-- =============================================
--  Autor:		joel.delcompare
-- Fecha de Creacion: 	2016-02-27 13:23:47
-- Description:		OBTIENE LAS UNIDADES DE CONVERSION 


/*
-- Ejemplo de Ejecucion:

USE SWIFT_INTERFACES_ONLINE
GO

SELECT
  CODE_SKU
 ,CODE_PACK_UNIT_FROM
 ,CODE_PACK_UNIT_TO
 ,CONVERSION_FACTOR
 ,LAST_UPDATE
 ,LAST_UPDATE_BY
 ,[ORDER]
FROM [SONDA].ERP_PACK_CONVERSION;
GO

*/
-- =============================================

CREATE VIEW [SONDA].[ERP_PACK_CONVERSION]
AS

	SELECT
		CODE_SKU
		,CODE_PACK_UNIT_FROM
		,CODE_PACK_UNIT_TO
		,CONVERSION_FACTOR
		, GETDATE() LAST_UPDATE
		,'BULK_DATA' LAST_UPDATE_BY
		, ROW_NUMBER() OVER (PARTITION BY CODE_SKU ORDER BY CONVERSION_FACTOR ASC) [ORDER]
	FROM OPENQUERY([ERP_SERVER], '
		SELECT DISTINCT
			[CVE_ART] AS CODE_SKU
			,UPPER([UNI_MED]) AS CODE_PACK_UNIT_FROM   
			,UPPER([UNI_MED]) AS CODE_PACK_UNIT_TO 
			,1 AS CONVERSION_FACTOR
		FROM [SAE70EMPRESA01].[dbo].[INVE01] I 
		WHERE [TIPO_ELE]=''P'' AND ISNULL([UNI_MED],'''')<>''''
		AND [STATUS]<>''B''
	')







