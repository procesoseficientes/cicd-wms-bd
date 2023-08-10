

-- =============================================
-- Autor:	Elder Lucas
-- Fecha de Creacion: 	2022.03.2022
-- Description:	 Vista con los productos y sus precios en SAE




/*
-- Ejemplo de Ejecucion:
			SELECT  * FROM [wms].[OP_WMS_VIEW_SAE_COST_BY_PRODUCT]
*/
-- =============================================
CREATE VIEW [wms].[OP_WMS_VIEW_SAE_COST_BY_PRODUCT]
AS
SELECT  DISTINCT
		[CVE_ART],
		[DESCR],
		[COSTO_PROM],
		[LIN_PROD]
FROM [SAE70EMPRESA01].[dbo].[INVE01] [m]
    

--INNER JOIN [wms].[OP_WMS_COMPANY] [c] ON [c].[CLIENT_CODE] = [m].[WERKS]




