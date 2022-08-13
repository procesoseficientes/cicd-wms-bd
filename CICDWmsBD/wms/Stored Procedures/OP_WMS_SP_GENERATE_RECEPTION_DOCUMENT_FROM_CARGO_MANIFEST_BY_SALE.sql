-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	13-Dec-17 @ Nexus Team Sprint HeyYouPikachu!
-- Description:			SP que genera la tarea de recepcion desde el documento de manifiesto de carga por devolucion

-- Modificacion 04-Jan-18 @ Nexus Team Sprint @IceAge
					-- pablo.aguilar
					-- Se agrega parentesis en validación de manifiesto y se retorna en caso da error

/*
-- Ejemplo de Ejecucion:
				EXEC [wms].[OP_WMS_SP_GENERATE_RECEPTION_DOCUMENT_FROM_CARGO_MANIFEST_BY_SALE]
					@MANIFEST_ID = 2210
					,@LOGIN = 'ACAMACHO'
				--
				EXEC [wms].[OP_WMS_SP_GENERATE_RECEPTION_DOCUMENT_FROM_CARGO_MANIFEST_BY_SALE]
					@MANIFEST_ID = 2211
					,@LOGIN = 'ACAMACHO'
*/
-- =============================================
CREATE PROCEDURE [wms].[OP_WMS_SP_GENERATE_RECEPTION_DOCUMENT_FROM_CARGO_MANIFEST_BY_SALE](
	@MANIFEST_ID INT
	,@LOGIN VARCHAR(50)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@RESULT TABLE (
			[Resultado] INT
			,[Mensaje] VARCHAR(1000)
			,[Codigo] INT
			,[DbData] VARCHAR(50)
		);
	--
	CREATE TABLE [#PICKING_DEMAND] (
		[PICKING_DEMAND_HEADER_ID] INT NOT NULL PRIMARY KEY
		, [DOC_ID] INT 
	)
	--
	CREATE TABLE [#DELIVERY_NOTE_DETAIL] (
		[MATERIAL_OWNER] VARCHAR(50) NOT NULL
		,[MATERIAL_OWNER_ID] VARCHAR(50) NOT NULL
		,[MATERIAL_ID] VARCHAR(50) NOT NULL
		,[QTY] DECIMAL(18,4) NOT NULL
	)
	--
	CREATE TABLE [#DETAIL] (
		[PICKING_DEMAND_DETAIL_ID] INT NOT NULL PRIMARY KEY
		,[PICKING_DEMAND_HEADER_ID] INT NOT NULL
		,[MATERIAL_OWNER] VARCHAR(50) NOT NULL
		,[MASTER_ID_MATERIAL] VARCHAR(50) NOT NULL
		,[MATERIAL_ID] VARCHAR(50) NOT NULL
		,[QTY] DECIMAL(18,4) NOT NULL
		,[LINE_NUM] INT NOT NULL
		,[DOC_ID] INT 
	)
	--
	DECLARE
		@STATUS VARCHAR(50) = 'CANCELED'
		,@PICKING_DEMAND_HEADER_ID INT = 0
		,@CLIENT_CODE VARCHAR(50)
		,@CLIENT_NAME VARCHAR(150)
		,@FECHA_POLIZA DATETIME = GETDATE()
		,@NUMERO_ORDEN VARCHAR(50)
		,@ACUERDO_COMERCIAL VARCHAR(50)
		,@CODIGO_POLIZA VARCHAR(50)
		,@TASK_ID INT
		,@ID INT
		,@Resultado INT = -1
		,@Mensaje VARCHAR(1000)
		,@PLATE_NUMBER VARCHAR(50)
		,@EXTERNAL_SOURCE_ID INT
        ,@SOURCE_NAME VARCHAR(50)
        ,@DATA_BASE_NAME VARCHAR(50)
        ,@SCHEMA_NAME VARCHAR(50)
        ,@QUERY NVARCHAR(MAX)
		,@IN_PROGRESS INT = 0;
	--
	DECLARE @RECEPTION_DOCUMENTS TABLE (
		[DOC_ID] INT
        ,[MATERIAL_ID] VARCHAR(50)
        ,[RECEPTION_QTY] NUMERIC(18,6)
        ,[DOCUMENT_QTY] NUMERIC(18,6)
	)
	--
	DECLARE @Codigo INT = 0

	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Obtiene la fuente del Sonda SD
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@EXTERNAL_SOURCE_ID = [ES].[EXTERNAL_SOURCE_ID]
		   ,@SOURCE_NAME = [ES].[SOURCE_NAME]
		   ,@DATA_BASE_NAME = [ES].[DATA_BASE_NAME]
		   ,@SCHEMA_NAME = [ES].[SCHEMA_NAME]
		   ,@QUERY = N''
		FROM [wms].[OP_SETUP_EXTERNAL_SOURCE] [ES]
		WHERE [EXTERNAL_SOURCE_ID] > 0
			AND [IS_SONDA_SD] = 1
		ORDER BY [ES].[EXTERNAL_SOURCE_ID]
		--
		PRINT '----> @EXTERNAL_SOURCE_ID: ' + CAST(@EXTERNAL_SOURCE_ID AS VARCHAR)
		PRINT '----> @SOURCE_NAME: ' + @SOURCE_NAME
		PRINT '----> @DATA_BASE_NAME: ' + @DATA_BASE_NAME
		PRINT '----> @SCHEMA_NAME: ' + @SCHEMA_NAME
		
		SELECT TOP 1 @IN_PROGRESS = 1  FROM 
		 [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [RD] 
		INNER JOIN [wms].[OP_WMS_TASK_LIST] [TL] ON [TL].[SERIAL_NUMBER] = [RD].[TASK_ID]
		WHERE [RD].[MANIFEST_HEADER_ID] = @MANIFEST_ID
			AND ([TL].[IS_COMPLETED] = 0  OR [TL].[IS_CANCELED] = 1)
		IF @IN_PROGRESS = 1 
		BEGIN 
			SELECT  
				-1 as Resultado
				,'Manifiesto aun tiene tareas pendientes de recepción.' Mensaje 
				,'1506' Codigo 
				,'' DbData			
			RETURN
		END 
		
   

		-- ------------------------------------------------------------------------------------
		-- Obtiene los datos del cliente
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@CLIENT_CODE = [COMPANY_CODE]
			,@CLIENT_NAME = [COMPANY_NAME]
			,@ACUERDO_COMERCIAL = ISNULL(CAST([AC].[ACUERDO_COMERCIAL] AS VARCHAR),'')
		FROM [wms].[OP_SETUP_COMPANY] [C]
		LEFT JOIN [wms].[OP_WMS_ACUERDOS_X_CLIENTE] [AC] ON ([AC].[CLIENT_ID] = [C].[COMPANY_CODE])

		PRINT '--> @CLIENT_CODE: ' + @CLIENT_CODE
		PRINT '--> @CLIENT_NAME: ' + @CLIENT_NAME
		PRINT '--> @ACUERDO_COMERCIAL: ' + @ACUERDO_COMERCIAL

		-- ------------------------------------------------------------------------------------
		-- Obtiene la placa del manifiesto
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1 @PLATE_NUMBER = [MH].[PLATE_NUMBER]
		FROM [wms].[OP_WMS_MANIFEST_HEADER] [MH]
		WHERE [MH].[MANIFEST_HEADER_ID] = @MANIFEST_ID

		-- ------------------------------------------------------------------------------------
		-- Obtiene detalles a operar
		-- ------------------------------------------------------------------------------------
		BEGIN
		    -- ------------------------------------------------------------------------------------
		    -- Obtiene los documentos del manifiesto
		    -- ------------------------------------------------------------------------------------
		    INSERT INTO [#PICKING_DEMAND]
		    		([PICKING_DEMAND_HEADER_ID]
					,[DOC_ID])
		    SELECT DISTINCT 
				[PD].[PICKING_DEMAND_HEADER_ID]
				,ISNULL([DH].[DELIVERY_NOTE_INVOICE],[DH].[ERP_REFERENCE_DOC_NUM]) [DOC_ID]
		    FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PD]
			INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH] ON [DH].[PICKING_DEMAND_HEADER_ID] = [PD].[PICKING_DEMAND_HEADER_ID]
		    INNER JOIN [wms].[OP_WMS_MANIFEST_DETAIL] [MD] ON (
		    	[MD].[PICKING_DEMAND_HEADER_ID] = [PD].[PICKING_DEMAND_HEADER_ID]
		    	AND [MD].[MATERIAL_ID] = [PD].[MATERIAL_ID]
		    )
		    WHERE [PD].[PICKING_DEMAND_DETAIL_ID] > 0
		    	AND [MD].[MANIFEST_HEADER_ID] = @MANIFEST_ID
		    
		    -- ------------------------------------------------------------------------------------
		    -- Obtiene los detalles de las entregas canceladas
		    -- ------------------------------------------------------------------------------------
		    SELECT 
				@QUERY = N'
			INSERT INTO [#DETAIL]
		    		(
		    			[PICKING_DEMAND_DETAIL_ID]
		    			,[PICKING_DEMAND_HEADER_ID]
		    			,[MATERIAL_OWNER]
		    			,[MASTER_ID_MATERIAL]
		    			,[MATERIAL_ID]
		    			,[QTY]
						,[LINE_NUM]
		    		)
		    SELECT
		    	[PD].[PICKING_DEMAND_DETAIL_ID]
		    	,[PD].[PICKING_DEMAND_HEADER_ID]
		    	,[PD].[MATERIAL_OWNER]
		    	,[PD].[MASTER_ID_MATERIAL]
		    	,[PD].[MATERIAL_ID]
		    	,[PD].[QTY]
				,[PD].[LINE_NUM]
		    FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PD]
		    INNER JOIN [#PICKING_DEMAND] [P] ON ([P].[PICKING_DEMAND_HEADER_ID] = [PD].[PICKING_DEMAND_HEADER_ID])
		    INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SONDA_PICKING_DEMAND_BY_TASK] [DS] ON ([DS].[PICKING_DEMAND_HEADER_ID] = [PD].[PICKING_DEMAND_HEADER_ID])
		    WHERE [DS].[PICKING_DEMAND_STATUS] = ''' + @STATUS + ''';';
		    --
			PRINT '--> @QUERY: ' + @QUERY
			--
			EXEC (@QUERY)

		    -- ------------------------------------------------------------------------------------
		    -- Obtiene los detalles de entregas parciales
		    -- ------------------------------------------------------------------------------------
		    SET @STATUS = 'PARTIAL'
		    --
		    SELECT 
				@QUERY = N'INSERT INTO [#DELIVERY_NOTE_DETAIL]
		    		(
		    			[MATERIAL_OWNER]
		    			,[MATERIAL_OWNER_ID]
		    			,[MATERIAL_ID]
		    			,[QTY]
		    		)
		    SELECT
		    	[S].[OWNER]
		    	,[S].[OWNER_ID]
		    	,[S].[OWNER] + ''/'' + [DD].[CODE_SKU]
		    	,[DD].[QTY]
		    FROM ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SONDA_PICKING_DEMAND_BY_TASK] [DS]
		    INNER JOIN [#PICKING_DEMAND] [PD] ON ([PD].[PICKING_DEMAND_HEADER_ID] = [DS].[PICKING_DEMAND_HEADER_ID])
		    INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SONDA_DELIVERY_NOTE_DETAIL] [DD] ON ([DD].[PICKING_DEMAND_HEADER_ID] = [DS].[PICKING_DEMAND_HEADER_ID])
		    INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SWIFT_VIEW_ALL_SKU] [S] ON ([S].[OWNER_ID] = [DD].[CODE_SKU])
		    WHERE [PD].[PICKING_DEMAND_HEADER_ID] > 0
		    	AND [DS].[PICKING_DEMAND_STATUS] = ''@STATUS''
		    --
		    INSERT INTO [#DETAIL]
		    		(
		    			[PICKING_DEMAND_DETAIL_ID]
		    			,[PICKING_DEMAND_HEADER_ID]
		    			,[MATERIAL_OWNER]
		    			,[MASTER_ID_MATERIAL]
		    			,[MATERIAL_ID]
		    			,[QTY]
						,[LINE_NUM]
						,[DOC_ID]
		    		)
		    SELECT
		    	[PD].[PICKING_DEMAND_DETAIL_ID]
		    	,[PD].[PICKING_DEMAND_HEADER_ID]
		    	,[PD].[MATERIAL_OWNER]
		    	,[PD].[MASTER_ID_MATERIAL]
		    	,[PD].[MATERIAL_ID]
		    	,[PD].[QTY] - ISNULL([DD].[QTY],0)
				,[PD].[LINE_NUM]
				,[P].[DOC_ID]
		    FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_DETAIL] [PD]
		    INNER JOIN [#PICKING_DEMAND] [P] ON ([P].[PICKING_DEMAND_HEADER_ID] = [PD].[PICKING_DEMAND_HEADER_ID])
		    INNER JOIN ' + @DATA_BASE_NAME + '.' + @SCHEMA_NAME + '.[SONDA_PICKING_DEMAND_BY_TASK] [DS] ON ([DS].[PICKING_DEMAND_HEADER_ID] = [PD].[PICKING_DEMAND_HEADER_ID])
		    LEFT JOIN [#DELIVERY_NOTE_DETAIL] [DD] ON (
		    	[DD].[MATERIAL_OWNER] = [PD].[MATERIAL_OWNER]
		    	AND [DD].[MATERIAL_ID] = [PD].[MATERIAL_ID]
		    )
		    WHERE [DS].[PICKING_DEMAND_STATUS] =''' + @STATUS + ''';';
			--
			PRINT '--> @QUERY: ' + @QUERY
			--
			EXEC (@QUERY)
		END

		-- ------------------------------------------------------------------------------------
		-- Obtiene los documentos necesarios para operar
		-- ------------------------------------------------------------------------------------
		DELETE FROM [#PICKING_DEMAND]
		--
		INSERT INTO [#PICKING_DEMAND]
				([PICKING_DEMAND_HEADER_ID]
				, [DOC_ID])
		SELECT DISTINCT [PICKING_DEMAND_HEADER_ID], [DOC_ID]
		FROM [#DETAIL]
		WHERE [PICKING_DEMAND_DETAIL_ID] > 0
		
		-- ------------------------------------------------------------------------------------
		-- Obtiene el detalle de los documentos de recepcion ya procesados para parcializar las nuevas recepciones
		-- ------------------------------------------------------------------------------------
		INSERT INTO @RECEPTION_DOCUMENTS
            	(
            		[DOC_ID]
            		,[MATERIAL_ID]
            		,[RECEPTION_QTY]
            		,[DOCUMENT_QTY]
            	)
		SELECT
			[H].[DOC_ID]
			,[D].[MATERIAL_ID]
			,ISNULL(SUM([IL].[ENTERED_QTY]), 0) [RECEPTION_QTY]
			,MAX([D].[QTY]) [DOCUMENT_QTY]
		FROM [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER] [H]
		INNER JOIN [#PICKING_DEMAND] [PD] ON [PD].[DOC_ID] = [H].[DOC_ID]
		INNER JOIN [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL] [D] ON [H].[ERP_RECEPTION_DOCUMENT_HEADER_ID] = [D].[ERP_RECEPTION_DOCUMENT_HEADER_ID]
		INNER JOIN [wms].[OP_WMS_TASK_LIST] [T] ON [H].[TASK_ID] = [T].[SERIAL_NUMBER]
		LEFT JOIN [wms].[OP_WMS_LICENSES] [L] ON [L].[CODIGO_POLIZA] = [T].[CODIGO_POLIZA_SOURCE]
		LEFT JOIN [wms].[OP_WMS_INV_X_LICENSE] [IL] ON (
			[IL].[LICENSE_ID] = [L].[LICENSE_ID]
			AND [D].[MATERIAL_ID] = [IL].[MATERIAL_ID]
		)
		WHERE [H].[IS_VOID] = 0
			AND [H].[SOURCE] = 'INVOICE'
		GROUP BY
			[H].[DOC_ID]
			,[D].[MATERIAL_ID];	

		-- ------------------------------------------------------------------------------------
		-- Crea la recepcion por documento
		-- ------------------------------------------------------------------------------------
		BEGIN
			WHILE EXISTS(SELECT TOP 1 1 FROM [#PICKING_DEMAND] WHERE [PICKING_DEMAND_HEADER_ID] > 0)
			BEGIN
				-- ------------------------------------------------------------------------------------
				-- Obtiene el documento a operar
				-- ------------------------------------------------------------------------------------
				SELECT TOP 1
					@PICKING_DEMAND_HEADER_ID = [PD].[PICKING_DEMAND_HEADER_ID]
					,@NUMERO_ORDEN = CAST(ISNULL([PDH].[DELIVERY_NOTE_INVOICE],[PDH].[ERP_REFERENCE_DOC_NUM]) AS VARCHAR) + '-SO'
					,@Resultado = -1
					,@Mensaje = ''
				FROM [#PICKING_DEMAND] [PD]
				INNER JOIN [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [PDH] ON ([PDH].[PICKING_DEMAND_HEADER_ID] = [PD].[PICKING_DEMAND_HEADER_ID])
				WHERE [PD].[PICKING_DEMAND_HEADER_ID] > 0
				--
				PRINT '--> @PICKING_DEMAND_HEADER_ID: ' + CAST(@PICKING_DEMAND_HEADER_ID AS VARCHAR)
				PRINT '--> : @NUMERO_ORDEN' + @NUMERO_ORDEN

				-- ------------------------------------------------------------------------------------
				-- Se inserta la poliza de recepcion general
				---- ------------------------------------------------------------------------------------
				INSERT	INTO @RESULT
						(
							[Resultado]
							,[Mensaje]
							,[Codigo]
							,[DbData]
						)
				EXEC [wms].[OP_WMS_SP_INSERT_RECEPTION_GENERAL_POLICY] 
					@ORDER_NUM = @NUMERO_ORDEN, -- varchar(50)
					@DOC_DATE = @FECHA_POLIZA, -- datetime
					@LAST_UPDATED_BY = @LOGIN, -- varchar(50)
					@CLIENT_CODE = @CLIENT_CODE, -- varchar(50)
					@TRADE_AGREEMENT = @ACUERDO_COMERCIAL, -- varchar(50)
					@INSURANCE_POLICY = NULL, -- varchar(50)
					@ASSIGNED_TO = @LOGIN; -- varchar(50)

				-- ------------------------------------------------------------------------------------
				-- Obtiene codigo de poliza y elimina los registros de la tabla temporal
				-- ------------------------------------------------------------------------------------
				SELECT TOP 1 
					@CODIGO_POLIZA = [DbData]
					,@Resultado = [Resultado]
					,@Mensaje = [Mensaje]
				FROM @RESULT;
				--
				PRINT '--> @CODIGO_POLIZA: ' + @CODIGO_POLIZA
				PRINT '--> @Resultado: ' + CAST(@Resultado AS VARCHAR)
				PRINT '--> @Mensaje: ' + @Mensaje

				
				-- ------------------------------------------------------------------------------------
				-- Valida el resultado
				-- ------------------------------------------------------------------------------------
				IF @Resultado = -1
				BEGIN
					SET @Codigo = 1504
				    RAISERROR(@Mensaje,16,1);
					RETURN;
				END
				ELSE
				BEGIN
				    DELETE FROM @RESULT;
				END

				-- ------------------------------------------------------------------------------------
				-- Inserta la tarea de recepcion por traslado
				-- ------------------------------------------------------------------------------------
				INSERT INTO @RESULT
				(
					[Resultado]
					,[Mensaje]
					,[Codigo]
					,[DbData]
				)
				EXEC [wms].[OP_WMS_SP_INSERT_TASK_RECEPTION_ERP]
					@TASK_SUBTYPE = 'DEVOLUCION_FACTURA', -- varchar(25)
					@TASK_OWNER = @LOGIN, -- varchar(25)
					@TASK_ASSIGNEDTO = @LOGIN, -- varchar(25)
					@TASK_COMMENTS = '', -- varchar(150)
					@REGIMEN = 'GENERAL', -- varchar(50)
					@CLIENT_OWNER = @CLIENT_CODE, -- varchar(25)
					@CLIENT_NAME = @CLIENT_NAME, -- varchar(150)
					@CODIGO_POLIZA_SOURCE = @CODIGO_POLIZA, -- varchar(25)
					@DOC_ID_SOURCE = @CODIGO_POLIZA, -- numeric
					@PRIORITY = 2, -- int
					@IS_FROM_ERP = 0, -- int
					@LOCATION_SPOT_TARGET = '', -- varchar(25)
					@OWNER = ''; -- varchar(50)

				-- ------------------------------------------------------------------------------------
				-- Obtiene el ID de la tarea
				-- ------------------------------------------------------------------------------------
				SELECT TOP 1 
					@TASK_ID = [DbData]
					,@Resultado = [Resultado]
					,@Mensaje = [Mensaje]
				FROM @RESULT;
				--
				PRINT '--> @TASK_ID: ' + CAST(@TASK_ID AS VARCHAR)
				
				-- ------------------------------------------------------------------------------------
				-- Valida el resultado
				-- ------------------------------------------------------------------------------------
				IF @Resultado = -1
				BEGIN
					SET @Codigo = 1505
				    RAISERROR(@Mensaje,16,1);
					RETURN;
				END
				ELSE
				BEGIN
				    DELETE FROM @RESULT;
				END

				-- ------------------------------------------------------------------------------------
				-- Inserta el encabezado del documento de recepcion
				-- ------------------------------------------------------------------------------------
				INSERT	INTO [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_HEADER]
						(
							[DOC_ID]
							,[TYPE]
							,[CODE_SUPPLIER]
							,[CODE_CLIENT]
							,[ERP_DATE]
							,[LAST_UPDATE]
							,[LAST_UPDATE_BY]
							,[ATTEMPTED_WITH_ERROR]
							,[IS_POSTED_ERP]
							,[POSTED_ERP]
							,[POSTED_RESPONSE]
							,[ERP_REFERENCE]
							,[IS_AUTHORIZED]
							,[IS_COMPLETE]
							,[TASK_ID]
							,[EXTERNAL_SOURCE_ID]
							,[ERP_REFERENCE_DOC_NUM]
							,[DOC_NUM]
							,[NAME_SUPPLIER]
							,[OWNER]
							,[IS_FROM_WAREHOUSE_TRANSFER]
							,[IS_FROM_ERP]
							,[DOC_ID_POLIZA]
							,[SOURCE]
							,[LOCKED_BY_INTERFACES]
							,[ERP_WAREHOUSE_CODE]
							,[MANIFEST_HEADER_ID]
							,[PLATE_NUMBER]
						)
				SELECT
					ISNULL([DH].[DELIVERY_NOTE_INVOICE],[DH].[ERP_REFERENCE_DOC_NUM])
					,'DEVOLUCION_FACTURA'
					,[DH].[CLIENT_CODE]
					,NULL
					,GETDATE()
					,GETDATE()
					,@LOGIN
					,0
					,0
					,NULL
					,NULL
					,NULL
					,0
					,0
					,@TASK_ID
					,[DH].[EXTERNAL_SOURCE_ID]
					,NULL
					,ISNULL([DH].[DELIVERY_NOTE_INVOICE],[DH].[ERP_REFERENCE_DOC_NUM])
					,[DH].[CLIENT_NAME]
					,[DH].[OWNER]
					,0
					,[DH].[IS_FROM_ERP]
					,CAST(@CODIGO_POLIZA AS NUMERIC)
					,'INVOICE'
					,1
					,[W].[ERP_WAREHOUSE]
					,@MANIFEST_ID
					,@PLATE_NUMBER
				FROM [wms].[OP_WMS_NEXT_PICKING_DEMAND_HEADER] [DH]
				INNER JOIN [wms].[OP_WMS_WAREHOUSES] [W] ON ([W].[WAREHOUSE_ID] = [DH].[CODE_WAREHOUSE])
				WHERE [DH].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;
				--
				SET @ID = SCOPE_IDENTITY();
				--
				PRINT '--> @ID: ' + CAST(@ID AS VARCHAR)

				-- ------------------------------------------------------------------------------------
				-- Inserta el detalle del documento de recepcion
				-- ------------------------------------------------------------------------------------
                INSERT  INTO [wms].[OP_WMS_ERP_RECEPTION_DOCUMENT_DETAIL]
                (
                         [ERP_RECEPTION_DOCUMENT_HEADER_ID]
                        ,[MATERIAL_ID]
                        ,[QTY]
                        ,[LINE_NUM]
				)
                SELECT
                    @ID
                   ,[D].[MATERIAL_ID]
                   ,[D].[QTY] - ISNULL([RD].[RECEPTION_QTY], 0)
                   ,[D].[LINE_NUM]
                FROM
                    [#DETAIL] [D]
                LEFT JOIN @RECEPTION_DOCUMENTS [RD] ON [RD].[DOC_ID] = [D].[DOC_ID] AND [RD].[MATERIAL_ID] = [D].[MATERIAL_ID]
                WHERE
                    [D].[PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID
                    AND [D].[QTY] - ISNULL([RD].[RECEPTION_QTY], 0) > 0;

				-- ------------------------------------------------------------------------------------
				-- Elimina el registro operado
				-- ------------------------------------------------------------------------------------
				DELETE FROM [#PICKING_DEMAND] WHERE [PICKING_DEMAND_HEADER_ID] = @PICKING_DEMAND_HEADER_ID;
			END
		END
		--
		SELECT  
			1 as Resultado
			,'Proceso Exitoso' Mensaje 
			,0 Codigo 
			,'SALES_ORDER' DbData
	END TRY
	BEGIN CATCH
		SELECT  
			-1 as Resultado
			,ERROR_MESSAGE() Mensaje 
			,@Codigo Codigo 
			,'' DbData
	END CATCH
END