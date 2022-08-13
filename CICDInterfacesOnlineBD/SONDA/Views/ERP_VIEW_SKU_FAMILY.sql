-- =============================================
-- Autor:				alejandro.ochoa
-- Fecha de Creacion: 	2019-01-30
-- Description:			Obtiene las familias de los productos

/*
-- Ejemplo de Ejecucion:
    USE SWIFT_INTERFACES_ONLINE
    GO
    
    SELECT  * FROM  [SONDA].ERP_VIEW_SKU_FAMILY
GO
*/
-- =============================================
CREATE VIEW [SONDA].[ERP_VIEW_SKU_FAMILY]
AS

	SELECT
		[CVE_LIN] AS CODE_FAMILY_SKU
		,[DESC_LIN] AS DESCRIPTION_FAMILY_SKU
		,ROW_NUMBER() OVER (ORDER BY [DESC_LIN] ASC) AS [ORDER]
		,GETDATE() AS LAST_UPDATE
		,'BULK_DATA' AS LAST_UPDATE_BY 
	FROM OPENQUERY(ERP_SERVER,'
		SELECT DISTINCT
			[CVE_LIN]
			,[DESC_LIN]
		FROM [SAE70EMPRESA01].[dbo].[CLIN01] CAT
		INNER JOIN [SAE70EMPRESA01].[dbo].[INVE01] PROD 
			ON CAT.[CVE_LIN] = PROD.[LIN_PROD]
		WHERE PROD.[TIPO_ELE] = ''P'' AND PROD.[STATUS] <> ''B''
	')


