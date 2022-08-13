-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-06-16 ERGON@BreathOfTheWild
-- Description:	 Actualizar el estado de una serie escaneada en la HH para picking o reubicación.




/*
-- Ejemplo de Ejecucion:
	EXEC [wms].[OP_WMS_SP_UPDATE_SCANNED_SERIAL_NUMBER_TO_PROCESS] @SERIAL_NUMBER = '201234567899'
                                                                    ,@LICENSE_ID = 167669
                                                                    ,@STATUS = 1
                                                                    ,@WAVE_PICKING_ID = 0
                                                                    ,@MATERIAL_ID = 'wms/100003'
                                                                    ,@LOGIN = 'ACAMACHO'		

	SELECT
		*
	FROM
		[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [S]
	WHERE
		SERIAL = '201234567899'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_UPDATE_SCANNED_SERIAL_NUMBER_TO_PROCESS] (
		@SERIAL_NUMBER VARCHAR(50)
		,@LICENSE_ID DECIMAL
		,@STATUS INT
		,@WAVE_PICKING_ID INT
		,@MATERIAL_ID VARCHAR(50)
		,@LOGIN VARCHAR(50)
		,@TASK_TYPE VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --


	DECLARE
		@PRESULT VARCHAR(MAX)
		,@COUNT_SERIES INT
		,@COUNT_SERIES_PENDING INT;
	SELECT
		@WAVE_PICKING_ID = CASE	WHEN @WAVE_PICKING_ID <= 0
								THEN NULL
								ELSE @WAVE_PICKING_ID
							END;

  ---------------------------------------------------------------------------------
  -- Validar que si la serie escaneada ya habia sido escaneada y se encuentra en proceso.
  ---------------------------------------------------------------------------------  
	IF EXISTS ( SELECT TOP 1
					1
				FROM
					[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [S]
				WHERE
					[S].[LICENSE_ID] = @LICENSE_ID
					AND (
							@TASK_TYPE <> 'DESPACHO_GENERAL'
							OR [S].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
						)
					AND [S].[SERIAL] = @SERIAL_NUMBER
					AND [S].[ASSIGNED_TO] = @LOGIN
					AND [S].[MATERIAL_ID] = @MATERIAL_ID
					AND [S].[STATUS] = 2 )
	BEGIN

		SELECT
			@PRESULT = 'ERROR, Serie "' + @SERIAL_NUMBER
			+ '" duplicada ¿Desea eliminarla de la operación? ';
		SELECT
			3 AS [Resultado]
			,@PRESULT [Mensaje]
			,0 [Codigo]
			,CAST('1' AS VARCHAR) [DbData];

		RETURN;

	END;


	IF @TASK_TYPE = 'DESPACHO_GENERAL'
	BEGIN
		SELECT
			@COUNT_SERIES_PENDING = SUM([TL].[QUANTITY_ASSIGNED])
		FROM
			[wms].[OP_WMS_TASK_LIST] [TL]
		WHERE
			[TL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
			AND [TL].[LICENSE_ID_SOURCE] = @LICENSE_ID
			AND [TL].[MATERIAL_ID] = @MATERIAL_ID;
	

		SELECT
			@COUNT_SERIES = COUNT(*)
		FROM
			[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [MS]
		WHERE
			[LICENSE_ID] = @LICENSE_ID
			AND [MS].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
			AND [MS].[MATERIAL_ID] = @MATERIAL_ID
			AND [MS].[ASSIGNED_TO] = @LOGIN
			AND [STATUS] > 0;
	

	END;
	ELSE
		IF @TASK_TYPE = 'REUBICACION_PARCIAL'
		BEGIN
			SELECT
				@COUNT_SERIES_PENDING = SUM([IL].[QTY])
				- SUM(ISNULL([CL].[COMMITED_QTY], 0))
			FROM
				[wms].[OP_WMS_INV_X_LICENSE] [IL]
			LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CL] ON [IL].[MATERIAL_ID] = [CL].[MATERIAL_ID]
											AND [CL].[LICENCE_ID] = [IL].[LICENSE_ID]
			WHERE
				[IL].[LICENSE_ID] = @LICENSE_ID
				AND [IL].[MATERIAL_ID] = @MATERIAL_ID;

			SELECT
				@COUNT_SERIES = COUNT(*)
			FROM
				[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [MS]
			WHERE
				[LICENSE_ID] = @LICENSE_ID
				AND [MS].[MATERIAL_ID] = @MATERIAL_ID
				AND [MS].[ASSIGNED_TO] = @LOGIN
				AND [STATUS] > 0;

		END;



	IF @COUNT_SERIES_PENDING <= @COUNT_SERIES
	BEGIN
		SELECT
			@PRESULT = 'ERROR, Ya escaneó todas las series necesarias.';
		SELECT
			-1 AS [Resultado]
			,@PRESULT [Mensaje]
			,1004 [Codigo]
			,'' [DbData];
		RETURN;
	END;


	SELECT
		@COUNT_SERIES = COUNT(*)
	FROM
		[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [MS]
	WHERE
		[LICENSE_ID] = @LICENSE_ID
		AND [MS].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
		AND [MS].[MATERIAL_ID] = @MATERIAL_ID
		AND [MS].[ASSIGNED_TO] = @LOGIN
		AND [STATUS] > 0;

	IF @COUNT_SERIES_PENDING <= @COUNT_SERIES
	BEGIN
		SELECT
			@PRESULT = 'ERROR, Ya escaneó todas las series necesarias.';
		SELECT
			-1 AS [Resultado]
			,@PRESULT [Mensaje]
			,1004 [Codigo]
			,'' [DbData];
		RETURN;
	END;



	BEGIN TRY
		BEGIN TRANSACTION;

    ---------------------------------------------------------------------------------
    -- Validar si es discrecional
    ---------------------------------------------------------------------------------  
		IF @WAVE_PICKING_ID IS NOT NULL
			AND @WAVE_PICKING_ID > 0
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
      --Tarea es discrecional
			IF EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [S]
						WHERE
							[S].[LICENSE_ID] = @LICENSE_ID
							AND [S].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
							AND [S].[SERIAL] = @SERIAL_NUMBER
							AND [S].[MATERIAL_ID] = @MATERIAL_ID
							AND [S].[STATUS] = 1 )
			BEGIN

				UPDATE
					[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
				SET	
					[STATUS] = 2
					,[ASSIGNED_TO] = @LOGIN
				WHERE
					[LICENSE_ID] = @LICENSE_ID
					AND [WAVE_PICKING_ID] = @WAVE_PICKING_ID
					AND [MATERIAL_ID] = @MATERIAL_ID
					AND [SERIAL] = @SERIAL_NUMBER
					AND [STATUS] > 0;
			END;
			ELSE
			BEGIN
				SELECT
					@PRESULT = 'ERROR, Serie "'
					+ @SERIAL_NUMBER
					+ '" no se encuentra en la tarea.';
				SELECT
					-1 AS [Resultado]
					,@PRESULT [Mensaje]
					,1005 [Codigo]
					,'' [DbData];
				ROLLBACK;
				RETURN;
			END;

		END;
		ELSE
		BEGIN
			IF EXISTS ( SELECT TOP 1
							1
						FROM
							[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [S]
						WHERE
							[S].[LICENSE_ID] = @LICENSE_ID
							AND [S].[SERIAL] = @SERIAL_NUMBER
							AND [S].[STATUS] = 1
							AND [S].[MATERIAL_ID] = @MATERIAL_ID
							AND ([S].[WAVE_PICKING_ID] IS NULL) )
			BEGIN
				UPDATE
					[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER]
				SET	
					[STATUS] = 2
					,[ASSIGNED_TO] = @LOGIN
					,[WAVE_PICKING_ID] = @WAVE_PICKING_ID
				WHERE
					[LICENSE_ID] = @LICENSE_ID
					AND [SERIAL] = @SERIAL_NUMBER
					AND [MATERIAL_ID] = @MATERIAL_ID
					AND [STATUS] > 0;
			END;
			ELSE
			BEGIN
				SELECT
					@PRESULT = 'ERROR, Serie "'
					+ @SERIAL_NUMBER
					+ '" no se encuentra en la licencia o esta ya se encuentra reservada.';
				SELECT
					-1 AS [Resultado]
					,@PRESULT [Mensaje]
					,1006 [Codigo]
					,'' [DbData];
				ROLLBACK;
				RETURN;
			END;
		END;


		SELECT
			@COUNT_SERIES = COUNT(*)
		FROM
			[wms].[OP_WMS_MATERIAL_X_SERIAL_NUMBER] [S]
		WHERE
			[LICENSE_ID] = @LICENSE_ID
			AND [S].[ASSIGNED_TO] = @LOGIN
			AND [S].[MATERIAL_ID] = @MATERIAL_ID
			AND [S].[STATUS] = 2;

    ---------------------------------------------------------------------------------
    -- Retornar éxito 
    ---------------------------------------------------------------------------------  
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,CAST(@COUNT_SERIES AS VARCHAR) [DbData];


		COMMIT TRANSACTION;

	END TRY
	BEGIN CATCH

		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,-1 [Codigo]
			,'' [DbData];
		IF XACT_STATE() <> 0
		BEGIN
			ROLLBACK TRANSACTION;
		END;

		PRINT ERROR_MESSAGE();


	END CATCH;





END;