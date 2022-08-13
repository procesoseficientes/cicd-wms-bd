-- =============================================
-- Autor:					henry.rodriguez
-- Fecha de Creacion: 		12-Junio-19 @ GForce-Team Sprint Cancun
-- Description:			    Obtienes todas las familias / clases 

--/*
-- Ejemplo de Ejecucion:
--        EXEC [wms].[OP_WMS_SP_GET_CLASS_NOT_ASSOCIATED_SLOTTING_ZONE] @ID_SLOTTING = 'E80CD6C1-3D8D-E911-8106-60A44CCD8810'
--*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_CLASS_NOT_ASSOCIATED_SLOTTING_ZONE]
(@ID_SLOTTING UNIQUEIDENTIFIER)
AS
BEGIN
    SELECT [C].[CLASS_ID],
           [C].[CLASS_NAME],
           [C].[CLASS_DESCRIPTION],
           [C].[PRIORITY]
    FROM [wms].[OP_WMS_CLASS] [C]
        LEFT JOIN [wms].[OP_WMS_SLOTTING_ZONE_BY_CLASS] [SZC]
            ON (
                   [C].[CLASS_ID] = [SZC].[CLASS_ID]
                   AND [SZC].[ID_SLOTTING_ZONE] = @ID_SLOTTING
               )
    WHERE [SZC].[ID] IS NULL
    ORDER BY [C].[CLASS_ID],
             [C].[CLASS_NAME];
END;