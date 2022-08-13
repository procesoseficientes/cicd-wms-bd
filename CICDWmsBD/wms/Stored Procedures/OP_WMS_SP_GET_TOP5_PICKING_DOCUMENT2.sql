
-- =============================================
-- Autor: hector.gonzalez
-- Fecha de Creacion: 2017-02-02 @ Team ERGON - Sprint ERGON II
-- Description: Sp que trae el top 5 de los documentos de demanda de despacho

-- Modificacion 8/10/2017 @ NEXUS-Team Sprint Banjo-Kazooie
-- rodrigo.gomez
-- Se ajusta para la obtención de pickings intercompany

-- Modificacion 8/23/2017 @ NEXUS-Team Sprint CommandAndConquer
-- rodrigo.gomez
-- Se agrega la columna INTERNAL_SALE_INTERFACE

-- Modificacion 11/3/2017 @ NEXUS-Team Sprint F-Zero
-- rodrigo.gomez
-- Se agrega columna de descuento
/*
-- Ejemplo de Ejecucion:
EXEC OP_WMS_ALZA.[wms].[OP_WMS_SP_GET_TOP5_PICKING_DOCUMENT2] @OWNER  = 'wms', @IS_INVOICE = 1
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TOP5_PICKING_DOCUMENT2]
(
 @OWNER VARCHAR(10)   = 'wms'
,@IS_INVOICE INT = 0
)
AS
BEGIN
SET NOCOUNT ON;
--
DECLARE
@SENT_STATUS VARCHAR(50)
,@ERROR_STATUS VARCHAR(50)
,@INTERNAL_SALE_COMPANIES VARCHAR(50)
,@SALE_INVOICE_STATUS VARCHAR(50)
,@QUERY NVARCHAR(4000);
--
CREATE TABLE [#DEMAND_DETAIL]
(
[PICKING_DEMAND_HEADER_ID] INT
);
-- ------------------------------------------------------------------------------------
-- Establece los valores a las variables de estados
-- ------------------------------------------------------------------------------------

 SELECT
@SENT_STATUS = [wms].[OP_WMS_FN_GET_PARAMETER_VALUE]('PICKING_DETAIL_STATUS',
'SENT')
,@ERROR_STATUS = [wms].[OP_WMS_FN_GET_PARAMETER_VALUE]('PICKING_DETAIL_STATUS',
'ERROR');

 -- ------------------------------------------------------------------------------------
-- Obtiene las compañias compraventa y crea la tabla temporal [#PEROFRMS_INTERNAL_SALE]
-- ------------------------------------------------------------------------------------

 SELECT
@INTERNAL_SALE_COMPANIES = [TEXT_VALUE]
FROM
[wms].[OP_WMS_CONFIGURATIONS]
WHERE
[PARAM_GROUP] = 'INTERCOMPANY'
AND [PARAM_NAME] = 'INTERNAL_SALE';
--
SELECT
CASE WHEN [ISC].[VALUE] IS NULL THEN 0
ELSE 1
END [PERFORMS_INTERNAL_SALE]
,CASE WHEN [ISC].[VALUE] =  'WMS' THEN 1
ELSE 0
END [INTERNAL_SALE_INTERFACE]
,CASE WHEN [ISC].[VALUE] IS NOT NULL
AND [ISC].[VALUE] !=  'WMS' THEN 1
ELSE 0
END [VALIDATE_INNER_SALE_STATUS]
,[ISC].[VALUE] [INTERNAL_SALE_COMPANY]
,[PDH].[PICKING_DEMAND_HEADER_ID]
INTO
[#PERFORMS_INTERNAL_SALE]
FROM
[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
LEFT JOIN [wms].[OP_WMS_FUNC_SPLIT](@INTERNAL_SALE_COMPANIES, '|') [ISC] ON ([ISC].[VALUE] = (CASE [PDH].[OWNER]
WHEN NULL
THEN CASE [PDH].[SELLER_OWNER]
WHEN NULL
THEN [PDH].[CLIENT_OWNER]
ELSE [PDH].[SELLER_OWNER]
END
ELSE [PDH].[OWNER]
END))
WHERE
ISNULL([PDH].[IS_POSTED_ERP], 0) = 0
AND ISNULL([PDH].[ATTEMPTED_WITH_ERROR], 0) = 0
AND ISNULL([PDH].[IS_AUTHORIZED], 0) = 1
AND [PDH].[PICKING_DEMAND_HEADER_ID] > 0
AND ISNULL([IS_SENDING], 0) = 0
ORDER BY
[PDH].[PICKING_DEMAND_HEADER_ID] DESC;

 -- ------------------------------------------------------------------------------------
-- Agrega los detalles de los pedidos que cumplan con los criterios de busqueda
-- ------------------------------------------------------------------------------------
SELECT
@QUERY = N'
INSERT INTO [#DEMAND_DETAIL]
SELECT TOP 5
[D].[PICKING_DEMAND_HEADER_ID]
FROM
[wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D]
INNER JOIN [#PERFORMS_INTERNAL_SALE] [PIS] ON [PIS].[PICKING_DEMAND_HEADER_ID] = [D].[PICKING_DEMAND_HEADER_ID]
WHERE
ISNULL([D].[ATTEMPTED_WITH_ERROR], 0) = 0
'
+ CASE WHEN @IS_INVOICE = 0
THEN ' AND ([PIS].[INTERNAL_SALE_INTERFACE] = 1 OR [D].[MATERIAL_OWNER] = '''
+  'WMS' + ''') '
ELSE ' AND (([PIS].[VALIDATE_INNER_SALE_STATUS] = 0 AND ([PIS].[PERFORMS_INTERNAL_SALE] = 1 OR [D].[MATERIAL_OWNER] = '''
+  'WMS'
+ '''))
OR ([PIS].[VALIDATE_INNER_SALE_STATUS] = 1 AND ISNULL([D].[INNER_SALE_STATUS], '''') NOT IN (''SALE_INVOICE'', ''FINAL_INVOICE'') AND [D].[MATERIAL_OWNER] = '''
+  'WMS' + ''')) '
END
+ '
AND ([PIS].[PERFORMS_INTERNAL_SALE] = 1 OR (ISNULL([D].[INNER_SALE_STATUS], '''') NOT IN (''SALE_INVOICE'', ''FINAL_INVOICE'')))
AND [D].[IS_POSTED_ERP] = 0
AND ISNULL([D].[POSTED_STATUS],'''') <> ''' + @SENT_STATUS + '''
AND ISNULL([D].[POSTED_STATUS],'''') <> ''' + @ERROR_STATUS + '''
AND [D].[PICKING_DEMAND_DETAIL_ID] > 0
GROUP BY
[D].[PICKING_DEMAND_HEADER_ID]
ORDER BY
[D].[PICKING_DEMAND_HEADER_ID] DESC;
';
PRINT (@QUERY);

 EXEC (@QUERY);
-- ------------------------------------------------------------------------------------
-- Da valor a la variable @SALE_INVOICE_STATUS
-- ------------------------------------------------------------------------------------

 SELECT
@SALE_INVOICE_STATUS = [wms].[OP_WMS_FN_GET_PARAMETER_VALUE]('INNER_SALE_STATUS',
'SALE_INVOICE');

 -- ------------------------------------------------------------------------------------
-- Selecciona el TOP 5 y filtra con la tablas temporales creadas anteriormente
-- ------------------------------------------------------------------------------------

 SELECT TOP 5
[PDH].[PICKING_DEMAND_HEADER_ID] [PICKING_HEADER]
,CONVERT(INT,[PDH].[DOC_NUM]) [DOC_NUM]
,[CI].[CARD_CODE] [CODE_CLIENT]
,[CI].[LICTRADNUM] [TAX_ID]
,[CI].[CARD_NAME]
,[PDH].[CODE_ROUTE]
,ISNULL([SI].[SLP_CODE], [PDH].[CODE_SELLER]) [CODE_SELLER]
,[PDH].[TOTAL_AMOUNT]
,ISNULL(CAST([SI].[SERIE] AS VARCHAR), CAST([SI2].[SERIE] AS VARCHAR)) [SERIAL_NUMBER]
,[PDH].[DOC_NUM_SEQUENCE]
,[PDH].[EXTERNAL_SOURCE_ID]
,[PDH].[IS_FROM_ERP]
,[PDH].[IS_FROM_SONDA]
,[PDH].[LAST_UPDATE]
,[PDH].[LAST_UPDATE_BY]
,[PDH].[IS_COMPLETED]
,[PDH].[WAVE_PICKING_ID]
,[W].[ERP_WAREHOUSE] [CODE_WAREHOUSE]
,CASE [PDH].[OWNER]
WHEN NULL THEN CASE [PDH].[SELLER_OWNER]
WHEN NULL THEN [PDH].[CLIENT_OWNER]
ELSE [PDH].[SELLER_OWNER]
END
ELSE [PDH].[OWNER]
END AS [OWNER]
,[PIS].[PERFORMS_INTERNAL_SALE]
,[PIS].[INTERNAL_SALE_INTERFACE]
,[PIS].[INTERNAL_SALE_COMPANY]
,[PDH].[INNER_SALE_STATUS]
,[PDH].[DISCOUNT]
,REPLACE([PDH].[SOURCE_TYPE], 'SO - ', '') [SOURCE_DOC_TYPE]
,CASE WHEN [PDH].[IS_COMPLETED] = 1 THEN 'C'
ELSE 'P'
END [PICKING_STATUS]
INTO
[#SALES_ORDER]
FROM
[wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
INNER JOIN [#DEMAND_DETAIL] [DD] ON [DD].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
LEFT JOIN [wms].[OP_WMS_CUSTOMER_INTERCOMPANY] [CI] ON [CI].[MASTER_ID] = [PDH].[CLIENT_CODE]
AND [CI].[SOURCE] = 'WMS'
LEFT JOIN [wms].[OP_WMS_SELLER_INTERCOMPANY] [SI] ON [SI].[MASTER_ID] = [PDH].[MASTER_ID_SELLER]
AND [SI].[SOURCE] =  'WMS'
LEFT JOIN [wms].[OP_WMS_SELLER_INTERCOMPANY] [SI2] ON [SI2].[SLP_CODE] = [PDH].[CODE_SELLER]
AND [SI2].[SOURCE] =  'WMS'
INNER JOIN [#PERFORMS_INTERNAL_SALE] [PIS] ON [PIS].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON [W].[WAREHOUSE_ID] = [PDH].[CODE_WAREHOUSE]
WHERE
(
[PIS].[INTERNAL_SALE_COMPANY] =  'WMS'
OR [PDH].[INNER_SALE_STATUS] IS NULL
)
AND (
(
@IS_INVOICE = 0
OR [PIS].[INTERNAL_SALE_INTERFACE] = 0
)
OR [PDH].[INNER_SALE_STATUS] IS NOT NULL
);

 --UPDATE
-- [PDH]
--SET
-- [PDH].[IS_SENDING] = 1
-- ,[PDH].[LAST_UPDATE_IS_SENDING] = GETDATE()
--FROM
-- [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
--INNER JOIN [#SALES_ORDER] [SO] ON ([SO].[PICKING_HEADER] = [PDH].[PICKING_DEMAND_HEADER_ID]);

 SELECT
*
FROM
[#SALES_ORDER];

END;