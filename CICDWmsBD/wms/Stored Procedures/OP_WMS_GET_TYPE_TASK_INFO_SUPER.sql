-- =================================================
-- Autor:				MICHAEL.MAZARIEGOS
-- Fecha de creacion:	12/11/2019 @ G-Force - TEAM Sprint Magadascar
-- Historia/Bug:		Product Backlog Item 33266: Tareas de reasignacion de tareas
-- Descripcion:			12/6/2019 - Obtiene el nombre, cantidad de tareas pendientes y completadas del usuario logeado.

-- Modificacion			16-Dic-19 @ G-Force Team Sprint Madagascar
-- autor:				jonathan.salvador
-- Descripcion:			Se agrega el campo LICENSE_ID_SOURCE como parte de la consulta y se agrega validación para obtener solo
--						tareas del operador en las bodegas asociadas al usuario supervisor
/*
-- Ejemplo de Ejecucion:
	EXEC [wms].[OP_WMS_GET_TYPE_TASK_INFO_SUPER]
	@LOGIN_PARAMETER = 'Marvin'
*/
CREATE PROCEDURE [wms].[OP_WMS_GET_TYPE_TASK_INFO_SUPER]
(
    @LOGIN_ID VARCHAR(25),
    @OPERATOR_ID VARCHAR(25) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;
    -- -----------------------------------------------------------------------------------
    -- SE OBTIENEN LAS TAREAS Y SUS ESPECIFICACIONES.
    -- -----------------------------------------------------------------------------------
	 DECLARE @WAREHOUSE_BY_USER TABLE
        (
            WAREHOUSE_ID VARCHAR(25)
        );

        DECLARE @USERS_X_WAREHOUSE TABLE
        (
            WAREHOUSE_ID VARCHAR(25),
            LOGIN_ID VARCHAR(25)
        );

		 INSERT INTO @WAREHOUSE_BY_USER
        (
            WAREHOUSE_ID
        )
        SELECT WAREHOUSE_ID
        FROM [wms].[OP_WMS_WAREHOUSE_BY_USER]
        WHERE [LOGIN_ID] = @LOGIN_ID AND WAREHOUSE_ID IS NOT NULL;

    IF (@OPERATOR_ID IS NULL)
    BEGIN
        INSERT INTO @USERS_X_WAREHOUSE
        (
            WAREHOUSE_ID,
            LOGIN_ID
        )
        SELECT [WBU].[LOGIN_ID],
               [WBU].[WAREHOUSE_ID]
        FROM [wms].[OP_WMS_WAREHOUSE_BY_USER] [WBU]
            INNER JOIN @WAREHOUSE_BY_USER [W]
                ON (WBU.WAREHOUSE_ID = W.WAREHOUSE_ID);

        SELECT [TL].[TASK_ASSIGNEDTO],
               [TL].[PRIORITY],
               [TL].[ASSIGNED_DATE],
               [TL].[SERIAL_NUMBER],
               [L].[LICENSE_ID],
			   [TL].[LICENSE_ID_SOURCE],
			   [TL].[TASK_TYPE],
			   [TL].[MATERIAL_ID],
			   [TL].[WAVE_PICKING_ID],
			   [TL].[WAREHOUSE_SOURCE]
        FROM [wms].[OP_WMS_TASK_LIST] [TL]
            LEFT JOIN [wms].[OP_WMS_LICENSES] [L]
                ON ([TL].[WAVE_PICKING_ID] = [L].[WAVE_PICKING_ID])
            LEFT JOIN @USERS_X_WAREHOUSE [UXW]
                ON ([TL].[TASK_ASSIGNEDTO] = [UXW].[LOGIN_ID])
        WHERE [TL].[IS_COMPLETED] = 0
              AND [TL].[IS_CANCELED] = 0
              AND [TL].[IS_PAUSED] = 0
        ORDER BY [TL].[TASK_ASSIGNEDTO] ASC;
    END;
    ELSE
    BEGIN

        SELECT [TL].[TASK_ASSIGNEDTO],
               [TL].[PRIORITY],
               [TL].[ASSIGNED_DATE],
               [TL].[SERIAL_NUMBER],
               [L].[LICENSE_ID],
			   [TL].[LICENSE_ID_SOURCE],
			   [TL].[TASK_TYPE],
			   [TL].[MATERIAL_ID],
			   [TL].[WAVE_PICKING_ID],
			   [TL].[WAREHOUSE_SOURCE]
        FROM [wms].[OP_WMS_TASK_LIST] [TL]
            LEFT JOIN [wms].[OP_WMS_LICENSES] [L]
                ON ([TL].[WAVE_PICKING_ID] = [L].[WAVE_PICKING_ID])
			INNER JOIN @WAREHOUSE_BY_USER [WU] ON ([WU].WAREHOUSE_ID = [TL].[WAREHOUSE_SOURCE])
        WHERE  [TL].[IS_COMPLETED] = 0
              AND [TL].[IS_CANCELED] = 0
              AND [TL].[IS_PAUSED] = 0
              AND [TL].[TASK_ASSIGNEDTO] = @OPERATOR_ID
        ORDER BY [TL].[TASK_ASSIGNEDTO] ASC;
    END;
END;

-- EXEC