-- =============================================
-- Autor:				jonathan.salvador
-- Fecha de creacion:	09/12/2019 @ G-Force - TEAM Sprint Magadascar
-- Historia/Bug:		Product Backlog Item 33840: Inventario en despacho
-- Descripcion:			09/12/2019 Sp que obtiene las olas de picking en picking
--						en la bodegas asociadas al usuario que se envia como parametro

-- Modificacion			17-Dic-19 @ G-Force Team Sprint Madagascar
-- autor:				jonathan.salvador
-- Descripcion:			Se remueve validacion para que muestre olas de picking a las que no se les han generado licencias de despacho

-- Modificacion			20-Dic-19 @ G-Force Team Sprint Madagascar
-- autor:				jonathan.salvador
-- Descripcion:			Se modifica la asociacion a la tabla NEX_PIKCKING_DEMAND_HEADER, se asocia a la ola de picking de las tareas. 
--						Y se modifica para considera olas de picking que no estan asignadas a un operador
/*
-- Ejemplo de Ejecucion:
	EXEC [wms].[OP_WMS_SP_GET_PICKING_WAVES_BY_USER_SUPER]
	@LOGIN_ID = 'Marvin'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_PICKING_WAVES_BY_USER_SUPER]
(@LOGIN_ID VARCHAR(50))
AS
BEGIN
    SET NOCOUNT ON;

    -- -----------------------------------------------------------------------------------------
    -- SE OBTIENEN LOS USUARIOS ASOCIADOS A LA MISMA BODEGA QUE EL USUARIO LOGUEADO
    -- -----------------------------------------------------------------------------------------
    DECLARE @WAREHOUSE_X_USER TABLE
    (
        WAREHOUSE_ID VARCHAR(25)
    );

    INSERT INTO @WAREHOUSE_X_USER
    (
        WAREHOUSE_ID
    )
    SELECT [WAREHOUSE_ID]
    FROM [wms].[OP_WMS_WAREHOUSE_BY_USER]
    WHERE [LOGIN_ID] = @LOGIN_ID;

    DECLARE @USERS_X_WAREHOUSE TABLE
    (
        WAREHOUSE_ID VARCHAR(25),
        LOGIN_ID VARCHAR(25)
    );

    INSERT INTO @USERS_X_WAREHOUSE
    (
        WAREHOUSE_ID,
        LOGIN_ID
    )
    SELECT [WBU].[WAREHOUSE_ID],
           [WBU].[LOGIN_ID]
    FROM [wms].[OP_WMS_WAREHOUSE_BY_USER] [WBU]
        INNER JOIN @WAREHOUSE_X_USER [W]
            ON ([WBU].[WAREHOUSE_ID] = [W].[WAREHOUSE_ID]);

    -- -----------------------------------------------------------------------------------------
    -- SE OBTIENEN LAS OLAS EN PICKING CORRESPONDIENTES A LA BODEGA DEL USUARIO
    -- -----------------------------------------------------------------------------------------
    SELECT [T].[WAVE_PICKING_ID],
           [T].[TASK_SUBTYPE],
           [T].[TASK_TYPE],
           MAX([T].[TASK_ASSIGNEDTO]) [ASSIGNED_TO],
           MAX([T].[CLIENT_NAME]) [PROVIDER_NAME],
           CASE MAX([NPH].[IS_CONSOLIDATED])
               WHEN 0 THEN
                   MAX([NPH].[CLIENT_NAME])
               WHEN 1 THEN
                   'CONSOLIDADO'
               ELSE
                   'GENERAL'
           END [CLIENT_NAME]
    FROM [wms].[OP_WMS_TASK_LIST] [T]
        INNER JOIN @USERS_X_WAREHOUSE [UW]
            ON (
                   [T].[TASK_ASSIGNEDTO] = [UW].[LOGIN_ID] OR [T].[TASK_ASSIGNEDTO] = ''
                   AND [T].[WAREHOUSE_SOURCE] = [UW].[WAREHOUSE_ID]
               )
        LEFT JOIN [wms].[OP_WMS_LICENSES] [L]
            ON [T].[WAVE_PICKING_ID] = [L].[WAVE_PICKING_ID]
        LEFT JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
            ON ([L].[LICENSE_ID] = [IL].[LICENSE_ID])
        LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [NPH]
            ON [NPH].[WAVE_PICKING_ID] = [T].[WAVE_PICKING_ID]
    WHERE [T].[TASK_ASSIGNEDTO] = [UW].[LOGIN_ID] 
			AND [T].[WAREHOUSE_SOURCE] = [UW].[WAREHOUSE_ID]
             AND [T].[WAVE_PICKING_ID] IS NOT NULL
             AND [T].[DISPATCH_LICENSE_EXIT_COMPLETED] = 0
             AND [T].[TASK_TYPE] = 'TAREA_PICKING'
             AND [T].[IS_CANCELED] = 0
			 OR [T].[TASK_ASSIGNEDTO] = ''
			 AND [T].[WAREHOUSE_SOURCE] = [UW].[WAREHOUSE_ID]
             AND [T].[WAVE_PICKING_ID] IS NOT NULL
             AND [T].[DISPATCH_LICENSE_EXIT_COMPLETED] = 0
             AND [T].[TASK_TYPE] = 'TAREA_PICKING'
             AND [T].[IS_CANCELED] = 0
    GROUP BY [T].[WAVE_PICKING_ID],
             [T].[TASK_SUBTYPE],
             [T].[TASK_TYPE],
             CASE
                 WHEN [NPH].[IS_CONSOLIDATED] = 0 THEN
                     [NPH].[CLIENT_NAME]
                 ELSE
                     'CONSOLIDADO'
             END
    ORDER BY [T].[WAVE_PICKING_ID];


END;