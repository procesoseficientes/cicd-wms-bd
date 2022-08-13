-- =============================================
-- Autor:					kevin.guerra
-- Fecha de Creacion: 		27-03-2020 GForce@Paris Sprint B
-- Description:			    Obtiene el slotting configurado por sub familias
--/*
-- Ejemplo de Ejecucion:
--        EXEC [wms].[OP_WMS_GET_SLOTTING_SUB_CLASS] @LOGIN = 'RUDI'
--*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_SLOTTING_SUB_CLASS]
(
    @LOGIN VARCHAR(25),
    @WAREHOUSE_XML XML = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- -----------------------------------------------------------------
    -- Declaramos las variables necesarias
    -- -----------------------------------------------------------------

    DECLARE @WAREHOUSE_TABLE TABLE
    (
        [CODE_WAREHOUSE] VARCHAR(25)
    );


    -- -----------------------------------------------------------------
    -- Obtemos las bodegas enviadas
    -- -----------------------------------------------------------------

    INSERT INTO @WAREHOUSE_TABLE
    (
        [CODE_WAREHOUSE]
    )
    SELECT [x].[Rec].[query]('./WAREHOUSE_ID').[value]('.', 'VARCHAR(25)')
    FROM @WAREHOUSE_XML.[nodes]('/ArrayOfBodega/Bodega') AS [x]([Rec]);

    -- -----------------------------------------------------------------
    -- Validamos si enviaron bodegas para filtrar
    -- -----------------------------------------------------------------
    IF NOT EXISTS (SELECT 1 FROM @WAREHOUSE_TABLE)
    BEGIN

        -- -----------------------------------------------------------------
        -- Si no enviarion bodegas para filtrar buscamos las de el usuario
        -- -----------------------------------------------------------------
        INSERT INTO @WAREHOUSE_TABLE
        (
            [CODE_WAREHOUSE]
        )
        SELECT [WU].[WAREHOUSE_ID]
        FROM [wms].[OP_WMS_WAREHOUSE_BY_USER] [WU]
            INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W]
                ON ([W].[WAREHOUSE_ID] = [WU].[WAREHOUSE_ID])
        WHERE [WU].[LOGIN_ID] = @LOGIN;
    END;

    SELECT [Z].[WAREHOUSE_CODE],
           [Z].[ZONE_ID],
           [Z].[ZONE],
           [SZ].[ID] AS [ID],
           ISNULL([SZ].[MANDATORY], 0) AS [MANDATORY],
           COUNT([SSC].[ID]) AS [FAMILY]
    FROM [wms].[OP_WMS_ZONE] [Z]
        INNER JOIN @WAREHOUSE_TABLE [WT]
            ON ([Z].[WAREHOUSE_CODE] = [WT].[CODE_WAREHOUSE])
        LEFT JOIN [wms].[OP_WMS_SLOTTING_ZONE] [SZ]
            ON [Z].[ZONE_ID] = [SZ].[ZONE_ID]
        LEFT JOIN [wms].[OP_WMS_SLOTTING_ZONE_BY_SUB_CLASS] [SSC]
            ON [SZ].[ID] = [SSC].[ID_SLOTTING_ZONE]
    GROUP BY [Z].[WAREHOUSE_CODE],
             [Z].[ZONE_ID],
             [Z].[ZONE],
             [SZ].[ID],
             [SZ].[MANDATORY]
    ORDER BY [Z].[WAREHOUSE_CODE],
             [Z].[ZONE_ID];

END;