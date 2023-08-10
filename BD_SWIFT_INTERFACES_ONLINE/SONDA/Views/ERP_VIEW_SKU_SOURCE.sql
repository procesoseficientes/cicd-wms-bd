

-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		14-Jun-17 @ A-Team Sprint Jibade 
-- Description:			    Vista para el codigo de sku por cada base de datos de la multiempresa

-- Modificacion 6/23/2017 @ A-Team Sprint Khalid
					-- rodrigo.gomez
					-- Se comento la parte de intercompany para las que se obtengan los datos cuando este no es intercompany

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].[ERP_VIEW_SKU_SOURCE]
*/
-- =============================================
CREATE VIEW [SONDA].[ERP_VIEW_SKU_SOURCE]
AS
   
	SELECT 
		[CODE_SKU] [MASTER_ID]
		,[CODE_SKU] [ITEM_CODE]
		,[OWNER] [SOURCE]
	 FROM [SWIFT_INTERFACES_ONLINE].[SONDA].[ERP_VIEW_SKU]


