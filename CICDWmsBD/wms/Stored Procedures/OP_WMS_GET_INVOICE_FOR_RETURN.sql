-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	10/11/2017 @ NEXUS-Team Sprint ewms 
-- Description:			Obtiene una factura para devolucion

-- Modificacion 15-Nov-17 @ Nexus Team Sprint F-Zero
					-- alberto.ruiz
					-- Se agrego el campo de MATERIAL_OWNER a la tabla [#INVOICE]

-- Modificacion 1/29/2018 @ Reborn-Team Sprint Trotzdem
					-- diego.as
					-- Se agrega envio de parametro @USE_SUBSIDIARY

-- Modificacion 06-Apr-18 @ Nexus Team Sprint Búho
					-- pablo.aguilar
					-- Se agrega el manejo de centro de costo y manejo de devoluciones parciales. 

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].OP_WMS_GET_INVOICE_FOR_RETURN @DOC_NUM='00000101-00085059', @OWNER=N'ALZA', @EXTERNAL_SOURCE_ID = 1
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_GET_INVOICE_FOR_RETURN]
    (
     @OWNER VARCHAR(50)
    ,@DOC_NUM VARCHAR(50)
    ,@EXTERNAL_SOURCE_ID INT
	)
AS
BEGIN
    SET NOCOUNT ON;
	--
    DECLARE @RECEPTION_DOCUMENTS TABLE
        (
         [DOC_ID] VARCHAR(50)
        ,[MATERIAL_ID] VARCHAR(50)
        ,[RECEPTION_QTY] NUMERIC(18, 6)
        ,[DOCUMENT_QTY] NUMERIC(18, 6)
        ,[UNIT] VARCHAR(100)
        ,[LINE_NUM] INT
        ,[IS_AUTHORIZED] INT
        );
--
    CREATE TABLE [#INVOICE]
        (
         [DOC_ENTRY] VARCHAR(50)
        ,[DOC_NUM] VARCHAR(50)
        ,[CLIENT_CODE] VARCHAR(50)
        ,[CLIENT_NAME] VARCHAR(150)
        ,[COMMENTS] VARCHAR(800)
        ,[DOC_DATE] DATETIME
        ,[DELIVERY_DATE] DATETIME
        ,[STATUS] CHAR(2)
        ,[CODE_SELLER] INT
        ,[TOTAL_AMOUNT] DECIMAL(18, 6)
        ,[LINE_NUM] INT
        ,[MATERIAL_ID] VARCHAR(50)
        ,[MATERIAL_NAME] VARCHAR(150)
        ,[QTY] DECIMAL(18, 6)
        ,[OPENQTY] DECIMAL(18, 6)
        ,[PRICE] DECIMAL(18, 6)
        ,[DISCOUNT_PERCENT] DECIMAL(18, 6)
        ,[TOTAL_LINE] DECIMAL(18, 6)
        ,[ERP_WAREHOUSE_CODE] VARCHAR(50)
        ,[MATERIAL_OWNER] VARCHAR(50)
        ,[ADDRESS] VARCHAR(250)
        ,[DOC_CURRENCY] NVARCHAR(3)
        ,[DOC_RATE] DECIMAL(18, 6)
        ,[SUBSIDIARY] VARCHAR(25)
        ,[DET_CURRENCY] NVARCHAR(3)
        ,[DET_RATE] DECIMAL(18, 6)
        ,[DET_TAX_CODE] NVARCHAR(8)
        ,[DET_VAT_PERCENT] DECIMAL(18, 6)
        ,[COST_CENTER] VARCHAR(25) NULL
        ,[UNIT] VARCHAR(100) NULL
        );
	--
    DECLARE
        @SOURCE_NAME VARCHAR(50)
       ,@DATA_BASE_NAME VARCHAR(50)
       ,@SCHEMA_NAME VARCHAR(50)
       ,@INTERFACE_DATA_BASE_NAME VARCHAR(50)
       ,@ERP_DATA_BASE_NAME VARCHAR(50)
       ,@QUERY NVARCHAR(MAX)
       ,@DELIMITER CHAR(1) = '|'
       ,@COMPANY_NAME VARCHAR(50)
       ,@USE_SUBSIDIARY VARCHAR(MAX);

    BEGIN TRY
			
		-- ------------------------------------------------------------------------------------
		-- Obtiene la fuente externa
		-- ------------------------------------------------------------------------------------
        SELECT TOP 1
            @SOURCE_NAME = [ES].[SOURCE_NAME]
           ,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
           ,@INTERFACE_DATA_BASE_NAME = [ES].[INTERFACE_DATA_BASE_NAME]
           ,@COMPANY_NAME = [C].[COMPANY_NAME]
           ,@ERP_DATA_BASE_NAME = [C].[ERP_DATABASE]
        FROM
            [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
        INNER JOIN [wms].[OP_WMS_COMPANY] [C] ON ([C].[EXTERNAL_SOURCE_ID] = [ES].[EXTERNAL_SOURCE_ID])
        WHERE
            [ES].[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID
            AND [C].[CLIENT_CODE] = @OWNER
            AND [C].[COMPANY_ID] > 0;
		--
        PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
        PRINT '----> @INTERFACE_DATA_BASE_NAME: ' + @INTERFACE_DATA_BASE_NAME;
        PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;
        PRINT '----> @ERP_DATA_BASE_NAME: ' + @ERP_DATA_BASE_NAME;
        PRINT '----> @COMPANY_NAME: ' + @COMPANY_NAME;
		-- ------------------------------------------------------------------------------------
		-- Obtiene las recepciones abiertas para las facturas
		-- ------------------------------------------------------------------------------------
        INSERT  INTO @RECEPTION_DOCUMENTS
                (
                 [DOC_ID]
                ,[MATERIAL_ID]
                ,[RECEPTION_QTY]
                ,[DOCUMENT_QTY]
                ,[UNIT]
                ,[LINE_NUM]
                ,[IS_AUTHORIZED]
            	)
        SELECT
            [RDH].[DOC_ENTRY]
           ,[RDD].[MATERIAL_ID]
           ,SUM([RDD].[QTY_CONFIRMED]) [RECEPTION_QTY]
           ,MAX([RDD].[QTY]) [DOCUMENT_QTY]
           ,[RDD].[UNIT]
           ,[RDD].[LINE_NUM]
           ,[RDH].[IS_AUTHORIZED]
        FROM
            [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RDH]
        INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RDD] ON [RDD].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [RDH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
        WHERE
            [RDD].[IS_CONFIRMED] = 1
            AND [RDH].[SOURCE] = 'INVOICE'
            AND [RDH].[IS_VOID] = 0
            AND [RDH].[DOC_NUM] = @DOC_NUM
        GROUP BY
            [RDH].[DOC_ENTRY]
           ,[RDH].[OWNER]
           ,[RDD].[MATERIAL_ID]
           ,[RDD].[LINE_NUM]
           ,[RDD].[UNIT]
           ,[RDH].[IS_AUTHORIZED];

        MERGE @RECEPTION_DOCUMENTS AS [RD]
        USING
            (SELECT
                [RH].[DOC_ENTRY]
               ,[RH].[OWNER]
               ,[RDD].[MATERIAL_ID]
               ,[RDD].[UNIT]
               ,[RDD].[LINE_NUM]
               ,MAX([RDD].[QTY]) [QTY]
             FROM
                [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RH] --ON [RH].[DOC_ID] = [RP].[DOC_ID] AND [RH].[OWNER] = [RP].[OWNER]
             INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [RDD] ON [RDD].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [RH].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
             INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON [TL].[SERIAL_NUMBER] = [RH].[TASK_ID]
             WHERE
                [RH].[IS_AUTHORIZED] = 0
                AND [TL].[IS_CANCELED] = 0
                AND [RH].[SOURCE] = 'INVOICE'
                AND [RH].[DOC_NUM] = @DOC_NUM
             GROUP BY
                [RH].[DOC_ENTRY]
               ,[RH].[OWNER]
               ,[RDD].[MATERIAL_ID]
               ,[RDD].[UNIT]
               ,[RDD].[LINE_NUM]
            ) AS [DET]
        ON [DET].[DOC_ENTRY] = [RD].[DOC_ID]
            AND [DET].[MATERIAL_ID] = [RD].[MATERIAL_ID]
            AND [DET].[UNIT] = [RD].[UNIT]
            AND [DET].[LINE_NUM] = [RD].[LINE_NUM]
        WHEN MATCHED THEN
            UPDATE SET
                    [RD].[RECEPTION_QTY] = [DET].[QTY]
        WHEN NOT MATCHED THEN
            INSERT
                   (
                    [DOC_ID]
                   ,[MATERIAL_ID]
                   ,[RECEPTION_QTY]
                   ,[DOCUMENT_QTY]
                   ,[UNIT]
                   ,[LINE_NUM]
				   ,[IS_AUTHORIZED]
                   )
            VALUES (
                    [DET].[DOC_ENTRY]
                   ,[DET].[MATERIAL_ID]
                   ,[DET].[QTY]
                   ,[DET].[QTY]
                   ,[DET].[UNIT]
                   ,[DET].[LINE_NUM]
				   ,0
                   );

		-- ------------------------------------------------------------------------------------
		-- Se verifica el valor del parametro USE_SUBSIDIARY de la recepcion ERP
		-- ------------------------------------------------------------------------------------ 
        SELECT
            @USE_SUBSIDIARY = ISNULL([T].[VALUE], '0')
        FROM
            [wms].[OP_WMS_FN_GET_PARAMETER_BY_GROUP]('ERP_RECEPTION') AS [T]
        WHERE
            [T].[PARAMETER_ID] = 'USE_SUBSIDIARY'
            AND [T].[IDENTITY] > 0;

		-- ------------------------------------------------------------------------------------
		-- Ejecuta el SP SWIFT_SP_GET_ERP_INVOICE_BY_DOC_NUM_FOR_RETURN_IN_WMS para obtener la factura
		-- ------------------------------------------------------------------------------------
        SELECT
            @QUERY = '
				INSERT INTO #INVOICE
				EXEC ' + @INTERFACE_DATA_BASE_NAME + '.' + @SCHEMA_NAME
            + '.[SWIFT_SP_GET_ERP_INVOICE_BY_DOC_NUM_FOR_RETURN_IN_WMS]
						@DATABASE = ''' + CAST(@ERP_DATA_BASE_NAME AS VARCHAR)
            + '''
						,@DOC_NUM = ''' + CAST(@DOC_NUM AS VARCHAR) + '''
						,@USE_SUBSIDIARY = ' + @USE_SUBSIDIARY + '
			';
        PRINT '@QUERY -> ' + @QUERY;
		--
        EXEC (@QUERY);
		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado final
		-- ------------------------------------------------------------------------------------
        SELECT
            CAST([I].[DOC_NUM] AS VARCHAR) [SAP_RECEPTION_ID]
           ,[I].[DOC_NUM] [ERP_DOC]
           ,[I].[CLIENT_CODE] [PROVIDER_ID]
           ,[I].[CLIENT_NAME] [PROVIDER_NAME]
           ,CAST([I].[MATERIAL_OWNER] + '/' + [I].[MATERIAL_ID] AS VARCHAR(50)) [SKU]
           ,[I].[MATERIAL_NAME] [SKU_DESCRIPTION]
           ,CAST(ISNULL([R].[DOCUMENT_QTY], [I].[OPENQTY]) AS NUMERIC(18, 6)) [TOTAL_QUANTITY]
           ,CAST(CASE WHEN [R].[DOCUMENT_QTY] IS NULL THEN [I].[QTY]
                      ELSE [R].[DOCUMENT_QTY] - [R].[RECEPTION_QTY]
                 END AS NUMERIC(18, 6)) [QTY]
           ,[I].[OPENQTY] [OPEN_QUANTITY]
           ,CAST(ISNULL([R].[RECEPTION_QTY], 0) AS NUMERIC(18, 6)) [RECEPTION_QUANTITY]
           ,[I].[LINE_NUM]
           ,[I].[COMMENTS]
           ,CAST(13 AS INT) [OBJECT_TYPE]
           ,[M].[BARCODE_ID]
           ,[M].[ALTERNATE_BARCODE]
           ,CAST(@EXTERNAL_SOURCE_ID AS INT) [EXTERNAL_SOURCE_ID]
           ,CAST(@SOURCE_NAME AS VARCHAR(50)) [SOURCE_NAME]
           ,CAST(CASE WHEN [R].[DOCUMENT_QTY] IS NULL THEN 0
                      WHEN [IS_AUTHORIZED] = 0 THEN 1
                      WHEN ISNULL([R].[RECEPTION_QTY], 0) >= 0
                           AND [R].[RECEPTION_QTY] < ISNULL([R].[DOCUMENT_QTY],
                                                            [I].[OPENQTY])
                      THEN 0
                      ELSE 1
                 END AS INT) [IS_ASSIGNED]
           ,CAST(CASE WHEN [IS_AUTHORIZED] = 0 THEN 0
                      WHEN [R].[RECEPTION_QTY] IS NOT NULL
                           AND ISNULL([R].[RECEPTION_QTY], 0) < ISNULL([R].[DOCUMENT_QTY],
                                                              [I].[OPENQTY])
                      THEN 1
                      ELSE 0
                 END AS INT) [IS_MISSING]
           ,[I].[MATERIAL_ID] [MASTER_ID_SKU]
           ,CAST(@OWNER AS VARCHAR(50)) [OWNER_SKU]
           ,CAST(@OWNER AS VARCHAR(50)) [OWNER]
           ,CAST('INVOICE' AS VARCHAR(50)) [SOURCE]
           ,[I].[ERP_WAREHOUSE_CODE]
           ,[I].[DOC_ENTRY]
           ,[I].[ADDRESS]
           ,[I].[DOC_CURRENCY]
           ,[I].[DOC_RATE]
           ,[I].[SUBSIDIARY]
           ,[I].[DET_CURRENCY]
           ,[I].[DET_RATE]
           ,[I].[DET_TAX_CODE]
           ,[I].[DET_VAT_PERCENT]
           ,[I].[DISCOUNT_PERCENT]
           ,[I].[PRICE]
           ,[I].[COST_CENTER]
           ,[I].[UNIT] [UNIT]
           ,ISNULL([UMM].[MEASUREMENT_UNIT], 'Unidad Base') + ' 1x'
            + CAST(ISNULL([UMM].[QTY], 1) AS VARCHAR) [UNIT_DESCRIPTION]
        FROM
            [#INVOICE] [I]
        INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([I].[MATERIAL_OWNER]
                                                        + '/'
                                                        + [I].[MATERIAL_ID] COLLATE DATABASE_DEFAULT = [M].[MATERIAL_ID] COLLATE DATABASE_DEFAULT)
        LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [UMM].[MATERIAL_ID]  COLLATE DATABASE_DEFAULT  = [M].[MATERIAL_ID]  COLLATE DATABASE_DEFAULT 
                                                              AND [I].[UNIT] COLLATE DATABASE_DEFAULT = [UMM].[MEASUREMENT_UNIT] COLLATE DATABASE_DEFAULT
        LEFT JOIN @RECEPTION_DOCUMENTS [R] ON (
                                               [R].[DOC_ID]  COLLATE DATABASE_DEFAULT  = [I].[DOC_ENTRY]  COLLATE DATABASE_DEFAULT 
												AND [M].[MATERIAL_ID] = [R].[MATERIAL_ID]
												AND [I].[LINE_NUM] = [R].[LINE_NUM]
                                              );

									
    END TRY
    BEGIN CATCH
        SELECT
            -1 AS [Resultado]
           ,ERROR_MESSAGE() [Mensaje]
           ,@@ERROR [Codigo];
    END CATCH;	
END;