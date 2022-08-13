-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		04-Apr-17 @ A-Team Sprint Garai 
-- Description:			    Vista para las oficinas de venta por alutech

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].[ERP_VIEW_SALES_OFFICE]
*/
-- =============================================
CREATE VIEW [SONDA].[ERP_VIEW_SALES_OFFICE]
AS (
	SELECT DISTINCT
		CAST(NULL AS VARCHAR(50)) [NAME_SALES_OFFICE]
		,CAST(NULL AS VARCHAR(50)) [DESCRIPTION_SALES_OFFICE]
)

