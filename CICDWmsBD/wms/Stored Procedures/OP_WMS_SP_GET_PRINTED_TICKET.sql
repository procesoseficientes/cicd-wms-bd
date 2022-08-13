-- =============================================
-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	18-Dic-2019 G-Force@Napoles-Swift
-- Description:			Devuelve los ultimos 10 tickets impresos
-- Product Backlog Item 34372: Pantalla de creación de Ticket

/*
-- Ejemplo de Ejecucion:
		EXECUTE [wms].[OP_WMS_SP_GET_PRINTED_TICKET]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_PRINTED_TICKET]
AS
BEGIN
    SET NOCOUNT ON;

    ---------------------------------------------------------------------------------
    -- DECLARAMOS LAS VARIABLES A UTILIZAR
    ---------------------------------------------------------------------------------

    SELECT TOP (10)
        [TICKET_NUMBER],
        [POLIZA_DOC_ID],
        FORMAT([CREATED_DATE], 'dd/MM/yyyy hh:mm:ss') [CREATED_DATE],
        [STATUS]
    FROM [wms].[OP_WMS_TICKETS]
    WHERE [STATUS] = 'PRINTED'
    ORDER BY [TICKET_NUMBER] DESC;


END;