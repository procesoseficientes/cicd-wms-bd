-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	08-Dec-17 @ Nexus Team Sprint HeyYouPikachu!
-- Description:			SP que cambia que quita la cantidad indicada de un material de la ola de picking indicada
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_REMOVE_QTY_IN_WAVE_PICKING]
					@WAVE_PICKING_ID = 4872
					,@MATERIAL_ID = 'viscosa/VCA1030'
					,@REMOVE_QTY = 6
					,@LOGIN = 'BETO'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REMOVE_QTY_IN_WAVE_PICKING](
	@WAVE_PICKING_ID NUMERIC(18,0)
	,@MATERIAL_ID VARCHAR(50)
	,@REMOVE_QTY NUMERIC(18,4)
	,@LOGIN VARCHAR(50)
	,@RESULT VARCHAR(1000) = '' OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	PRINT '----> START [OP_WMS_SP_REMOVE_QTY_IN_WAVE_PICKING]'
	--
	DECLARE @TASK TABLE (
		[SERIAL_NUMBER] NUMERIC(18,0) NOT NULL PRIMARY KEY
		,[QUANTITY_PENDING] NUMERIC(18,4) NOT NULL
		,[QUANTITY_ASSIGNED] NUMERIC(18,4) NOT NULL
		,[USED] INT NOT NULL DEFAULT(0)
		,[IS_COMPLETED] NUMERIC(18,0) NOT NULL DEFAULT(0)
		,[IS_CANCELED] NUMERIC(18,0) NOT NULL DEFAULT(0)
		,[CANCELED_DATETIME] DATETIME
		,[CANCELED_BY] VARCHAR(25)
	)
	--
	DECLARE	
		@SERIAL_NUMBER NUMERIC(18,0) = 0
		,@QUANTITY_PENDING NUMERIC(18,4) = 0
		,@QUANTITY_ASSIGNED NUMERIC(18,4) = 0
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene las tareas para el material indicado
		-- ------------------------------------------------------------------------------------
		INSERT INTO @TASK
		    	(
		    		[SERIAL_NUMBER]
		    		,[QUANTITY_PENDING]
		    		,[QUANTITY_ASSIGNED]
		    	)
		SELECT
			[TL].[SERIAL_NUMBER]
			,[TL].[QUANTITY_PENDING]
			,[TL].[QUANTITY_ASSIGNED]
		FROM [wms].[OP_WMS_TASK_LIST] [TL]
		WHERE [TL].[SERIAL_NUMBER] > 0
			AND [TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
			AND [TL].[MATERIAL_ID] = @MATERIAL_ID

		-- ------------------------------------------------------------------------------------
		-- Cancela todas las tareas cuando la cantidad es cero
		-- ------------------------------------------------------------------------------------
		IF @REMOVE_QTY = 0
		BEGIN
		    UPDATE @TASK
			SET 
				[IS_CANCELED] = 1
				,[IS_COMPLETED] = 1
				,[CANCELED_DATETIME] = GETDATE()
				,[CANCELED_BY] = @LOGIN
			WHERE [SERIAL_NUMBER] > 0
		END
		ELSE
		BEGIN
			-- ------------------------------------------------------------------------------------
			-- Recorre todas las tareas
			-- ------------------------------------------------------------------------------------
			WHILE @REMOVE_QTY > 0 AND EXISTS(SELECT TOP 1 1 FROM @TASK WHERE [SERIAL_NUMBER] > 0 AND [USED] = 0)
			BEGIN
				SELECT TOP 1
					@SERIAL_NUMBER = [SERIAL_NUMBER]
					,@QUANTITY_PENDING = [QUANTITY_PENDING]
					,@QUANTITY_ASSIGNED = [QUANTITY_ASSIGNED]
				FROM @TASK
				WHERE [SERIAL_NUMBER] > 0
					AND [USED] = 0
				ORDER BY [QUANTITY_ASSIGNED] DESC;
				--
				PRINT '--->'
				PRINT '--> @SERIAL_NUMBER ' + CAST(@SERIAL_NUMBER AS VARCHAR)
				PRINT '--> @QUANTITY_PENDING ' + CAST(@QUANTITY_PENDING AS VARCHAR)
				PRINT '--> @QUANTITY_ASSIGNED ' + CAST(@QUANTITY_ASSIGNED AS VARCHAR)
				PRINT '--> @REMOVE_QTY ' + CAST(@REMOVE_QTY AS VARCHAR)
				--
				UPDATE @TASK
				SET
					[QUANTITY_PENDING] = CASE WHEN @REMOVE_QTY >= @QUANTITY_ASSIGNED THEN @QUANTITY_PENDING ELSE (@QUANTITY_PENDING - @REMOVE_QTY) END
					,[QUANTITY_ASSIGNED] = CASE WHEN @REMOVE_QTY >= @QUANTITY_ASSIGNED THEN @QUANTITY_ASSIGNED ELSE (@QUANTITY_ASSIGNED - @REMOVE_QTY) END
					,[IS_COMPLETED] = CASE WHEN @REMOVE_QTY >= @QUANTITY_ASSIGNED THEN 1 ELSE 0 END
					,[IS_CANCELED] = CASE WHEN @REMOVE_QTY >= @QUANTITY_ASSIGNED THEN 1 ELSE 0 END
					,[CANCELED_DATETIME] = CASE WHEN @REMOVE_QTY >= @QUANTITY_ASSIGNED THEN GETDATE() ELSE NULL END
					,[CANCELED_BY] = CASE WHEN @REMOVE_QTY >= @QUANTITY_ASSIGNED THEN @LOGIN ELSE NULL END
					,[USED] = 1
				WHERE [SERIAL_NUMBER] = @SERIAL_NUMBER
				--
				SET @REMOVE_QTY = @REMOVE_QTY - @QUANTITY_ASSIGNED
			END
		END
		
		-- ------------------------------------------------------------------------------------
		-- Actualiza todas las tareas
		-- ------------------------------------------------------------------------------------
		UPDATE [TL]
		SET
			[TL].[QUANTITY_PENDING] = [T].[QUANTITY_PENDING]
			,[TL].[QUANTITY_ASSIGNED] = [T].[QUANTITY_ASSIGNED]
			,[TL].[IS_COMPLETED] = [T].[IS_COMPLETED]
			,[TL].[IS_CANCELED] = [T].[IS_CANCELED]
			,[TL].[CANCELED_DATETIME] = [T].[CANCELED_DATETIME]
			,[TL].[CANCELED_BY] = [T].[CANCELED_BY]
		FROM [wms].[OP_WMS_TASK_LIST] [TL]
		INNER JOIN @TASK [T] ON ([T].[SERIAL_NUMBER] = [TL].[SERIAL_NUMBER])

		-- ------------------------------------------------------------------------------------
		-- Retorna el resultado
		-- ------------------------------------------------------------------------------------
		SET @RESULT = 'OK'
	END TRY
	BEGIN CATCH
		SET @RESULT = ERROR_MESSAGE()
	END CATCH
	--
	PRINT '----> END [OP_WMS_SP_REMOVE_QTY_IN_WAVE_PICKING]'
END