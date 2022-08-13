-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/19/2017 @ NEXUS-Team Sprint DuckHunt 
-- Description:			Finaliza el proceso de implosión.

-- Autor:					marvin.solares
-- Fecha de Creacion: 		7/9/2018 GForce@FocaMonje 
-- Description:			    asigna el costo del material a la transaccion

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_FINISH_IMPLOSION]
					@MATERIAL_ID = '',
					@LOCATION_ID = '',
					@LICENSE_ID = 100248,
					@LOGIN = 'ADMIN',
					@QTY = 10	
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_FINISH_IMPLOSION] (
		@MATERIAL_ID VARCHAR(50)
		,@LOCATION_ID VARCHAR(25)
		,@LICENSE_ID INT
		,@LOGIN VARCHAR(25)
		,@QTY DECIMAL	
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@LOGIN_NAME VARCHAR(50)
		,@AUTORIZACION_AUTOMATICA INT = 0
		,@MATERIAL_NAME VARCHAR(200)
		,@BARCODE_ID VARCHAR(25)
		,@TERMS_OF_TRADE VARCHAR(50)
		,@CODIGO_POLIZA VARCHAR(25)
		,@CURRENT_WAREHOUSE VARCHAR(25)
		,@CLIENT_CODE VARCHAR(50)
		,@CLIENT_NAME VARCHAR(150);
	--
	BEGIN TRY
		SELECT TOP 1
			@LOGIN_NAME = [LOGIN_NAME]
		FROM
			[wms].[OP_WMS_LOGINS]
		WHERE
			[LOGIN_ID] = @LOGIN;
		--
		SELECT
			@CURRENT_WAREHOUSE = [WAREHOUSE_PARENT]
		FROM
			[wms].[OP_WMS_SHELF_SPOTS]
		WHERE
			[LOCATION_SPOT] = @LOCATION_ID;
		--
		SELECT TOP 1
			@AUTORIZACION_AUTOMATICA = [NUMERIC_VALUE]
		FROM
			[wms].[OP_WMS_CONFIGURATIONS]
		WHERE
			[PARAM_GROUP] = 'MASTER_PACK_SETTINGS'
			AND [PARAM_NAME] = 'AUTORIZA_ERP_AUTOMATICO';
		--
		SELECT TOP 1
			@MATERIAL_NAME = [MATERIAL_NAME]
			,@BARCODE_ID = [BARCODE_ID]
			,@CLIENT_CODE = [CLIENT_OWNER]
		FROM
			[wms].[OP_WMS_MATERIALS]
		WHERE
			[MATERIAL_ID] = @MATERIAL_ID;
		--
		SELECT TOP 1
			@CODIGO_POLIZA = [CODIGO_POLIZA]
		FROM
			[wms].[OP_WMS_LICENSES]
		WHERE
			[LICENSE_ID] = @LICENSE_ID;
		--
		SELECT TOP 1
			@TERMS_OF_TRADE = [ACUERDO_COMERCIAL]
		FROM
			[wms].[OP_WMS_POLIZA_HEADER]
		WHERE
			[CODIGO_POLIZA] = @CODIGO_POLIZA;
		--
		SELECT
			@QTY = [QTY]
		FROM
			[wms].[OP_WMS_MASTER_PACK_HEADER]
		WHERE
			[MATERIAL_ID] = @MATERIAL_ID
			AND [LICENSE_ID] = @LICENSE_ID;
		-- ------------------------------------------------------------------------------------
		-- Inserta las tareas a una tabla temporal
		-- ------------------------------------------------------------------------------------
		SELECT
			[SERIAL_NUMBER]
			,[WAVE_PICKING_ID]
			,[QUANTITY_PENDING]
			,[QUANTITY_ASSIGNED]
			,[CODIGO_POLIZA_SOURCE]
			,[CODIGO_POLIZA_TARGET]
			,[LICENSE_ID_SOURCE]
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
			,[OWNER]
			,[TASK_ASSIGNEDTO]
		INTO
			[#TASK]
		FROM
			[wms].[OP_WMS_TASK_LIST] [TL]
		WHERE
			[TL].[LICENSE_ID_TARGET] = @LICENSE_ID
			AND [TL].[TASK_TYPE] = 'IMPLOSION_INVENTARIO';
		--
		SELECT
			[MATERIAL_ID]
			,[LICENSE_ID_SOURCE]
			,SUM([QUANTITY_PENDING]) [QTY]
		INTO
			[#GROUPED_TASK]
		FROM
			[#TASK]
		GROUP BY
			[MATERIAL_ID]
			,[LICENSE_ID_SOURCE];
		--
		BEGIN TRANSACTION;
		-- ------------------------------------------------------------------------------------
		-- Inserta las transacciones
		-- ------------------------------------------------------------------------------------
		INSERT	INTO [wms].[OP_WMS_TRANS]
				(
					[TRANS_DATE]
					,[LOGIN_ID]
					,[LOGIN_NAME]
					,[TRANS_TYPE]
					,[TRANS_DESCRIPTION]
					,[MATERIAL_BARCODE]
					,[MATERIAL_CODE]
					,[MATERIAL_DESCRIPTION]
					,[MATERIAL_COST]
					,[SOURCE_LICENSE]
					,[TARGET_LICENSE]
					,[SOURCE_LOCATION]
					,[TARGET_LOCATION]
					,[CLIENT_OWNER]
					,[CLIENT_NAME]
					,[QUANTITY_UNITS]
					,[SOURCE_WAREHOUSE]
					,[TARGET_WAREHOUSE]
					,[TRANS_SUBTYPE]
					,[CODIGO_POLIZA]
					,[LICENSE_ID]
					,[STATUS]
					,[WAVE_PICKING_ID]
					,[TASK_ID] 
				)
		SELECT
			GETDATE()
			,@LOGIN
			,@LOGIN_NAME
			,'EXPLODE_OUT'
			,'EXPLODE OUT'
			,[T].[BARCODE_ID]
			,[T].[MATERIAL_ID]
			,[T].[MATERIAL_NAME]
			,[wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL]([T].[MATERIAL_ID],
											[T].[CLIENT_OWNER])
			,[T].[LICENSE_ID_SOURCE]
			,@LICENSE_ID
			,[T].[LOCATION_SPOT_SOURCE]
			,@LOCATION_ID
			,[T].[CLIENT_OWNER]
			,[T].[CLIENT_NAME]
			,[T].[QUANTITY_ASSIGNED]
			,[T].[WAREHOUSE_SOURCE]
			,[T].[WAREHOUSE_TARGET]
			,''
			,[T].[CODIGO_POLIZA_TARGET]
			,@LICENSE_ID
			,'PROCESSED'
			,[T].[WAVE_PICKING_ID]
			,[T].[SERIAL_NUMBER]
		FROM
			[#TASK] [T];
		--
		INSERT	INTO [wms].[OP_WMS_TRANS]
				(
					[TRANS_DATE]
					,[LOGIN_ID]
					,[LOGIN_NAME]
					,[TRANS_TYPE]
					,[TRANS_DESCRIPTION]
					,[MATERIAL_BARCODE]
					,[MATERIAL_CODE]
					,[MATERIAL_DESCRIPTION]
					,[MATERIAL_COST]
					,[SOURCE_LICENSE]
					,[TARGET_LICENSE]
					,[SOURCE_LOCATION]
					,[TARGET_LOCATION]
					,[CLIENT_OWNER]
					,[CLIENT_NAME]
					,[QUANTITY_UNITS]
					,[SOURCE_WAREHOUSE]
					,[TARGET_WAREHOUSE]
					,[TRANS_SUBTYPE]
					,[CODIGO_POLIZA]
					,[LICENSE_ID]
					,[STATUS]
					,[WAVE_PICKING_ID]
					,[TASK_ID] 
				)
		VALUES
				(
					GETDATE()
					,@LOGIN
					,@LOGIN_NAME
					,'EXPLODE_IN'
					,'EXPLODE IN'
					,@BARCODE_ID
					,@MATERIAL_ID
					,@MATERIAL_NAME
					,[wms].[OP_WMS_FN_GET_MATERIAL_COST_BY_MATERIAL](@MATERIAL_ID,
											@CLIENT_CODE)
					,NULL
					,@LICENSE_ID
					,''
					,@LOCATION_ID
					,@CLIENT_CODE
					,@CLIENT_CODE
					,@QTY
					,''
					,@CURRENT_WAREHOUSE
					,''
					,@CODIGO_POLIZA
					,@LICENSE_ID
					,'PROCESSED'
					,NULL
					,NULL
				);
		-- ------------------------------------------------------------------------------------
		-- Completa las tareas en TASK_LIST
		-- ------------------------------------------------------------------------------------
		UPDATE
			[TL]
		SET	
			[TL].[IS_COMPLETED] = 1
		FROM
			[wms].[OP_WMS_TASK_LIST] [TL]
		INNER JOIN [#TASK] [T] ON [T].[SERIAL_NUMBER] = [TL].[SERIAL_NUMBER]
		WHERE
			[TL].[SERIAL_NUMBER] > 0;
		-- ------------------------------------------------------------------------------------
		-- Reduce inventario de cada licencia
		-- ------------------------------------------------------------------------------------
		UPDATE
			[IXL]
		SET	
			[IXL].[QTY] = CASE	WHEN [IXL].[QTY] - [T].[QTY] < 0
								THEN 0
								ELSE [IXL].[QTY] - [T].[QTY]
							END
		FROM
			[wms].[OP_WMS_INV_X_LICENSE] [IXL]
		INNER JOIN [#GROUPED_TASK] [T] ON [T].[MATERIAL_ID] = [IXL].[MATERIAL_ID]
											AND [T].[LICENSE_ID_SOURCE] = [IXL].[LICENSE_ID]
		WHERE
			[IXL].[LICENSE_ID] > 0;
		-- ------------------------------------------------------------------------------------
		-- Ubica licencia
		-- ------------------------------------------------------------------------------------
		UPDATE
			[wms].[OP_WMS_LICENSES]
		SET	
			[CURRENT_LOCATION] = @LOCATION_ID
			,[CURRENT_WAREHOUSE] = @CURRENT_WAREHOUSE
		WHERE
			[LICENSE_ID] = @LICENSE_ID;
		-- ------------------------------------------------------------------------------------
		-- Bloquea el inventario del masterpack
		-- ------------------------------------------------------------------------------------
		INSERT	INTO [wms].[OP_WMS_INV_X_LICENSE]
				(
					[LICENSE_ID]
					,[MATERIAL_ID]
					,[MATERIAL_NAME]
					,[QTY]
					,[LAST_UPDATED]
					,[LAST_UPDATED_BY]
					,[BARCODE_ID]
					,[TERMS_OF_TRADE]
					,[STATUS]
					,[CREATED_DATE]
					,[ENTERED_QTY]
					,[IS_EXTERNAL_INVENTORY]
					,[IS_BLOCKED] 
				)
		VALUES
				(
					@LICENSE_ID
					, -- LICENSE_ID - numeric
					@MATERIAL_ID
					, -- MATERIAL_ID - varchar(50)
					@MATERIAL_NAME
					, -- MATERIAL_NAME - varchar(150)
					@QTY
					, -- QTY - numeric
					GETDATE()
					, -- LAST_UPDATED - datetime
					@LOGIN
					, -- LAST_UPDATED_BY - varchar(25)
					@BARCODE_ID
					, -- BARCODE_ID - varchar(25)
					@TERMS_OF_TRADE
					, -- TERMS_OF_TRADE - varchar(50)
					'PROCESSED'
					, -- STATUS - varchar(25)
					GETDATE()
					, -- CREATED_DATE - datetime
					@QTY
					, -- ENTERED_QTY - numeric
					0
					, -- IS_EXTERNAL_INVENTORY - int
					1  -- IS_BLOCKED - int
				);
		-- ------------------------------------------------------------------------------------
		-- Autoriza automaticamente si esta activo y pone la columna IS_IMPLOSION como 1
		-- ------------------------------------------------------------------------------------
		UPDATE
			[wms].[OP_WMS_MASTER_PACK_HEADER]
		SET	
			[IS_AUTHORIZED] = @AUTORIZACION_AUTOMATICA
		WHERE
			[MATERIAL_ID] = @MATERIAL_ID
			AND [LICENSE_ID] = @LICENSE_ID;
		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado final
		-- ------------------------------------------------------------------------------------
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'' [DbData];
		COMMIT TRANSACTION;
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]; 

		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;
	END CATCH;
END;