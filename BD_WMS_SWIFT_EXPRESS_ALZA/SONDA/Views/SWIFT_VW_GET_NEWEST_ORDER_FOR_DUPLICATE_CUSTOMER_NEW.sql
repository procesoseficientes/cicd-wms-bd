-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		01-Dec-16 @ A-Team Sprint 5
-- Description:			    Vista para obtener el orden de los scouting repetidos

-- Modificacion 6/22/2017 @ A-Team Sprint Khalid
					-- rodrigo.gomez
					-- Se cambio la referencia a la vista de scoutings

/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [SONDA].[SWIFT_VW_GET_NEWEST_ORDER_FOR_DUPLICATE_CUSTOMER_NEW]
*/
-- =============================================
CREATE VIEW [SONDA].[SWIFT_VW_GET_NEWEST_ORDER_FOR_DUPLICATE_CUSTOMER_NEW]
AS(
    SELECT
		[CN].[CUSTOMER]
		,[CN].[CODE_CUSTOMER]
		,[CN].[NAME_CUSTOMER]
		,[CN].[SYNC_ID]
		,ROW_NUMBER() OVER(PARTITION BY [CN].[SYNC_ID] ORDER BY [CN].[CUSTOMER] DESC) AS [NEWEST_ORDER]
	FROM [SONDA].[SWIFT_VIEW_ALL_CUSTOMER_NEW] [CN]
)
