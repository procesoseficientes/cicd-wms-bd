-- =============================================
-- Autor:					rudi.garcia
-- Fecha de Creacion: 25-Jun-19 G-Force@Cancun-Swift3pl
-- Description:			    Obtine las clases con sus productos compatibles.
/*
-- Ejemplo de Ejecucion:
        SELECT * FROM [wms].[OP_WMS_FN_GET_CLASSES_BY_LICENSE](408468)
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LICENSE_COMPATIBLE_CLASS_FOR_LOCATION]
(
    @LOGIN VARCHAR(25),
    @LICENSE_ID INT,
    @LOCATION_SPOT VARCHAR(25)
)
AS
BEGIN
    SET NOCOUNT ON;
    -- ------------------------------------------------------------------------------------
    -- Declaramos las variables necesarias
    -- ------------------------------------------------------------------------------------
    DECLARE @LICENSE_CLASSES TABLE
    (
        [MATERIAL_ID] VARCHAR(50),
        [MATERIAL_NAME] VARCHAR(150),
        [CLASS_ID] INT,
        [CLASS_NAME] VARCHAR(50),
        [CLASS_DESCRIPTION] VARCHAR(250)
    );

    DECLARE @LOCATION_CLASSES TABLE
    (
        [CLASS_ID] INT,
        [CLASS_NAME] VARCHAR(50)
    );

    -- ------------------------------------------------------------------------------------
    -- Obtiene las clases en la ubicacion destino
    -- ------------------------------------------------------------------------------------
    INSERT INTO @LOCATION_CLASSES
    (
        [CLASS_ID],
        [CLASS_NAME]
    )
    SELECT [SZC].[CLASS_ID],
           [SZC].[CLASS_NAME]
    FROM [wms].[OP_WMS_SHELF_SPOTS] [SS]
        INNER JOIN [wms].[OP_WMS_SLOTTING_ZONE] [SZ]
            ON (
                   [SS].[ZONE] = [SZ].[ZONE]
                   AND [SS].[WAREHOUSE_PARENT] = [SZ].[WAREHOUSE_CODE]
               )
        INNER JOIN [wms].[OP_WMS_SLOTTING_ZONE_BY_CLASS] [SZC]
            ON ([SZ].[ID] = [SZC].[ID_SLOTTING_ZONE])
    WHERE [SS].[LOCATION_SPOT] = @LOCATION_SPOT;

    -- ------------------------------------------------------------------------------------
    -- Obtiene las clases en la licencia actual
    -- ------------------------------------------------------------------------------------
    INSERT INTO @LICENSE_CLASSES
    (
        [MATERIAL_ID],
        [MATERIAL_NAME],
        [CLASS_ID],
        [CLASS_NAME],
        [CLASS_DESCRIPTION]
    )
    SELECT [IL].[MATERIAL_ID],
           [IL].[MATERIAL_NAME],
           [C].[CLASS_ID],
           [C].[CLASS_NAME],
           [C].[CLASS_DESCRIPTION]
    FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
        INNER JOIN [wms].[OP_WMS_MATERIALS] [M]
            ON ([M].[MATERIAL_ID] = [IL].[MATERIAL_ID])
        INNER JOIN [wms].[OP_WMS_CLASS] [C]
            ON ([M].[MATERIAL_CLASS] = [C].[CLASS_ID])
    WHERE [IL].[QTY] > 0
          AND [IL].[LICENSE_ID] = @LICENSE_ID;

    -- ------------------------------------------------------------------------------------
    -- Retornamos los materiales con sus clases indicando cuales son compatibles.
    -- ------------------------------------------------------------------------------------
    SELECT [LIC].[MATERIAL_ID],
           [LIC].[MATERIAL_NAME],
           [LIC].[CLASS_ID],
           [LIC].[CLASS_NAME],
           [LIC].[CLASS_DESCRIPTION],
           CASE
               WHEN [LOC].[CLASS_ID] IS NULL THEN
                   0
               ELSE
                   1
           END AS [COMPATIBLE]
    FROM @LICENSE_CLASSES [LIC]
        LEFT JOIN @LOCATION_CLASSES [LOC]
            ON ([LIC].[CLASS_ID] = [LOC].[CLASS_ID]);

END;