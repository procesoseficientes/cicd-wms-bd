-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	11/10/2017 @ NEXUS-Team Sprint F-Zero 
-- Description:			Regenera el detalle del manifiesto en base a la ola de picking enviada

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_REGENERATE_CARGO_MANIFEST_FROM_PICKING_DEMAND]
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REGENERATE_CARGO_MANIFEST_FROM_PICKING_DEMAND](
	@WAVE_PICKING_ID INT
    ,@LOGIN VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @RESULT TABLE(
		Resultado INT
        ,Mensaje VARCHAR(MAX)
		,Codigo INT
		,DbData VARCHAR(MAX)
	)
	--
	DECLARE @PICKING_DEMAND TABLE (
		[PICKING_DEMAND_HEADER_ID] INT
	)
	--
	DECLARE 
		@MANIFEST_HEADER_ID INT = 0
		,@PICKING_DEMAND_HEADER_ID INT = 0
		,@LAST_RESULT INT = 1
		,@MESSAGE VARCHAR(1000) = ''
		,@SOURCE VARCHAR(50) = 'DEMANDA_DE_DESPACHO';
	--
	BEGIN TRAN
	BEGIN TRY
		INSERT INTO @PICKING_DEMAND
				(
					[PICKING_DEMAND_HEADER_ID]
				)
		SELECT [DH].[PICKING_DEMAND_HEADER_ID]
		FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH]
		INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD] ON ([MD].[PICKING_DEMAND_HEADER_ID] = [DH].[PICKING_DEMAND_HEADER_ID])
		WHERE [DH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID

		-- ------------------------------------------------------------------------------------
		-- Obtiene el header del manifiesto
		-- ------------------------------------------------------------------------------------
		SELECT @MANIFEST_HEADER_ID = [MH].[MANIFEST_HEADER_ID] 
		FROM [wms].[OP_WMS_MANIFEST_DETAIL] [MD]
		INNER JOIN [wms].[OP_WMS_MANIFEST_HEADER] [MH] ON [MH].[MANIFEST_HEADER_ID] = [MD].[MANIFEST_HEADER_ID]
		WHERE [WAVE_PICKING_ID] = @WAVE_PICKING_ID
			AND [MH].[STATUS] = 'IN_PICKING'
		-- ------------------------------------------------------------------------------------
		-- Elimina los picking labels by manifest de este manifiesto
		-- ------------------------------------------------------------------------------------
		DELETE [P]
		FROM [wms].[OP_WMS_PICKING_LABEL_BY_MANIFEST] [P]
		INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD] ON [MD].[MANIFEST_DETAIL_ID] = [P].[MANIFEST_DETAIL_ID]
		WHERE [MD].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
		-- ------------------------------------------------------------------------------------
		-- Elimina toda la ola de picking en el manifiesto detalle para volver a regenerarla
		-- ------------------------------------------------------------------------------------
		DELETE [MD]
		FROM [wms].[OP_WMS_MANIFEST_DETAIL] [MD]
		INNER JOIN [wms].[OP_WMS_MANIFEST_HEADER] [MH] ON [MH].[MANIFEST_HEADER_ID] = [MD].[MANIFEST_HEADER_ID]
		WHERE [MD].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
			AND [MH].[STATUS] = 'IN_PICKING'

		-- ------------------------------------------------------------------------------------
		-- Agrega el nuevo detalle con lo que pickeo
		-- ------------------------------------------------------------------------------------
		WHILE EXISTS (SELECT TOP 1 1 FROM @PICKING_DEMAND)
		BEGIN
			-- ------------------------------------------------------------------------------------
			-- Obtiene el picking header id
			-- ------------------------------------------------------------------------------------
			SELECT TOP 1 
				@PICKING_DEMAND_HEADER_ID = [P].[PICKING_DEMAND_HEADER_ID]
				,@LAST_RESULT = 1
				,@MESSAGE = ''
			FROM @PICKING_DEMAND [P]
			
			-- ------------------------------------------------------------------------------------
			-- Agrega los nuevos detalles
			-- ------------------------------------------------------------------------------------
			INSERT INTO @RESULT
			EXEC [wms].[OP_WMS_SP_INSERT_MANIFEST_DETAIL] 
				@MANIFEST_HEADER_ID = @MANIFEST_HEADER_ID, -- int
				@PICKING_DEMAND_HEADER_ID = @PICKING_DEMAND_HEADER_ID, -- int
				@LAST_UPDATE_BY = @LOGIN -- varchar(50)
			
			-- ------------------------------------------------------------------------------------
			-- Valida el resultado
			-- ------------------------------------------------------------------------------------
			SELECT TOP 1
				@LAST_RESULT = [R].[Resultado]
				,@MESSAGE = [R].[Mensaje]
			FROM @RESULT [R]
			WHERE [R].[Resultado] = -1
			--
			IF (@LAST_RESULT = -1)
			BEGIN
			    RAISERROR(@MESSAGE,16,1);
			END

			-- ------------------------------------------------------------------------------------
			-- Elimina el registro de la tabla temporal
			-- ------------------------------------------------------------------------------------
			DELETE FROM @PICKING_DEMAND WHERE [PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
			--
			DELETE FROM @RESULT
		END
		
		-- ------------------------------------------------------------------------------------
		-- Revisa si el manifiesto tiene otras olas abiertas, de estar todas cerradas le cambia el estado a creado
		-- ------------------------------------------------------------------------------------
		UPDATE [wms].[OP_WMS_MANIFEST_HEADER]
		SET [STATUS] = 'CREATED'
		WHERE [MANIFEST_HEADER_ID] IN (
			SELECT [MH].[MANIFEST_HEADER_ID]
			FROM [wms].[OP_WMS_MANIFEST_HEADER] [MH]
				INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD] ON [MD].[MANIFEST_HEADER_ID] = [MH].[MANIFEST_HEADER_ID]
				INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON [TL].[WAVE_PICKING_ID] = [MD].[WAVE_PICKING_ID]
			WHERE [MH].[STATUS] = 'IN_PICKING' AND [MD].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
			GROUP BY [MH].[MANIFEST_HEADER_ID]
			HAVING MIN(ISNULL([TL].[IS_COMPLETED],0)) > 0
		)
		--
		COMMIT
	END TRY
	BEGIN CATCH
		ROLLBACK
		--
		DECLARE @CATCH_MESSAGE VARCHAR(1000) = @@ERROR
		--
		RAISERROR(@CATCH_MESSAGE,16,1);
	END CATCH
END