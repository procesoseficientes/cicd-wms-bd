-- =============================================
-- Autor:					henry.rodriguez
-- Fecha de Creacion: 		13-Junio-19 @ GForce-Team Sprint Cancun
-- Description:			    Obtiene las familias asociadas a un slotting configurado
--/*
-- Ejemplo de Ejecucion:
--        EXEC [wms].[OP_WMS_SP_GET_CLASS_BY_SLOTTING_ZONE] @ID_SLOTTING = '8461C8AF-708D-E911-8106-60A44CCD8810' -- uniqueidentifier
--*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_CLASS_BY_SLOTTING_ZONE]
(@ID_SLOTTING UNIQUEIDENTIFIER)
AS
BEGIN

    SELECT [ID],
           [ID_SLOTTING_ZONE],
           [CLASS_ID],
           [CLASS_NAME]
    FROM [wms].[OP_WMS_SLOTTING_ZONE_BY_CLASS]
    WHERE [ID_SLOTTING_ZONE] = @ID_SLOTTING;

END;