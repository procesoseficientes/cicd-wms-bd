-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		08-Jun-17 @ A-Team Sprint Jibade 
-- Description:			    Vista para el codigo de cliente por cada base de datos de la multiempresa

-- Modificacion 6/23/2017 @ A-Team Sprint Khalid
-- rodrigo.gomez
-- Se comento la parte de intercompany para las que se obtengan los datos cuando este no es intercompany

-- Modificacion 8/21/2017 @ NEXUS-Team Sprint ComandAndConquer
-- rodrigo.gomez
-- Se agregaron las columnas LICTRADNUM y CARD_NAME

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].[ERP_VIEW_CUSTOMER_SOURCE]
*/
-- =============================================
CREATE VIEW [SONDA].[ERP_VIEW_CUSTOMER_SOURCE]
AS (

	SELECT
	  [CODE_CUSTOMER] [MASTER_ID]
	  ,[CODE_CUSTOMER] [CARD_CODE]
	  ,[NAME_CUSTOMER] [CARD_NAME]
	  ,[TAX_ID]
	  ,[OWNER] [SOURCE]
	FROM [SWIFT_INTERFACES_ONLINE].[SONDA].[ERP_VIEW_COSTUMER]

)


