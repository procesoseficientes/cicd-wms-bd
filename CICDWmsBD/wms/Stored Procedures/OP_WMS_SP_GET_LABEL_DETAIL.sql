-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/7/2017 @ NEXUS-Team Sprint HeyYoyPikachu! 
-- Description:			Obtiene los contenidos de la etiqueta o caja

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_LABEL_DETAIL]
					@TYPE = 'CAJA'
					,@BARCODE = 'P-4881-1/2'
					,@WAVE_PICKING_ID = 4881
				--
				EXEC [wms].[OP_WMS_SP_GET_LABEL_DETAIL]
					@TYPE = 'ETIQUETA'
					,@BARCODE = '3'
					,@WAVE_PICKING_ID = 4711
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_LABEL_DETAIL] (
		@TYPE VARCHAR(50)
		,@BARCODE VARCHAR(50)
		,@WAVE_PICKING_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	IF @TYPE = 'CAJA'
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Obtiene todas las cajas
		-- ------------------------------------------------------------------------------------
		SELECT
			[MATERIAL_ID]
			,[MATERIAL_NAME]
			,[QUANTITY]
			,[BOX_ID]
			,[ERP_DOC]
			 ,CASE [STATUS]
            WHEN 'PICKED' THEN 'Despachado'
            ELSE 'Pendiente'
        END [STATUS]
		INTO
			[#BOXES]
		FROM
			[op_wms].[dbo].[OP_WMS_DISTRIBUTED_TASK]
		UNION ALL
		SELECT
			[MATERIAL_ID]
			,[MATERIAL_NAME]
			,[QUANTITY]
			,[BOX_ID]
			,[ERP_DOC]
			 ,CASE [STATUS]
            WHEN 'PICKED' THEN 'Despachado'
            ELSE 'Pendiente' END [STATUS]
		FROM
			[op_wms].[dbo].[OP_WMS_DISTRIBUTED_TASK_HISTORY];
		
		
		SELECT DISTINCT
			[B].[MATERIAL_ID]
			,[B].[MATERIAL_NAME]
			,[B].[QUANTITY]
			,[B].[STATUS]
		FROM
			[#BOXES] [B]
		INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [wms].[OP_WMS_FN_SPLIT_COLUMNS]([B].[ERP_DOC],
											2, '-') = [T].[WAVE_PICKING_ID]
		WHERE
			[B].[BOX_ID] = @BARCODE
			AND [T].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;
	END;
	ELSE
	BEGIN
		SELECT DISTINCT
			[PL].[MATERIAL_ID]
			,[PL].[MATERIAL_NAME]
			,[PL].[QTY] [QUANTITY]
			,'' [STATUS]
		FROM
			[wms].[OP_WMS_PICKING_LABELS] [PL]
		INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [T].[WAVE_PICKING_ID] = [PL].[WAVE_PICKING_ID]
		WHERE
			[LABEL_ID] = @BARCODE
			AND [PL].[WAVE_PICKING_ID] = @WAVE_PICKING_ID;
	END;
END;