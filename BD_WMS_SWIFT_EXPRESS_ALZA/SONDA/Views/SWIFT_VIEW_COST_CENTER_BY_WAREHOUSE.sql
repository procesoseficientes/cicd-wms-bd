


-- =============================================
-- Autor:				jose.garcia
-- Fecha de Creacion: 	11-05-2016
-- Description:			Obtiene los centros de costo por bodega

/*
-- Ejemplo de Ejecucion:
				SELECT * FROM [SONDA].[SWIFT_VIEW_COST_CENTER_BY_WAREHOUSE]
*/
-- =============================================
CREATE VIEW [SONDA].[SWIFT_VIEW_COST_CENTER_BY_WAREHOUSE]
AS
SELECT [Descr], [WhsCode] FROM [SWIFT_INTERFACES].[SONDA].[ERP_SWIFT_VIEW_COST_CENTER_BY_WAREHOUSE]
