-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	07-Dec-17 @ Nexus Team Sprint HeyYouPikachu!
-- Description:			SP que actualiza la tarea de linea de picking
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_UPDATE_BOX_QTY]
					@LOGIN = 'BETO'
					,@ERP_DOC = 'P-4881'
					,@BOX_ID = '666'
					,@MATERIAL_ID = 'autovanguard/VRA1103'
					,@QTY = 1
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_BOX_QTY](
	@LOGIN VARCHAR(50)
	,@ERP_DOC VARCHAR(50)
	,@BOX_ID VARCHAR(50)
	,@MATERIAL_ID VARCHAR(50)
	,@QTY NUMERIC(18,6)
	,@PICKING_LINE VARCHAR(15) = ''
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@WAVE_PICKING_ID INT
		,@IT_FINISH_THE_ORDER INT = 0
		,@REMOVE_QTY NUMERIC(18,6) = 0
		,@STATUS VARCHAR(25) = 'PICKED'
		,@RESULT VARCHAR(1000) = '';

	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene la ola
		-- ------------------------------------------------------------------------------------
		SELECT @WAVE_PICKING_ID = [wms].[OP_WMS_FN_SPLIT_COLUMNS](@ERP_DOC,2,'-')
		--
		PRINT '------> @WAVE_PICKING_ID: ' + CAST(@WAVE_PICKING_ID AS VARCHAR)

		-- ------------------------------------------------------------------------------------
		-- Obtiene la diferecia con la cantidad original
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@REMOVE_QTY = [QUANTITY] - @QTY
		FROM [op_wms].[dbo].[OP_WMS_DISTRIBUTED_TASK]
		WHERE [ERP_DOC] = @ERP_DOC
			AND [BOX_ID] = @BOX_ID
			AND [MATERIAL_ID] = @MATERIAL_ID

		-- ------------------------------------------------------------------------------------
		-- Actualiza o elimina la tarea de la linea
		-- ------------------------------------------------------------------------------------
		IF @QTY = 0
		BEGIN
			DELETE FROM [op_wms].[dbo].[OP_WMS_DISTRIBUTED_TASK]
			WHERE [ERP_DOC] = @ERP_DOC
				AND [BOX_ID] = @BOX_ID
				AND [MATERIAL_ID] = @MATERIAL_ID
		END
		ELSE
		BEGIN
			UPDATE [op_wms].[dbo].[OP_WMS_DISTRIBUTED_TASK]
			SET [QUANTITY] = @QTY
			WHERE [ERP_DOC] = @ERP_DOC
				AND [BOX_ID] = @BOX_ID
				AND [MATERIAL_ID] = @MATERIAL_ID
		END

		-- ------------------------------------------------------------------------------------
		-- Actualiza la tarea
		-- ------------------------------------------------------------------------------------
		EXEC [wms].[OP_WMS_SP_REMOVE_QTY_IN_WAVE_PICKING]
			@WAVE_PICKING_ID = @WAVE_PICKING_ID
			,@MATERIAL_ID = @MATERIAL_ID
			,@REMOVE_QTY = @REMOVE_QTY
			,@LOGIN = @LOGIN
			,@RESULT = @RESULT OUTPUT
		--
		IF @RESULT != 'OK'
		BEGIN
		    RAISERROR(@RESULT,16,1);
		END
		-- ------------------------------------------------------------------------------------
		-- Actualiza los documentos de picking
		-- ------------------------------------------------------------------------------------
		EXEC [wms].[OP_WMS_SP_REMOVE_QTY_IN_PICKING_DEMAND_DOCUMENT]
			@WAVE_PICKING_ID = @WAVE_PICKING_ID
			,@MATERIAL_ID = @MATERIAL_ID
			,@REMOVE_QTY = @REMOVE_QTY
			,@LOGIN = @LOGIN
			,@RESULT = @RESULT OUTPUT
		--
		IF @RESULT != 'OK'
		BEGIN
		    RAISERROR(@RESULT,16,1);
		END

		-- ------------------------------------------------------------------------------------
		-- Valida si es lo ultimo para finalizar el pedido
		-- ------------------------------------------------------------------------------------
		IF NOT EXISTS(SELECT TOP 1 1 FROM [op_wms].[dbo].[OP_WMS_DISTRIBUTED_TASK] WHERE [ERP_DOC] = @ERP_DOC AND [STATUS] != @STATUS)
		BEGIN
		    -- ------------------------------------------------------------------------------------
		    -- Obtiene la linea
		    -- ------------------------------------------------------------------------------------
			SELECT TOP 1
				@PICKING_LINE = [DP].[ASSIGNED_TO_LINE]
			FROM [op_wms].[dbo].[OP_WMS_DEMAND_TO_PICK] [DP]
			WHERE [DP].[ERP_DOCUMENT] = @ERP_DOC
			--
			PRINT '------> @PICKING_LINE: ' + @PICKING_LINE
			
			-- ------------------------------------------------------------------------------------
			-- Manda a rebajar el inventario
			-- ------------------------------------------------------------------------------------
			EXEC [op_wms].[dbo].[OP_WMS_SP_SYNCHRONIZE_PICKING_TASK_FROM_PICKING_LINE]
				@WAVE_PICKING_ID = @WAVE_PICKING_ID, -- int
		    	@PICKING_LINE = @PICKING_LINE -- varchar(15)
		END

		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado
		-- ------------------------------------------------------------------------------------
		SELECT  
			1 as Resultado
			,'Proceso Exitoso' Mensaje
			,0 Codigo
			,'' DbData
	END TRY
	BEGIN CATCH
		SELECT  
			-1 as Resultado
			,ERROR_MESSAGE() Mensaje 
			,@@ERROR Codigo
			,'' DbData
	END CATCH
END