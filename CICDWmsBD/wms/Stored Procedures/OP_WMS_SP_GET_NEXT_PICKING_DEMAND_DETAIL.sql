
-- =============================================
-- Autor:	        hector.gonzalez
-- Fecha de Creacion: 	2017-02-02 @ Team ERGON - Sprint ERGON 
-- Description:	        Sp que trae el detalle de un Picking wms


-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-02-28 Team ERGON - Sprint ERGON IV
-- Description:	 se agrega el campo del taxcode que proviene de un parametro

-- Modificacion 14-Jul-17 @ Nexus Team Sprint AgeOfEmperies
-- alberto.ruiz
-- Se agregaron los campos [IS_MASTER_PACK] y [WAS_IMPLODED]

-- Modificacion 10-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- alberto.ruiz
-- Ajuste por intercompany
-- Modificacion 9/18/2017 @ Reborn-Team Sprint Collin
-- diego.as
-- Se agrean columnas TONE y CALIBER

-- Modificacion 11/3/2017 @ NEXUS-Team Sprint F-Zero
-- rodrigo.gomez
-- Se agrega columna de descuento
/*
-- Ejemplo de Ejecucion:
			select * from [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER]
			--
			EXEC [wms].[OP_WMS_SP_GET_NEXT_PICKING_DEMAND_DETAIL] 
				@PICKING_DEMAND_HEADER_ID = 5229
				,@OWNER = 'VISCOSA'
*/
-- =============================================
CREATE PROCEDURE wms.OP_WMS_SP_GET_NEXT_PICKING_DEMAND_DETAIL (@PICKING_DEMAND_HEADER_ID INT
, @OWNER VARCHAR(50))
AS
BEGIN
  SET NOCOUNT ON;
  --
  DECLARE @TAX_CODE VARCHAR(50)
         ,@INTERNAL_SALE VARCHAR(50)
         ,@IS_INTERNAL_SALE INT = 0
         ,@QUERY NVARCHAR(4000)
         ,@PICKING_OWNER VARCHAR(50);
  --


  --
  SELECT
    @PICKING_OWNER =
    CASE [PDH].[OWNER]
      WHEN NULL THEN CASE [PDH].[SELLER_OWNER]
          WHEN NULL THEN [PDH].[CLIENT_OWNER]
          ELSE [PDH].[SELLER_OWNER]
        END
      ELSE [PDH].[OWNER]
    END
  FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH]
  WHERE [PDH].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
  --
  SELECT TOP 1
    @TAX_CODE = [C].[TEXT_VALUE]
  FROM [wms].[OP_WMS_CONFIGURATIONS] [C]
  WHERE [C].[PARAM_TYPE] = 'SISTEMA'
  AND [C].[PARAM_GROUP] = 'ERP_PARAMS'
  AND [C].[PARAM_NAME] = 'TAX_CODE_ERP';
  --
  SELECT TOP 1
    @INTERNAL_SALE = [C].[TEXT_VALUE]
  FROM [wms].[OP_WMS_CONFIGURATIONS] [C]
  WHERE [C].[PARAM_TYPE] = 'SISTEMA'
  AND [C].[PARAM_GROUP] = 'INTERCOMPANY'
  AND [C].[PARAM_NAME] = 'INTERNAL_SALE';
  --
  SELECT TOP 1
    @IS_INTERNAL_SALE = 1
  FROM [wms].[OP_WMS_FUNC_SPLIT_3](@INTERNAL_SALE, '|')
  WHERE [VALUE] = @PICKING_OWNER
  --



  --
  SELECT
    @QUERY = N'
    DECLARE @MATERIALS_WITH_BATCH TABLE (
    [MATERIAL_ID] VARCHAR(50)
   ,[BATCH] VARCHAR(50)
  )
    
    
     INSERT INTO @MATERIALS_WITH_BATCH
  EXEC [wms].OP_WMS_SP_GET_MATERIALS_WITH_BATCH_FROM_DEMAND_DISPATCH @PICKING_DEMAND_HEADER_ID = ' + CAST(@PICKING_DEMAND_HEADER_ID AS VARCHAR) + '

    
    SELECT
		[PDD].[PICKING_DEMAND_DETAIL_ID]
		,[PDD].[PICKING_DEMAND_HEADER_ID] AS [DoEntry]
		,CASE WHEN [PDD].[MATERIAL_OWNER] = ''' + @OWNER + '''
			THEN [PDH].[DOC_ENTRY] 
			ELSE 0 
		END AS [DocEntryErp]
		,[M].[ITEM_CODE_ERP] [ItemCode]
		,[PDD].[QTY] AS [Quantity]
		,CASE [PDH].[IS_FROM_SONDA]
			WHEN 1 THEN -1
			ELSE [PDD].[LINE_NUM] - 1
		END AS [LineNum]
		,CASE [PDH].[IS_FROM_ERP]
			WHEN 1 THEN 17
			ELSE [PDD].[ERP_OBJECT_TYPE]
		END [ObjType]
		,[PDD].[PRICE] AS [Price]
		,[W].[ERP_WAREHOUSE] AS [Warehouse]
		,''' + @TAX_CODE + '''[TaxCode]
		,[M].[IS_MASTER_PACK]
		,[PDD].[WAS_IMPLODED]
		,[PDD].[ATTEMPTED_WITH_ERROR]
		,[PDD].[IS_POSTED_ERP]
		,[PDD].[POSTED_ERP]
		,[PDD].[ERP_REFERENCE]
		,[PDD].[POSTED_STATUS]
		,[PDD].[POSTED_RESPONSE]
		,[PDD].[MATERIAL_OWNER]
		,[PDD].[TONE]
		,[PDD].[CALIBER]
		,[PDD].[DISCOUNT]
		--, 0 [DISCOUNT]
		,[PDD].[DISCOUNT_TYPE]
    ,[MWB].[BATCH]
    ,[MWC].[CATEGORY_CODE] AS U_FAMILIA
	FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PDD]
	INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON [PDD].[PICKING_DEMAND_HEADER_ID] = [PDH].[PICKING_DEMAND_HEADER_ID]
	INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([M].[MATERIAL_ID] = [PDD].[MATERIAL_ID])
	--INNER JOIN [wms].[OP_WMS_MATERIAL_INTERCOMPANY] [MI] ON ([MI].[SOURCE] = ''' + @OWNER + ''' AND [PDD].[MASTER_ID_MATERIAL] = [MI].[MASTER_ID])
	LEFT JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON [PDH].[CODE_WAREHOUSE] = [W].[WAREHOUSE_ID]
  LEFT JOIN @MATERIALS_WITH_BATCH [MWB] ON ([MWB].[MATERIAL_ID] = [PDD].[MATERIAL_ID])
  LEFT JOIN [wms].[OP_WMS_MATERIALS_WITH_CATEGORY] [MWC] ON ([MWC].ITEM_CODE = [M].[MATERIAL_ID] )
  --LEFT JOIN SWIFT_INTERFACES.wms.ERP_VIEW_SALES_ORDER_DETAIL_CHANNEL_MODERN ODCM ON (ODCM.docentry = pdh.doc_num and ODCM.U_MasterIdSKU = pdd.MASTER_ID_MATERIAL COLLATE DATABASE_DEFAULT) 
	WHERE PDD.QTY > 0 AND  [PDH].[PICKING_DEMAND_HEADER_ID] = ' + CAST(@PICKING_DEMAND_HEADER_ID AS VARCHAR)
    +
    CASE
      WHEN @IS_INTERNAL_SALE = 0 THEN ' AND [PDD].[MATERIAL_OWNER] = ''' + @OWNER + ''';'
      ELSE ';'
    END
  --
  PRINT '--> @QUERY: ' + @QUERY
  --
  EXEC (@QUERY)
END;