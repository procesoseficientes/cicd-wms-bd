

-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		08-Jun-17 @ A-Team Sprint Jibade 
-- Description:			    Vista para el codigo de vendedor por cada base de datos de la multiempresa

-- Modificacion 6/23/2017 @ A-Team Sprint Khalid
					-- rodrigo.gomez
					-- Se comento la parte de intercompany para las que se obtengan los datos cuando este no es intercompany

-- Modificacion 8/22/2017 @ NEXUS-Team Sprint CommandAndConquer	
					-- rodrigo.gomez
					-- Se agrega columna serie para intercompany

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].[ERP_VIEW_SELLER_SOURCE]
*/
-- =============================================
CREATE VIEW [SONDA].[ERP_VIEW_SELLER_SOURCE]
AS (
	
	SELECT
		 [SELLER_CODE] [MASTER_ID]
		,[SELLER_CODE] [SLP_CODE]
		,[OWNER] [SOURCE]
	FROM [SWIFT_INTERFACES_ONLINE].[SONDA].[ERP_VIEW_SELLER]

)


