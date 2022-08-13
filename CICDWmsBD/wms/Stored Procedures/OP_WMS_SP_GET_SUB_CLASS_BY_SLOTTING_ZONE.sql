-- =============================================
-- Autor:					kevin.guerra
-- Fecha de Creacion: 		30-03-2020 @ GForce@Paris Sprint B
-- Description:			    Obtiene las sub familias asociadas a un slotting configurado
--/*
-- Ejemplo de Ejecucion:
--        EXEC [wms].[OP_WMS_SP_GET_SUB_CLASS_BY_SLOTTING_ZONE] @ID_SLOTTING = '8461C8AF-708D-E911-8106-60A44CCD8810' -- uniqueidentifier
--*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_SUB_CLASS_BY_SLOTTING_ZONE]
(@ID_SLOTTING UNIQUEIDENTIFIER)
AS
BEGIN

    SELECT [ID],
           [ID_SLOTTING_ZONE],
           [SUB_CLASS_ID] [CLASS_ID],
           [SUB_CLASS_NAME] [CLASS_NAME]
    FROM [wms].[OP_WMS_SLOTTING_ZONE_BY_SUB_CLASS]
    WHERE [ID_SLOTTING_ZONE] = @ID_SLOTTING;

END;