-- =============================================
-- Autor:				        hector.gonzalez
-- Fecha de Creacion: 	2017-01-13 TeamErgon Sprint 1
-- Description:			    SP que obtiene el detalle de recepciones de una fuente externa

-- Modificación: pablo.aguilar
-- Fecha de Creacion: 	2017-02-13 Team ERGON - Sprint ERGON III
-- Description:	 se agrega open quantity y se realiza manejo y comparación de cantidades con recepciones reales. 

-- Modificación: pablo.aguilar
-- Fecha de Modificación: 2017-07-11 Nexus@AgeOfEmpires
-- Description:	 Se agrega que la cantidad ya sea mayor ó = 0 retorne is_assigned con valor 0 

-- Modificacion 09-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
					-- alberto.ruiz
					-- Agregan campos por intercompany

-- Modificacion 10/11/2017 @ NEXUS-Team Sprint ewms
					-- rodrigo.gomez
					-- Se agrega la validacion para que solo revise los documentos que no estan cancelados

-- Modificacion 12-Jan-18 @ Nexus Team Sprint Ransey
					-- alberto.ruiz
					-- Se agrega columna [ERP_WAREHOUSE_CODE]

-- Modificacion 1-Jun-18 @ GForce Team Sprint Dinosaurio
					-- marvin.solares
					-- Se agregan columnas [UNIT] y [UNIT_DESCRIPTION]

-- Modificacion 8-Jun-18 @ GForce Team Sprint Dinosaurio
					-- marvin.garcia
					-- Se valida que el duenio del material corresponda al cliente especificado en parametro (@CLIENT_CODE)

-- Modificacion 10-Jul-19 @  G-FORCE Team Sprint Dublin 
					-- pablo.aguilar
					-- Se modificá para utilizar docnum, doc_entry y erp_doc como varchar
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_ERP_RECEPTION_DOCUMENT_DETAIL] 
					@DOC_ID = '4162|4163|4165|4166|4173|4174|4175|4176|4177|4179|4182|4188|4189|4193|4194|4195|4197|4198|4199|4200|4201|4203|4208|4218|4219|4220|4221|4223|4229|4231|4234|4238|4239|4240|4248', -- varchar(max)
					@EXTERNAL_SOURCE_ID = 1, -- int
					@CLIENT_CODE = 'me_llega' -- varchar(25)

*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_ERP_RECEPTION_DOCUMENT_DETAIL] (
		@DOC_ID VARCHAR(MAX)
		,@EXTERNAL_SOURCE_ID INT
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
		,@INTERFACE_DATA_BASE_NAME VARCHAR(50)
		,@QUERY NVARCHAR(MAX)
		,@DELIMITER CHAR(1) = '|'
		,@COMPANY_NAME VARCHAR(50);

	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene la fuente externa
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@SOURCE_NAME = [ES].[SOURCE_NAME]
			,@DATA_BASE_NAME = [ES].[DATA_BASE_NAME]
			,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
			,@INTERFACE_DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
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
		
		SELECT
			[RDH].[DOC_ID]
			,[RDH].[OWNER]
			,[RDD].[MATERIAL_ID]
			,SUM([RDD].[QTY_CONFIRMED]) [RECEPTION_QTY]
			,MAX([RDD].[QTY]) [DOCUMENT_QTY]
			,[RDD].[UNIT]
			,[RDD].[LINE_NUM]
		INTO
			[#RECEPTION_DOCUMENTS]
		FROM
			[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
		INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RDD] ON [RDD].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
		INNER JOIN [wms].[OP_WMS_FN_SPLIT](@DOC_ID,
											@DELIMITER) [DOCS] ON [DOCS].[VALUE] COLLATE DATABASE_DEFAULT = [RDH].[DOC_ID] COLLATE DATABASE_DEFAULT
		WHERE
			[RDD].[IS_CONFIRMED] = 1
			AND [RDH].[SOURCE] = 'PURCHASE_ORDER'
			AND [RDH].[IS_VOID] = 0
		GROUP BY
			[RDH].[DOC_ID]
			,[RDH].[OWNER]
			,[RDD].[MATERIAL_ID]
			,[RDD].[LINE_NUM]
           --,[RDD].[QTY_CONFIRMED]
			,[RDD].[UNIT];
			

		--
		MERGE [#RECEPTION_DOCUMENTS] AS [RD]
		USING
			(SELECT
					[RH].[DOC_ID]
					,[RH].[OWNER]
					,[RDD].[MATERIAL_ID]
					,[RDD].[UNIT]
					,[RDD].[LINE_NUM]
					,MAX([RDD].[QTY]) [QTY]
				FROM
					[wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH] --ON [RH].[DOC_ID] = [RP].[DOC_ID] AND [RH].[OWNER] = [RP].[OWNER]
				INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RDD] ON [RDD].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [RH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
				INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON [TL].[SERIAL_NUMBER] = [RH].[TASK_ID]
				INNER JOIN [wms].[OP_WMS_FN_SPLIT](@DOC_ID COLLATE DATABASE_DEFAULT,
											@DELIMITER) [DOCS] ON [DOCS].[VALUE] = [RH].[DOC_ID]
				WHERE
					[RH].[IS_AUTHORIZED] = 0
					AND [TL].[IS_CANCELED] = 0
				GROUP BY
					[RH].[DOC_ID]
					,[RH].[OWNER]
					,[RDD].[MATERIAL_ID]
					,[RDD].[UNIT]
					,[RDD].[LINE_NUM]) AS [DET]
		ON [DET].[DOC_ID] = [RD].[DOC_ID]
			AND [DET].[OWNER] COLLATE DATABASE_DEFAULT = [RD].[OWNER] COLLATE DATABASE_DEFAULT
			AND [DET].[MATERIAL_ID] COLLATE DATABASE_DEFAULT = [RD].[MATERIAL_ID] COLLATE DATABASE_DEFAULT
			AND [DET].[UNIT] COLLATE DATABASE_DEFAULT = [RD].[UNIT] COLLATE DATABASE_DEFAULT
			AND [DET].[LINE_NUM] = [RD].[LINE_NUM]
		WHEN MATCHED THEN
			UPDATE SET
					[RD].[RECEPTION_QTY] = [DET].[QTY]
		WHEN NOT MATCHED THEN
			INSERT
					(
						[DOC_ID]
						,[OWNER]
						,[MATERIAL_ID]
						,[RECEPTION_QTY]
						,[DOCUMENT_QTY]
						,[UNIT]
						,[LINE_NUM]
					)
			VALUES	(
						[DET].[DOC_ID]
						,[DET].[OWNER]
						,[DET].[MATERIAL_ID]
						,[DET].[QTY]
						,[DET].[QTY]
						,[DET].[UNIT]
						,[DET].[LINE_NUM]
					);
			
		-- ------------------------------------------------------------------------------------
		-- Obtiene el detalle de la ordenes de venta de la fuente externa
		-- ------------------------------------------------------------------------------------
		SELECT
			@QUERY = N'SELECT DISTINCT
				CAST(  evrdd.SAP_RECEPTION_ID  AS VARCHAR) SAP_RECEPTION_ID
				,CAST(  evrdd.ERP_DOC  AS VARCHAR) ERP_DOC
				,evrdd.PROVIDER_ID
				,evrdd.PROVIDER_NAME
				,CAST([evrdd].[OWNER_SKU] +'
			+ '''/'' + evrdd.[SKU] COLLATE DATABASE_DEFAULT AS VARCHAR(50)) [SKU] 
				,[M].[MATERIAL_NAME] SKU_DESCRIPTION
				,CAST(ISNULL([R].[DOCUMENT_QTY], evrdd.QTY) AS NUMERIC(18,6)) AS [TOTAL_QUANTITY]
				,CAST( CASE 
					WHEN [R].[DOCUMENT_QTY] IS NULL  THEN evrdd.QTY 
					ELSE [R].[DOCUMENT_QTY] - [R].[RECEPTION_QTY]
					END AS NUMERIC(18,6))  [QTY]
				,CAST(evrdd.QTY AS NUMERIC(18,6)) [OPEN_QUANTITY]
				,CAST(ISNULL([R].[RECEPTION_QTY], 0) AS NUMERIC(18,6)) RECEPTION_QUANTITY
				,CAST(evrdd.LINE_NUM AS INT) [LINE_NUM]
				,CAST(evrdd.COMMENTS AS  VARCHAR(250)) [COMMENTS]
				,CAST(evrdd.OBJECT_TYPE AS INT) [OBJECT_TYPE]
				,CAST([M].[BARCODE_ID] AS VARCHAR(50)) [BARCODE_ID]
				,CAST([M].[ALTERNATE_BARCODE] AS VARCHAR(50)) [ALTERNATE_BARCODE]
				,' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
			+ ' [EXTERNAL_SOURCE_ID]
				,''' + @SOURCE_NAME
			+ ''' [SOURCE_NAME]
				, CASE             
					WHEN  [R].[DOCUMENT_QTY] IS NULL THEN 0
						WHEN ISNULL([R].[RECEPTION_QTY],0) >= 0 AND [R].[RECEPTION_QTY] < ISNULL([R].[DOCUMENT_QTY], evrdd.QTY)  THEN 0            
					ELSE 1
					END IS_ASSIGNED
				, CASE 
					WHEN [R].[RECEPTION_QTY] IS NOT NULL AND ISNULL([R].[RECEPTION_QTY], 0) < ISNULL([R].[DOCUMENT_QTY], evrdd.QTY)  THEN 1
					ELSE 0
					END  IS_MISSING
				,[evrdd].[MASTER_ID_SKU]
				,[evrdd].[OWNER_SKU]
				,[evrdd].[OWNER]
				,CAST(''PURCHASE_ORDER'' AS VARCHAR(50)) [SOURCE]
				,CAST(0 AS INT) [IS_VOID]
				,[evrdd].[ERP_WAREHOUSE_CODE]
				,[evrdd].[UNIT] [UNIT]
				,[evrdd].[UNIT_DESCRIPTION] [UNIT_DESCRIPTION]
		FROM ' + @INTERFACE_DATA_BASE_NAME + '.'
			+ @SCHEMA_NAME
			+ '.[ERP_VIEW_RECEPTION_DOCUMENT_DETAIL] evrdd
        INNER JOIN [wms].[OP_WMS_FN_SPLIT](''' + @DOC_ID COLLATE DATABASE_DEFAULT 
			+ ''', ''' + @DELIMITER
			+ ''') SO ON SO.VALUE COLLATE DATABASE_DEFAULT = evrdd.SAP_RECEPTION_ID COLLATE DATABASE_DEFAULT
		INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ( [M].[CLIENT_OWNER] COLLATE DATABASE_DEFAULT = [evrdd].[OWNER_SKU] COLLATE DATABASE_DEFAULT AND [evrdd].[OWNER_SKU] COLLATE DATABASE_DEFAULT +'
			+ '''/'' + evrdd.[SKU] COLLATE DATABASE_DEFAULT = [M].[MATERIAL_ID] COLLATE DATABASE_DEFAULT)
		LEFT JOIN #RECEPTION_DOCUMENTS [R] ON ( [R].[DOC_ID] COLLATE DATABASE_DEFAULT = evrdd.SAP_RECEPTION_ID AND evrdd.LINE_NUM = [R].LINE_NUM AND  [M].[MATERIAL_ID] COLLATE DATABASE_DEFAULT  = [R].[MATERIAL_ID] COLLATE DATABASE_DEFAULT 
													AND [R].[UNIT] COLLATE DATABASE_DEFAULT  = [evrdd].[UNIT] COLLATE DATABASE_DEFAULT )
		WHERE [evrdd].[OWNER] COLLATE DATABASE_DEFAULT  = ''' + @CLIENT_CODE COLLATE DATABASE_DEFAULT + '''
		';
		--
		PRINT '--> @QUERY: ' + @QUERY;
		--
		EXEC (@QUERY);
	END TRY
	BEGIN CATCH
		SELECT
			-1 AS [Resultado]
			,ERROR_MESSAGE() [Mensaje]
			,@@ERROR [Codigo];
	END CATCH;
END;