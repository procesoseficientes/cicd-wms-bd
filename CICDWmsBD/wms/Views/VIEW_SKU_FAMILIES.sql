-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-31 @ Team G-FORCE LANGOSTA
-- Description:	 NA


/*
-- Ejemplo de Ejecucion:
			SELECT * FROM [wms].[VIEW_SKU_FAMILIES]
*/
-- =============================================
CREATE VIEW [wms].[VIEW_SKU_FAMILIES]
AS

SELECT [LIN_PROD] [FAMILY_CODE],
       [LIN_PROD] [FAMILY_NAME],
       ROW_NUMBER() OVER (ORDER BY [LIN_PROD]) AS [PRIORITY]
FROM [$(CICDSaeBD)].[dbo].[INVE01]
WHERE [LIN_PROD] IS NOT NULL AND [LIN_PROD] <> ''
GROUP BY [LIN_PROD]





