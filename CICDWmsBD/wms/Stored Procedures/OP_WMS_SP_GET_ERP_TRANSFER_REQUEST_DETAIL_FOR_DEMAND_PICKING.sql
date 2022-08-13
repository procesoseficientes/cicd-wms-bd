-- =============================================
-- Autor:					alberto.ruiz
-- Fecha de Creacion: 		17-Aug-17 @ Nexus Team Sprint Banjo-Kazooie
-- Description:			    SP que obtiene el detalle de las solicitudes de transferencia solicitadas del ERP

-- Modificacion 10/4/2017 @ NEXUS-Team Sprint ewms
					-- rodrigo.gomez
					-- Se agrega el cambio para la lectura de external_source desde erp

-- Modificacion:			henry.rodriguez
-- Fecha:					08-Agosto-2019 G-Force@Estambul
-- Descripcion:				Se agregan cambios aplicados de wms.

-- Autor:				marvin.solares
-- Creacion: 			12/8/2019 G-Force@FlorencioVarela
-- Bug 31163: Duplicidad en lineas de traslado de bodegas
-- Description:	       se modifica tipo de datos para columnas docentry y docnum
/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GET_ERP_TRANSFER_REQUEST_DETAIL_FOR_DEMAND_PICKING]
					@XML = N'<?xml version="1.0"?>
					<ArrayOfDocumento>
						<Documento>
							<ExternalSourceId>1</ExternalSourceId>
							<DocumentId>1576</DocumentId>
							<Owner>Arium</Owner>
						</Documento>
						<Documento>
							<ExternalSourceId>1</ExternalSourceId>
							<DocumentId>1614</DocumentId>
							<Owner>Arium</Owner>
						</Documento>
						<Documento>
							<ExternalSourceId>4</ExternalSourceId>
							<DocumentId>1</DocumentId>
							<Owner>Arium</Owner>
						</Documento>
						<Documento>
							<ExternalSourceId>4</ExternalSourceId>
							<DocumentId>2</DocumentId>
							<Owner>Arium</Owner>
						</Documento> 
					</ArrayOfDocumento>'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GET_ERP_TRANSFER_REQUEST_DETAIL_FOR_DEMAND_PICKING] ( @XML XML )
AS
    BEGIN
        SET NOCOUNT ON;
	--
        DECLARE @SOURCE_NAME VARCHAR(50) ,
            @DATA_BASE_NAME VARCHAR(50) ,
            @SCHEMA_NAME VARCHAR(50) ,
            @QUERY NVARCHAR(MAX) ,
            @SALE_ORDER_ID VARCHAR(50)  ,
            @EXTERNAL_SOURCE_ID INT
		,@DEFAULT_STATUS VARCHAR(25);
	--
        CREATE TABLE [#PICKING_DOCUMENT]
            (
              [EXTERNAL_SOURCE_ID] INT ,
              [PICKING_DOCUMENT_ID] VARCHAR(50) COLLATE DATABASE_DEFAULT ,
              [OWNER] VARCHAR(50) ,
              [SOURCE_NAME] VARCHAR(50) ,
              [DATA_BASE_NAME] VARCHAR(50) ,
              [SCHEMA_NAME] VARCHAR(50) ,
              --PRIMARY KEY
              --  ( [EXTERNAL_SOURCE_ID], [PICKING_DOCUMENT_ID], [OWNER] )
            );
	--
        CREATE TABLE [#PICKING_DOCUMENT_DETAIL]
            (
              [SALES_ORDER_ID] VARCHAR(50) COLLATE DATABASE_DEFAULT ,
              [SKU] VARCHAR(200) ,
              [LINE_SEQ] INT NULL ,
              [QTY] DECIMAL(18, 2) NULL ,
              [QTY_PENDING] DECIMAL(18, 2) NULL ,
              [QTY_ORIGINAL] DECIMAL(18, 2) NULL ,
              [PRICE] MONEY NULL ,
              [DISCOUNT] MONEY NULL ,
              [TOTAL_LINE] MONEY NULL ,
              [POSTED_DATETIME] DATETIME ,
              [SERIE] VARCHAR(50) ,
              [SERIE_2] VARCHAR(50) ,
              [REQUERIES_SERIE] INT ,
              [COMBO_REFERENCE] VARCHAR(50) ,
              [PARENT_SEQ] INT ,
              [IS_ACTIVE_ROUTE] INT ,
              [CODE_PACK_UNIT] VARCHAR(50) ,
              [IS_BONUS] INT ,
              [DESCRIPTION_SKU] VARCHAR(200) ,
              [BARCODE_ID] VARCHAR(25) ,
              [ALTERNATE_BARCODE] VARCHAR(25) ,
              [EXTERNAL_SOURCE_ID] INT ,
              [SOURCE_NAME] VARCHAR(50) ,
              [ERP_OBJECT_TYPE] INT ,
              [IS_MASTER_PACK] INT ,
              [MATERIAL_OWNER] VARCHAR(50) ,
              [MASTER_ID_MATERIAL] VARCHAR(50) ,
              [SOURCE] VARCHAR(50) ,
              [USE_PICKING_LINE] INT ,
              [unitMsr] VARCHAR(100) ,
              [STATUS_CODE] VARCHAR(50)
            );
	--

		---------------------------------------------------------------------------------
		-- Crear detalle
		---------------------------------------------------------------------------------  
        CREATE TABLE [#PICKING_DEMAND_DETAIL]
            (
              [DOC_NUM] INT ,
              [DOC_ENTRY] INT ,
              [MATERIAL_ID] VARCHAR(50) ,
              [QTY] DECIMAL(16, 6) ,
              [OWNER] VARCHAR(50) ,
              [LINE_SEQ] INT
            );


        BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene los documentos con su fuente externa
		-- ------------------------------------------------------------------------------------
            INSERT  INTO [#PICKING_DOCUMENT]
                    ( [EXTERNAL_SOURCE_ID] ,
                      [PICKING_DOCUMENT_ID] ,
                      [OWNER] ,
                      [SOURCE_NAME] ,
                      [DATA_BASE_NAME] ,
                      [SCHEMA_NAME]
				    )
                    SELECT  [x].[Rec].[query]('./ExternalSourceId').[value]('.',
                                                              'int') ,
                            [x].[Rec].[query]('./DocumentId').[value]('.',
                                                              'NUMERIC(18,0)') ,
                            [x].[Rec].[query]('./Owner').[value]('.',
                                                              'varchar(50)') ,
                            [SES].[SOURCE_NAME] ,
                            [SES].[INTERFACE_DATA_BASE_NAME] ,
                            [SES].[SCHEMA_NAME]
                    FROM    @XML.[nodes]('/ArrayOfDocumento/Documento') AS [x] ( [Rec] )
                            INNER JOIN [wms].[OP_SETUP_EXTERNAL_SOURCE] [SES] ON ( [x].[Rec].[query]('./ExternalSourceId').[value]('.',
                                                              'int') = [SES].[EXTERNAL_SOURCE_ID] )
                    WHERE   [SES].[EXTERNAL_SOURCE_ID] > 0
                            AND [SES].[READ_ERP] = 1;


            INSERT  [#PICKING_DEMAND_DETAIL]
                    SELECT  [H].[DOC_NUM] ,
                            H.[DOC_ENTRY] ,
                            [D].[MATERIAL_ID] ,
                            SUM([D].[QTY]) [QTY] ,
                            [H].[OWNER] ,
                            [D].[LINE_NUM] [LINE_SEQ]
                    FROM    [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [D]
                            INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [H] ON [D].[PICKING_DEMAND_HEADER_ID] = [H].[PICKING_DEMAND_HEADER_ID]
                            INNER JOIN [#PICKING_DOCUMENT] [S] ON [S].[PICKING_DOCUMENT_ID] = [H].[DOC_ENTRY]
                                                              AND [S].[EXTERNAL_SOURCE_ID] = [H].[EXTERNAL_SOURCE_ID]
                    WHERE  -- [H].[EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID AND 
                             [H].[IS_FROM_ERP] = 1
                            AND [H].[SOURCE_TYPE] = 'WT - ERP'
                    GROUP BY [H].[OWNER] ,
                            [H].[DOC_NUM] ,
                            H.[DOC_ENTRY] ,
                            [D].[MATERIAL_ID] ,
                            [D].[LINE_NUM];

		-- ------------------------------------------------------------------------------------
		-- Ciclo para obtener los detalles
		-- ------------------------------------------------------------------------------------
            PRINT '--> Inicia el ciclo';
		--
            WHILE EXISTS ( SELECT TOP 1
                                    1
                           FROM     [#PICKING_DOCUMENT]
                           WHERE    [EXTERNAL_SOURCE_ID] > 0
                                    AND [PICKING_DOCUMENT_ID] > 0 )
                BEGIN
			-- ------------------------------------------------------------------------------------
			-- Obtiene la fuente externa
			-- ------------------------------------------------------------------------------------
                    SELECT TOP 1
                            @EXTERNAL_SOURCE_ID = [PD].[EXTERNAL_SOURCE_ID] ,
                            @SOURCE_NAME = [PD].[SOURCE_NAME] ,
                            @DATA_BASE_NAME = [PD].[DATA_BASE_NAME] ,
                            @SCHEMA_NAME = [PD].[SCHEMA_NAME]
                    FROM    [#PICKING_DOCUMENT] [PD]
                    WHERE   [PD].[EXTERNAL_SOURCE_ID] > 0
                            AND [PD].[PICKING_DOCUMENT_ID] > 0;
			--
                    PRINT '----> @EXTERNAL_SOURCE_ID: '
                        + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR);
                    PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME;
                    PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME;
                    PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME;


			SELECT TOP 1
				@DEFAULT_STATUS = [PARAM_NAME]
			FROM
				[wms].[OP_WMS_CONFIGURATIONS]
			WHERE
				[PARAM_GROUP] = 'ESTADOS'
				AND [PARAM_TYPE] = 'ESTADO'
				AND [NUMERIC_VALUE] = 1;
            -- ------------------------------------------------------------------------------------
            -- Obtiene el detalle de la ordenes de venta de la fuente externa
            -- ------------------------------------------------------------------------------------
			SELECT
				@QUERY = N'INSERT INTO [#PICKING_DOCUMENT_DETAIL]
					SELECT
						[TRD].[DOC_ENTRY]
						,[TRD].[MATERIAL_ID]
						,[TRD].[LINE_NUM]
						,([TRD].[QTY] * ISNULL(UMM.QTY, 1)) - ISNULL([DD].[QTY], 0) [QTY]
						,([TRD].[QTY] * ISNULL(UMM.QTY, 1)) - ISNULL([DD].[QTY], 0) [QTY_PENDING]
						,([TRD].[QTY] * ISNULL(UMM.QTY, 1)) [QTY_ORIGINAL]
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,NULL
						,[M].[MATERIAL_NAME] [DESCRIPTION_SKU]
						,[M].[BARCODE_ID]
						,[M].[ALTERNATE_BARCODE]
						,' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
                            + N' [EXTERNAL_SOURCE_ID]
						,''' + @SOURCE_NAME + N''' [SOURCE_NAME]
						,[TRD].[ERP_OBJECT_TYPE]
						,[M].[IS_MASTER_PACK]
						,[M].[CLIENT_OWNER] [MATERIAL_OWNER]
						,[TRD].[MATERIAL_MASTER_ID]
						,[TRD].[SOURCE]
						,[M].[USE_PICKING_LINE]
						,[TRD].unitMsr
						, '''' STATUS_CODE
					FROM ' + @DATA_BASE_NAME + N'.' + @SCHEMA_NAME
                            + '.[ERP_VW_TRANSFER_REQUEST_DETAIL] [TRD]
					INNER JOIN #PICKING_DOCUMENT [PD] ON ([PD].[PICKING_DOCUMENT_ID] = [TRD].[DOC_ENTRY] AND [PD].[OWNER] COLLATE DATABASE_DEFAULT = [TRD].[SOURCE] COLLATE DATABASE_DEFAULT)
					INNER JOIN [wms].[OP_WMS_MATERIALS] [M] ON ([M].[MATERIAL_ID] COLLATE DATABASE_DEFAULT = [TRD].[MATERIAL_ID] COLLATE DATABASE_DEFAULT)
					LEFT JOIN [#PICKING_DEMAND_DETAIL] DD ON ([TRD].[DOC_ENTRY]	= DD.[DOC_ENTRY]  AND DD.[LINE_SEQ]= [TRD].[LINE_NUM])


					--LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH] ON (
					--	[DH].[DOC_NUM] = [TRD].[DOC_ENTRY]						
     --       AND [DH].[SOURCE_TYPE] = ''WT - ERP''
					--)
					--LEFT JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [DD] ON (
					--	[DD].[PICKING_DEMAND_HEADER_ID] = [DH].[PICKING_DEMAND_HEADER_ID]
					--	AND [DD].[MATERIAL_ID] COLLATE DATABASE_DEFAULT = [TRD].[MATERIAL_ID] COLLATE DATABASE_DEFAULT
					--	AND [DD].[LINE_NUM] = [TRD].[LINE_NUM]
					--)
					LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON (
						[UMM].[MEASUREMENT_UNIT] = [TRD].unitMsr collate database_default
						AND [M].MATERIAL_ID COLLATE DATABASE_DEFAULT = [UMM].MATERIAL_ID COLLATE DATABASE_DEFAULT
					)
					WHERE [PD].[EXTERNAL_SOURCE_ID] = '
                            + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR) + N';';
			--
                    PRINT '--> @QUERY: ' + @QUERY;
			--
                    EXEC (@QUERY);

      -- ------------------------------------------------------------------------------------
      -- Eleminamos la fuente externa
      -- ------------------------------------------------------------------------------------
                    DELETE  FROM [#PICKING_DOCUMENT]
                    WHERE   [EXTERNAL_SOURCE_ID] = @EXTERNAL_SOURCE_ID;
                END;
		--
            PRINT '--> Termino el ciclo';
		
		-- ------------------------------------------------------------------------------------
		-- Muestra el resultado
		-- ------------------------------------------------------------------------------------
            SELECT  [PDD].[SALES_ORDER_ID] ,
                    [PDD].[SKU] ,
                    [PDD].[LINE_SEQ] ,
                    [PDD].[QTY] ,
                    [PDD].[QTY_PENDING] ,
                    [PDD].[QTY_ORIGINAL] ,
                    [PDD].[PRICE] ,
                    [PDD].[DISCOUNT] ,
                    [PDD].[TOTAL_LINE] ,
                    [PDD].[POSTED_DATETIME] ,
                    [PDD].[SERIE] ,
                    [PDD].[SERIE_2] ,
                    [PDD].[REQUERIES_SERIE] ,
                    [PDD].[COMBO_REFERENCE] ,
                    [PDD].[PARENT_SEQ] ,
                    [PDD].[IS_ACTIVE_ROUTE] ,
                    [PDD].[CODE_PACK_UNIT] ,
                    [PDD].[IS_BONUS] ,
                    [PDD].[DESCRIPTION_SKU] ,
                    [PDD].[BARCODE_ID] ,
                    [PDD].[ALTERNATE_BARCODE] ,
                    [PDD].[EXTERNAL_SOURCE_ID] ,
                    [PDD].[SOURCE_NAME] ,
                    [PDD].[ERP_OBJECT_TYPE] ,
                    [PDD].[IS_MASTER_PACK] ,
                    [PDD].[MATERIAL_OWNER] ,
                    [PDD].[MASTER_ID_MATERIAL] ,
                    [PDD].[SOURCE] ,
                    [PDD].[USE_PICKING_LINE] ,
                    ISNULL([UMM].[MEASUREMENT_UNIT], 'Unidad Base') + ' 1x'
                    + CAST(ISNULL([UMM].[QTY], 1) AS VARCHAR) [MEASUREMENT_UNIT] ,
                    ISNULL([UMM].[MEASUREMENT_UNIT], 'Unidad Base') [unitMsr] ,
			CASE	WHEN ISNULL([PDD].[STATUS_CODE], '') = ''
					THEN @DEFAULT_STATUS
					ELSE [PDD].[STATUS_CODE]
				END [STATUS_CODE]
            FROM    [#PICKING_DOCUMENT_DETAIL] [PDD]
                    LEFT JOIN [wms].[OP_WMS_UNIT_MEASUREMENT_BY_MATERIAL] [UMM] ON [UMM].[MATERIAL_ID] COLLATE DATABASE_DEFAULT = [PDD].[SKU] COLLATE DATABASE_DEFAULT
                                                              AND [UMM].[MEASUREMENT_UNIT] COLLATE DATABASE_DEFAULT = [PDD].[unitMsr] COLLATE DATABASE_DEFAULT
            WHERE   [PDD].[SALES_ORDER_ID] > 0
                    AND [PDD].[EXTERNAL_SOURCE_ID] > 0
					AND [PDD].[QTY_PENDING]>0;
        END TRY
        BEGIN CATCH
            SELECT  -1 AS [Resultado] ,
                    ERROR_MESSAGE() [Mensaje] ,
                    @@ERROR [Codigo];
        END CATCH;
    END;