-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/7/2017 @ NEXUS-Team Sprint HeyYouPikachu! 
-- Description:			Obtiene la información principal de la etiqueta o caja.

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_LABEL_INFORMATION]
					
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LABEL_INFORMATION](
	@TYPE VARCHAR(50)
	,@BARCODE VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @BOXES AS TABLE(
		[BOX_ID] VARCHAR(25)
		,[ERP_DOC] VARCHAR(25)
		,PRIMARY KEY([BOX_ID],[ERP_DOC])
	)
	--
	IF @TYPE = 'CAJA' 
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Obtiene todas las cajas
		-- ------------------------------------------------------------------------------------
		INSERT INTO @BOXES	
		SELECT DISTINCT	[BOX_ID],[ERP_DOC] FROM [op_wms].[dbo].[OP_WMS_DISTRIBUTED_TASK] WHERE [BOX_ID] = @BARCODE
		UNION ALL
		SELECT DISTINCT	[BOX_ID],[ERP_DOC] FROM [op_wms].[dbo].[OP_WMS_DISTRIBUTED_TASK_HISTORY] WHERE [BOX_ID] = @BARCODE
		
		
	    SELECT TOP 1
			[T].[WAVE_PICKING_ID]
			,[B].[BOX_ID] [LABEL_ID]
			,[T].[LOCATION_SPOT_TARGET]
			, [T].[CLIENT_OWNER]
			, [T].[CLIENT_NAME]
			, [T].[REGIMEN]
			, '' [STATE_CODE]
		FROM @BOXES [B]
		INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [wms].[OP_WMS_FN_SPLIT_COLUMNS]([B].[ERP_DOC],2,'-') = [T].[WAVE_PICKING_ID]		
		WHERE [B].[BOX_ID] = @BARCODE
		ORDER BY [T].[SERIAL_NUMBER] DESC
	END
	ELSE
    BEGIN
        SELECT DISTINCT
			[T].[WAVE_PICKING_ID]
			,[PL].[LABEL_ID]
			,[T].[LOCATION_SPOT_TARGET]
			,[T].[CLIENT_OWNER]
			,[T].[CLIENT_NAME]
			, CASE WHEN [PL].[STATE_CODE] = 0 THEN ''
			ELSE [PL].[STATE_CODE] END [STATE_CODE]
			, [T].[REGIMEN]
		FROM [wms].[OP_WMS_PICKING_LABELS] [PL]
		INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [T].[WAVE_PICKING_ID] = [PL].[WAVE_PICKING_ID]		
		WHERE [LABEL_ID] = @BARCODE
    END
END