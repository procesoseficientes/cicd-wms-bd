
-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		04-Apr-17 @ A-Team Sprint Garai 
-- Description:			    Vista para las organizaciones de venta por alutech

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].[ERP_VIEW_SALES_ORGANIZATION]
*/
-- =============================================
CREATE VIEW [SONDA].[ERP_VIEW_SALES_ORGANIZATION]
AS
    ( SELECT    NULL [SALES_ORGANIZATION_ID] ,
                NULL [NAME_SALES_ORGANIZATION]
	--SELECT
	--	CAST(NULL AS VARCHAR(50)) [SALES_ORGANIZATION_ID]
	--	,CAST(NULL AS VARCHAR(50)) [NAME_SALES_ORGANIZATION]
    );

