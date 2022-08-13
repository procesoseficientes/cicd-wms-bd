-- =============================================
-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	01-Enero-2020 G-Force@Paris
-- Description:			Devuelve los datos del ticket ingresado

/*
-- Ejemplo de Ejecucion:
		EXECUTE [wms].[OP_WMS_SP_GET_TICKET] @TICKET_NUMBER = 1
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TICKET]
(@TICKET_NUMBER AS BIGINT)
AS
BEGIN
    SET NOCOUNT ON;

    ---------------------------------------------------------------------------------
    -- OBTENEMOS EL TICKET SOLICITADO
    ---------------------------------------------------------------------------------

    SELECT ISNULL([POLIZA_DOC_ID], 0) [POLIZA_DOC_ID],
           [CREATED_DATE],
           [STATUS]
    FROM [wms].[OP_WMS_TICKETS]
    WHERE [TICKET_NUMBER] = @TICKET_NUMBER;


END;