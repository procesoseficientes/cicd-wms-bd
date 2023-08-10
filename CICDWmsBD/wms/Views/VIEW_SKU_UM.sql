-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-31 @ Team G-FORCE - Sprint LANGOSTA
-- Description:	 NA




/*
-- Ejemplo de Ejecucion:
			SELECT * FROM [wms].[VIEW_SKU_UM]
*/
-- =============================================
CREATE VIEW [wms].[VIEW_SKU_UM]
AS
SELECT
	[m].[MATNR] [ItemCode]
	,[m].[WERKS] + '/' +  STUFF([m].[MATNR], 1,
								PATINDEX('%[^0]%',
											[m].[MATNR]) - 1,
								'') [MateriaId]
	,[m].[WERKS] [ClientCode]
	,[m].[MEINS] [BaseUnit]
	,[m].[MEINH] [AlternativeUnit]
	,CASE WHEN [m].[EAN11_2] = '' THEN 
	STUFF([m].[MATNR], 1,
								PATINDEX('%[^0]%',
											[m].[MATNR]) - 1,
								'') + [m].[MEINH] ELSE 
	REPLACE([m].[EAN11_2] ,'-','') END  [BarcodeAlternativeUnit]
	,[m].[UMREZ] [Factor]
FROM
	[SWIFT_R3_INTER].[dbo].[RFC_MATERIALS] [m]
INNER JOIN [wms].[OP_WMS_COMPANY] [c] ON [c].[CLIENT_CODE] = [m].[WERKS]
WHERE
	[m].[MEINS] <> [m].[MEINH]
	AND [m].[UMREZ] > 1
	AND [MATNR] NOT LIKE 'V_SER%'
--	AND [m].[EAN11_2] <> ''
GROUP BY
	[m].[MATNR]
	,[m].[WERKS]
	,[m].[MEINS]
	,[m].[MEINH]
	,[m].[EAN11_2]
	,[m].[UMREZ]

	;