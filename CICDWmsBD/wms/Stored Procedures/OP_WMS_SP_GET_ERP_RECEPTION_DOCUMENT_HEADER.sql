-- =============================================
-- Autor:	pablo.aguilar
-- Fecha de Creacion: 	2017-01-13 Team ERGON - Sprint ERGON 1
-- Description:	 SP que consulta de fuente externas las documentos de recepcion como orden de compra para realizar recepciones

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-02-13 Team ERGON - Sprint ERGON III
-- Description:	 Se agrega modificación para obtener unicamente recepciones con faltantes. 

-- Modificacion 09-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- alberto.ruiz
-- Agregan campos por intercompany

-- Modificacion 15-Nov-17 @ Nexus Team Sprint F-Zero
					-- alberto.ruiz
					-- Se agrega else en case de @ONLY_ROWS_WITH_SPECIFIC_DATA_ON_COLUMN

-- Modificacion 10-Jul-19 @  G-FORCE Team Sprint Dublin 
					-- pablo.aguilar
					-- Se modificá para utilizar docnum, doc_entry y erp_doc como varchar

-- Modificacion:	henry.rodriguez
-- Fecha:			16-Agosto-2019 G-Force@FlorencioVarela
-- Descripcion:		Se convierte SAP_REFERENCE a varchar ya que doc_num es un varchar.

/*
-- Ejemplo de Ejecucion:
			EXEC [wms].[OP_WMS_SP_GET_ERP_RECEPTION_DOCUMENT_HEADER] 
				@INITIAL_DATE = '2016-01-13 00:00:00.000'
                ,@END_DATE = '2017-08-13 23:59:59.000'
                ,@EXTERNAL_SOURCE_ID = 1
                ,@HAS_MISSING = 0
				,@CLIENT_CODE = 'arium'
			--
			EXEC [wms].[OP_WMS_SP_GET_ERP_RECEPTION_DOCUMENT_HEADER] 
				@INITIAL_DATE = '2016-01-13 00:00:00.000'
                ,@END_DATE = '2017-08-13 23:59:59.000'
                ,@EXTERNAL_SOURCE_ID = 1
                ,@HAS_MISSING = 1
				,@CLIENT_CODE = 'arium'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_ERP_RECEPTION_DOCUMENT_HEADER] (
		@INITIAL_DATE DATETIME
		,@END_DATE DATETIME
		,@EXTERNAL_SOURCE_ID INT
		,@HAS_MISSING INT
		,@CLIENT_CODE VARCHAR(25)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE
		@SOURCE_NAME VARCHAR(50)
		,@DATA_BASE_NAME VARCHAR(50)
		,@SCHEMA_NAME VARCHAR(50)
		,@COMPANY_NAME VARCHAR(50)
		,@QUERY NVARCHAR(MAX)
		,@ONLY_ROWS_WITH_SPECIFIC_DATA_ON_COLUMN VARCHAR(1) = '0';

	-- ------------------------------------------------------------------------------------
	-- Obtiene la configuracion del cliente 
	-- ------------------------------------------------------------------------------------
	SELECT
		@ONLY_ROWS_WITH_SPECIFIC_DATA_ON_COLUMN = ISNULL([P].[VALUE],
											'0')
	FROM
		[wms].[OP_WMS_PARAMETER] [P]
	WHERE
		[P].[GROUP_ID] = 'CLIENT_CONFIGURATIONS'
		AND [P].[PARAMETER_ID] = 'ONLY_SALES_ORDERS_WITH_SPECIFIC_DATA_ON_COLUMN';

	-- ------------------------------------------------------------------------------------
	-- Obtiene la fuente externa
	-- ------------------------------------------------------------------------------------
	SELECT TOP 1
		@SOURCE_NAME = [ES].[SOURCE_NAME]
		,@DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
		,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
		,@COMPANY_NAME = [C].[COMPANY_NAME]
	FROM
		[wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
	INNER JOIN [wms].[OP_WMS_COMPANY] [C] ON ([C].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID])
	WHERE
		[ES].[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID
		AND [C].[CLIENT_CODE] = @CLIENT_CODE
		AND [C].[COMPANY_ID] > 0;
	--
	PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
	PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME;
	PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;
	PRINT '----> @COMPANY_NAME: ' + @COMPANY_NAME;

	-- ------------------------------------------------------------------------------------
	-- Obtiene el detalle de la ordenes de venta de la fuente externa
	-- ------------------------------------------------------------------------------------
	SELECT
		@QUERY = N'  SELECT 
			CAST( [R].[SAP_REFERENCE] as varchar) SAP_REFERENCE
			,CAST ([R].DocNum  as varchar) [DOC_NUM]
			,MAX([R].[DOC_TYPE]) [DOC_TYPE]
			,MAX([R].[DESCRIPTION_TYPE]) [DESCRIPTION_TYPE]
			,MAX([R].[CUSTOMER_ID]) [SUPPLIER_ID]
			,MAX([R].[CUSTOMER_NAME]) [SUPPLIER_NAME]
			,MAX([R].[DOC_DATE]) [DOC_DATE]
			,CASE 
				WHEN MAX(D.[IS_COMPLETE])  IS NULL THEN 0 
				ELSE 1 END HAS_MISSING
			,MAX([R].[MASTER_ID_PROVIDER]) [MASTER_ID_PROVIDER]
			,MAX([R].[OWNER_PROVIDER]) [OWNER_PROVIDER]
			,MAX([R].[OWNER]) [OWNER]
		FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME
		+ '.[ERP_VIEW_RECEPTION_DOCUMENT] [R] 
		LEFT JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [D] ON ([D].[DOC_ID] = CAST([R].[SAP_REFERENCE] AS VARCHAR(50)) COLLATE DATABASE_DEFAULT) 
		WHERE [R].[DOC_DATE] BETWEEN  '''
		+ CONVERT(VARCHAR, @INITIAL_DATE, 121) + ''' AND '''
		+ CONVERT(VARCHAR, @END_DATE, 121) + ''' 
			' + CASE @ONLY_ROWS_WITH_SPECIFIC_DATA_ON_COLUMN
					WHEN '1' THEN ' --AND [R].Series = 12 '
					ELSE ' '
				END
		+ '
		GROUP BY 
			[R].[SAP_REFERENCE]
			,[R].DocNum 
		HAVING MAX(ISNULL(D.[IS_COMPLETE],0)) = 0 AND MAX([R].[OWNER]) = '''
		+ @CLIENT_CODE + ''''
		+ CASE	WHEN @HAS_MISSING = 1
				THEN '  AND MAX(D.[IS_COMPLETE])  IS NOT NULL ' 
				ELSE ''
			END;

	--
	PRINT '--> @QUERY: ' + @QUERY;
	--
	EXEC (@QUERY);
END;