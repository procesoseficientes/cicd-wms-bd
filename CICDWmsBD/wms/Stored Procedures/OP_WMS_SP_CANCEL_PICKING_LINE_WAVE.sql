-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/8/2017 @ NEXUS-Team Sprint HeyYouPikachu! 
-- Description:			SP que cancela una ola de picking si esta es de linea de picking

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_CANCEL_PICKING_LINE_WAVE]
					@WAVE_PICKING_ID = 4897
					,@LOGIN = 'ADMIN'
				-- 
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_CANCEL_PICKING_LINE_WAVE] (
		@WAVE_PICKING_ID INT
		,@LOGIN VARCHAR(50)
	)
AS
BEGIN
	SET NOCOUNT ON;
    --
	DECLARE	@ERROR VARCHAR(250);
    --
	DECLARE	@RESULT AS TABLE (
			[Resultado] INT
			,[Mensaje] VARCHAR(250)
			,[Codigo] INT
			,[DbData] VARCHAR(250)
		);

	BEGIN TRY
		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_TASK_LIST]
					WHERE
						[WAVE_PICKING_ID] = @WAVE_PICKING_ID
						AND [IS_ACCEPTED] = 1 )
		BEGIN
			RAISERROR(N'No se puede cancelar la tarea porque esta ya fue aceptada.', 16, 1);
		END;
		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_TASK_LIST]
					WHERE
						[WAVE_PICKING_ID] = @WAVE_PICKING_ID
						AND [IS_COMPLETED] = 1 )
		BEGIN
			RAISERROR(N'No se puede cancelar la tarea porque esta ya tiene lineas completadas.', 16, 1);
		END;
        -- ------------------------------------------------------------------------------------
        -- Actualiza la tarea y le deja como estado cancelado.
        -- ------------------------------------------------------------------------------------
		UPDATE
			[wms].[OP_WMS_TASK_LIST]
		SET	
			[IS_PAUSED] = 3
			,[IS_COMPLETED] = 1
			,[IS_CANCELED] = 1
			,[CANCELED_DATETIME] = CURRENT_TIMESTAMP
			,[QUANTITY_PENDING] = 0
			,[CANCELED_BY] = @LOGIN
		WHERE
			[WAVE_PICKING_ID] = @WAVE_PICKING_ID;

        -- ------------------------------------------------------------------------------------
        -- Si viene de demanda despacho, actualiza las cantidades para que pueda ser pickeada de nuevo.
        -- ------------------------------------------------------------------------------------
		IF EXISTS ( SELECT TOP 1
						1
					FROM
						[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H]
					WHERE
						[H].[WAVE_PICKING_ID] = @WAVE_PICKING_ID )
		BEGIN
			UPDATE
				[DD]
			SET	
				[DD].[QTY] = 0
			FROM
				[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH]
			INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD] ON [DD].[PICKING_DEMAND_HEADER_ID] = [DH].[PICKING_DEMAND_HEADER_ID]
			WHERE
				[DH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;
            --
			UPDATE
				[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
			SET	
				[IS_COMPLETED] = 0
			WHERE
				[WAVE_PICKING_ID] = @WAVE_PICKING_ID;
		END;

        -- ------------------------------------------------------------------------------------
        -- Elimina la tarea de linea de picking
        -- ------------------------------------------------------------------------------------
		INSERT	INTO @RESULT
				EXEC [dbo].[OP_WMS_SP_DELETE_PICKING] @WAVE_PICKING_ID = @WAVE_PICKING_ID; -- int

        -- ------------------------------------------------------------------------------------
        -- Regenera el manifiesto de carga si utiliza NEXT
        -- ------------------------------------------------------------------------------------
		INSERT	INTO @RESULT
				EXEC [wms].[OP_WMS_SP_PICKING_HAS_BEEN_COMPLETED] @WAVE_PICKING_ID = @WAVE_PICKING_ID, -- int
					@LOGIN = @LOGIN;                     -- varchar(50)

		IF EXISTS ( SELECT TOP 1
						1
					FROM
						@RESULT
					WHERE
						[Resultado] = -1 )
		BEGIN
			SELECT TOP 1
				@ERROR = [Mensaje]
			FROM
				@RESULT
			WHERE
				[Resultado] = -1;
            --
			RAISERROR(@ERROR, 16, 1);
		END;

        --
		SELECT
			1 AS [Resultado]
			,'Proceso Exitoso' [Mensaje]
			,0 [Codigo]
			,'' [DbData];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,CASE CAST(@@ERROR AS VARCHAR)
				WHEN '2627' THEN ''
				ELSE ERROR_MESSAGE()
				END [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;