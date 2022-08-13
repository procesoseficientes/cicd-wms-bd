-- =============================================
-- Autor:	              marvin.solares
-- Fecha de Creacion: 	20190422 GForce@Xoloescuincle
-- Description:	        Sp que trae el top 5 de los documentos de pedidos de transferencia para envio a sap r3

/*
-- Ejemplo de Ejecucion:
			EXEC  [wms].[OP_WMS_SP_GET_TOP5_PICKING_TRANSFER_DOCUMENT_R3]  @IS_INVOICE = 0
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TOP5_PICKING_TRANSFER_DOCUMENT_R3] (@IS_INVOICE INT = 0)
AS
BEGIN
	SET NOCOUNT ON;
	--
	-- ------------------------------------------------------------------------------------
	-- Selecciona el TOP 5 y filtra con la tablas temporales creadas anteriormente
	-- ------------------------------------------------------------------------------------

	SELECT TOP 5
		CAST([PDH].[PICKING_DEMAND_HEADER_ID] AS VARCHAR) [PICKING_HEADER]
		,[PDH].[DOC_NUM]
		,'' [CODE_CLIENT]
		,'' [TAX_ID]
		,'' [CARD_NAME]
		,[PDH].[CODE_ROUTE]
		,[PDH].[CODE_SELLER] [CODE_SELLER]
		,[PDH].[TOTAL_AMOUNT]
		,'' [SERIAL_NUMBER]
		,[PDH].[DOC_NUM_SEQUENCE]
		,[PDH].[EXTERNAL_SOURCE_ID]
		,[PDH].[IS_FROM_ERP]
		,[PDH].[IS_FROM_SONDA]
		,[PDH].[LAST_UPDATE]
		,[PDH].[LAST_UPDATE_BY]
		,[PDH].[IS_COMPLETED]
		,[PDH].[WAVE_PICKING_ID]
		,[W].[ERP_WAREHOUSE] [CODE_WAREHOUSE]
		,[PDH].[OWNER] [OWNER]
		,'' [PERFORMS_INTERNAL_SALE]
		,'' [INTERNAL_SALE_INTERFACE]
		,'' [INTERNAL_SALE_COMPANY]
		,[PDH].[INNER_SALE_STATUS]
		,[PDH].[DISCOUNT]
		,REPLACE([PDH].[SOURCE_TYPE], 'SO - ', '') [SOURCE_DOC_TYPE]
		,CASE	WHEN [PDH].[IS_COMPLETED] = 1 THEN 'C'
				ELSE 'P'
			END [PICKING_STATUS]
		,[PDH].[TYPE_DEMAND_CODE]
	INTO
		[#PICKING_DOCUMENT]
	FROM
		[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
	INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON [W].[WAREHOUSE_ID] = [PDH].[CODE_WAREHOUSE]
	WHERE
		ISNULL([PDH].[IS_POSTED_ERP], 0) <> 1
		AND ISNULL([PDH].[ATTEMPTED_WITH_ERROR], 0) < 2
		AND ISNULL([PDH].[IS_AUTHORIZED], 0) = 1
		AND [PDH].[IS_FROM_ERP] = 1
		AND [PDH].[IS_SENDING] = 0
		AND [PDH].[DEMAND_TYPE] = 'TRANSFER_REQUEST';


	UPDATE
		[PDH]
	SET	
		[PDH].[IS_SENDING] = 1
		,[PDH].[LAST_UPDATE_IS_SENDING] = GETDATE()
	FROM
		[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
	INNER JOIN [#PICKING_DOCUMENT] [PD] ON ([PD].[PICKING_HEADER] = [PDH].[PICKING_DEMAND_HEADER_ID]);

	SELECT
		*
	FROM
		[#PICKING_DOCUMENT];
END;


