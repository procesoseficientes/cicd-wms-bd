
-- =============================================
-- Autor:				julio.ochoa
-- Fecha de Creacion: 	2020-03-05
-- Description:			Obtiene las sub familias de los productos, vista especifica de ALZA
--						Funciona unicamente para segmentacion de productos para el slotting

/*
-- Ejemplo de Ejecucion:
    USE SWIFT_INTERFACES_ONLINE
    GO
    
    SELECT  * FROM  [SONDA].ERP_VIEW_SKU_SUBFAMILY
GO
*/
-- =============================================
CREATE VIEW [SONDA].[ERP_VIEW_SKU_SUBFAMILY]
AS

	SELECT
		[CAMPLIB45] AS CODE_SUBFAMILY_SKU
		,ROW_NUMBER() OVER (ORDER BY [CAMPLIB45] ASC) AS [ORDER]
		,GETDATE() AS LAST_UPDATE
		,'BULK_DATA' AS LAST_UPDATE_BY 
	FROM (
		SELECT DISTINCT 
			[CAMPLIB45]
		FROM SAE70EMPRESA01.dbo.INVE_CLIB01 CamposExtras
		where [CAMPLIB45] IS NOT NULL
	) AS ID
