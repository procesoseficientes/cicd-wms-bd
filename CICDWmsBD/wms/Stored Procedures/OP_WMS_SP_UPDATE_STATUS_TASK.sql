-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-05-17 @ Team ERGON - Sprint ERGON 
-- Description:	        Sp que cambia el status de una tarea, se copio lo que estaba en el WebService

-- Modificacion 12/13/2017 @ NEXUS-Team Sprint HeyYouPikachu!
					-- rodrigo.gomez
					-- Se valida si la tarea es de LP y esta pausada

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_UPDATE_STATUS_TASK] @NEW_STATUS = 1 , @SERIAL_NUMBER =1 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_STATUS_TASK] (
		@NEW_STATUS NUMERIC
		,@SERIAL_NUMBER NUMERIC
		,@WAVE_PICKING_ID NUMERIC = NULL
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Verifica si es tarea de linea de picking
		-- ------------------------------------------------------------------------------------
		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_TASK_LIST]
					WHERE
						[WAVE_PICKING_ID] = @WAVE_PICKING_ID
						AND [IS_ACCEPTED] = 1
						AND [IN_PICKING_LINE] = 1 )
		BEGIN
			RAISERROR(N'No se puede pausar la tarea porque esta ya fue aceptada.',16,1);
		END;

		-- ------------------------------------------------------------------------------------
		-- Pausa o Reaunda la tarea
		-- ------------------------------------------------------------------------------------
		UPDATE
			[wms].[OP_WMS_TASK_LIST]
		SET	
			[IS_PAUSED] = @NEW_STATUS
		WHERE
			(
				@SERIAL_NUMBER = 0
				AND [WAVE_PICKING_ID] = @WAVE_PICKING_ID
			)
			OR (
				@SERIAL_NUMBER <> 0
				AND [SERIAL_NUMBER] = @SERIAL_NUMBER
				);

		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'0' [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;

END;