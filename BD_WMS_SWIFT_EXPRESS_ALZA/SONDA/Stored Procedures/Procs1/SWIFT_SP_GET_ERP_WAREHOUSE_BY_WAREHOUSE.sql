-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	29-02-2016
-- Description:			Obtiene la bodega de erp de una bodega

/*
-- Ejemplo de Ejecucion:				
		-- EXEC [SONDA].[SWIFT_SP_GET_ERP_WAREHOUSE_BY_WAREHOUSE] @CODE_WAREHOUSE = 'BODEGA_CENTRAL'						
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ERP_WAREHOUSE_BY_WAREHOUSE]

	@CODE_WAREHOUSE VARCHAR(50)

AS
BEGIN 
	SET NOCOUNT ON;

	SELECT TOP 1 [ERP_WAREHOUSE]		
	FROM [SONDA].[SWIFT_VIEW_WAREHOUSES]	
	WHERE [CODE_WAREHOUSE] = @CODE_WAREHOUSE
END
