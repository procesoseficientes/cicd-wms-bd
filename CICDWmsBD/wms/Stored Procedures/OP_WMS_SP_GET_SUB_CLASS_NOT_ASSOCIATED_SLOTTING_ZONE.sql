-- =============================================
-- Autor:					kevin.guerra
-- Fecha de Creacion: 		30-03-2020 @ GForce@Paris Sprint B
-- Description:			    Obtienes todas las subfamilias / subclases 

--/*
-- Ejemplo de Ejecucion:
--        EXEC [wms].[OP_WMS_SP_GET_SUB_CLASS_NOT_ASSOCIATED_SLOTTING_ZONE] @ID_SLOTTING = 'E80CD6C1-3D8D-E911-8106-60A44CCD8810'
--*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_SUB_CLASS_NOT_ASSOCIATED_SLOTTING_ZONE]
(@ID_SLOTTING UNIQUEIDENTIFIER)
AS
BEGIN
    SELECT [C].[SUB_CLASS_ID] [CLASS_ID],
           [C].[SUB_CLASS_NAME] [CLASS_NAME]
    FROM [wms].[OP_WMS_SUB_CLASS] [C]
        LEFT JOIN [wms].[OP_WMS_SLOTTING_ZONE_BY_SUB_CLASS] [SZC]
            ON (
                   [C].[SUB_CLASS_ID] = [SZC].[SUB_CLASS_ID]
                   AND [SZC].[ID_SLOTTING_ZONE] = @ID_SLOTTING
               )
    WHERE [SZC].[ID] IS NULL
    ORDER BY [C].[SUB_CLASS_ID],
             [C].[SUB_CLASS_NAME];
END;