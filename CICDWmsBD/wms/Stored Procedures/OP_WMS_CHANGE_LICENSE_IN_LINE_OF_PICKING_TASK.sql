-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	30-Ago-2019 @ G-Force-Team Sprint FlorencioVarela
-- Description:         SP que anula una línea de una tarea de picking y genera una nueva en base a la cantidad pendiente por pickinear( :=) )

/*|
-- Ejemplo de Ejecucion:
        
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_CHANGE_LICENSE_IN_LINE_OF_PICKING_TASK]
(
    @SERIAL_NUMBER NUMERIC(18, 0),
    @LOGIN VARCHAR(64)
)
AS
DECLARE @TASK_OWNER VARCHAR(25),
        @TASK_ASSIGNEDTO VARCHAR(25),
        @QUANTITY_ASSIGNED NUMERIC(18, 4),
        @QUANTITY_PENDING NUMERIC(18, 4),
        @CODIGO_POLIZA_TARGET VARCHAR(25),
        @MATERIAL_ID VARCHAR(50),
        @BARCODE_ID VARCHAR(50),
        @ALTERNATE_BARCODE VARCHAR(50) = '',
        @MATERIAL_NAME VARCHAR(200),
        @CLIENT_OWNER VARCHAR(25),
        @CLIENT_NAME VARCHAR(150),
        @IS_FROM_SONDA INT = 0,
        @CODE_WAREHOUSE VARCHAR(50),
        @IS_FROM_ERP INT,
        @WAVE_PICKING_ID NUMERIC(18, 0),
        @DOC_ID_TARGET INT,
        @LOCATION_SPOT_TARGET VARCHAR(25),
        @IS_CONSOLIDATED INT = 0,
        @FROM_MASTERPACK INT = 0,
        @SOURCE_TYPE VARCHAR(50) = NULL,
        @TRANSFER_REQUEST_ID INT = 0,
        @TONE VARCHAR(20) = NULL,
        @CALIBER VARCHAR(20) = NULL,
        @IN_PICKING_LINE INT = 0,
        @IS_FOR_DELIVERY_IMMEDIATE INT,
        @PRIORITY INT = 1,
        @PICKING_HEADER_ID INT = NULL,
        @STATUS_CODE VARCHAR(50) = NULL,
        @PROJECT_ID UNIQUEIDENTIFIER = NULL,
        @ORDER_NUMBER VARCHAR(25),
        @MIN_DAYS_EXPIRATION_DATE INT,
        @DOC_NUM VARCHAR(50),
        @LICENSE_ID_SOURCE INT,
        @IS_COMPLETED INT = 0,
        @IS_CANCELED INT = 0;



DECLARE @OPERACION TABLE
(
    [Resultado] INT,
    [Mensaje] VARCHAR(MAX),
    [Codigo] INT,
    [DbData] VARCHAR(MAX)
);

DECLARE @Resultado INT,
        @Mensaje VARCHAR(MAX),
        @ASSEMBLED_QTY INT;
BEGIN

    -- ------------------------------------------------------------------------------------
    -- OBTENGO LOS DATOS DE LA TAREA PARA PODER ENVIAR AL PROCESO DE GENERACION DE LA NUEVA TAREA
    -- ------------------------------------------------------------------------------------
    SELECT @TASK_ASSIGNEDTO = [TL].[TASK_ASSIGNEDTO],
           @QUANTITY_ASSIGNED = [TL].[QUANTITY_ASSIGNED],
           @QUANTITY_PENDING = [TL].[QUANTITY_PENDING],
           @CODIGO_POLIZA_TARGET = [TL].[CODIGO_POLIZA_TARGET],
           @MATERIAL_ID = [MATERIAL_ID],
           @BARCODE_ID = [TL].[BARCODE_ID],
           @ALTERNATE_BARCODE = [TL].[ALTERNATE_BARCODE],
           @MATERIAL_NAME = [TL].[MATERIAL_NAME],
           @CLIENT_OWNER = [TL].[CLIENT_OWNER],
           @CLIENT_NAME = [TL].[CLIENT_NAME],
           @IS_FROM_SONDA = [TL].[IS_FROM_SONDA],
           @CODE_WAREHOUSE = [TL].[WAREHOUSE_SOURCE],
           @IS_FROM_ERP = [TL].[IS_FROM_ERP],
           @WAVE_PICKING_ID = [TL].[WAVE_PICKING_ID],
           @DOC_ID_TARGET = [TL].[DOC_ID_TARGET],
           @LOCATION_SPOT_TARGET = [TL].[LOCATION_SPOT_TARGET],
           @FROM_MASTERPACK = [TL].[FROM_MASTERPACK],
           @SOURCE_TYPE = [TL].[SOURCE_TYPE],
           @TRANSFER_REQUEST_ID = [TL].[TRANSFER_REQUEST_ID],
           @TONE = [TL].[TONE],
           @CALIBER = [TL].[CALIBER],
           @IN_PICKING_LINE = [TL].[IN_PICKING_LINE],
           @IS_FOR_DELIVERY_IMMEDIATE = [TL].[IS_FOR_DELIVERY_IMMEDIATE],
           @PRIORITY = [TL].[PRIORITY],
           @PICKING_HEADER_ID = 0,
           @STATUS_CODE = [TL].[STATUS_CODE],
           @PROJECT_ID = [TL].[PROJECT_ID],
           @ORDER_NUMBER = [TL].[ORDER_NUMBER],
           @LICENSE_ID_SOURCE = [TL].[LICENSE_ID_SOURCE],
           @IS_COMPLETED = [TL].[IS_COMPLETED],
           @IS_CANCELED = [TL].[IS_CANCELED]
    FROM [wms].[OP_WMS_TASK_LIST] [TL]
    WHERE [SERIAL_NUMBER] = @SERIAL_NUMBER;

    IF @IS_COMPLETED = 1
       OR @IS_CANCELED = 1
    BEGIN
        SET @Mensaje = 'La línea ya fue completada ';

        RAISERROR(@Mensaje, 16, 1);
        RETURN;
    END;

    SELECT @IS_CONSOLIDATED = MAX([IS_CONSOLIDATED]),
           @DOC_NUM = CASE MAX([IS_CONSOLIDATED])
                          WHEN 1 THEN
                              'CONSOLIDADO'
                          WHEN 0 THEN
                              MAX([DOC_NUM])
                      END,
           @MIN_DAYS_EXPIRATION_DATE = MAX([MIN_DAYS_EXPIRATION_DATE])
    FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
    WHERE [WAVE_PICKING_ID] = @WAVE_PICKING_ID
    GROUP BY [WAVE_PICKING_ID];

    -- ------------------------------------------------------------------------------------
    -- hago un sumarizado de la cantidad pendiente de despachar para el material de la línea seleccionada y verifico que después de pasar por el proceso de generación de la nueva línea de la tarea no exceda lo pendiente de despachar
    -- sin tomar en cuenta la línea que deseaba anular
    -- ------------------------------------------------------------------------------------

    DECLARE @TOTAL_PENDING_BEFORE NUMERIC(18, 4) = 0;
    DECLARE @TOTAL_PENDING_AFTER NUMERIC(18, 4) = 0;
    SELECT @TOTAL_PENDING_BEFORE = SUM([QUANTITY_PENDING])
    FROM [wms].[OP_WMS_TASK_LIST]
    WHERE [WAVE_PICKING_ID] = @WAVE_PICKING_ID
          AND [MATERIAL_ID] = @MATERIAL_ID
          AND [QUANTITY_PENDING] < [QUANTITY_ASSIGNED]
          AND [IS_CANCELED] = 0
          AND [IS_COMPLETED] = 0
          AND [SERIAL_NUMBER] <> @SERIAL_NUMBER;

    PRINT 'DOC NUM =>' + @DOC_NUM;

    IF @DOC_NUM IS NOT NULL
    BEGIN
        -- ------------------------------------------------------------------------------------
        -- creo una o varias tareas dependiendo de la cantidad pendiente en la linea de task_list para demanda de despacho
        -- ------------------------------------------------------------------------------------
        INSERT INTO @OPERACION
        (
            [Resultado],
            [Mensaje],
            [Codigo],
            [DbData]
        )
        EXEC [wms].[OP_WMS_SP_INSERT_TASKS_GENERAL_PICKING_DEMAND] @TASK_OWNER = @LOGIN,                          -- varchar(25)
                                                                   @TASK_ASSIGNEDTO = @TASK_ASSIGNEDTO,           -- varchar(25)
                                                                   @QUANTITY_ASSIGNED = @QUANTITY_PENDING,        -- numeric
                                                                   @CODIGO_POLIZA_TARGET = @CODIGO_POLIZA_TARGET, -- varchar(25)
                                                                   @MATERIAL_ID = @MATERIAL_ID,                   -- varchar(50)
                                                                   @BARCODE_ID = @BARCODE_ID,                     -- varchar(50)
                                                                   @ALTERNATE_BARCODE = @ALTERNATE_BARCODE,       -- varchar(50)
                                                                   @MATERIAL_NAME = @MATERIAL_NAME,               -- varchar(200)
                                                                   @CLIENT_OWNER = @CLIENT_OWNER,                 -- varchar(25)
                                                                   @CLIENT_NAME = @CLIENT_NAME,                   -- varchar(150)
                                                                   @IS_FROM_SONDA = @IS_FROM_SONDA,               -- int
                                                                   @CODE_WAREHOUSE = @CODE_WAREHOUSE,             -- varchar(50)
                                                                   @IS_FROM_ERP = @IS_FROM_ERP,                   -- int
                                                                   @WAVE_PICKING_ID = @WAVE_PICKING_ID,           -- numeric
                                                                   @DOC_ID_TARGET = @DOC_ID_TARGET,               -- int
                                                                   @LOCATION_SPOT_TARGET = @LOCATION_SPOT_TARGET, -- varchar(25)
                                                                   @IS_CONSOLIDATED = @IS_CONSOLIDATED,           -- int
                                                                   @SOURCE_TYPE = @SOURCE_TYPE,                   -- varchar(50)
                                                                   @TRANSFER_REQUEST_ID = @TRANSFER_REQUEST_ID,   -- int
                                                                   @TONE = @TONE,                                 -- varchar(20)
                                                                   @CALIBER = @CALIBER,                           -- varchar(20)
                                                                   @IN_PICKING_LINE = @IN_PICKING_LINE,           -- int
                                                                   @IS_FOR_DELIVERY_IMMEDIATE = @IS_FOR_DELIVERY_IMMEDIATE,
                                                                   @PRIORITY = @PRIORITY,
                                                                   @PICKING_HEADER_ID = NULL,
                                                                   @STATUS_CODE = @STATUS_CODE,
                                                                   @PROJECT_ID = @PROJECT_ID,
                                                                   @ORDER_NUMBER = @ORDER_NUMBER,
                                                                   @MIN_DAYS_EXPIRATION_DATE = @MIN_DAYS_EXPIRATION_DATE,
                                                                   @DOC_NUM = @DOC_NUM,
                                                                   @LICENSE_ID_TO_EXCLUDE = @LICENSE_ID_SOURCE;


        SELECT @Resultado = [O].[Resultado],
               @Mensaje = [O].[Mensaje],
               @WAVE_PICKING_ID = CAST([wms].[OP_WMS_FN_SPLIT_COLUMNS]([O].[DbData], 1, '|') AS INT),
               @ASSEMBLED_QTY = ISNULL(CAST([wms].[OP_WMS_FN_SPLIT_COLUMNS]([O].[DbData], 2, '|') AS INT), 0)
        FROM @OPERACION [O];
        --
        PRINT '--> @WAVE_PICKING_ID: ' + CAST(@WAVE_PICKING_ID AS VARCHAR);
        PRINT '--> @ASSEMBLED_QTY: ' + CAST(@ASSEMBLED_QTY AS VARCHAR);

        IF @Resultado = -1
        BEGIN
            RAISERROR(@Mensaje, 16, 1);
            RETURN;
        END;
    END;
    ELSE
    BEGIN
        -- ------------------------------------------------------------------------------------
        -- -- creo una o varias tareas dependiendo de la cantidad pendiente en la linea de task_list para picking general
        -- ------------------------------------------------------------------------------------
        DECLARE @presult VARCHAR(4000);
        EXEC [wms].[OP_WMS_SP_INSERT_TASKS_GENERAL] @TASK_OWNER = @LOGIN,                          -- varchar(25)
                                                    @TASK_ASSIGNEDTO = @TASK_ASSIGNEDTO,           -- varchar(25)
                                                    @QUANTITY_ASSIGNED = @QUANTITY_PENDING,        -- numeric
                                                    @CODIGO_POLIZA_TARGET = @CODIGO_POLIZA_TARGET, -- varchar(25)
                                                    @MATERIAL_ID = @MATERIAL_ID,                   -- varchar(25)
                                                    @BARCODE_ID = @BARCODE_ID,                     -- varchar(50)
                                                    @ALTERNATE_BARCODE = @ALTERNATE_BARCODE,       -- varchar(50)
                                                    @MATERIAL_NAME = @MATERIAL_NAME,               -- varchar(200)
                                                    @CLIENT_OWNER = @CLIENT_OWNER,                 -- varchar(25)
                                                    @CLIENT_NAME = @CLIENT_NAME,                   -- varchar(150)
                                                    @PRESULT = @presult,                           -- varchar(4000)
                                                    @WAVE_PICKING_ID = @WAVE_PICKING_ID,           -- numeric
                                                    @IS_FROM_SONDA = @IS_FROM_SONDA,               -- int
                                                    @WAREHOUSE = @CODE_WAREHOUSE,                  -- varchar(50)
                                                    @FROM_MASTERPACK = @FROM_MASTERPACK,           -- int
                                                    @MASTER_PACK_CODE = '',                        -- varchar(50)
                                                    @SEND_ERP = @IS_FROM_ERP,                      -- int
                                                    @PRIORITY = @PRIORITY,                         -- int
                                                    @PROJECT_ID = @PROJECT_ID,                     -- uniqueidentifier
                                                    @STATUS_CODE = @STATUS_CODE,                   -- varchar(100)
                                                    @LOCATION_SPOT_TARGET = @LOCATION_SPOT_TARGET, -- varchar(50)
                                                    @LICENSE_ID_TO_EXCLUDE = @LICENSE_ID_SOURCE;

        IF @presult <> 'OK'
        BEGIN
            RAISERROR(@presult, 16, 1);
            RETURN;
        END;

    END;

    -- ------------------------------------------------------------------------------------
    -- obtengo la cantidad después de haber generado la(s) nueva(s) línea(s) de la tarea sin tomar en cuenta la línea que deseaba anular
    -- ------------------------------------------------------------------------------------
    SELECT @TOTAL_PENDING_AFTER = SUM([QUANTITY_PENDING])
    FROM [wms].[OP_WMS_TASK_LIST]
    WHERE [WAVE_PICKING_ID] = @WAVE_PICKING_ID
          AND [MATERIAL_ID] = @MATERIAL_ID
          AND [QUANTITY_PENDING] < [QUANTITY_ASSIGNED]
          AND [IS_CANCELED] = 0
          AND [IS_COMPLETED] = 0
          AND [SERIAL_NUMBER] <> @SERIAL_NUMBER;

    -- ------------------------------------------------------------------------------------
    -- las cantidades deben ser iguales pues el proceso solo busca que las nuevas líneas pidan que se realice el picking con otras licencias
    -- ------------------------------------------------------------------------------------
    IF @TOTAL_PENDING_AFTER <> @TOTAL_PENDING_BEFORE
    BEGIN
        SET @Mensaje
            = 'El proceso generó una tarea o varias por más cantidad que la cantidad original de la línea = '
              + CAST(@SERIAL_NUMBER AS VARCHAR);
        RAISERROR(@Mensaje, 16, 1);
        RETURN;
    END;

    -- ------------------------------------------------------------------------------------
    -- si para la línea ya habían realizado el picking parcial marco la tarea como completada de lo contrario anulo la tarea
    -- ------------------------------------------------------------------------------------

    IF @QUANTITY_PENDING > 0
    BEGIN
        UPDATE [wms].[OP_WMS_TASK_LIST]
        SET [IS_COMPLETED] = 1,
            [QUANTITY_ASSIGNED] = [QUANTITY_ASSIGNED] - [QUANTITY_PENDING],
            [QUANTITY_PENDING] = 0
        WHERE [SERIAL_NUMBER] = @SERIAL_NUMBER;
    END;
    ELSE
    BEGIN
        UPDATE [wms].[OP_WMS_TASK_LIST]
        SET [IS_CANCELED] = 1,
            [IS_PAUSED] = 3
        WHERE [SERIAL_NUMBER] = @SERIAL_NUMBER;
    END;

    SELECT 1 AS [Resultado],
           'Proceso Exitoso' [Mensaje],
           0 [Codigo],
           '' [DbData];


END;
