-- =============================================
-- Autor:				rudi.garcia
-- Fecha de Creacion: 	18-ene-17 @ TeamErgon Sprint 1
-- Description:			obtiene el detalle de una orde de compra en sap de la cual se hizo una recepcion 

-- Modificado Fecha
-- anonymous
-- ningun motivo

-- Modificacion 9/17/2017 @ Reborn-Team Sprint Collin
					-- diego.as
					-- Se agregan columnas @WAREHOUSE_CODE_PARAMETER AS WarehouseCode
					-- TONE y CALIBER

/*
-- Ejemplo de Ejecucion:
         EXEC [wms].[OP_WMS_SP_GET_RECEPTION_DETAILS] @RECEPTION_HEADER = 2006
*/
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_RECEPTION_DETAILS]
    (
     @RECEPTION_HEADER INT
	)
AS
BEGIN
	--
    SET NOCOUNT ON;
	--
    DECLARE
        @WAREHOUSE_CODE_PARAMETER VARCHAR(15) = NULL
       ,@COST_WAREHOUSE_PARAMETER VARCHAR(15) = NULL
       ,@SERIE INT
       ,@DOC_ID VARCHAR(50) = '-1'
       ,@INTERFACE_DATA_BASE_NAME VARCHAR(50)
       ,@SCHEMA_NAME VARCHAR(50)
       ,@SQL VARCHAR(MAX)
	   ,@COST_SERIE INT ;
	--
    CREATE TABLE [#SERIE] ([SERIES] INT);
	--
    SELECT TOP 1
        @DOC_ID = [RDH].[DOC_ID]
       ,@INTERFACE_DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
       ,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
    FROM
        [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
    INNER JOIN [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES] ON [RDH].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID]
    WHERE
        [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER;

	-- ------------------------------------------------------------------------------------
	-- Obtiene la serie
	-- ------------------------------------------------------------------------------------
    SELECT
        @SQL = 'SELECT
		VRD.SERIES
	FROM ' + @INTERFACE_DATA_BASE_NAME + '.' + @SCHEMA_NAME
        + '.ERP_VIEW_RECEPTION_DOCUMENT VRD
	WHERE VRD.SAP_REFERENCE = ' + CAST(@DOC_ID AS VARCHAR) + '';

    INSERT  INTO [#SERIE]
            EXEC (
                  @SQL
                );

    SELECT
        @SERIE = [SERIES]
    FROM
        [#SERIE];
	-- ------------------------------------------------------------------------------------
	-- Obtiene la bodega por defecto para recepciones
	-- ------------------------------------------------------------------------------------
    SELECT
        @WAREHOUSE_CODE_PARAMETER = [C].[TEXT_VALUE]
    FROM
        [wms].[OP_WMS_CONFIGURATIONS] AS [C]
    WHERE
        [C].[PARAM_NAME] = 'ERP_WAREHOUSE_PURCHASE_ORDER';
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene la bodega de costeos
	-- ------------------------------------------------------------------------------------
    SELECT
		@COST_WAREHOUSE_PARAMETER = [TEXT_VALUE],
		@COST_SERIE = [NUMERIC_VALUE]
	FROM
		[wms].[OP_WMS_CONFIGURATIONS]
	WHERE
		[PARAM_NAME] = 'ERP_COST_WAREHOUSE_PURCHASE_ORDER';
	PRINT '@COST_SERIE: ' + CAST(@COST_SERIE AS VARCHAR)
	PRINT '@SERIE: ' + CAST(@SERIE AS VARCHAR)
	PRINT '@COST_WAREHOUSE_PARAMETER: ' + CAST(@COST_WAREHOUSE_PARAMETER AS VARCHAR)
	PRINT '@WAREHOUSE_CODE_PARAMETER: ' + CAST(@WAREHOUSE_CODE_PARAMETER AS VARCHAR)

    SELECT
        [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID] [DocEntry]
       ,[wms].[OP_WMS_GET_STRING_FROM_CHAR]([D].[MATERIAL_ID], '/') [ItemCode]
       ,SUM([D].[QTY_CONFIRMED]) [Quantity]
       ,[D].[LINE_NUM] [LineNum]
       ,CAST([D].[ERP_OBJECT_TYPE] AS VARCHAR) [ObjType]
       ,[H].[DOC_ID] [DocEntryErp]
       ,CASE WHEN @SERIE = @COST_SERIE THEN @COST_WAREHOUSE_PARAMETER
             ELSE @WAREHOUSE_CODE_PARAMETER
        END AS [WarehouseCode]
    FROM
        [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D]
    INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H] ON [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
    INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [H].[TASK_ID] = [T].[SERIAL_NUMBER]
    WHERE
        [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER
		AND [D].[LINE_NUM]  > -1 
    GROUP BY
        [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
       ,[H].[DOC_ID]
       ,[D].[MATERIAL_ID]
       ,[D].[LINE_NUM]
       ,[D].[ERP_OBJECT_TYPE]

	  HAVING   SUM([D].[QTY_CONFIRMED])  > 0
    UNION
    SELECT
        -1 [DocEntry]
       ,[wms].[OP_WMS_GET_STRING_FROM_CHAR]([D].[MATERIAL_ID], '/') [ItemCode]
	    ,SUM([D].[QTY_CONFIRMED])[Quantity]
       ,-1 [LineNum]
       ,'22' [ObjType]
       ,-1 [DocEntryErp]
       ,CASE WHEN @SERIE = @COST_SERIE THEN @COST_WAREHOUSE_PARAMETER
             ELSE @WAREHOUSE_CODE_PARAMETER
        END AS [WarehouseCode]
        FROM
        [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D]
    INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H] ON [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
    INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [H].[TASK_ID] = [T].[SERIAL_NUMBER]
    WHERE
        [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = @RECEPTION_HEADER
		AND [D].[LINE_NUM]  = -1 
    GROUP BY
        [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
       ,[H].[DOC_ID]
       ,[D].[MATERIAL_ID]
       ,[D].[LINE_NUM]
       ,[D].[ERP_OBJECT_TYPE]
	   HAVING   SUM([D].[QTY_CONFIRMED])  > 0 ;
		 



END;