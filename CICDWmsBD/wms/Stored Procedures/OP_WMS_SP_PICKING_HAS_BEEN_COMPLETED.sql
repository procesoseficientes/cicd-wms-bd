-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	11/10/2017 @ NEXUS-Team Sprint F-Zero 
-- Description:			Validar si la ola ha sido completado y el manifiesto sea de demanda de despacho

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_PICKING_HAS_BEEN_COMPLETED]
					@WAVE_PICKING_ID = 1
					,@LOGIN = 'admin'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_PICKING_HAS_BEEN_COMPLETED](
	@WAVE_PICKING_ID INT
	,@LOGIN VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE 
		@MANIFEST_HEADER_ID INT = 0
		,@IS_COMPLETED INT = 0;
	-- ------------------------------------------------------------------------------------
	-- Obtiene el Id del manifiesto
	-- ------------------------------------------------------------------------------------
	SELECT @MANIFEST_HEADER_ID = [MH].[MANIFEST_HEADER_ID] 
	FROM [wms].[OP_WMS_MANIFEST_HEADER] [MH]
	INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD] ON [MD].[MANIFEST_HEADER_ID] = [MH].[MANIFEST_HEADER_ID]
	WHERE [MH].[MANIFEST_HEADER_ID] > 0
		AND [MH].[STATUS] = 'IN_PICKING'
		AND [MD].[WAVE_PICKING_ID] = @WAVE_PICKING_ID
	
	-- ------------------------------------------------------------------------------------
	-- Verifica que la ola ya haya sido completada
	-- ------------------------------------------------------------------------------------
	IF(@MANIFEST_HEADER_ID > 0)
	BEGIN
		SELECT @IS_COMPLETED = MIN([IS_COMPLETED])
		FROM [wms].[OP_WMS_TASK_LIST]
		WHERE [WAVE_PICKING_ID] = @WAVE_PICKING_ID	    
		--
		IF(@IS_COMPLETED > 0)
		BEGIN
		    EXEC [wms].[OP_WMS_SP_REGENERATE_CARGO_MANIFEST_FROM_PICKING_DEMAND] 
				@WAVE_PICKING_ID = @WAVE_PICKING_ID, -- int
		        @LOGIN = @LOGIN -- varchar(50)
		END
	END
END