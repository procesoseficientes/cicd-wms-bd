-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/8/2017 @ NEXUS-Team Sprint HeyYouPikachu! 
-- Description:			Se reasigna la tarea de linea de picking completa.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_CHANGE_LINE_PICKING_BY_WAVE_PICKING]
					@WAVE_PICKING_ID = 4894
					,@PICKING_LINE_ID = 'LINEA_PICKING_1'
					,@LOGIN = 'ADMIN'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CHANGE_LINE_PICKING_BY_WAVE_PICKING](
	@WAVE_PICKING_ID INT
	,@PICKING_LINE_ID VARCHAR(50)
	,@LOGIN VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @IS_CONSOLIDATED INT = 0
		,@ERROR_MESSAGE VARCHAR(150) = ''
	--
	DECLARE @RESULT AS TABLE (
		Resultado INT 
		,Mensaje VARCHAR(500)
		,Codigo INT
		,DbData VARCHAR(500)
 	)
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Verifica si la ola no ha sido aceptada
		-- ------------------------------------------------------------------------------------
		IF EXISTS(SELECT TOP 1 1 FROM [wms].[OP_WMS_TASK_LIST] WHERE ([IS_ACCEPTED] = 1 OR [IS_CANCELED] = 1 OR [IS_COMPLETED] = 1) AND [WAVE_PICKING_ID] = @WAVE_PICKING_ID)
		BEGIN
			SET @ERROR_MESSAGE = 'La ola ' + CAST(@WAVE_PICKING_ID AS VARCHAR) + ' ya fue aceptada, completada o esta cancelada por lo que no se puede reasignar.'
		    RAISERROR (@ERROR_MESSAGE, 16, 1);
		END

		-- ------------------------------------------------------------------------------------
		-- Obtiene si es consolidado
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1 
			@IS_CONSOLIDATED = [IS_CONSOLIDATED] 
		FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
	    WHERE [WAVE_PICKING_ID] = @WAVE_PICKING_ID
		
		-- ------------------------------------------------------------------------------------
		-- Reasigna las tareas en TASK_LIST
		-- ------------------------------------------------------------------------------------
		UPDATE [wms].[OP_WMS_TASK_LIST] 
		SET [TASK_ASSIGNEDTO] = @PICKING_LINE_ID
			,[ASSIGNED_DATE] = GETDATE()
		WHERE [IN_PICKING_LINE] = 1
			AND [WAVE_PICKING_ID] = @WAVE_PICKING_ID
		
		-- ------------------------------------------------------------------------------------
		-- Elimina las tareas en la linea de picking
		-- ------------------------------------------------------------------------------------
		INSERT INTO @RESULT
		EXEC [op_wms].[dbo].[OP_WMS_SP_DELETE_PICKING]
					@WAVE_PICKING_ID = @WAVE_PICKING_ID

		--
		IF EXISTS (SELECT TOP 1 1 FROM @RESULT WHERE [Resultado] = -1)
		BEGIN
			SELECT TOP 1 
				@ERROR_MESSAGE = [Mensaje]
			FROM @RESULT
			WHERE [Resultado] = -1 
			--
		    RAISERROR (@ERROR_MESSAGE, 16, 1);
		END
		-- ------------------------------------------------------------------------------------
		-- Vuelve a crear la tarea para la linea de picking 
		-- ------------------------------------------------------------------------------------
		INSERT INTO @RESULT
		EXEC [wms].[OP_WMS_SP_INSERT_PICKING_LINE_TASK] 
			@WAVE_PICKING_ID = @WAVE_PICKING_ID, -- int
			@IS_CONSOLIDATED = @IS_CONSOLIDATED, -- int
			@PICKING_LINE_ID = @PICKING_LINE_ID, -- varchar(15)
			@LOGIN = @LOGIN -- varchar(50)

		--
		IF EXISTS (SELECT TOP 1 1 FROM @RESULT WHERE [Resultado] = -1)
		BEGIN
			SELECT TOP 1 
				@ERROR_MESSAGE = [Mensaje]
			FROM @RESULT
			WHERE [Resultado] = -1 
			--
		    RAISERROR (@ERROR_MESSAGE, 16, 1);
		END

		-- ------------------------------------------------------------------------------------
		-- Devuelve el resultado final
		-- ------------------------------------------------------------------------------------
		SELECT
            1 AS Resultado
           ,'Proceso Exitoso' Mensaje
           ,0 Codigo
           ,'' DbData;
	END TRY
	BEGIN CATCH	
		--
	    SELECT
            -1 AS Resultado
           ,ERROR_MESSAGE() Mensaje
           ,@@ERROR Codigo
           ,'' DbData;
	END CATCH	
END