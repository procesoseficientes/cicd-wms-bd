-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-06-16 ERGON@BreathOfTheWild
-- Description:	 Actualizar el estado de una serie escaneada en la HH para picking o reubicación.




/*
-- Ejemplo de Ejecucion:
	EXEC [wms].[OP_WMS_SP_UPDATE_SET_ACTIVE_SERIAL_NUMBER] @SERIAL_NUMBER = '201234567899'
                                                                    ,@MATERIAL_ID = 'wms/100003'
                                                                    ,@LICENSE_ID = 167669 
                                                                    ,@WAVE_PICKING_ID = 0
                                                                    ,@LOGIN = 'ACAMACHO'

  SELECT *        
      FROM [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [S] WHERE SERIAL = '201234567899'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_SET_ACTIVE_SERIAL_NUMBER] (
		@SERIAL_NUMBER VARCHAR(50)
		,@MATERIAL_ID VARCHAR(50)
		,@LICENSE_ID DECIMAL
		,@WAVE_PICKING_ID INT
		,@LOGIN VARCHAR(50)
		,@TASK_TYPE VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	DECLARE	@COUNT_SERIES INT;
	SELECT
		@WAVE_PICKING_ID = CASE	WHEN @WAVE_PICKING_ID <= 0
								THEN NULL
								ELSE @WAVE_PICKING_ID
							END;

	BEGIN TRY
		BEGIN TRANSACTION;

		IF @TASK_TYPE = 'DESPACHO_GENERAL'
			AND EXISTS ( SELECT TOP 1
								1
							FROM
								[wms].[OP_WMS_TASK_LIST] [T]
							WHERE
								[T].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
								AND [T].[MATERIAL_ID] = @MATERIAL_ID
								AND [T].[TASK_ASSIGNEDTO] = @LOGIN
								AND [T].[IS_DISCRETIONARY] = 1 )
		BEGIN
      -- discrecional
			UPDATE
				[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
			SET	
				[STATUS] = 1
				,[ASSIGNED_TO] = NULL
			WHERE
				[LICENSE_ID] = @LICENSE_ID
				AND [WAVE_PICKING_ID] = @WAVE_PICKING_ID
				AND [SERIAL] = @SERIAL_NUMBER
				AND [MATERIAL_ID] = @MATERIAL_ID
				AND [STATUS] > 0;

			SELECT
				@COUNT_SERIES = COUNT(*)
			FROM
				[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [S]
			WHERE
				[LICENSE_ID] = @LICENSE_ID
				AND [S].[MATERIAL_ID] = @MATERIAL_ID
				AND [S].[ASSIGNED_TO] = @LOGIN
				AND [S].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
				AND [S].[STATUS] > 0;

		END;
		ELSE
			IF @TASK_TYPE = 'DESPACHO_GENERAL'
				AND EXISTS ( SELECT TOP 1
									1
								FROM
									[wms].[OP_WMS_TASK_LIST] [T]
								WHERE
									[T].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
									AND [T].[MATERIAL_ID] = @MATERIAL_ID
									AND [T].[TASK_ASSIGNEDTO] = @LOGIN
									AND [T].[IS_DISCRETIONARY] = 0 )
			BEGIN
      -- NO discrecional
				UPDATE
					[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
				SET	
					[STATUS] = 1
					,[ASSIGNED_TO] = NULL
					,[WAVE_PICKING_ID] = NULL
				WHERE
					[LICENSE_ID] = @LICENSE_ID
					AND [SERIAL] = @SERIAL_NUMBER
					AND [MATERIAL_ID] = @MATERIAL_ID
					AND @WAVE_PICKING_ID = [WAVE_PICKING_ID]
					AND [STATUS] > 0;

				SELECT
					@COUNT_SERIES = COUNT(*)
				FROM
					[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [S]
				WHERE
					[LICENSE_ID] = @LICENSE_ID
					AND [S].[MATERIAL_ID] = @MATERIAL_ID
					AND [S].[ASSIGNED_TO] = @LOGIN
					AND [S].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
					AND [S].[STATUS] > 0;
			END;
			ELSE
			BEGIN
				UPDATE
					[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
				SET	
					[STATUS] = 1
					,[ASSIGNED_TO] = NULL
					,[WAVE_PICKING_ID] = NULL
				WHERE
					[LICENSE_ID] = @LICENSE_ID
					AND [SERIAL] = @SERIAL_NUMBER
					AND [MATERIAL_ID] = @MATERIAL_ID
					AND [STATUS] > 0;

				SELECT
					@COUNT_SERIES = COUNT(*)
				FROM
					[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [S]
				WHERE
					[LICENSE_ID] = @LICENSE_ID
					AND [S].[MATERIAL_ID] = @MATERIAL_ID
					AND [S].[ASSIGNED_TO] = @LOGIN
					AND [S].[STATUS] > 0;

			END;

		COMMIT TRANSACTION;



    ---------------------------------------------------------------------------------
    -- Retornar éxito 
    ---------------------------------------------------------------------------------  
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [CODIGO]
			,CAST(@COUNT_SERIES AS VARCHAR) [DbData];


	END TRY
	BEGIN CATCH

		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [CODIGO];

		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;

		PRINT ERROR_MESSAGE();
	END CATCH;





END;