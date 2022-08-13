-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 17-04-2017 @Team Ergon Sprint Epona
-- Description:			Sp que crear una una nueva ola de picking.

/*
  -- Ejemplo de Ejecucion:
				-- 
				EXEC sp_INSERT_TASKS
            	@TASK_TYPE = ''
            	,@TASK_SUBTYPE = ''
            	,@TASK_OWNER = ''
            	,@TASK_ASSIGNEDTO	= ''
            	,@QUANTITY_ASSIGNED	= 0
            	,@QUANTITY_PENDING = 0
            	,@CODIGO_POLIZA_SOURCE = ''
            	,@CODIGO_POLIZA_TARGET = ''
            	,@REGIMEN = ''
            	,@MATERIAL_ID = ''
            	,@BARCODE_ID = ''
            	,@ALTERNATE_BARCODE = ''
            	,@MATERIAL_NAME = ''
            	,@CLIENT_OWNER = ''
            	,@CLIENT_NAME = ''
            	,@PRESULT = ''
            	,@WAVE_PICKING_ID = ''
            	,@TRAMSLATION = ''
              ,@LINE_NUMBER_SOURCE = 0
              ,@LINE_NUMBER_TARGET = 0
        
*/
-- =============================================

CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_TASKS_FISCAL]
(
    @TASK_TYPE VARCHAR(25),
    @TASK_SUBTYPE VARCHAR(25),
    @TASK_OWNER VARCHAR(25),
    @TASK_ASSIGNEDTO VARCHAR(25),
    @QUANTITY_ASSIGNED NUMERIC(18, 4),
    @QUANTITY_PENDING NUMERIC(18, 4),
    @CODIGO_POLIZA_SOURCE VARCHAR(25),
    @CODIGO_POLIZA_TARGET VARCHAR(25),
    @REGIMEN VARCHAR(50),
    @MATERIAL_ID VARCHAR(25),
    @BARCODE_ID VARCHAR(50),
    @ALTERNATE_BARCODE VARCHAR(50),
    @MATERIAL_NAME VARCHAR(200),
    @CLIENT_OWNER VARCHAR(25),
    @CLIENT_NAME VARCHAR(150),
    @PRESULT VARCHAR(4000) OUTPUT,
    @WAVE_PICKING_ID NUMERIC(18, 0) OUTPUT,
    @TRAMSLATION VARCHAR(10),
    @LINE_NUMBER_POLIZA_SOURCE INT = 0,
    @LINE_NUMBER_POLIZA_TARGET INT = 0,
    @LICENCE_ID NUMERIC(18, 0)
)
AS
BEGIN
    DECLARE @ASSIGNED_DATE DATETIME;
    DECLARE @CURRENT_LOCATION VARCHAR(25);
    DECLARE @CURRENT_WAREHOUSE VARCHAR(25);
    DECLARE @TASK_COMMENTS VARCHAR(150);
    DECLARE @SHORT_DESC VARCHAR(50);
    DECLARE @POLIZA_REGIME VARCHAR(25);
    DECLARE @QTY_LICENCE NUMERIC(18, 4);

    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRAN;
        SELECT @ASSIGNED_DATE = GETDATE();
        IF @WAVE_PICKING_ID = 0
        BEGIN
            SELECT @WAVE_PICKING_ID = NEXT VALUE FOR [wms].[OP_WMS_SEQ_WAVE_PICKING_ID];
        END;

        IF @WAVE_PICKING_ID = NULL
        BEGIN
            SET @WAVE_PICKING_ID = 1;
        END;

        SELECT @POLIZA_REGIME = [REGIMEN]
        FROM [wms].[OP_WMS_POLIZA_HEADER]
        WHERE [CODIGO_POLIZA] = @CODIGO_POLIZA_TARGET;

        IF @TRAMSLATION = 'SI'
        BEGIN
            SET @TASK_SUBTYPE = 'TRASLADO_GENERAL';
        END;

        SELECT @TASK_COMMENTS = 'OLA DE PICKING #' + CAST(@WAVE_PICKING_ID AS VARCHAR);

        SELECT @SHORT_DESC = SUBSTRING([SHORT_NAME], 1, 50)
        FROM [wms].[OP_WMS_MATERIALS]
        WHERE [MATERIAL_ID] = @MATERIAL_ID
              AND [BARCODE_ID] = @BARCODE_ID;

        --- --------------------------------------------------------------
        --- Obtenemos la ubicacion y la bodega de la licencia
        --- --------------------------------------------------------------
        SELECT @CURRENT_LOCATION = [L].[CURRENT_LOCATION],
               @CURRENT_WAREHOUSE = [L].[CURRENT_WAREHOUSE]
        FROM [wms].[OP_WMS_LICENSES] [L]
        WHERE [L].[LICENSE_ID] = @LICENCE_ID;

        --- --------------------------------------------------------------
        --- Validamos si la licensia tiene todavia la cantidad ingresada
        --- --------------------------------------------------------------  

        SELECT @QTY_LICENCE = [IL].[QTY]
        FROM [wms].[OP_WMS_INV_X_LICENSE] [IL]
        WHERE [IL].[LICENSE_ID] = @LICENCE_ID
              AND [IL].[MATERIAL_ID] = @MATERIAL_ID;

        IF @QTY_LICENCE >= @QUANTITY_ASSIGNED
        BEGIN
            --- --------------------------------------------------------------
            --- Insertamos la linea de la tarea
            --- --------------------------------------------------------------
            INSERT INTO [wms].[OP_WMS_TASK_LIST]
            (
                [WAVE_PICKING_ID],
                [TASK_TYPE],
                [TASK_SUBTYPE],
                [TASK_OWNER],
                [TASK_ASSIGNEDTO],
                [ASSIGNED_DATE],
                [QUANTITY_PENDING],
                [QUANTITY_ASSIGNED],
                [CODIGO_POLIZA_SOURCE],
                [CODIGO_POLIZA_TARGET],
                [LICENSE_ID_SOURCE],
                [REGIMEN],
                [IS_DISCRETIONAL],
                [MATERIAL_ID],
                [BARCODE_ID],
                [ALTERNATE_BARCODE],
                [MATERIAL_NAME],
                [WAREHOUSE_SOURCE],
                [LOCATION_SPOT_SOURCE],
                [CLIENT_OWNER],
                [CLIENT_NAME],
                [TASK_COMMENTS],
                [TRANS_OWNER],
                [IS_COMPLETED],
                [MATERIAL_SHORT_NAME],
                [LINE_NUMBER_POLIZA_SOURCE],
                [LINE_NUMBER_POLIZA_TARGET]
            )
            VALUES
            (@WAVE_PICKING_ID, @TASK_TYPE, @TASK_SUBTYPE, @TASK_OWNER, @TASK_ASSIGNEDTO, @ASSIGNED_DATE,
             @QUANTITY_PENDING, @QUANTITY_ASSIGNED, @CODIGO_POLIZA_SOURCE, @CODIGO_POLIZA_TARGET, @LICENCE_ID,
             @REGIMEN, 1, @MATERIAL_ID, @BARCODE_ID, @ALTERNATE_BARCODE, @MATERIAL_NAME, @CURRENT_WAREHOUSE,
             @CURRENT_LOCATION, @CLIENT_OWNER, @CLIENT_NAME, @TASK_COMMENTS, 0, 0, @SHORT_DESC,
             @LINE_NUMBER_POLIZA_SOURCE, @LINE_NUMBER_POLIZA_TARGET);

            INSERT INTO [wms].[OP_LOG]
            (
                [ERR_DATETIME],
                [ERR_TEXT],
                [ERR_SQL]
            )
            VALUES
            (GETDATE(), 'INSERTED',
             '@MATERIAL_ID: ' + @MATERIAL_ID + ' @CODIGO_POLIZA_SOURCE: ' + @CODIGO_POLIZA_SOURCE
             + ' @CODIGO_POLIZA_TARGET: ' + @CODIGO_POLIZA_TARGET + ' @LICENCE_ID: '
             + CONVERT(VARCHAR(20), @LICENCE_ID));

            SELECT @PRESULT = 'OK';
        END;
        ELSE
        BEGIN
            DELETE FROM [wms].[OP_WMS_TASK_LIST]
            WHERE [WAVE_PICKING_ID] = @WAVE_PICKING_ID;
            SELECT @PRESULT = 'Las licecias ya no tienen la misma cantidad ';
        END;
        COMMIT TRAN;
    END TRY
    BEGIN CATCH
        ROLLBACK TRAN;
        SELECT @PRESULT = ERROR_MESSAGE();
        SELECT @WAVE_PICKING_ID = 0;
    END CATCH;

END;