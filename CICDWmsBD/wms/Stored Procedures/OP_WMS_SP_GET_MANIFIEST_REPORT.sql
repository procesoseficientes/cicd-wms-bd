-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-02-14 @ Team ERGON - Sprint ERGON III
-- Description:	        

-- Modificacion 31-Aug-17 @ Nexus Team Sprint CommandAndConquer
-- alberto.ruiz
-- Se agrega campo de TRANSFER_REQUEST_ID

-- Modificacion 08-Sep-17 @ Nexus Team Sprint CommandAndConquer
-- alberto.ruiz
-- Se agrega campo de peso

-- Modificacion 9/20/2017 @ NEXUS-Team Sprint DuckHunt
-- rodrigo.gomez
-- Se agrega direccion

-- Modificacion 21-Sep-17 @ Nexus Team Sprint DuckHunt
-- alberto.ruiz
-- Se agrega el doc num del ERP y estado, se modifica el Join a demanda detalle para que las cantidades hagan match debido a las bonificaciones de SONDA

-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-10-30 @ Team REBORN - Sprint Drache
-- Description:	   Se agrego la placa del vehiculo

-- Modificacion 11/22/2017 @ NEXUS-Team Sprint GTA
					-- rodrigo.gomez
					-- Se agrega un ISNULL para devolver el numero de factura o de nota de entrega.

-- Modificacion 12/7/2017 @ NEXUS-Team Sprint HeyYouPikachu!
					-- rodrigo.gomez
					-- Se agregan campos de descuentos

-- Modificacion 18-Apr-18 @ G-FORCE Team Sprint buho
					-- pablo.aguilar
					-- se agregan campos de nombre de piloto y bodega destino si vienere de una transferencia.

-- Modificacion 01/19/2022 @ G-FORCE Team Sprint buho
					-- Elder Lucas
					-- Agrego campo de estado para mostrar en el reporte

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_GET_MANIFIEST_REPORT] @MANIFEST_HEADER_ID = 2169
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_MANIFIEST_REPORT] (
		@MANIFEST_HEADER_ID INT
	)
AS
BEGIN
	SET NOCOUNT ON;
  --
	SELECT
		[MH].[MANIFEST_HEADER_ID]
		,[MH].[DRIVER]
		,[MH].[PLATE_NUMBER] AS [VEHICLE]
		,[MH].[DISTRIBUTION_CENTER]
		,[MD].[CODE_ROUTE]
		,[MD].[CLIENT_CODE]
		,[MD].[CLIENT_NAME]
		,[MD].[WAVE_PICKING_ID]
		,[MD].[MATERIAL_ID]
		,[M].[MATERIAL_NAME]
		,[MD].[QTY]
		,[MH].[TRANSFER_REQUEST_ID]
		,ISNULL(([M].[WEIGTH] * [MD].[QTY]), 0) [WEIGHT]
		,ISNULL([MD].[ADDRESS_CUSTOMER], '') [ADDRESS_CUSTOMER]
		,ISNULL([DH].[DELIVERY_NOTE_INVOICE],
				[DD].[ERP_REFERENCE]) [ERP_REFERENCE_DOC_NUM]
		,[MD].[STATE_CODE]
		,CASE	WHEN [DH].[DELIVERY_NOTE_INVOICE] IS NULL
				THEN 'Nota de Entrega: '
				ELSE 'Factura: '
			END [SHOWN_DOCUMENT]
		,[MD].[PRICE]
		,[MD].[LINE_DISCOUNT]
		,[DD].[DISCOUNT_TYPE] [LINE_DISCOUNT_TYPE]
		,[MD].[HEADER_DISCOUNT]
		,[T].[WAREHOUSE_TO]
		,[T].[WAREHOUSE_FROM]
		,[P].[NAME] [PILOT_NAME]
		,ISNULL(MH.[CAI], '') [CAI]
		,ISNULL(MH.CAI_SERIE, '')  + ' - ' +  ISNULL(MH.CAI_NUMERO, '') CAI_SERIE
		,ISNULL(MH.CAI_NUMERO, '') CAI_NUMERO
		,ISNULL(MH.CAI_RANGO_INICIAL, 0) CAI_RANGO_INICIAL
		,ISNULL(MH.CAI_RANGO_FINAL, 0) CAI_RANGO_FINAL
		,ISNULL(CONVERT(DATE, MH.CAI_FECHA_VENCIMIENTO), '') CAI_FECHA_VENCIMIENTO
		,MD.STATUS_CODE
	FROM
		[wms].[OP_WMS_MANIFEST_HEADER] [MH]
	INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD] ON [MH].[MANIFEST_HEADER_ID] = [MD].[MANIFEST_HEADER_ID]
	INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH] ON ([MD].[PICKING_DEMAND_HEADER_ID] = [DH].[PICKING_DEMAND_HEADER_ID])
	INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD] ON (
											[DH].[PICKING_DEMAND_HEADER_ID] = [DD].[PICKING_DEMAND_HEADER_ID]
											AND [MD].[MATERIAL_ID] = [DD].[MATERIAL_ID]
											AND [MD].[LINE_NUM] = [DD].[LINE_NUM]
											)
	LEFT JOIN [wms].[OP_WMS_MATERIALS] [M] ON [MD].[MATERIAL_ID] = [M].[MATERIAL_ID]
	LEFT JOIN [wms].[OP_WMS_VIEW_CLIENTS] [C] ON [MD].[CLIENT_CODE] = [C].[CLIENT_CODE]
	LEFT JOIN [wms].[OP_WMS_TRANSFER_REQUEST_HEADER] [T] ON [T].[TRANSFER_REQUEST_ID] = [DH].[TRANSFER_REQUEST_ID]
	LEFT JOIN [wms].[OP_WMS_PILOT] [P] ON [P].[PILOT_CODE] = [MH].[DRIVER]
	WHERE
		[MH].[MANIFEST_HEADER_ID] = @MANIFEST_HEADER_ID
		AND [MD].[MANIFEST_DETAIL_ID] > 0
		and md.QTY>0;
END;