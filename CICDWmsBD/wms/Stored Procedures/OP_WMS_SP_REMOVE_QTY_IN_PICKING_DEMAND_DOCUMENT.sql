-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	08-Dec-17 @ Nexus Team Sprint HeyYouPikachu!
-- Description:			SP que cambia que quita la cantidad indicada de un material de los documentos relacionados a la ola de picking indicada
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_REMOVE_QTY_IN_PICKING_DEMAND_DOCUMENT]
					@WAVE_PICKING_ID = 4729
					,@MATERIAL_ID = 'viscosa/VCA1014'
					,@REMOVE_QTY = 6
					,@LOGIN = 'BETO'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_REMOVE_QTY_IN_PICKING_DEMAND_DOCUMENT](
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
	PRINT '----> START [OP_WMS_SP_REMOVE_QTY_IN_PICKING_DEMAND_DOCUMENT]'
	--
	DECLARE @DOCUMENT TABLE (
		[PICKING_DEMAND_DETAIL_ID] INT NOT NULL PRIMARY KEY
		,[PRIORITY] INT NOT NULL
		,[QTY] DECIMAL (18,4)
		,[USED] INT NOT NULL DEFAULT(0)
	)
	--
	DECLARE
		@PICKING_DEMAND_HEADER_ID INT = 0
		,@PICKING_DEMAND_DETAIL_ID INT = 0
		,@PRIORITY INT = 0
		,@QTY DECIMAL(18,4)
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene los documentos
		-- ------------------------------------------------------------------------------------
		INSERT INTO @DOCUMENT
				(
					[PICKING_DEMAND_DETAIL_ID]
					,[PRIORITY]
					,[QTY]
				)
		SELECT
			[PD].[PICKING_DEMAND_DETAIL_ID]
			,[PH].[PRIORITY]
			,[PD].[QTY]
		FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PH]
		INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PD] ON ([PD].[PICKING_DEMAND_HEADER_ID] = [PH].[PICKING_DEMAND_HEADER_ID])
		WHERE [PH].[PICKING_DEMAND_HEADER_ID] > 0
			AND [PH].[WAVE_PICKING_ID] = @WAVE_PICKING_ID

		-- ------------------------------------------------------------------------------------
		-- Le quita la cantidad a todos los documentos cuando es cero
		-- ------------------------------------------------------------------------------------
		IF @REMOVE_QTY = 0
		BEGIN
		    UPDATE @DOCUMENT
			SET [QTY] = @REMOVE_QTY
			WHERE [PICKING_DEMAND_DETAIL_ID] > 0
		END
		ELSE
		BEGIN
		    -- ------------------------------------------------------------------------------------
		    -- Recorre los documentos
		    -- ------------------------------------------------------------------------------------
			WHILE @REMOVE_QTY > 0 AND EXISTS(SELECT TOP 1 1 FROM @DOCUMENT WHERE [PICKING_DEMAND_DETAIL_ID] > 0 AND [USED] = 0)
			BEGIN
			    SELECT TOP 1
					@PICKING_DEMAND_DETAIL_ID = [D].[PICKING_DEMAND_DETAIL_ID]
					,@PRIORITY = [D].[PRIORITY]
					,@QTY = [D].[QTY]
				FROM @DOCUMENT [D]
				WHERE [D].[PICKING_DEMAND_DETAIL_ID] > 0
					AND [USED] = 0
				ORDER BY [D].[PRIORITY] DESC;
				--
				PRINT '--->'
				PRINT '--> @PICKING_DEMAND_DETAIL_ID ' + CAST(@PICKING_DEMAND_DETAIL_ID AS VARCHAR)
				PRINT '--> @PRIORITY ' + CAST(@PRIORITY AS VARCHAR)
				PRINT '--> @QTY ' + CAST(@QTY AS VARCHAR)
				PRINT '--> @REMOVE_QTY ' + CAST(@REMOVE_QTY AS VARCHAR)
				--
				UPDATE @DOCUMENT
				SET 
					[QTY] = CASE WHEN @REMOVE_QTY >= @QTY THEN 0 ELSE (@QTY - @REMOVE_QTY) END
					,[USED] = 1
				WHERE [PICKING_DEMAND_DETAIL_ID] = @PICKING_DEMAND_DETAIL_ID
				--
				SET @REMOVE_QTY = @REMOVE_QTY - @QTY
			END
		END

		-- ------------------------------------------------------------------------------------
		-- Actualiza el documento
		-- ------------------------------------------------------------------------------------
		UPDATE [PD]
		SET [PD].[QTY] = [D].[QTY]
		FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PD]
		INNER JOIN @DOCUMENT [D] ON ([D].[PICKING_DEMAND_DETAIL_ID] = [PD].[PICKING_DEMAND_DETAIL_ID])

		-- ------------------------------------------------------------------------------------
		-- Retorna el resultado
		-- ------------------------------------------------------------------------------------
		SET @RESULT = 'OK'
	END TRY
	BEGIN CATCH
		SET @RESULT = ERROR_MESSAGE()
	END CATCH
	--
	PRINT '----> END [OP_WMS_SP_REMOVE_QTY_IN_PICKING_DEMAND_DOCUMENT]'
END