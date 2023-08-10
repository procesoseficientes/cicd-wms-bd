-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		04-Apr-17 @ A-Team Sprint Garai 
-- Description:			    Vista para las bodegas por oficina de venta para alutech

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].[ERP_VIEW_WAREHOUSE_BY_SALES_OFFICE]
*/
-- =============================================
CREATE VIEW [SONDA].[ERP_VIEW_WAREHOUSE_BY_SALES_OFFICE]
AS (
	SELECT DISTINCT
		CAST(NULL AS VARCHAR(50)) [NAME_SALES_OFFICE]
		,CAST(NULL AS VARCHAR(50)) [WAREHOUSE]
)

