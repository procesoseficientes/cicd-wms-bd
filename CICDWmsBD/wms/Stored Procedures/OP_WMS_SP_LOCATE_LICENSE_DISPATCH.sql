-- =============================================
-- Autor:	        rudi.garcia
-- Fecha de Creacion: 	30-Aug-2018 G-Force@Ibice
-- Description:	        Sp que ubica la licencia de despacho

-- Autor:				marvin.solares
-- Fecha de Creacion: 	20181810 GForce@Mamba
-- Description:			Se modifica para que no permita usar la ubicacion cuando la licencia tiene inventario bloqueado por interfaces en ubicacion de fast picking

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	08-Abril-2020 GForce@Paris
-- Description:			Se agrega validacion para obtener el subtipo de la tarea

-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_LOCATE_LICENSE_DISPATCH]
(
    @LOCATION VARCHAR(25),
    @LICENSE_ID INT,
    @LOGIN VARCHAR(15)
)
AS
BEGIN
    SET NOCOUNT ON;
    --

    BEGIN TRY

        DECLARE @CODE_WAREHOUSE VARCHAR(25),
                @COUNT_INVENTORY_LOCKED_BY_INTERFACES INT = 0,
                @ALLOW_FAST_PICKING INT = 0,
                @ErrorCode INT = 0,
                @ERROR VARCHAR(200),
                @TASK_SUBTYPE VARCHAR(100);

        SELECT TOP 1
               @CODE_WAREHOUSE = [SS].[WAREHOUSE_PARENT],
               @ALLOW_FAST_PICKING = [SS].[ALLOW_FAST_PICKING]
        FROM [wms].[OP_WMS_SHELF_SPOTS] [SS]
        WHERE [SS].[LOCATION_SPOT] = @LOCATION;

        -- ------------------------------------------------------------------------
        -- Se obtiene el subtipo de la tarea para saber si es traslado general
        -- ------------------------------------------------------------------------
        SELECT TOP 1
               @TASK_SUBTYPE = [TASK_SUBTYPE]
        FROM [wms].[OP_WMS_TASK_LIST]
        WHERE [WAVE_PICKING_ID] =
        (
            SELECT TOP 1
                   [WAVE_PICKING_ID]
            FROM [wms].[OP_WMS_LICENSES]
            WHERE [LICENSE_ID] = @LICENSE_ID
        );

        IF @ALLOW_FAST_PICKING = 1
           AND EXISTS
        (
            SELECT TOP 1
                   1
            FROM [wms].[OP_WMS_INV_X_LICENSE]
            WHERE [LICENSE_ID] = @LICENSE_ID
                  AND [LOCKED_BY_INTERFACES] = 1
        )
        BEGIN

            -- ------------------------------------------------------------------------------------
            -- obtengo cuantos materiales de la licencia estan bloqueados por interfaces
            -- ------------------------------------------------------------------------------------

            SELECT @ERROR
                = 'No se puede ubicar en ubicación de fast picking porque hay inventario bloqueado por interfaces';

            SELECT @ErrorCode = 3052;
            RAISERROR(@ERROR, 16, 1);
        END;

        UPDATE [L]
        SET [L].[CURRENT_LOCATION] = @LOCATION,
            [L].[CURRENT_WAREHOUSE] = @CODE_WAREHOUSE,
            [L].[LAST_UPDATED_BY] = @LOGIN,
            [L].[LAST_UPDATED] = GETDATE()
        FROM [wms].[OP_WMS_LICENSES] [L]
        WHERE [L].[LICENSE_ID] = @LICENSE_ID;

        SELECT 1 AS [Resultado],
               'Proceso Exitoso' [Mensaje],
               0 [Codigo],
               CAST(0 AS VARCHAR) [DbData];

    END TRY
    BEGIN CATCH
        SELECT @ERROR = ERROR_MESSAGE();
        SELECT -1 AS [Resultado],
               @ERROR [Mensaje],
               @ErrorCode [Codigo],
               '' [DbData];
    END CATCH;

END;