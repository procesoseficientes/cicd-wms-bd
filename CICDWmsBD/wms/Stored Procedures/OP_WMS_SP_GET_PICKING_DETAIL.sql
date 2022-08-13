-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-02-13 @ Team ERGON - Sprint ERGON IV
-- Description:	        Sp que trae el detalle de un picking

-- Modificacion 30-Aug-17 @ Nexus Team Sprint CommandAndConquer
-- alberto.ruiz
-- Se agrega el campo [TRANSFER_REQUEST_ID]

-- Modificacion 08-Sep-17 @ Nexus Team Sprint CommandAndConquer
-- alberto.ruiz
-- Se agrega campo de peso

-- Modificacion 9/20/2017 @ NEXUS-Team Sprint DuckHunt
-- rodrigo.gomez
-- Se agrega campo de direccion y estado

-- Modificacion 21-Sep-17 @ Nexus Team Sprint DuckHunt
-- alberto.ruiz
-- Se corrge el peso y se agrupa por PICKING_DEMAND_HEADER_ID

-- Modificacion 9/25/2017 @ NEXUS-Team Sprint DuckHunt
-- rodrigo.gomez
-- Se obtiene el detalle por medio de la demanda despacho

-- Modificacion 10/19/2017 @ NEXUS-Team Sprint ewms
-- rodrigo.gomez
-- Se modifica el metodo de obtencion dependiendo al parametro de configuracion de manifiestos de carga

-- Modificacion 21-Nov-2017 @ Reborn - Team Sprint Nach
-- diego.as
-- Se agregaron los campos de [TYPE_DEMAND_NAME]

-- Modificacion 12/7/2017 @ NEXUS-Team Sprint HeyYouPikachu!
					-- rodrigo.gomez
					-- Se agregan los precios y descuentos

-- Modificacion 12/7/2017 @ NEXUS-Team Sprint HeyYouPikachu!
					-- rodrigo.gomez
					-- Se agregan los precios y descuentos

-- Modificacion 12/7/2017 @ NEXUS-Team Sprint HeyYouPikachu!
					-- rodrigo.gomez
					-- Se agregan los precios y descuentos

-- Autor:				henry.rodriguez
-- Fecha de Creacion: 	30-Noviembre-2019 GForce@Kioto
-- Description:			Se agrega validacion cuando se tiene producto pendiente de entrega

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_PICKING_DETAIL] @PICKING_HEADER_ID = '6371|6372|6373|6374' 
			--
			EXEC [wms].[OP_WMS_SP_GET_PICKING_DETAIL] @PICKING_HEADER_ID = '67500'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_PICKING_DETAIL] (
		@PICKING_HEADER_ID VARCHAR(MAX)
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	DECLARE
		@CARGO_MANIFEST_CONFIGURATION VARCHAR(50)
		,@QUERY VARCHAR(4000);
  -- ------------------------------------------------------------------------------------
  -- Obtiene la configuracion del manifiesto de carga
  -- ------------------------------------------------------------------------------------
	SELECT
		@CARGO_MANIFEST_CONFIGURATION = [TEXT_VALUE]
	FROM
		[wms].[OP_WMS_CONFIGURATIONS]
	WHERE
		[PARAM_TYPE] = 'SISTEMA'
		AND [PARAM_NAME] = 'TIPO_MANIFIESTO_DE_CARGA';
  --
	SELECT
		@QUERY = ' 
    
	DECLARE	@MANIFEST_DETALLE TABLE (
			[MANIFEST_DETAIL_ID] INT
			,[PICKING_DEMAND_HEADER_ID] INT
			,[MATERIAL_ID] VARCHAR(50)
			,[LINE_NUM] INT
			,[QTY_PENDING_DELIVERY] DECIMAL(18, 4)
			,[QTY_DELIVERED] DECIMAL(18, 4)
			,[ROW_NUMBER] INT
		);
    ---
	INSERT	INTO @MANIFEST_DETALLE
			(
				[MANIFEST_DETAIL_ID]
				,[PICKING_DEMAND_HEADER_ID]
				,[MATERIAL_ID]
				,[LINE_NUM]
				,[QTY_PENDING_DELIVERY]
				,[QTY_DELIVERED]
				,[ROW_NUMBER]
			)
	
	
	SELECT
		[D].[MANIFEST_DETAIL_ID]
		,[D].[PICKING_DEMAND_HEADER_ID]
		,[D].[MATERIAL_ID]
		,[D].[LINE_NUM]
		,[D].[QTY_PENDING_DELIVERY]
		,[D].[QTY_DELIVERED]
		,ROW_NUMBER() OVER (PARTITION BY  D.[PICKING_DEMAND_HEADER_ID], [D].[LINE_NUM], [D].[MATERIAL_ID] ORDER BY [H].[CREATED_DATE] DESC) AS [rn]
	FROM
		[wms].[OP_WMS_MANIFEST_DETAIL] [D]
	INNER JOIN [wms].[OP_WMS_MANIFEST_HEADER] [H] ON [H].[MANIFEST_HEADER_ID] = [D].[MANIFEST_HEADER_ID]
	WHERE
		[H].[STATUS] <> ''CANCELED'';
    --
			
		SELECT DISTINCT ISNULL([CMP].[COMPONENT_MATERIAL],
				[M].[MATERIAL_ID]) [MATERIAL_ID],
				 ISNULL([MC].[MATERIAL_NAME],
				[M].[MATERIAL_NAME])  MATERIAL_NAME,
				CASE WHEN [MD].[QTY_PENDING_DELIVERY] > 0
				THEN [MD].[QTY_PENDING_DELIVERY]
				ELSE  ISNULL( [CMP].[QTY] , 1 ) * [DD].[QTY] 
				END [QTY],
				[DH].[CLIENT_CODE] ,
				[DH].[CLIENT_NAME] ,
				[DH].[CREATED_DATE] [COMPLETED_DATE] ,
				[DH].[WAVE_PICKING_ID] ,
				[DD].[LINE_NUM] ,
				[DH].[TRANSFER_REQUEST_ID] ,
				[wms].[OP_WMS_FN_CONVERT_FROM_WEIGHT_MEASURE_UNIT_TO_DEFAULT](ISNULL(( ( ISNULL(MC.[WEIGTH],[M].[WEIGTH]) ) * ( CASE WHEN [MD].[QTY_PENDING_DELIVERY] > 0
				THEN [MD].[QTY_PENDING_DELIVERY]
				ELSE  ISNULL( [CMP].[QTY] , 1 ) * [DD].[QTY] 
				END) ), 0),M.WEIGHT_MEASUREMENT) [WEIGHT] ,
				[DH].[ADDRESS_CUSTOMER] ,
				[DH].[STATE_CODE] ,
				[DH].[PICKING_DEMAND_HEADER_ID] ,
				([M].[VOLUME_FACTOR] * [DD].[QTY]) [TOTAL_VOLUME],
				[DD].[PRICE],
				[DD].[DISCOUNT] [LINE_DISCOUNT],
				[DD].[DISCOUNT_TYPE] [LINE_DISCOUNT_TYPE],
				[DH].[DISCOUNT] [HEADER_DISCOUNT]
				,[DH].[TYPE_DEMAND_CODE]
				,[DH].[TYPE_DEMAND_NAME]
				, CAST(DH.DOC_NUM AS VARCHAR) ERP_REFERENCE_DOC_NUM
				,[DD].[STATUS_CODE]
		FROM    [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD]
				INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH] ON [DH].[PICKING_DEMAND_HEADER_ID] = [DD].[PICKING_DEMAND_HEADER_ID] 
			
	
				INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([M].[MATERIAL_ID] = [DD].[MATERIAL_ID] AND M.MATERIAL_ID > '''' )
				LEFT JOIN [wms].[OP_WMS_COMPONENTS_BY_MASTER_PACK] [CMP] ON [CMP].[MASTER_PACK_CODE] = [M].[MATERIAL_ID] AND M.IS_MASTER_PACK = 1
				LEFT JOIN [wms].[OP_WMS_MATERIALS] [MC] ON [CMP].[COMPONENT_MATERIAL] = [MC].[MATERIAL_ID]
				LEFT JOIN @MANIFEST_DETALLE [MD] ON (
											[MD].[PICKING_DEMAND_HEADER_ID] = [DH].[PICKING_DEMAND_HEADER_ID]
											AND [MD].[LINE_NUM] = [DD].[LINE_NUM]
											AND [MD].[MATERIAL_ID] = ISNULL([CMP].[COMPONENT_MATERIAL],[M].[MATERIAL_ID])
											AND [MD].[ROW_NUMBER] = 1
										)
				INNER JOIN [wms].[OP_WMS_FN_SPLIT]('''
		+ @PICKING_HEADER_ID
		+ ''', ''|'') [PHID] ON [PHID].[VALUE] = 
				'
		+ CASE	WHEN @CARGO_MANIFEST_CONFIGURATION = 'POR_PEDIDO'
				THEN ' [DH].[PICKING_DEMAND_HEADER_ID] '
				ELSE ' [DH].[WAVE_PICKING_ID] '
			END + '
		WHERE 
		([MD].[PICKING_DEMAND_HEADER_ID] IS NULL
		OR [MD].[QTY_PENDING_DELIVERY] > 0)
	';
  --
	PRINT (@QUERY);
  --
	EXEC (@QUERY);
END;