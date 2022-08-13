-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-06-16 ERGON@BreathOfTheWild
-- Description:	 Actualizar el estado de una serie escaneada en la HH para picking o reubicación.




/*
-- Ejemplo de Ejecucion:
	EXEC [wms].OP_WMS_SP_ROLLBACK_SERIAL_NUMBERS_ON_PROCESS @LICENSE_ID = 167669 
                                                                    ,@MATERIAL_ID = 'wms/100003'
                                                                    ,@LOGIN = 'ACAMACHO'

  SELECT *        
      FROM [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [S] WHERE SERIAL = '201234567899'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_ROLLBACK_SERIAL_NUMBERS_ON_PROCESS] (
		@LICENSE_ID DECIMAL
		,@MATERIAL_ID VARCHAR(50)
		,@LOGIN VARCHAR(25)
		,@WAVE_PICKING_ID INT
		,@TASK_TYPE VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --


	BEGIN TRY
		BEGIN TRANSACTION;



		IF @TASK_TYPE = 'DESPACHO_GENERAL'
			AND EXISTS ( SELECT TOP 1
								1
							FROM
								[wms].[OP_WMS_TASK_LIST] [T]
							WHERE
								[T].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
								AND [T].[IS_DISCRETIONARY] = 1
								AND [T].[MATERIAL_ID] = @MATERIAL_ID )
		BEGIN
			UPDATE
				[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
			SET	
				[STATUS] = 1
				,[ASSIGNED_TO] = NULL
			WHERE
				[LICENSE_ID] = @LICENSE_ID
				AND [MATERIAL_ID] = @MATERIAL_ID
				AND [ASSIGNED_TO] = @LOGIN
				AND [WAVE_PICKING_ID] = @WAVE_PICKING_ID;
		END;
		ELSE
			IF @TASK_TYPE = 'DESPACHO_GENERAL'
				AND EXISTS ( SELECT TOP 1
									1
								FROM
									[wms].[OP_WMS_TASK_LIST] [T]
								WHERE
									[T].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
									AND [T].[IS_DISCRETIONARY] = 0
									AND [T].[MATERIAL_ID] = @MATERIAL_ID )
			BEGIN
				UPDATE
					[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
				SET	
					[STATUS] = 1
					,[ASSIGNED_TO] = NULL
					,[WAVE_PICKING_ID] = NULL
				WHERE
					[LICENSE_ID] = @LICENSE_ID
					AND [MATERIAL_ID] = @MATERIAL_ID
					AND [ASSIGNED_TO] = @LOGIN
					AND [WAVE_PICKING_ID] = @WAVE_PICKING_ID
					AND [STATUS] > 0; 
			END;
			ELSE
				IF (@TASK_TYPE = 'TAREA_RECEPCION')
				BEGIN 
					DELETE
						[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
					WHERE
						[LICENSE_ID] = @LICENSE_ID
						AND [MATERIAL_ID] = @MATERIAL_ID
						AND [STATUS] = 1; 
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
						AND (
								ISNULL(@MATERIAL_ID, '') = ''
								OR [MATERIAL_ID] = @MATERIAL_ID
							)
						AND [ASSIGNED_TO] = @LOGIN
						AND [STATUS] > 0;
				END;



    ---------------------------------------------------------------------------------
    -- Retornar éxito 
    ---------------------------------------------------------------------------------  
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [CODIGO]
			,CAST('0' AS VARCHAR) [DbData];


		COMMIT TRANSACTION;
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