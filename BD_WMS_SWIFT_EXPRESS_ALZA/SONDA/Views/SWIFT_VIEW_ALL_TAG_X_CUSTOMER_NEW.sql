
-- =============================================
-- Autor:					rodrigo.gomez
-- Fecha de Creacion: 		6/21/2017 @ A-Team Sprint Khalid 
-- Description:			    Une las etiquetas de los scoutings.

-- =============================================
-- Modificacion:					rudi.garcia
-- Fecha de Creacion: 		7/24/2017 @ A-Team Sprint Bearbeitung
-- Description:			    Se cambio la tabla [SWIFT_TAG_X_CUSTOMER] por [SWIFT_TAG_X_CUSTOMER_NEW]

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].SWIFT_VIEW_ALL_TAG_X_CUSTOMER_NEW
*/
-- =============================================
CREATE VIEW [SONDA].[SWIFT_VIEW_ALL_TAG_X_CUSTOMER_NEW]
AS (
	SELECT
		[TAG_COLOR]
		,[CN].[CODE_CUSTOMER] [CUSTOMER] 
	FROM [SONDA].[SWIFT_TAG_X_CUSTOMER_NEW] [T]
		INNER JOIN [SONDA].[SWIFT_CUSTOMERS_NEW] [CN] ON ([CN].[CODE_CUSTOMER] = [T].[CUSTOMER])
	UNION ALL
	SELECT [TGN].[TAG_COLOR]
			,[TGN].[CUSTOMER] 
	FROM [SONDA].[SWIFT_TAG_X_CUSTOMER] [TGN] 
)
