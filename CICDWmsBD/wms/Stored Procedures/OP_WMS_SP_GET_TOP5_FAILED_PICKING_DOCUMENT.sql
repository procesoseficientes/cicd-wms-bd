
-- =============================================
-- Autor:	              hector.gonzalez
-- Fecha de Creacion: 	2017-02-02 @ Team ERGON - Sprint ERGON II
-- Description:	        Sp que trae el top 5 de los documentos de PICKING para sap erroneos

-- Modificacion 14-Jul-17 @ Nexus Team Sprint AgeOfEmpires
-- alberto.ruiz
-- Se cambio el filtro para que obtenga todos los pickings con [IS_POSTED_ERP] <0

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
			EXEC  [wms].[OP_WMS_SP_GET_TOP5_FAILED_PICKING_DOCUMENT] @OWNER = 'Arium'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_TOP5_FAILED_PICKING_DOCUMENT] (@OWNER VARCHAR(50), @IS_INVOICE INT = 0)
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @MAX_ATTEMPTS INT = 5
         ,@SENT_STATUS VARCHAR(50)
         ,@INTERNAL_SALE_COMPANIES VARCHAR(50);

  -- ------------------------------------------------------------------------------------
  -- Establece los valores a las variables de estados
  -- ------------------------------------------------------------------------------------

  SELECT
    @SENT_STATUS = [wms].[OP_WMS_FN_GET_PARAMETER_VALUE]('PICKING_DETAIL_STATUS', 'SENT');

  --
  SELECT
    @MAX_ATTEMPTS = [owc].[NUMERIC_VALUE]
  FROM [wms].[OP_WMS_CONFIGURATIONS] [owc]
  WHERE [owc].[PARAM_TYPE] = 'SISTEMA'
  AND [owc].[PARAM_GROUP] = 'MAX_NUMBER_OF_ATTEMPTS'
  AND [owc].[PARAM_NAME] = 'MAX_NUMBER_OF_SENDING_ATTEMPTS_TO_ERP';

  -- ------------------------------------------------------------------------------------
  -- Obtiene las compañias compraventa y crea la tabla temporal [#PEROFRMS_INTERNAL_SALE]
  -- ------------------------------------------------------------------------------------

  SELECT
    @INTERNAL_SALE_COMPANIES = [TEXT_VALUE]
  FROM [wms].[OP_WMS_CONFIGURATIONS]
  WHERE [PARAM_GROUP] = 'INTERCOMPANY'
  AND [PARAM_NAME] = 'INTERNAL_SALE';
  --
  SELECT TOP 5
    CASE
      WHEN [ISC].[VALUE] IS NULL THEN 0
      ELSE 1
    END [PERFORMS_INTERNAL_SALE]
   ,CASE
      WHEN [ISC].[VALUE] = @OWNER THEN 1
      ELSE 0
    END [INTERNAL_SALE_INTERFACE]
   ,[ISC].[VALUE] [INTERNAL_SALE_COMPANY]
   ,[PDH].[PICKING_DEMAND_HEADER_ID] INTO [#PERFORMS_INTERNAL_SALE]
  FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
  LEFT JOIN [wms].[OP_WMS_FUNC_SPLIT](@INTERNAL_SALE_COMPANIES,
  '|') [ISC]
    ON ([ISC].[VALUE] = (CASE [PDH].[OWNER]
        WHEN NULL THEN CASE [PDH].[SELLER_OWNER]
            WHEN NULL THEN [PDH].[CLIENT_OWNER]
            ELSE [PDH].[SELLER_OWNER]
          END
        ELSE [PDH].[OWNER]
      END))
  WHERE [PICKING_DEMAND_HEADER_ID] > 0
  AND ISNULL([PDH].[IS_POSTED_ERP], 0) < 0
  AND ISNULL([PDH].[ATTEMPTED_WITH_ERROR], 0) < @MAX_ATTEMPTS
  AND ISNULL([PDH].[ATTEMPTED_WITH_ERROR], 0) > 0
  AND ISNULL([PDH].[IS_AUTHORIZED], 0) = 1;
  --
  CREATE NONCLUSTERED INDEX [IN_TEMP_PERFOMS_INTERNAL_SALE]
  ON [#PERFORMS_INTERNAL_SALE] ([PICKING_DEMAND_HEADER_ID]) INCLUDE ([PERFORMS_INTERNAL_SALE]);

  -- ------------------------------------------------------------------------------------
  -- Agrega los detalles de los pedidos que cumplan con los criterios de busqueda
  -- ------------------------------------------------------------------------------------

  SELECT TOP 5
    [D].[PICKING_DEMAND_HEADER_ID] INTO [#DEMAND_DETAIL]
  FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D]
  INNER JOIN [#PERFORMS_INTERNAL_SALE] [PIS]
    ON [PIS].[PICKING_DEMAND_HEADER_ID] = [D].[PICKING_DEMAND_HEADER_ID]
  WHERE ([PIS].[INTERNAL_SALE_INTERFACE] = 1
  OR [D].[MATERIAL_OWNER] = @OWNER)
  AND ISNULL([D].[POSTED_STATUS], '') <> @SENT_STATUS
  AND ISNULL([D].[ATTEMPTED_WITH_ERROR], 0) < @MAX_ATTEMPTS
  AND ISNULL([D].[ATTEMPTED_WITH_ERROR], 0) > 0
  GROUP BY [D].[PICKING_DEMAND_HEADER_ID]
  ORDER BY [D].[PICKING_DEMAND_HEADER_ID] DESC;
  --
  CREATE NONCLUSTERED INDEX IN_TEMP_DEMAND_DETAIL
  ON [#DEMAND_DETAIL] ([PICKING_DEMAND_HEADER_ID])
  -- ------------------------------------------------------------------------------------
  -- Selecciona el TOP 5 y filtra con la tablas temporales creadas anteriormente
  -- ------------------------------------------------------------------------------------

  SELECT TOP 5
    [PDH].[PICKING_DEMAND_HEADER_ID] [PICKING_HEADER]
	,CONVERT(INT,[PDH].[DOC_NUM]) [DOC_NUM]
   --,[PDH].[DOC_NUM]
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
   ,CASE
      WHEN [PDH].[IS_COMPLETED] = 1 THEN 'C'
      ELSE 'P'
    END [PICKING_STATUS]
  FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
  INNER JOIN [#DEMAND_DETAIL] [DD]
    ON [DD].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
  LEFT JOIN [wms].[OP_WMS_CUSTOMER_INTERCOMPANY] [CI]
    ON [CI].[MASTER_ID] = [PDH].[CLIENT_CODE]
      AND [CI].[SOURCE] = @OWNER
  LEFT JOIN [wms].[OP_WMS_SELLER_INTERCOMPANY] [SI]
    ON [SI].[MASTER_ID] = [PDH].[MASTER_ID_SELLER]
      AND [SI].[SOURCE] = @OWNER
  LEFT JOIN [wms].[OP_WMS_SELLER_INTERCOMPANY] [SI2]
    ON [SI2].[SLP_CODE] = [PDH].[CODE_SELLER]
      AND [SI2].[SOURCE] = @OWNER
  INNER JOIN [#PERFORMS_INTERNAL_SALE] [PIS]
    ON [PIS].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
  INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W]
    ON [W].[WAREHOUSE_ID] = [PDH].[CODE_WAREHOUSE]
  WHERE ([PIS].[INTERNAL_SALE_COMPANY] = @OWNER
  OR [PDH].[INNER_SALE_STATUS] IS NULL)
  AND ((@IS_INVOICE = 0
  OR [PIS].[INTERNAL_SALE_INTERFACE] = 0)
  OR [PDH].[INNER_SALE_STATUS] IS NOT NULL);
END;