-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	19-Sep-17 @ Nexus Team Sprint DuckHunt
-- Description:			SP que crea un registro en la tabla OP_WMS_TASK_LIST

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_INSERT_IMPLOSION_STEP_IN_TASK_LIST]
					@LICENSE_ID = 378261, -- int
					@MATERIAL_ID = 'autovanguard/VAD1002', -- varchar(50)
					@QTY = 10, -- numeric
					@LOGIN = 'ACAMACHO', -- varchar(25)
					@MASTER_PACK_ID = 'autovanguard/VAD1001', -- varchar(50)
					@LICENSE_ID_TARGET = 378263 -- int
				-- 
				SELECT * FROM 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_INSERT_IMPLOSION_STEP_IN_TASK_LIST](
	@LICENSE_ID INT
	,@MATERIAL_ID VARCHAR(50)
	,@QTY NUMERIC(18,4)
	,@LOGIN VARCHAR(25)
	,@MASTER_PACK_ID VARCHAR(50)
	,@LICENSE_ID_TARGET INT
) AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@ID INT 
		,@TASK_TYPE VARCHAR(25) = 'IMPLOSION_INVENTARIO'
        ,@TASK_SUBTYPE VARCHAR(25) = 'IMPLOSION_MANUAL'
		,@CODIGO_POLIZA VARCHAR(50)
		,@CODIGO_POLIZA_TARGET VARCHAR(50)
		,@REGIMEN VARCHAR(50)
		,@WAREHOUSE_SOURCE VARCHAR(25)
		,@WAREHOUSE_TARGET VARCHAR(25) 
		,@LOCATION_SPOT_SOURCE VARCHAR(25)
		,@LOCATION_SPOT_TARGET VARCHAR(25)
		,@CLIENT_OWNER VARCHAR(25)
		,@CLIENT_NAME VARCHAR(150)
		,@BARCODE_ID VARCHAR(25)
		,@ALTERNATE_BARCODE VARCHAR(25)
		,@MATERIAL_NAME VARCHAR(200)
		,@MATERIAL_SHORT_NAME VARCHAR(200)
		,@IS_FINISHED INT = 1;
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene datos
		-- ------------------------------------------------------------------------------------
		SELECT @CODIGO_POLIZA = [CODIGO_POLIZA]
				,@REGIMEN = [REGIMEN]
				,@WAREHOUSE_SOURCE = [CURRENT_WAREHOUSE]
				,@LOCATION_SPOT_SOURCE = [CURRENT_LOCATION]
		FROM [wms].[OP_WMS_LICENSES]
		WHERE [LICENSE_ID] = @LICENSE_ID
		--
		SELECT @CODIGO_POLIZA_TARGET = [CODIGO_POLIZA]
				,@WAREHOUSE_TARGET = [CURRENT_WAREHOUSE]
				,@LOCATION_SPOT_TARGET = [CURRENT_LOCATION]
		FROM [wms].[OP_WMS_LICENSES]
		WHERE [LICENSE_ID] = @LICENSE_ID_TARGET
		--
		SELECT @CLIENT_OWNER = [CLIENT_OWNER] 
				,@BARCODE_ID = [BARCODE_ID]
				,@ALTERNATE_BARCODE = [ALTERNATE_BARCODE]
				,@MATERIAL_NAME = [MATERIAL_NAME]
				,@MATERIAL_SHORT_NAME = [SHORT_NAME]
		FROM [wms].[OP_WMS_MATERIALS]
		WHERE [MATERIAL_ID] = @MATERIAL_ID
		--
		SELECT @CLIENT_NAME = [CLIENT_NAME] 
		FROM [wms].[OP_WMS_VIEW_CLIENTS]
		WHERE [CLIENT_CODE] = @CLIENT_OWNER
		-- ------------------------------------------------------------------------------------
		-- Inserta el detalle
		-- ------------------------------------------------------------------------------------
		INSERT INTO [wms].[OP_WMS_TASK_LIST]
				(
					[WAVE_PICKING_ID]
					,[TRANS_OWNER]
					,[TASK_TYPE]
					,[TASK_SUBTYPE]
					,[TASK_OWNER]
					,[TASK_ASSIGNEDTO]
					,[TASK_COMMENTS]
					,[ASSIGNED_DATE]
					,[QUANTITY_PENDING]
					,[QUANTITY_ASSIGNED]
					,[CODIGO_POLIZA_SOURCE]
					,[CODIGO_POLIZA_TARGET]
					,[LICENSE_ID_SOURCE]
					,[REGIMEN]
					,[IS_COMPLETED]
					,[IS_DISCRETIONAL]
					,[IS_PAUSED]
					,[IS_CANCELED]
					,[MATERIAL_ID]
					,[BARCODE_ID]
					,[ALTERNATE_BARCODE]
					,[MATERIAL_NAME]
					,[WAREHOUSE_SOURCE]
					,[WAREHOUSE_TARGET]
					,[LOCATION_SPOT_SOURCE]
					,[LOCATION_SPOT_TARGET]
					,[CLIENT_OWNER]
					,[CLIENT_NAME]
					,[ACCEPTED_DATE]
					,[COMPLETED_DATE]
					,[CANCELED_DATETIME]
					,[CANCELED_BY]
					,[MATERIAL_SHORT_NAME]
					,[IS_lOCKED]
					,[IS_DISCRETIONARY]
					,[TYPE_DISCRETIONARY]
					,[LINE_NUMBER_POLIZA_SOURCE]
					,[LINE_NUMBER_POLIZA_TARGET]
					,[DOC_ID_SOURCE]
					,[DOC_ID_TARGET]
					,[IS_ACCEPTED]
					,[IS_FROM_SONDA]
					,[IS_FROM_ERP]
					,[PRIORITY]
					,[REPLENISH_MATERIAL_ID_TARGET]
					,[FROM_MASTERPACK]
					,[MASTER_PACK_CODE]
					,[OWNER]
					,[SOURCE_TYPE]
					,[TRANSFER_REQUEST_ID]
					,[TONE]
					,[CALIBER]
					,[LICENSE_ID_TARGET]
				)
		VALUES
				(
					NULL  -- WAVE_PICKING_ID - numeric
					,NULL  -- TRANS_OWNER - numeric
					,@TASK_TYPE  -- TASK_TYPE - varchar(25)
					,@TASK_SUBTYPE -- TASK_SUBTYPE - varchar(25)
					,@LOGIN  -- TASK_OWNER - varchar(25)
					,@LOGIN  -- TASK_ASSIGNEDTO - varchar(25)
					,'IMPLOSION DE INVENTARIO'  -- TASK_COMMENTS - varchar(150)
					,GETDATE()  -- ASSIGNED_DATE - datetime
					,@QTY  -- QUANTITY_PENDING - numeric
					,@QTY  -- QUANTITY_ASSIGNED - numeric
					,@CODIGO_POLIZA  -- CODIGO_POLIZA_SOURCE - varchar(25)
					,@CODIGO_POLIZA_TARGET  -- CODIGO_POLIZA_TARGET - varchar(25)
					,@LICENSE_ID  -- LICENSE_ID_SOURCE - numeric
					,@REGIMEN  -- REGIMEN - varchar(50)
					,0  -- IS_COMPLETED - numeric
					,0  -- IS_DISCRETIONAL - int
					,0  -- IS_PAUSED - numeric
					,0  -- IS_CANCELED - numeric
					,@MATERIAL_ID  -- MATERIAL_ID - varchar(50)
					,@BARCODE_ID  -- BARCODE_ID - varchar(50)
					,@ALTERNATE_BARCODE  -- ALTERNATE_BARCODE - varchar(50)
					,@MATERIAL_NAME  -- MATERIAL_NAME - varchar(200)
					,@WAREHOUSE_SOURCE  -- WAREHOUSE_SOURCE - varchar(25)
					,@WAREHOUSE_TARGET  -- WAREHOUSE_TARGET - varchar(25)
					,@LOCATION_SPOT_SOURCE  -- LOCATION_SPOT_SOURCE - varchar(25)
					,@LOCATION_SPOT_TARGET  -- LOCATION_SPOT_TARGET - varchar(25)
					,@CLIENT_OWNER  -- CLIENT_OWNER - varchar(25)
					,@CLIENT_NAME  -- CLIENT_NAME - varchar(150)
					,GETDATE()  -- ACCEPTED_DATE - datetime
					,GETDATE()  -- COMPLETED_DATE - datetime
					,NULL  -- CANCELED_DATETIME - datetime
					,NULL  -- CANCELED_BY - varchar(25)
					,@MATERIAL_SHORT_NAME  -- MATERIAL_SHORT_NAME - varchar(200)
					,'0'  -- IS_lOCKED - varchar(1)
					,0  -- IS_DISCRETIONARY - int
					,NULL  -- TYPE_DISCRETIONARY - varchar(100)
					,0  -- LINE_NUMBER_POLIZA_SOURCE - int
					,0  -- LINE_NUMBER_POLIZA_TARGET - int
					,NULL  -- DOC_ID_SOURCE - numeric
					,NULL  -- DOC_ID_TARGET - numeric
					,0  -- IS_ACCEPTED - int
					,0  -- IS_FROM_SONDA - int
					,0  -- IS_FROM_ERP - int
					,0  -- PRIORITY - int
					,NULL  -- REPLENISH_MATERIAL_ID_TARGET - varchar(25)
					,1  -- FROM_MASTERPACK - int
					,@MASTER_PACK_ID  -- MASTER_PACK_CODE - varchar(50)
					,NULL  -- OWNER - varchar(50)
					,NULL  -- SOURCE_TYPE - varchar(50)
					,NULL  -- TRANSFER_REQUEST_ID - int
					,NULL  -- TONE - varchar(20)
					,NULL  -- CALIBER - varchar(20)
					,@LICENSE_ID_TARGET  -- LICENSE_ID_TARGET - int
				)
		--
		SET @ID = SCOPE_IDENTITY()

		-- ------------------------------------------------------------------------------------
		-- Valida si esta completa la implosion
		-- ------------------------------------------------------------------------------------
		
		SELECT TOP 1 @IS_FINISHED = 0
		FROM  [wms].[OP_WMS_MASTER_PACK_HEADER] [H]
		INNER JOIN [wms].[OP_WMS_MASTER_PACK_DETAIL] [D] ON [D].[MASTER_PACK_HEADER_ID] = [H].[MASTER_PACK_HEADER_ID]
		LEFT JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON [TL].[MATERIAL_ID] = [D].[MATERIAL_ID]
													AND [TL].[LICENSE_ID_TARGET] = @LICENSE_ID_TARGET
													AND [TL].[TASK_TYPE] = @TASK_TYPE
		WHERE [H].[MATERIAL_ID] = @MASTER_PACK_ID
		AND [H].[LICENSE_ID] = @LICENSE_ID_TARGET
		AND [H].[IS_IMPLOSION] = 1 
		GROUP BY 
			[D].[MATERIAL_ID]
		HAVING  MAX([D].[QTY]) * MAX([H].[QTY])  <> SUM(ISNULL([TL].[QUANTITY_ASSIGNED],0)) 


		-- ------------------------------------------------------------------------------------
		-- Muestra resultado de la operacion
		-- ------------------------------------------------------------------------------------
		SELECT
			1 as Resultado
			,'Proceso Exitoso' Mensaje
			,@IS_FINISHED Codigo
			,CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT
			-1 as Resultado
			,ERROR_MESSAGE() Mensaje 
			,@@ERROR Codigo 
			,'' DbData
	END CATCH
END