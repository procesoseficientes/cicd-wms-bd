-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	12/12/2017 @ NEXUS-Team Sprint HeyYouPikachu! 
-- Description:			Obtiene el detalle de la recepcion por devolucion con las licencias y cantidad ingresada

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_RECEPTION_RETURN_BY_TASK]
					@TASK_ID = 518217
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_RECEPTION_RETURN_BY_TASK](
	@TASK_ID INT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @INV_ON_LICENSES AS TABLE(
		[LICENSE_ID] INT
		,[MATERIAL_ID] VARCHAR(50)
		,[QTY] NUMERIC(18,4)
	)
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene lo que ya esta en recepcionado en con sus licencias y cantidades
	-- ------------------------------------------------------------------------------------
	INSERT INTO @INV_ON_LICENSES
	SELECT [IL].[LICENSE_ID]
			 ,[RD].[MATERIAL_ID]
			 ,SUM(ISNULL([IL].[QTY],0)) [QTY]
	FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH]
	INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RD] ON [RD].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [RH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
	INNER JOIN [wms].[OP_WMS_POLIZA_HEADER] [PH] ON [PH].[DOC_ID] = [RH].[DOC_ID_POLIZA]
	LEFT JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[CODIGO_POLIZA] = [PH].[CODIGO_POLIZA]
	LEFT JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON [IL].[LICENSE_ID] = [L].[LICENSE_ID] AND [RD].[MATERIAL_ID] = [IL].[MATERIAL_ID]
	WHERE [TASK_ID] = @TASK_ID
		AND [IL].[LICENSE_ID] IS NOT NULL	
	GROUP BY [IL].[LICENSE_ID]
            ,[RD].[MATERIAL_ID]
			,[RD].[LINE_NUM]
	
	-- ------------------------------------------------------------------------------------
	-- Despliega tanto lo que ya esta recepcionado como lo que aun no se ha recepcionado.
	-- ------------------------------------------------------------------------------------
	SELECT [IL].[LICENSE_ID]
          ,[RD].[MATERIAL_ID]
          ,[M].[MATERIAL_NAME]
          ,[IL].[QTY]
		  ,[RD].[QTY] [MAX_QTY]
	FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH]
	INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RD] ON [RD].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [RH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [RD].[MATERIAL_ID]
	LEFT JOIN @INV_ON_LICENSES [IL] ON [IL].[MATERIAL_ID] = [RD].[MATERIAL_ID]
	WHERE [RH].[TASK_ID] = @TASK_ID
END