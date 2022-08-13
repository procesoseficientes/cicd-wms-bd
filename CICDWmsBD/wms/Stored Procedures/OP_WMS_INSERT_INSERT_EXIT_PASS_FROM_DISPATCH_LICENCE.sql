-- =============================================
-- Autor:               rudi.garcia 
-- Fecha de Creacion:   22-Jan-2019 G-Force@Quetal
-- Description:         SP que inserta el pase de salida desde el movil
/*
                                                    
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_INSERT_INSERT_EXIT_PASS_FROM_DISPATCH_LICENCE] (
		@DISPATCH_LICENSE_EXIT_HEADER INT
		,@VEHICLE_CODE INT
		,@PILOT_CODE INT
		,@LOGIN VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;

	BEGIN TRY;
		BEGIN TRAN;

    -- ------------------------------------------------------------------------------------
    -- Declaramos las variables necesarias.
    -- ------------------------------------------------------------------------------------

		DECLARE
			@PASS_ID INT
			,@WAVE_PICKING_ID INT
			,@CLIENT_CODE VARCHAR(25)
			,@CLIENT_NAME VARCHAR(200)
			,@VEHICLE_PLATE VARCHAR(25)
			,@VEHICLE_DRIVER VARCHAR(200)
			,@AUTORIZED_BY VARCHAR(200);

    -- ------------------------------------------------------------------------------------
    -- Obtenemos los registros necesarios
    -- ------------------------------------------------------------------------------------

		SELECT TOP 1
			@WAVE_PICKING_ID = [DLED].[WAVE_PICKING_ID]
		FROM
			[wms].[OP_WMS_DISPATCH_LICENSE_EXIT_HEADER] [DLEH]
		INNER JOIN [wms].[OP_WMS_DISPATCH_LICENSE_EXIT_DETAIL] [DLED] ON ([DLEH].[DISPATCH_LICENSE_EXIT_HEADER_ID] = [DLED].[DISPATCH_LICENSE_EXIT_HEADER_ID])
		WHERE
			[DLEH].[DISPATCH_LICENSE_EXIT_HEADER_ID] = @DISPATCH_LICENSE_EXIT_HEADER;


		SELECT TOP 1
			@CLIENT_CODE = [TL].[CLIENT_OWNER]
			,@CLIENT_NAME = [TL].[CLIENT_NAME]
			,@AUTORIZED_BY = [TL].[TASK_ASSIGNEDTO]
		FROM
			[wms].[OP_WMS_TASK_LIST] [TL]
		WHERE
			[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;

		SELECT TOP 1
			@VEHICLE_PLATE = [V].[PLATE_NUMBER]
		FROM
			[wms].[OP_WMS_VEHICLE] [V]
		WHERE
			[V].[VEHICLE_CODE] = @VEHICLE_CODE;

		SELECT TOP 1
			@VEHICLE_DRIVER = [P].[NAME]
		FROM
			[wms].[OP_WMS_PILOT] [P]
		WHERE
			[P].[PILOT_CODE] = @PILOT_CODE;



		INSERT	[wms].[OP_WMS3PL_PASSES]
				(
					[CLIENT_CODE]
					,[CLIENT_NAME]
					,[LAST_UPDATED_BY]
					,[LAST_UPDATED]
					,[ISEMPTY]
					,[VEHICLE_PLATE]
					,[VEHICLE_DRIVER]
					,[VEHICLE_ID]
					,[DRIVER_ID]
					,[AUTORIZED_BY]
					,[HANDLER]
					,[LOADUNLOAD]
					,[CREATED_DATE]
					,[CREATED_BY]
					,[STATUS]
					,[TYPE]
				)
		VALUES
				(
					@CLIENT_CODE
					,@CLIENT_NAME
					,@LOGIN
					,GETDATE()
					,'Y'
					,@VEHICLE_PLATE
					,@VEHICLE_DRIVER
					,@VEHICLE_CODE
					,@PILOT_CODE
					,@AUTORIZED_BY
					,@LOGIN
					,'C'
					,GETDATE()
					,@LOGIN
					,'CREATED'
					,'SALES_ORDER'
				);

		SET @PASS_ID = SCOPE_IDENTITY();

		INSERT	INTO [wms].[OP_WMS_PASS_DETAIL]
				(
					[PASS_HEADER_ID]
					,[CLIENT_CODE]
					,[CLIENT_NAME]
					,[PICKING_DEMAND_HEADER_ID]
					,[DOC_NUM]
					,[MATERIAL_ID]
					,[MATERIAL_NAME]
					,[QTY]
					,[DOC_NUM_POLIZA]
					,[CODIGO_POLIZA]
					,[NUMERO_ORDEN_POLIZA]
					,[WAVE_PICKING_ID]
					,[CREATED_DATE]
					,[CODE_WAREHOUSE]
					,[TYPE_DEMAND_CODE]
					,[TYPE_DEMAND_NAME]
					,[LINE_NUM]
				)
		SELECT
			@PASS_ID
			,[DLED].[CLIENT_CODE]
			,[DLED].[CLIENT_NAME]
			,[DLED].[PICKING_DEMAND_HEADER_ID]
			,[DLED].[DOC_NUM]
			,[DLED].[MATERIAL_ID]
			,[DLED].[MATERIAL_NAME]
			,[DLED].[QTY]
			,[DLED].[DOC_NUM_POLIZA]
			,[DLED].[CODIGO_POLIZA]
			,[DLED].[NUMERO_ORDEN_POLIZA]
			,[DLED].[WAVE_PICKING_ID]
			,[DLED].[CREATED_DATE]
			,[DLED].[CODE_WAREHOUSE]
			,[DLED].[TYPE_DEMAND_CODE]
			,[DLED].[TYPE_DEMAND_NAME]
			,[DLED].[LINE_NUM]
		FROM
			[wms].[OP_WMS_DISPATCH_LICENSE_EXIT_DETAIL] [DLED]
		WHERE
			[DLED].[DISPATCH_LICENSE_EXIT_HEADER_ID] = @DISPATCH_LICENSE_EXIT_HEADER;

		UPDATE
			[DLEH]
		SET	
			[DLEH].[PASS_EXIT_ID] = @PASS_ID
		FROM
			[wms].[OP_WMS_DISPATCH_LICENSE_EXIT_HEADER] [DLEH]
		WHERE
			[DLEH].[DISPATCH_LICENSE_EXIT_HEADER_ID] = @DISPATCH_LICENSE_EXIT_HEADER;

		COMMIT;

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@PASS_ID AS VARCHAR(20)) [DbData];

	END TRY
	BEGIN CATCH
		ROLLBACK;
		DECLARE	@message VARCHAR(1000) = @@ERROR;
		PRINT @message;
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];

		RAISERROR (@message, 16, 1);

	END CATCH;
END;
