
-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 19-08-2016
-- Description:			Se creo la vista descuento

/*
  -- Ejemplo de Ejecucion:
				-- 
				SELECT * FROM SONDA.ERP_VIEW_DISCOUNT        
        
*/
-- =============================================

CREATE VIEW [SONDA].[ERP_VIEW_DISCOUNT]
AS
  SELECT 
    CODE_ROUTE
    ,CODE_CUSTOMER
    ,SKU
    ,DISCOUNT
  FROM SONDA.ERP_TB_DISCOUNT

