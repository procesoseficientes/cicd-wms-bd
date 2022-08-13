-- =================================================
-- Autor:				MICHAEL.MAZARIEGOS
-- Fecha de creacion:	12/11/2019 @ G-Force - TEAM Sprint Magadascar
-- Historia/Bug:		Product Backlog Item 33266: Tareas de reasignacion de tareas
-- Descripcion:			12/6/2019 - Obtiene el nombre y cantidad de tareas pendientes en un orden de forma descendente

-- Modificacion			16-Dic-19 @ G-Force Team Sprint Madagascar
-- autor:				jonathan.salvador
-- Historia/Bug:		Product Backlog Item 35054: Las tareas de los uusarios no deberian ser agrupadas por bodega
-- Descripcion:			Se elimina de la agrupación el campo WAREHOUSE_SOURCE para que se agrupen las tareas por usuario sin distinguir bodegas

/*
-- Ejemplo de Ejecucion:
	EXEC [wms].[OP_WMS_GET_PENDING_TASK_BY_USER_SUPER]
	@LOGIN_PARAMETER = 'Marvin'
*/
CREATE PROCEDURE [wms].[OP_WMS_GET_PENDING_TASK_BY_USER_SUPER]
(@LOGIN_ID VARCHAR(100))
AS
BEGIN
    SET NOCOUNT ON;
    -- -----------------------------------------------------------------------------------
    -- SE OBTIENEN LOS USUARIOS Y LAS TAREAS PENDIENTES.
    -- -----------------------------------------------------------------------------------

    DECLARE @TEMP_WAREHOUSE_MY_USER AS TABLE
    (
        ID INT IDENTITY(1, 1),
        WAREHOUSE_ID VARCHAR(25)
    );

    INSERT INTO @TEMP_WAREHOUSE_MY_USER
    (
        WAREHOUSE_ID
    )
    SELECT WAREHOUSE_ID
    FROM wms.OP_WMS_WAREHOUSE_BY_USER
    WHERE LOGIN_ID = @LOGIN_ID;

    -- INGRESAMOS LOS USUARIOS DE NUESTRAS BODEGAS ASOCIADAS
    DECLARE @TEMP_TASKS_PENDING AS TABLE
    (
        IS_ASSIGNED VARCHAR(25),
        QTY_PENDING INT NOT NULL,
        WAREHOUSE_SOURCE VARCHAR(25)
    );

    INSERT INTO @TEMP_TASKS_PENDING
    (
        IS_ASSIGNED,
        QTY_PENDING,
        WAREHOUSE_SOURCE
    )
    SELECT WTL.TASK_ASSIGNEDTO,
           COUNT(WTL.IS_ACCEPTED) IS_ACCEPTED,
           MAX(WTL.WAREHOUSE_SOURCE)
    FROM wms.OP_WMS_TASK_LIST [WTL]
        INNER JOIN @TEMP_WAREHOUSE_MY_USER [TWU]
            ON (TWU.WAREHOUSE_ID = WTL.WAREHOUSE_SOURCE)
    WHERE WTL.IS_CANCELED = 0
          AND WTL.IS_COMPLETED = 0
          AND WTL.IS_PAUSED = 0
    GROUP BY WTL.TASK_ASSIGNEDTO;


    SELECT DISTINCT
           WTL.TASK_ASSIGNEDTO,
		   TP.QTY_PENDING,
           --MAX(TP.QTY_PENDING) QTY_PENDING,
           MAX(WTL.WAREHOUSE_SOURCE) [WAREHOUSE]
    FROM wms.OP_WMS_TASK_LIST [WTL]
        INNER JOIN @TEMP_WAREHOUSE_MY_USER [TWU]
            ON (TWU.WAREHOUSE_ID = WTL.WAREHOUSE_SOURCE)
        INNER JOIN @TEMP_TASKS_PENDING [TP]
            ON (
                   TP.WAREHOUSE_SOURCE = WTL.WAREHOUSE_SOURCE
                   AND TP.IS_ASSIGNED = WTL.TASK_ASSIGNEDTO
               )
    GROUP BY WTL.TASK_ASSIGNEDTO,
			 TP.QTY_PENDING
	ORDER BY TP.QTY_PENDING DESC;
--SELECT * FROM @TEMP_USERS
END;

--EXECUTE wms.OP_WMS_GET_PENDING_TASK_BY_USER_SUPER @LOGIN_ID = 'MARVIN' -- varchar(100)