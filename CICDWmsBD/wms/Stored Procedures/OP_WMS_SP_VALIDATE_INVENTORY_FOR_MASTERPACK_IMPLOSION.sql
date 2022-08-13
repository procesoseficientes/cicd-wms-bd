-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	9/18/2017 @ NEXUS-Team Sprint DuckHunt 
-- Description:			Valida el inventario para la implosion desde la HH.

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_VALIDATE_INVENTORY_FOR_MASTERPACK_IMPLOSION] 
				@MATERIAL_ID = 'autovanguard/VAD1001', -- varchar(50)
				@WAREHOUSE = 'BODEGA_01', -- varchar(50)
				@QUANTITY = 4 -- decimal
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_VALIDATE_INVENTORY_FOR_MASTERPACK_IMPLOSION] (
	@MATERIAL_ID VARCHAR(50)
	,@WAREHOUSE VARCHAR(50)
	,@QUANTITY DECIMAL	
)
AS
BEGIN
	SET NOCOUNT ON;
    --
	DECLARE	@MENSAJE VARCHAR(150) = 'Proceso exitóso.';
	
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Despliega las cantidades cuando se tiene inventario
		-- ------------------------------------------------------------------------------------
		SELECT
			[CMP].[MASTER_PACK_CODE]
			,[CMP].[COMPONENT_MATERIAL] [MATERIAL_ID]
			,[CMP].[QTY] * @QUANTITY [QTY]
			,SUM(CASE WHEN [L].[LICENSE_ID] IS NOT NULL THEN ISNULL([IXL].[QTY], 0) ELSE 0 END) - MAX(ISNULL([IR].[COMMITED_QTY], 0)) [QTY_AVAILABLE]
		INTO [#MATERIALS]
		FROM [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [CMP]
		LEFT JOIN [wms].[OP_WMS_INV_X_LICENSE] [IXL] ON [CMP].[COMPONENT_MATERIAL] = [IXL].[MATERIAL_ID]
		LEFT JOIN [wms].[OP_WMS_LICENSES] [L] ON (
			[L].[LICENSE_ID] = [IXL].[LICENSE_ID]
			AND [L].[CURRENT_WAREHOUSE] = @WAREHOUSE
		)
		LEFT JOIN [wms].[OP_WMS_FN_GET_COMMITED_INVENTORY_BY_LICENCE]() [IR] ON (
			[IR].[MATERIAL_ID] = [IXL].[MATERIAL_ID]
			AND [IR].[LICENCE_ID] = [IXL].[LICENSE_ID]
			AND [IR].[CODE_WAREHOUSE] = [L].[CURRENT_WAREHOUSE]
		)
		WHERE [CMP].[MASTER_PACK_CODE] = @MATERIAL_ID
		GROUP BY [CMP].[QTY]
			,[CMP].[MASTER_PACK_CODE]
			,[CMP].[COMPONENT_MATERIAL];
		
		-- ------------------------------------------------------------------------------------
		-- Verifica si hay algun registro que no tenga inventario
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1 @MENSAJE = 'Inventario insuficiente.'
		FROM [#MATERIALS]
		WHERE [#MATERIALS].[QTY] > [QTY_AVAILABLE]; 

		-- ------------------------------------------------------------------------------------
		-- Despliega resultados
		-- ------------------------------------------------------------------------------------
		SELECT
			CASE	
				WHEN @MENSAJE = 'Inventario insuficiente.'THEN -1
				ELSE 1
			END AS [Resultado]
			,@MENSAJE [Mensaje]
			,0 [Codigo]
			,'' [DbData];
			--
		SELECT
			[MASTER_PACK_CODE]
			,[MATERIAL_ID]
			,[#MATERIALS].[QTY]
			,[QTY_AVAILABLE]
		FROM [#MATERIALS];
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo]; 
	END CATCH;
END;