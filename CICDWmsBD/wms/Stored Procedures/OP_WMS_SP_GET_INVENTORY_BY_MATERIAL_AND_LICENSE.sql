-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/18/2017 @ NEXUS-Team Sprint DuckHunt 
-- Description:			Devuelve el inventario disponible en la licencia escaneada.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_INVENTORY_BY_MATERIAL_AND_LICENSE]
					@LICENSE_ID_SOURCE = 367975
					,@LICENSE_ID_TARGET = 378263
					,@MASTER_PACK_ID = 'autovanguard/VAD1001'
					,@MATERIAL = 'autovanguard/VAD1002'
					,@WAREHOUSE = 'BODEGA_01'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_INVENTORY_BY_MATERIAL_AND_LICENSE] (
	@LICENSE_ID_SOURCE NUMERIC(18,0)
	,@LICENSE_ID_TARGET NUMERIC(18,0)
	,@MASTER_PACK_ID VARCHAR(50)
	,@MATERIAL VARCHAR(50)
	,@WAREHOUSE VARCHAR(25)
) AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@QTY NUMERIC(18, 4) = 0
		,@IS_COMPLETED NUMERIC(18,0) = 0
		,@TASK_TYPE VARCHAR(25) = 'IMPLOSION_INVENTARIO'
		,@TASK_SUBTYPE VARCHAR(25) = 'IMPLOSION_MANUAL'
		,@MATERIAL_ID VARCHAR(50) = ''
		,@IS_COMPONENT INT = 0
		,@IS_IN_WAREHOUSE INT = 0
		,@MESSAGE VARCHAR(1000) = '';
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene el codigo real de material
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1 @MATERIAL_ID = [M].[MATERIAL_ID]
		FROM [wms].[OP_WMS_MATERIALS] [M]
		WHERE [M].[MATERIAL_ID] = @MATERIAL
			OR [M].[BARCODE_ID] = @MATERIAL
			OR [M].[ALTERNATE_BARCODE] = @MATERIAL
		--
		IF @MATERIAL_ID = ''
		BEGIN
		    RAISERROR('No existe el componente',16,1)
		END

		-- ------------------------------------------------------------------------------------
		-- Valida si es componente del master pack
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1 @IS_COMPONENT = 1
		FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [C]
		WHERE [C].[MASTER_PACK_CODE] = @MASTER_PACK_ID
			AND [C].[COMPONENT_MATERIAL] = @MATERIAL_ID
		--
		IF @IS_COMPONENT = 0
		BEGIN
			SET @MESSAGE = 'El material ' + @MATERIAL_ID + ' no es un componente.'
			--
		    RAISERROR (@MESSAGE,16,1)
		END

		-- ------------------------------------------------------------------------------------
		-- Valida si la licencia esta en la bodega enviada
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1 @IS_IN_WAREHOUSE = 1
		FROM [wms].[OP_WMS_LICENSES] [L]
		WHERE [L].[LICENSE_ID] = @LICENSE_ID_SOURCE
			AND [L].[CURRENT_WAREHOUSE] = @WAREHOUSE
		--
		IF @IS_IN_WAREHOUSE = 0
		BEGIN
			SET @MESSAGE = 'La licencia no esta en la bodega ' + @WAREHOUSE + '.'
			--
		    RAISERROR (@MESSAGE,16,1)
		END
		-- ------------------------------------------------------------------------------------
		-- Obtiene la cantidad
		-- ------------------------------------------------------------------------------------
		SELECT 
			@QTY = CASE 
				WHEN ((MAX([PH].[QTY]) * MAX([PD].[QTY])) - ISNULL(SUM([T].[QUANTITY_ASSIGNED]),0)) <= (SUM([I].[QTY]) - SUM(ISNULL([CIL].[COMMITED_QTY],0))) THEN ((MAX([PH].[QTY]) * MAX([PD].[QTY])) - ISNULL(SUM([T].[QUANTITY_ASSIGNED]),0))				
				ELSE (SUM([I].[QTY]) - SUM(ISNULL([CIL].[COMMITED_QTY],0)))
			END 
		FROM [wms].[OP_WMS_MASTER_PACK_HEADER] [PH]
		INNER JOIN [wms].[OP_WMS_MASTER_PACK_DETAIL] [PD] ON ([PD].[MASTER_PACK_HEADER_ID] = [PH].[MASTER_PACK_HEADER_ID])
		LEFT JOIN [wms].[OP_WMS_TASK_LIST] [T] ON (
			[T].[LICENSE_ID_TARGET] = [PH].[LICENSE_ID]
			AND [T].[TASK_TYPE] = @TASK_TYPE
			AND [T].[TASK_SUBTYPE] = @TASK_SUBTYPE
			AND [T].[IS_COMPLETED] = @IS_COMPLETED
			AND [T].[MATERIAL_ID] = [PD].[MATERIAL_ID]
		)
		LEFT JOIN [wms].[OP_WMS_INV_X_LICENSE] [I] ON (
			[I].[LICENSE_ID] = @LICENSE_ID_SOURCE
			AND [I].[MATERIAL_ID] = [PD].[MATERIAL_ID]
		)
		LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [CIL] ON (
			[CIL].[MATERIAL_ID] = [I].[MATERIAL_ID]
			AND [CIL].[LICENCE_ID] = [I].[LICENSE_ID]
		)
		WHERE [PH].[LICENSE_ID] = @LICENSE_ID_TARGET
			AND [PH].[MATERIAL_ID] = @MASTER_PACK_ID
			AND [I].[MATERIAL_ID] = @MATERIAL_ID
		GROUP BY [PD].[MATERIAL_ID]
		--

		IF @QTY <= 0
		BEGIN
			SET @MESSAGE = 'La licencia ya no posee inventario disponible. '
			--
		    RAISERROR (@MESSAGE,16,1)
		END

		SELECT
			1 as Resultado
			,'Proceso Exitoso' Mensaje
			,0 Codigo
			,CAST(@QTY AS VARCHAR(50)) + '|' + @MATERIAL_ID DbData
	END TRY
	BEGIN CATCH
			SELECT
				-1 AS [Resultado]
				,ERROR_MESSAGE()[Mensaje]
				,@@ERROR [Codigo]
				,'' DbData; 
	END CATCH
END;