-- =============================================
-- Autor:				jonathan.salvador
-- Fecha de creacion:	12/12/2019 @ G-Force - TEAM Sprint Magadascar
-- Historia/Bug:		Product Backlog Item 33840: Inventario en despacho
-- Descripcion:			Sp que obtiene las tareas pendientes de la ola de picking 
--						en la bodegas asociadas al usuario que se envia como parametro

-- Modificacion			17-Dic-19 @ G-Force Team Sprint Madagascar
-- autor:				jonathan.salvador
-- Descripcion:			Se agrega validación de usuario y bodega en la tabla @QTY_X_MATERIAL
--						para obtener total correcto de productos en picking para la ola 

-- Modificacion			20-Dic-19 @ G-Force Team Sprint Madagascar
-- autor:				jonathan.salvador
-- Descripcion:			Se modifica para que incluya las tareas que no se han asignado a ningun operador y que pertenecen a la ola 
/*
-- Ejemplo de Ejecucion:
	EXEC [wms].[OP_WMS_SP_GET_TOTAL_TASK_BY_WAVE_PICKING_SUPER]
	@WAVE_PICKING_ID = 19932,
	@LOGIN_ID = 'Marvin'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TOTAL_TASK_BY_WAVE_PICKING_SUPER]
(
    @WAVE_PICKING_ID NUMERIC(18, 0),
    @LOGIN_ID VARCHAR(25)
)
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

	DECLARE @QTY_X_MATERIAL TABLE
    (
        MATERIAL_ID VARCHAR(25),
        QUANTITY_TOTAL_ASSIGNED NUMERIC(18,6),
		QUANTITY_OPERATED NUMERIC(18,6)
    );

	INSERT INTO @QTY_X_MATERIAL
	(
	    MATERIAL_ID,
	    QUANTITY_TOTAL_ASSIGNED,
		QUANTITY_OPERATED
	)
	SELECT 
           MAX([TL].[MATERIAL_ID]),
           SUM([TL].[QUANTITY_ASSIGNED]),
		   SUM([TL].[QUANTITY_ASSIGNED] - [TL].[QUANTITY_PENDING])
    FROM [wms].[OP_WMS_TASK_LIST] AS [TL]
		LEFT JOIN @USERS_X_WAREHOUSE [UW] 
			ON ([TL].[TASK_ASSIGNEDTO] = [UW].[LOGIN_ID]
			AND [TL].[WAREHOUSE_SOURCE] = [UW].[WAREHOUSE_ID])
        LEFT  JOIN [wms].[OP_WMS_MATERIALS] AS [M]
            ON [TL].[MATERIAL_ID] = [M].[MATERIAL_ID]
        LEFT JOIN [wms].[OP_WMS_LICENSES] AS [L]
            ON [TL].[LICENSE_ID_SOURCE] = [L].[LICENSE_ID]
        LEFT JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH]
            ON [TL].[CODIGO_POLIZA_TARGET] = [PH].[CODIGO_POLIZA]
        LEFT JOIN [wms].[OP_WMS_POLIZA_HEADER] [PHR]
            ON [TL].[CODIGO_POLIZA_SOURCE] = [PHR].[CODIGO_POLIZA]
    WHERE [TL].[TASK_ASSIGNEDTO] = [UW].[LOGIN_ID]
		  AND [TL].[IS_COMPLETED] = 0
          AND [TL].[IS_PAUSED] = 0
          AND [TL].[IS_CANCELED] = 0
          AND [TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
		  OR [TL].[TASK_ASSIGNEDTO] = ''
		  AND [TL].[IS_COMPLETED] = 0
          AND [TL].[IS_PAUSED] = 0
          AND [TL].[IS_CANCELED] = 0
          AND [TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
		  GROUP BY [TL].[MATERIAL_ID]

	-- -----------------------------------------------------------------------------------------
    -- SE OBTIENEN TODAS LAS TAREAS DE PICKING REFERENTES A LA OLA
    -- -----------------------------------------------------------------------------------------
    SELECT [TL].[SERIAL_NUMBER] AS [ID],
		   MAX([QT].[QUANTITY_TOTAL_ASSIGNED]) [TOTAL_MATERIAL],
		   MAX([QT].[QUANTITY_OPERATED]) [TOTAL_OPERATED],
           MAX([TL].[WAVE_PICKING_ID]) AS [WAVE_PICKING_ID],
           MAX([TL].[TASK_ASSIGNEDTO]) AS [TASK_ASSIGNEDTO],
		   MAX([L].[CURRENT_LOCATION]) [CURRENT_LOCATION],
           MAX([TL].[QUANTITY_PENDING]) AS [QUANTITY_PENDING],
           MAX([TL].[QUANTITY_ASSIGNED]) AS [QUANTITY_ASSIGNED],
           MAX([TL].[LICENSE_ID_SOURCE]) AS [LICENSE_ID],
           MAX([TL].[MATERIAL_ID]) AS [MATERIAL_ID],
           MAX([TL].[LOCATION_SPOT_SOURCE]) AS [LOCATION_SOURCE],
           MAX([TL].[CLIENT_NAME]) AS [CLIENT_NAME],
           MAX([TL].[LICENSE_ID_SOURCE])[LICENSE_ID_SOURCE],
           MAX([IL].[STATUS]) AS [STATUS]
    FROM [wms].[OP_WMS_TASK_LIST] AS [TL]
		LEFT JOIN @USERS_X_WAREHOUSE [UW] 
			ON ([TL].[TASK_ASSIGNEDTO] = [UW].[LOGIN_ID])
        LEFT OUTER JOIN [wms].[OP_WMS_MATERIALS] AS [M]
            ON [TL].[MATERIAL_ID] = [M].[MATERIAL_ID]
        LEFT OUTER JOIN [wms].[OP_WMS_LICENSES] AS [L]
            ON [TL].[LICENSE_ID_SOURCE] = [L].[LICENSE_ID]
        LEFT OUTER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH]
            ON [TL].[CODIGO_POLIZA_TARGET] = [PH].[CODIGO_POLIZA]
        LEFT OUTER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PHR]
            ON [TL].[CODIGO_POLIZA_SOURCE] = [PHR].[CODIGO_POLIZA]
		LEFT OUTER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL]
			ON  ([L].[LICENSE_ID] = [IL].[LICENSE_ID] AND
			[IL].[MATERIAL_ID] = [TL].[MATERIAL_ID])
		LEFT JOIN @QTY_X_MATERIAL [QT] 
			ON ([QT].[MATERIAL_ID] = [TL].[MATERIAL_ID])
    WHERE [TL].[TASK_ASSIGNEDTO] = [UW].[LOGIN_ID]
		  AND [TL].[IS_COMPLETED] = 0
          AND [TL].[IS_PAUSED] = 0
          AND [TL].[IS_CANCELED] = 0
          AND [TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
		  AND QT.QUANTITY_TOTAL_ASSIGNED > [QT].[QUANTITY_OPERATED]
		  OR [TL].[TASK_ASSIGNEDTO] = ''
		  AND [TL].[IS_COMPLETED] = 0
          AND [TL].[IS_PAUSED] = 0
          AND [TL].[IS_CANCELED] = 0
          AND [TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
		  AND QT.QUANTITY_TOTAL_ASSIGNED > [QT].[QUANTITY_OPERATED]
		  GROUP BY  [TL].[SERIAL_NUMBER]

	
END;