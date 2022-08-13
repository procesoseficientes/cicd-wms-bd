


-- =============================================
--  Autor:		joel.delcompare
-- Fecha de Creacion: 	2016-04-14 02:12:43
-- Description:		Obtiene las unidades de medida que maneja el ERP


/*
-- Ejemplo de Ejecucion:
USE SWIFT_INTERFACES_ONLINE
GO

SELECT
  CODE_PACK_UNIT
 ,DESCRIPTION_PACK_UNIT
 ,LAST_UPDATE
 ,LAST_UPDATE_BY
 ,UM_ENTRY
FROM [SONDA].ERP_PACK_UNIT;
GO
*/	
-- =============================================
CREATE VIEW [SONDA].[ERP_PACK_UNIT]
  AS 

	SELECT
		CODE_PACK_UNIT
		,DESCRIPTION_PACK_UNIT
		, GETDATE() LAST_UPDATE
		,'BULK_DATA' LAST_UPDATE_BY
		, ROW_NUMBER() OVER (ORDER BY [CODE_PACK_UNIT] ASC) UM_ENTRY
	FROM OPENQUERY(ERP_SERVER, '
		SELECT  DISTINCT
			UPPER([UNI_MED]) CODE_PACK_UNIT
			,UPPER([UNI_MED]) DESCRIPTION_PACK_UNIT
			,UPPER([UNI_MED]) UM_ENTRY   
		FROM [SAE70EMPRESA01].[dbo].[INVE01]
		WHERE [TIPO_ELE] = ''P'' AND [UNI_MED]<>''''
		AND [STATUS]<>''B''
	')
	


