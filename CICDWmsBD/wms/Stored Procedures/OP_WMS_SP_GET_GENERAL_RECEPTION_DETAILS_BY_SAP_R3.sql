-- =============================================
-- Autor:				marvin.solares
-- Fecha de Creacion: 	20180829 GForce@Jaguarundi
-- Description:			obtiene el detalle de una recepcion general para posterior envió a sap r3

/*
-- Ejemplo de Ejecucion:
         EXEC [wms].[OP_WMS_SP_GET_GENERAL_RECEPTION_DETAILS_BY_SAP_R3] @RECEPTION_HEADER = 109
*/
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_GENERAL_RECEPTION_DETAILS_BY_SAP_R3] (
		@RECEPTION_HEADER INT
	)
AS
BEGIN
	--
	SET NOCOUNT ON;
	--
	DECLARE
		@WAREHOUSE_CODE_PARAMETER VARCHAR(15) = NULL
		,@DOC_ID VARCHAR(50) = '-1'
		,@DATE_CONFIRMED DATETIME
		,@COD_SUPPLIER VARCHAR(50)
		,@NAME_SUPPLIER VARCHAR(100)
		,@OWNER VARCHAR(50)
		,@MOVE_TYPE VARCHAR(50)
		,@PARAM_NAME VARCHAR(50)
		,@SPARE1 VARCHAR(50)
		,@TASK_ID NUMERIC(18, 0);
	--
	CREATE TABLE [#SERIE] ([SERIES] INT);
	--
	SELECT TOP 1
		@DOC_ID = [RDH].[DOC_ID]
		,@OWNER = [RDH].[OWNER]
		,@DATE_CONFIRMED = [RDH].[DATE_CONFIRMED]
		,@COD_SUPPLIER = '0000000516'
		,@NAME_SUPPLIER = 'AMESA'
		,@PARAM_NAME = [RDH].[RECEPTION_TYPE_ERP]
		,@TASK_ID = [RDH].[TASK_ID]
	FROM
		[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
	WHERE
		[RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER;

		-- ------------------------------------------------------------------------------------
		-- obtenermos configuracion de tipo de movimiento
		-- ------------------------------------------------------------------------------------
	SELECT TOP 1
		@MOVE_TYPE = [TEXT_VALUE]
		,@SPARE1 = [SPARE1]
	FROM
		[wms].[OP_WMS_CONFIGURATIONS]
	WHERE
		[PARAM_GROUP] = 'TIPO_RECEPCION_RFC'
		AND [PARAM_NAME] = @PARAM_NAME;
	

	SELECT
		'' [EBELN]
		,[CP].[MASTER_ID_CLIENT_CODE] [BUKRS]--'' [BUKRS]--este campo esta pendiente de definir de donde se va a extraer y si es importante para esta rfc
		,@DATE_CONFIRMED [AEDAT]
		,@COD_SUPPLIER [LIFNR]
		,[C].[SPARE3] [EKORG]--este campo esta pendiente de definir de donde se va a extraer y si es importante para esta rfc
		,[M].[ITEM_CODE_ERP] [MATNR]
		,@OWNER [WERKS]
		,[D].[WAREHOUSE_CODE] [LGORT]
		,[D].[QTY_CONFIRMED] [MENGE]
		,@NAME_SUPPLIER [NAME1_LIFNR]
		,CAST(0 AS NUMERIC(18, 0)) [EBELP]
		,[M].[BASE_MEASUREMENT_UNIT] [MEINS]
		,[CM].[TEXT_VALUE] [MSEHL]
		,[C].[TEXT_VALUE] [BSART]
		,[C].[SPARE1] [CHARG]
		,[C].[TEXT_VALUE] [MOVE_TYPE]
		,'IG' [INPUT_TYPE]
		,'Creador: ' + [tl].[TASK_OWNER] [FRBNR]
		,'Recepciona: ' + [tl].[TASK_ASSIGNEDTO] [XBLNR]
		,'Tarea Swift WMS: '
		+ CAST([h].[TASK_ID] AS VARCHAR(100)) [BKTXT]
		,'Recibida en Swift 3PL' [ITEM_TEXT]
		,'' [RESWK]
		,'' [FRGKE]
		,'' [EST_POS]
		,'' [EST_DOC]
	FROM
		[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D]
	INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [h] ON [h].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
	INNER JOIN [wms].[OP_WMS_TASK_LIST] [tl] ON [tl].[SERIAL_NUMBER] = [h].[TASK_ID]
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON [M].[MATERIAL_ID] = [D].[MATERIAL_ID]
	INNER JOIN [wms].[OP_WMS_COMPANY] [CP] ON [CP].[EXTERNAL_SOURCE_ID] = [h].[EXTERNAL_SOURCE_ID]
											AND [CP].[CLIENT_CODE] = [h].[OWNER]
	LEFT JOIN [wms].[OP_WMS_CONFIGURATIONS] [C] ON [C].[PARAM_GROUP] = 'TIPO_RECEPCION_RFC'
											AND [C].[PARAM_NAME] = @PARAM_NAME
	LEFT JOIN [wms].[OP_WMS_CONFIGURATIONS] [CM] ON [CM].[PARAM_NAME] = [M].[BASE_MEASUREMENT_UNIT]
											AND [CM].[PARAM_GROUP] = 'TIPOS_EMPAQUE'
	WHERE
		[D].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER
		AND [D].[IS_CONFIRMED] = 1
	ORDER BY
		[D].[ERP_RECEPTION_DOCUMENT_DETAIL_ID];




END;
