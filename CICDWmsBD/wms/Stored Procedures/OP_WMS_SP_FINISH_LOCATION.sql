-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-02-21 @ Team ERGON - Sprint ERGON  III
-- Description:	     


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-04-03 Team ERGON - Sprint ERGON hyper
-- Description:	 Se modifica por error al finalizar ubicaciones sin inventario. 

-- Autor:					marvin.solares
-- Fecha de Creacion: 		7/9/2018 GForce@FocaMonje 
-- Description:			    se formatea el codigo

/*
-- Ejemplo de Ejecucion:
  
  EXEC [wms].[OP_WMS_SP_FINISH_LOCATION] @LOGIN = 'ACAMACHO'
                                             ,@TASK_ID = 7
                                             ,@LOCATION = 'B02-P01-F01-NU'
                                             ,@RESULT = ''
  
			SELECT * FROM [wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [D]
          INNER JOIN  [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [H] 
        ON [D].[PHYSICAL_COUNT_HEADER_ID] = [H].[PHYSICAL_COUNT_HEADER_ID] WHERE H.TASK_ID = 7
      SELECT * FROM [wms].OP_WMS_TASK
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_FINISH_LOCATION] (
		@LOGIN VARCHAR(25)
		,@TASK_ID INT
		,@LOCATION VARCHAR(25)
--, @RESULT VARCHAR(500) OUTPUT
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	DECLARE	@RESULT VARCHAR(500);

	BEGIN
		BEGIN TRY
			BEGIN TRANSACTION;
      ---------------------------------------------------------------------------------
      -- Marcar como completada ubicación 
      ---------------------------------------------------------------------------------  
			UPDATE
				[D]
			SET	
				[D].[STATUS] = 'COMPLETED'
			FROM
				[wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [D]
			INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [H] ON [H].[PHYSICAL_COUNT_HEADER_ID] = [D].[PHYSICAL_COUNT_HEADER_ID]
			WHERE
				[D].[ASSIGNED_TO] = @LOGIN
				AND [D].[LOCATION] = @LOCATION
				AND [H].[TASK_ID] = @TASK_ID;



      ---------------------------------------------------------------------------------
      -- Consulta sin SERIE
      ---------------------------------------------------------------------------------  
			INSERT	INTO [wms].[OP_WMS_PHYSICAL_COUNTS_EXECUTION]
			SELECT
				[D].[PHYSICAL_COUNT_DETAIL_ID]
				,[D].[LOCATION]
				,[L].[LICENSE_ID]
				,[IL].[MATERIAL_ID]
				,0 [QTY_SCANNED]
				,[IL].[QTY] [QTY_EXPECTED]
				,'M' [HIT_OR_MISS]
				,GETDATE() [EXECUTED]
				,@LOGIN [EXECUTED_BY]
				,NULL [BATCH]
				,NULL [DATE_EXPIRATION]
				,NULL [SERIAL]
				,CASE [IL].[BATCH]
					WHEN '' THEN NULL
					ELSE [IL].[DATE_EXPIRATION]
					END [EXPIRATION_DATE_EXPECTED]
				,CASE [IL].[BATCH]
					WHEN '' THEN NULL
					ELSE [IL].[BATCH]
					END [BATCH_EXPECTED]
				,NULL [SERIAL_EXPECTED]
			FROM
				[wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [D]
			INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [H] ON [D].[PHYSICAL_COUNT_HEADER_ID] = [H].[PHYSICAL_COUNT_HEADER_ID]
			INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[CURRENT_LOCATION] = [D].[LOCATION]
			INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON (
											[IL].[LICENSE_ID] = [L].[LICENSE_ID]
											AND ISNULL([IL].[HANDLE_SERIAL],
											0) = 0
											AND (
											[D].[MATERIAL_ID] IS NULL
											OR [D].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											)
											)
			LEFT JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_EXECUTION] [E] ON (
											[E].[PHYSICAL_COUNT_DETAIL_ID] = [D].[PHYSICAL_COUNT_DETAIL_ID]
											AND ([IL].[MATERIAL_ID] = [E].[MATERIAL_ID])
											AND [IL].[LICENSE_ID] = [E].[LICENSE_ID]
											AND [D].[LOCATION] = [E].[LOCATION]
											AND [D].[ASSIGNED_TO] = [E].[EXECUTED_BY]
											)
			WHERE
				[H].[TASK_ID] = @TASK_ID
				AND [IL].[QTY] > 0
				AND [D].[LOCATION] = @LOCATION
				AND [D].[ASSIGNED_TO] = @LOGIN
				AND [E].[PHYSICAL_COUNTS_EXECUTION_ID] IS NULL;

      ---------------------------------------------------------------------------------
      -- Consulta con SERIE
      ---------------------------------------------------------------------------------  
			INSERT	INTO [wms].[OP_WMS_PHYSICAL_COUNTS_EXECUTION]
			SELECT
				[D].[PHYSICAL_COUNT_DETAIL_ID]
				,[D].[LOCATION]
				,[L].[LICENSE_ID]
				,[IL].[MATERIAL_ID]
				,0 [QTY_SCANNED]
				,1 [QTY_EXPECTED]
				,'M' [HIT_OR_MISS]
				,GETDATE() [EXECUTED]
				,@LOGIN [EXECUTED_BY]
				,NULL [BATCH]
				,NULL [DATE_EXPIRATION]
				,NULL [SERIAL]
				,[S].[DATE_EXPIRATION] [EXPIRATION_DATE_EXPECTED]
				,[S].[BATCH] [BATCH_EXPECTED]
				,[S].[SERIAL] [SERIAL_EXPECTED]
			FROM
				[wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [D]
			INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [H] ON [D].[PHYSICAL_COUNT_HEADER_ID] = [H].[PHYSICAL_COUNT_HEADER_ID]
			INNER JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[CURRENT_LOCATION] = [D].[LOCATION]
			INNER JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON (
											[IL].[LICENSE_ID] = [L].[LICENSE_ID]
											AND [IL].[HANDLE_SERIAL] = 1
											AND (
											[D].[MATERIAL_ID] IS NULL
											OR [D].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											)
											)
			INNER JOIN [wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [S] ON (
											[S].[LICENSE_ID] = [L].[LICENSE_ID]
											AND [S].[MATERIAL_ID] = [IL].[MATERIAL_ID]
											AND [S].[STATUS] > 0
											)
			LEFT JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_EXECUTION] [E] ON (
											[E].[PHYSICAL_COUNT_DETAIL_ID] = [D].[PHYSICAL_COUNT_DETAIL_ID]
											AND ([IL].[MATERIAL_ID] = [E].[MATERIAL_ID])
											AND [D].[LOCATION] = [E].[LOCATION]
											AND [D].[ASSIGNED_TO] = [E].[EXECUTED_BY]
											AND [E].[SERIAL] = [S].[SERIAL]
											)
			WHERE
				[H].[TASK_ID] = @TASK_ID
				AND [D].[LOCATION] = @LOCATION
				AND [D].[ASSIGNED_TO] = @LOGIN
				AND [IL].[QTY] > 0
				AND [E].[PHYSICAL_COUNTS_EXECUTION_ID] IS NULL;
      ---------------------------------------------------------------------------------
      -- Insertar transaccion de DETALLE de conteo 
      ---------------------------------------------------------------------------------
			DECLARE
				@BARCODE_ID VARCHAR(25)
				,@MATERIAL_DESCRIPTION VARCHAR(200)
				,@CLIENT_OWNER VARCHAR(25)
				,@CLIENT_NAME VARCHAR(150)
				,@WAREHOUSE VARCHAR(25)
				,@MATERIAL_ID VARCHAR(25)
				,@LICENSE_ID NUMERIC
				,@QTY_SCANNED NUMERIC
				,@SERIAL VARCHAR(50)
				,@BATCH VARCHAR(50)
				,@EXPIRATION_DATE DATE;




			INSERT	INTO [wms].[OP_WMS_TRANS]
					(
						[TRANS_DATE]
						,[LOGIN_ID]
						,[LOGIN_NAME]
						,[TRANS_TYPE]
						,[TRANS_DESCRIPTION]
						,[TARGET_WAREHOUSE]
						,[STATUS]
						,[TASK_ID]
						,[TRANS_SUBTYPE]
						,[MATERIAL_BARCODE]
						,[MATERIAL_CODE]
						,[SOURCE_LOCATION]
						,[TARGET_LOCATION]
						,[QUANTITY_UNITS]
						
					)
			VALUES
					(
						GETDATE()
						,@LOGIN
						,(SELECT TOP 1
								[LOGIN_NAME]
							FROM
								[wms].[OP_WMS_FUNC_GETLOGIN_NAME](@LOGIN))
						,'CONTEO_FISICO'
						,'CONTEO UBICACION'
						,@WAREHOUSE
						,'COMPLETED'
						,@TASK_ID
						,'FINALIZACION UBICACION'
						,''
						,''
						,''
						,''
						,0
						
					);
      ---------------------------------------------------------------------------------
      -- Validar si es la tarea esta en finalizada totalmente e inserta transaccion de tarea de conteo
      ---------------------------------------------------------------------------------  

			IF NOT EXISTS ( SELECT TOP 1
								1
							FROM
								[wms].[OP_WMS_PHYSICAL_COUNTS_DETAIL] [CD]
							INNER JOIN [wms].[OP_WMS_PHYSICAL_COUNTS_HEADER] [CH] ON [CD].[PHYSICAL_COUNT_HEADER_ID] = [CH].[PHYSICAL_COUNT_HEADER_ID]
							INNER JOIN [wms].[OP_WMS_TASK] [T] ON [CH].[TASK_ID] = [T].[TASK_ID]
							WHERE
								[CH].[TASK_ID] = @TASK_ID
								AND (
										[CD].[STATUS] = 'IN_PROGRESS'
										OR [CD].[STATUS] = 'CREATED'
									) )
			BEGIN
				UPDATE
					[wms].[OP_WMS_PHYSICAL_COUNTS_HEADER]
				SET	
					[STATUS] = 'COMPLETED'
				WHERE
					[TASK_ID] = @TASK_ID;

				UPDATE
					[T]
				SET	
					[T].[IS_COMPLETE] = 1
					,[T].[COMPLETED_DATE] = GETDATE()
				FROM
					[wms].[OP_WMS_TASK] [T]
				WHERE
					[T].[TASK_ID] = @TASK_ID;


				INSERT	INTO [wms].[OP_WMS_TRANS]
						(
							[TRANS_DATE]
							,[LOGIN_ID]
							,[LOGIN_NAME]
							,[TRANS_TYPE]
							,[TRANS_DESCRIPTION]
							,[TARGET_WAREHOUSE]
							,[STATUS]
							,[TASK_ID]
							,[TRANS_SUBTYPE]
							,[MATERIAL_BARCODE]
							,[MATERIAL_CODE]
							,[SOURCE_LOCATION]
							,[TARGET_LOCATION]
							,[QUANTITY_UNITS]
							
						)
				VALUES
						(
							GETDATE()
							,@LOGIN
							,(SELECT TOP 1
									[LOGIN_NAME]
								FROM
									[wms].[OP_WMS_FUNC_GETLOGIN_NAME](@LOGIN))
							,'CONTEO_FISICO'
							,'TAREA CONTEO FISICO'
							,@WAREHOUSE
							,'COMPLETED'
							,@TASK_ID
							,'FINALIZACION OP CONTEO'
							,''
							,''
							,''
							,''
							,0
							
						);

				SELECT
					@RESULT = 'COMPLETED';
			END;
			ELSE
			BEGIN
				SELECT
					@RESULT = 'OK';
			END;

			COMMIT TRANSACTION;
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION;
			SELECT
				@RESULT = ERROR_MESSAGE();

		END CATCH;
		SELECT
			@RESULT [RESULT];
	END;
END;