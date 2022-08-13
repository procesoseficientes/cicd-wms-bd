/* =============================================
 Autor:	kevin.guerra
 Fecha de Creacion: 	25-03-2020 GForce@Paris
 Description:	 Vista para obtener las subfamilias.

-- Ejemplo de Ejecucion:
			SELECT * FROM [wms].[VIEW_SKU_SUB_FAMILIES]

 =============================================*/
CREATE VIEW wms.VIEW_SKU_SUB_FAMILIES
AS

SELECT DISTINCT SUB_FAMILY_NAME FROM
(
SELECT DISTINCT [CAMPLIB45] [SUB_FAMILY_NAME]
FROM [$(CICDSaeBD)].[dbo].[INVE_CLIB01]
WHERE [CAMPLIB45] IS NOT NULL AND [CAMPLIB45] <> ''
) AS Datos 
