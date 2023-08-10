-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	5/18/2017 @ A-TEAM Sprint  
-- Description:			Procesa todos los documentos de SondaIonic.

/*
-- Ejemplo de Ejecucion:
				USE [SWIFT_EXPRESS]
				EXEC [SONDA].[SONDA_SP_ADD_DOCUMENTS_BY_XML] @XML = '
				<Data>
					<documents>
						<document>
							<DocumentId>25</DocumentId>
							<DocmentType>0</DocmentType>
							<Terms>CASH</Terms>
							<PostedDatetime>2017-05-22T22:37:47.323Z</PostedDatetime>
							<ClientId>SO-158461</ClientId>
							<PosTerminal>GUA0017@ARIUM</PosTerminal>
							<GpsUrl>0,0</GpsUrl>
							<TotalAmount>415</TotalAmount>
							<Status>1</Status>
							<PostedBy>Henry Ciraiz</PostedBy>
							<Images>
								<id>1</id>
								<content>img1</content>
							</Images>
							<Images>
								<id>2</id>
								<content>img1</content>
							</Images>
							<Images>
								<id>3</id>
								<content>img1</content>
							</Images>
							<Signature>signature</Signature>
							<IsActiveRoute>1</IsActiveRoute>
							<GpsExpected>0,0</GpsExpected>
							<IsParent>false</IsParent>
							<ReferenceId>abc</ReferenceId>
							<TimesPrinted>0</TimesPrinted>
							<DocSerie>SERIE1</DocSerie>
							<DocNum>25</DocNum>
							<IsVoid>false</IsVoid>
							<PaymentType>CASH</PaymentType>
							<Discount>0</Discount>
							<IsDraft>0</IsDraft>
							<TaskId>124474</TaskId>
							<Comment>Prueba</Comment>
							<IsPosted>0</IsPosted>
							<Sync>0</Sync>
							<IsPostedVoid>0</IsPostedVoid>
							<IsUpdated>0</IsUpdated>
							<PaymentTimesPrinted>0</PaymentTimesPrinted>
							<PaidToDate>0</PaidToDate>
							<ToBill> </ToBill>
							<Authorized>NO</Authorized>
							<DetailQty>3</DetailQty>
							<Lines>
								<skuItem>
									<doc>
										<skuPresale>
											<WAREHOUSE>C002</WAREHOUSE>
											<SKU>U00000693</SKU>
											<SKU_NAME>MISABOR SARDINAS EN SALSA DE TOMATE CON CHILE 155G  UNIDAD</SKU_NAME>
											<ON_HAND>110000</ON_HAND>
											<IS_COMITED>0</IS_COMITED>
											<DIFFERENCE>110000</DIFFERENCE>
											<SKU_PRICE>5</SKU_PRICE>
											<CODE_FAMILY_SKU>100</CODE_FAMILY_SKU>
											<DESCRIPTION_FAMILY_SKU>Artículos</DESCRIPTION_FAMILY_SKU>
											<SALES_PACK_UNIT>No tiene unidad Asociada</SALES_PACK_UNIT>
											<HANDLE_DIMENSION>0</HANDLE_DIMENSION>
											<OWNER>Arium</OWNER>
											<OWNER_ID>U00000693</OWNER_ID>
											<HANDLE_SERIAL_NUMBER>0</HANDLE_SERIAL_NUMBER>
											<PACK_UNIT>1</PACK_UNIT>
											<CODE_PACK_UNIT>Manual</CODE_PACK_UNIT>
										</skuPresale>
										<history>
											<QTY_CONSIGNED>0</QTY_CONSIGNED>
											<QTY_SOLD>0</QTY_SOLD>
											<QTY_COLLECTED>0</QTY_COLLECTED>
										</history>
										<docType>3b0a8d93-2aeb-419a-8e99-c2785f330ac3C002</docType>
										<_id>19bb6bcd-a8c5-4a8a-88fe-9948de7a4104</_id>
										<_rev>1-a9953eafffed2d08a4c5511d7fd6f925</_rev>
									</doc>
									<skuType>Item</skuType>
									<total>275</total>
									<quantity>55</quantity>
								</skuItem>
								<line>
									<DocumentId>25</DocumentId>
									<Sku>U00000693</Sku>
									<SkuName>MISABOR SARDINAS EN SALSA DE TOMATE CON CHILE 155G  UNIDAD</SkuName>
									<LineSeq>1</LineSeq>
									<Qty>55</Qty>
									<Price>5</Price>
									<Discount>0</Discount>
									<TotalLine>275</TotalLine>
									<Serie>0</Serie>
									<Serie2>0</Serie2>
									<RequeriesSerie>false</RequeriesSerie>
									<ComboReference></ComboReference>
									<ParentSeq>0</ParentSeq>
									<CodePackUnit>Manual</CodePackUnit>
									<IsBonus>0</IsBonus>
									<Long>0</Long>
								</line>
							</Lines>
							<Lines>
								<skuItem>
									<doc>
										<skuPresale>
											<WAREHOUSE>C002</WAREHOUSE>
											<SKU>UP0000703</SKU>
											<SKU_NAME>CAPULLO ACEITE  3 L + FRIJOL 5.5  UNIDAD</SKU_NAME>
											<ON_HAND>10000</ON_HAND>
											<IS_COMITED>0</IS_COMITED>
											<DIFFERENCE>10000</DIFFERENCE>
											<SKU_PRICE>40</SKU_PRICE>
											<CODE_FAMILY_SKU>100</CODE_FAMILY_SKU>
											<DESCRIPTION_FAMILY_SKU>Artículos</DESCRIPTION_FAMILY_SKU>
											<SALES_PACK_UNIT>No tiene unidad Asociada</SALES_PACK_UNIT>
											<HANDLE_DIMENSION>0</HANDLE_DIMENSION>
											<OWNER>Arium</OWNER>
											<OWNER_ID>UP0000703</OWNER_ID>
											<HANDLE_SERIAL_NUMBER>0</HANDLE_SERIAL_NUMBER>
											<PACK_UNIT>1</PACK_UNIT>
											<CODE_PACK_UNIT>Manual</CODE_PACK_UNIT>
										</skuPresale>
										<history>
											<QTY_CONSIGNED>0</QTY_CONSIGNED>
											<QTY_SOLD>0</QTY_SOLD>
											<QTY_COLLECTED>0</QTY_COLLECTED>
										</history>
										<docType>3b0a8d93-2aeb-419a-8e99-c2785f330ac3C002</docType>
										<_id>7d647a9b-d2b4-429b-cce8-e03ec15ef0dd</_id>
										<_rev>1-1df2d451c07478566ee9eca2f58fb8f0</_rev>
									</doc>
									<skuType>Item</skuType>
									<total>120</total>
									<quantity>3</quantity>
								</skuItem>
								<line>
									<DocumentId>25</DocumentId>
									<Sku>UP0000703</Sku>
									<SkuName>CAPULLO ACEITE  3 L + FRIJOL 5.5  UNIDAD</SkuName>
									<LineSeq>2</LineSeq>
									<Qty>3</Qty>
									<Price>40</Price>
									<Discount>0</Discount>
									<TotalLine>120</TotalLine>
									<Serie>0</Serie>
									<Serie2>0</Serie2>
									<RequeriesSerie>false</RequeriesSerie>
									<ComboReference></ComboReference>
									<ParentSeq>0</ParentSeq>
									<CodePackUnit>Manual</CodePackUnit>
									<IsBonus>0</IsBonus>
									<Long>0</Long>
								</line>
							</Lines>
							<Lines>
								<skuItem>
									<doc>
										<skuPresale>
											<WAREHOUSE>C002</WAREHOUSE>
											<SKU>U00000692</SKU>
											<SKU_NAME>MISABOR SARDINAS EN SALSA DE TOMATE 155G  UNIDAD</SKU_NAME>
											<ON_HAND>110000</ON_HAND>
											<IS_COMITED>0</IS_COMITED>
											<DIFFERENCE>110000</DIFFERENCE>
											<SKU_PRICE>5</SKU_PRICE>
											<CODE_FAMILY_SKU>100</CODE_FAMILY_SKU>
											<DESCRIPTION_FAMILY_SKU>Artículos</DESCRIPTION_FAMILY_SKU>
											<SALES_PACK_UNIT>No tiene unidad Asociada</SALES_PACK_UNIT>
											<HANDLE_DIMENSION>0</HANDLE_DIMENSION>
											<OWNER>Arium</OWNER>
											<OWNER_ID>U00000692</OWNER_ID>
											<HANDLE_SERIAL_NUMBER>0</HANDLE_SERIAL_NUMBER>
											<PACK_UNIT>1</PACK_UNIT>
											<CODE_PACK_UNIT>Manual</CODE_PACK_UNIT>
										</skuPresale>
										<history>
											<QTY_CONSIGNED>0</QTY_CONSIGNED>
											<QTY_SOLD>0</QTY_SOLD>
											<QTY_COLLECTED>0</QTY_COLLECTED>
										</history>
										<docType>3b0a8d93-2aeb-419a-8e99-c2785f330ac3C002</docType>
										<_id>b66be708-0c28-4b13-a1ed-06f28a4c72ec</_id>
										<_rev>1-f1b5f311a009a43e1ab0f1268d28bd59</_rev>
									</doc>
									<skuType>Item</skuType>
									<total>20</total>
									<quantity>4</quantity>
								</skuItem>
								<line>
									<DocumentId>25</DocumentId>
									<Sku>U00000692</Sku>
									<SkuName>MISABOR SARDINAS EN SALSA DE TOMATE 155G  UNIDAD</SkuName>
									<LineSeq>3</LineSeq>
									<Qty>4</Qty>
									<Price>5</Price>
									<Discount>0</Discount>
									<TotalLine>20</TotalLine>
									<Serie>0</Serie>
									<Serie2>0</Serie2>
									<RequeriesSerie>false</RequeriesSerie>
									<ComboReference></ComboReference>
									<ParentSeq>0</ParentSeq>
									<CodePackUnit>Manual</CodePackUnit>
									<IsBonus>0</IsBonus>
									<Long>0</Long>
								</line>
							</Lines>
							<Battery>100</Battery>
							<Routeid>GUA0017@ARIUM</Routeid>
							<Warehouse>C002</Warehouse>
							<Uuid>2b9cd997e9ffcd98</Uuid>
							<IsPostedAndValidated>0</IsPostedAndValidated>
							<TaxId>C.F</TaxId>
							<ClientName>TIENDA JIREH</ClientName>
							<DocResolution>RES-00002-2017</DocResolution>
							<Change>0</Change>
							<InRoutePlan>1</InRoutePlan>
						</document>
						<docType>43229de6-2172-4d69-aa15-cb0d8246afcd</docType>
						<_id>6732BB7A-E492-AB42-AC4E-A44D2ED56752</_id>
						<_rev>1-e409ff119d63bbfd361d220a688592da</_rev>
					</documents>
					<dbuser>USONDA</dbuser>
					<dbuserpass>SONDAServer1237710</dbuserpass>
					<routeid>GUA0017@ARIUM</routeid>
					<uuid>wof72t</uuid>
					<warehouse>V005</warehouse>
				</Data>' , -- xml
					@JSON = '' -- varchar(max)

					
*/
-- =============================================
CREATE PROCEDURE [SONDA].SONDA_SP_ADD_DOCUMENTS_BY_XML(
	@XML XML
	,@JSON VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@DETAIL TABLE (
		[DOCUMENT_ID] INT
		,[SKU] [VARCHAR](25) NOT NULL
		,[INVOICE_SERIAL] VARCHAR(50) NULL
		,[LINE_SEQ] [INT] NOT NULL
		,[QTY] [NUMERIC](18, 2) NULL
		,[PRICE] [MONEY] NULL
		,[DISCOUNT] [MONEY] NULL
		,[TOTAL_LINE] [MONEY] NULL
		,[POSTED_DATETIME] [DATETIME] NULL
		,[SERIE] [VARCHAR](50) NULL
		,[SERIE_2] [VARCHAR](50) NULL
		,[REQUERIES_SERIE] [INT] NULL
		,[COMBO_REFERENCE] [VARCHAR](50) NULL
		,[PARENT_SEQ] [INT] NULL
		,[IS_ACTIVE_ROUTE] [INT] NULL
		,[CODE_PACK_UNIT] [VARCHAR](50) NULL
		,[IS_BONUS] [INT] NULL
		,[LONG] [NUMERIC](18, 6) NULL
		,[RESOLUTION] [VARCHAR](50) NULL
		,[ID] [NUMERIC](18, 6) NULL
	);
	--
	DECLARE @IMAGES TABLE (
		[IMAGE] VARCHAR(MAX),
		[DOCUMENT_ID] INT,
		[NUMBER] INT
	);
	--
	DECLARE @RESULT_VALIDATION_INVOICE TABLE (
		[EXISTS] [INT]
		,[ID] [INT]
		,[DOC_RESOLUTION] VARCHAR(100)
		,[DOC_SERIE] VARCHAR(100)
		,[DOC_NUM] INT
	);

	DECLARE @RESULT_VALIDATION_SALES_ORDER TABLE (
		[EXISTS] [INT]
		,[ID] [INT]
	)
	--
	DECLARE @RESULTS TABLE (
		[DOC_ID] INT
		,[BO_ID] INT
		,[DOC_SERIE] VARCHAR(100)
		,[DOC_NUM] INT
		,[DOC_TYPE] INT
		,[SUCCESS] INT
		,[ERROR] VARCHAR(100)
		,[_ID] VARCHAR(150)
	);
	--
	DECLARE
		@DOCUMENT_ID INT
		,@ID INT
		,@HEADER_POSTEDDATIME DATETIME
		,@DETAIL_QTY INT
		,@HEADER_DETAIL_QTY INT
		,@DOC_RESOLUTION VARCHAR(100)
		,@DOC_SERIE VARCHAR(100)
		,@DOC_NUM INT
		,@CODE_ROUTE VARCHAR(50)
		,@CODE_CUSTOMER VARCHAR(50)
		,@EXISTS INT = 0
		,@WAREHOUSE VARCHAR(50)
		,@DEVICE_ID VARCHAR(50)
		,@LOGIN VARCHAR(50)
		,@BATTERY INT
		,@DOC_TYPE INT
		,@INSERT_ERROR VARCHAR(1000)
		,@ID_BO INT
		,@_ID VARCHAR(150)
		,@SIGNATURE VARCHAR(MAX)
	--
	BEGIN TRY
		-- ------------------------------------------------------------------------------------
		-- Guarda todos los documentos a una tabla temporan [#DOCUMENTS]
		-- ------------------------------------------------------------------------------------
		SELECT
			[x].[Rec].[query]('./DocumentId').[value]('.', 'int') [DOCUMENT_ID]
			,[x].[Rec].[query]('./DocmentType').[value]('.', 'int') [DOCUMENT_TYPE]
			,[x].[Rec].[query]('./PostedDatetime').[value]('.', 'datetime') [POSTED_DATETIME]
			,[x].[Rec].[query]('./DetailQty').[value]('.', 'int') [DETAIL_QTY]
			,[x].[Rec].[query]('./DocResolution').[value]('.', 'varchar(50)') [DOC_RESOLUTION]
			,[x].[Rec].[query]('./DocSerie').[value]('.', 'varchar(50)') [DOC_SERIE]
			,[x].[Rec].[query]('./DocNum').[value]('.', 'int')	[DOC_NUM]
			,[x].[Rec].[query]('./PosTerminal').[value]('.', 'varchar(50)') [POS_TERMINAL]
			,[x].[Rec].[query]('./ClientId').[value]('.', 'varchar(50)') [CLIENT_ID]
			,CASE x.Rec.query('./DocumentIdBo').value('.', 'varchar(50)') WHEN 'null' THEN 0 ELSE x.Rec.query('./DocumentIdBo').value('.', 'int') END [DOCUMENT_ID_BO]
			,[x].[Rec].[query]('./Signature').[value]('.', 'varchar(MAX)') [SIGNATURE]
		INTO [#DOCUMENTS]
		FROM @XML.[nodes]('/Data/documents/document') as [x]([Rec])
		-- ------------------------------------------------------------------------------------
		-- Obtiene los datos generales de la ruta
		-- ------------------------------------------------------------------------------------
		SELECT
			@WAREHOUSE = [x].[Rec].[query]('./warehouse').[value]('.', 'varchar(50)')
			--,@DEVICE_ID = [x].[Rec].[query]('./uuid').[value]('.', 'varchar(50)')
			,@LOGIN = [SONDA].[SWIFT_FN_GET_LOGIN_BY_ROUTE]([x].[Rec].[query]('./routeid').[value]('.', 'varchar(50)'))
		FROM @xml.[nodes]('/Data') as [x]([Rec])
		-- ------------------------------------------------------------------------------------
		-- Obtiene los _id de todos los documentos
		-- ------------------------------------------------------------------------------------
		SELECT
			[x].[Rec].query('./_id').value('.','varchar(150)') [_ID]
		INTO [#_ID]
		FROM @XML.nodes('/Data/documents') AS [x]([Rec])
		-- ------------------------------------------------------------------------------------
		-- Procesa los documentos
		-- ------------------------------------------------------------------------------------
		WHILE EXISTS ( SELECT TOP 1 1 FROM [#DOCUMENTS])
		BEGIN
			-- ------------------------------------------------------------------------------------
			-- Obtiene los datos del encabezado
			-- ------------------------------------------------------------------------------------
			SELECT TOP 1
				@DOCUMENT_ID = [DOCUMENT_ID]
				,@HEADER_POSTEDDATIME = [POSTED_DATETIME]
				,@HEADER_DETAIL_QTY = [DETAIL_QTY]
				,@DOC_RESOLUTION = [DOC_RESOLUTION]
				,@DOC_SERIE = [DOC_SERIE]
				,@DOC_NUM = [DOC_NUM]
				,@CODE_ROUTE = [POS_TERMINAL]
				,@CODE_CUSTOMER = [CLIENT_ID]
				,@DOC_TYPE = [DOCUMENT_TYPE]
				,@ID_BO = [DOCUMENT_ID_BO]
				,@SIGNATURE = [SIGNATURE]
			FROM [#DOCUMENTS]
			-- ------------------------------------------------------------------------------------
			-- Obtiene el _id
			-- ------------------------------------------------------------------------------------
			SELECT TOP 1
				@_ID = [_ID]
			FROM [#_ID]
			-- ------------------------------------------------------------------------------------
			-- Obtiene las imagenes
			-- ------------------------------------------------------------------------------------
			INSERT INTO @IMAGES
					([IMAGE] ,[DOCUMENT_ID], [NUMBER])
			SELECT 
					[x].[Rec].[query]('./content').[value]('.', 'varchar(MAX)')
					,@DOCUMENT_ID
					,[x].[Rec].[query]('./id').[value]('.', 'varchar(MAX)')
			FROM @XML.[nodes]('/Data/documents/document/Images') as [x]([Rec])
			-- ------------------------------------------------------------------------------------
			-- Obtiene el detalle
			-- ------------------------------------------------------------------------------------
			INSERT INTO @DETAIL
					(
						[DOCUMENT_ID]
						,[SKU]
						,[INVOICE_SERIAL]
						,[LINE_SEQ]
						,[QTY] 
						,[PRICE] 
						,[DISCOUNT] 
						,[TOTAL_LINE] 
						,[POSTED_DATETIME] 
						,[SERIE] 
						,[SERIE_2]
						,[REQUERIES_SERIE] 
						,[COMBO_REFERENCE]
						,[PARENT_SEQ]
						,[IS_ACTIVE_ROUTE] 
						,[CODE_PACK_UNIT]
						,[IS_BONUS] 
						,[LONG]
						,[RESOLUTION]
					)
			SELECT
				@DOCUMENT_ID
				,[x].[Rec].[query]('./Sku').[value]('.', 'varchar(50)')
				,@DOC_SERIE
				,[x].[Rec].[query]('./LineSeq').[value]('.', 'int')
				,[x].[Rec].[query]('./Qty').[value]('.', 'int')
				,[x].[Rec].[query]('./Price').[value]('.', 'money')
				,[x].[Rec].[query]('./Discount').[value]('.', 'money')
				,[x].[Rec].[query]('./TotalLine').[value]('.', 'money')
				,@HEADER_POSTEDDATIME
				,[x].[Rec].[query]('./Serie').[value]('.', 'varchar(50)')
				,[x].[Rec].[query]('./Serie2').[value]('.', 'varchar(50)')
				,CASE [x].[Rec].[query]('./RequeriesSerie').[value]('.', 'varchar(50)') WHEN 'true' THEN 1 ELSE 0 END 
				,[x].[Rec].[query]('./ComboReference').[value]('.', 'varchar(50)')
				,CASE [x].[Rec].[query]('./ParentSeq').[value]('.', 'varchar(50)') WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./ParentSeq').[value]('.', 'int') END
				,[x].[Rec].[query]('./IsActive').[value]('.', 'int')
				,[x].[Rec].[query]('./CodePackUnit').[value]('.', 'varchar(50)')
				,CASE [x].[Rec].[query]('./IsBonus').[value]('.', 'varchar(50)') WHEN 'NO' THEN 0 ELSE 1 END
				,CASE x.Rec.query('./Long').value('.', 'varchar(50)') WHEN 'null' THEN NULL ELSE x.Rec.query('./Long').value('.', 'varchar(50)') END
				,@DOC_RESOLUTION
			FROM @xml.[nodes]('/Data/documents/document/Lines') as [x]([Rec])
			WHERE [x].[Rec].[query]('./DocumentId').[value]('.', 'int') = @DOCUMENT_ID
			--
			SET @DETAIL_QTY = @@ROWCOUNT

			IF(@DETAIL_QTY = @HEADER_DETAIL_QTY)
			BEGIN
				IF(@DOC_TYPE = 0) -- FACTURA
				BEGIN
					-- ------------------------------------------------------------------------------------
					-- Valida si existe la factura
					-- ------------------------------------------------------------------------------------
					INSERT INTO @RESULT_VALIDATION_INVOICE
					EXEC [SONDA].[SONDA_SP_VALIDATE_IF_EXISTS_INVOICE_DOCUMENT] 
						@CODE_ROUTE = @CODE_ROUTE
						,@CODE_CUSTOMER = @CODE_CUSTOMER
						,@DOC_RESOLUTION = @DOC_RESOLUTION
						,@DOC_SERIE = @DOC_SERIE
						,@DOC_NUM = @DOC_NUM
						,@POSTED_DATETIME = @HEADER_POSTEDDATIME
						,@DETAIL_QTY = @DETAIL_QTY
						,@DECREASE_INVENTORY = 0
						,@ID_BO = @ID_BO
						,@XML = @XML
						,@JSON = @JSON
					--
					SELECT
						@EXISTS = [R].[EXISTS]
						,@ID = [R].[ID]
					FROM @RESULT_VALIDATION_INVOICE [R] 
					--
					IF(@EXISTS = 1)
					BEGIN
						PRINT '--> ya existe la factura con el ID :' + CAST(@ID AS VARCHAR)
						--
						INSERT INTO @RESULTS
								(
									[DOC_ID]
									,[BO_ID]
									,[DOC_SERIE]
									,[DOC_NUM]
									,[DOC_TYPE]
									,[SUCCESS]
									,[ERROR]
									,[_ID]
								)
						VALUES
								(
									@DOCUMENT_ID  -- DOC_ID - int
									,@ID  -- BO_ID - varchar(100)
									,@DOC_SERIE  -- DOC_SERIE - varchar(100)
									,@DOC_NUM  -- DOC_NUM - int
									,@DOC_TYPE -- DOC_TYPE - int
									,0
									,'Ya existe la factura con el ID :' + CAST(@ID AS VARCHAR)
									,@_ID
								)
					END
					ELSE
					BEGIN
						BEGIN TRY
							BEGIN TRAN
							-- ------------------------------------------------------------------------------------
							-- Inserta el encabezado
							-- ------------------------------------------------------------------------------------
							INSERT INTO [SONDA].[SONDA_POS_INVOICE_HEADER]
									(
										[INVOICE_ID]
										,[TERMS]
										,[POSTED_DATETIME]
										,[CLIENT_ID]
										,[POS_TERMINAL]
										,[GPS_URL]
										,[TOTAL_AMOUNT]
										,[STATUS]
										,[POSTED_BY]
										,[IMAGE_1]
										,[IMAGE_2]
										,[IMAGE_3]
										,[IS_POSTED_OFFLINE]
										,[INVOICED_DATETIME]
										,[DEVICE_BATTERY_FACTOR]
										,[CDF_INVOICENUM]
										,[CDF_DOCENTRY]
										,[CDF_SERIE]
										,[CDF_NIT]
										,[CDF_NOMBRECLIENTE]
										,[CDF_RESOLUCION]
										,[CDF_POSTED_ERP]
										,[IS_CREDIT_NOTE]
										,[VOID_DATETIME]
										,[CDF_PRINTED_COUNT]
										,[VOID_REASON]
										,[VOID_NOTES]
										,[VOIDED_INVOICE]
										,[CLOSED_ROUTE_DATETIME]
										,[CLEARING_DATETIME]
										,[IS_ACTIVE_ROUTE]
										,[SOURCE_CODE]
										,[GPS_EXPECTED]
										,[ATTEMPTED_WITH_ERROR]
										,[IS_POSTED_ERP]
										,[POSTED_ERP]
										,[POSTED_RESPONSE]
										,[IS_DRAFT]
										,[ERP_REFERENCE]
										-- ,[CONSIGNMENT_ID]
										,[LIQUIDATION_ID]
										-- ,[INITIAL_TASK_IMAGE]
										,[IN_ROUTE_PLAN]
										,[IS_READY_TO_SEND]
										,[IS_SENDING]
										,[LAST_UPDATE_IS_SENDING]
										,[SIGNATURE]
									)
							SELECT
								@DOC_NUM
								,[x].[Rec].[query]('./Terms').[value]('.', 'varchar(50)')
								,GETDATE()
								,@CODE_CUSTOMER
								,@CODE_ROUTE
								,[x].[Rec].[query]('./GpsUrl').[value]('.', 'varchar(50)')
								,[x].[Rec].[query]('./TotalAmount').[value]('.', 'money')
								,[x].[Rec].[query]('./Status').[value]('.', 'int')
								,@LOGIN
								,ISNULL((SELECT TOP 1 [IMAGE] FROM @IMAGES WHERE [NUMBER] = 1 AND [DOCUMENT_ID] = @DOCUMENT_ID),'')
								,ISNULL((SELECT TOP 1 [IMAGE] FROM @IMAGES WHERE [NUMBER] = 2 AND [DOCUMENT_ID] = @DOCUMENT_ID),'')
								,ISNULL((SELECT TOP 1 [IMAGE] FROM @IMAGES WHERE [NUMBER] = 3 AND [DOCUMENT_ID] = @DOCUMENT_ID),'')
								,NULL
								,@HEADER_POSTEDDATIME
								,[x].[Rec].[query]('./Battery').[value]('.', 'int')
								,NULL
								,NULL
								,@DOC_SERIE
								,[x].[Rec].[query]('./TaxId').[value]('.', 'varchar(50)')
								,[x].[Rec].[query]('./ClientName').[value]('.', 'varchar(150)')
								,@DOC_RESOLUTION
								,NULL
								,CASE [x].[Rec].[query]('./IsVoid').[value]('.', 'varchar(50)') WHEN 'true' THEN 1 ELSE 0 END 
								,NULL
								,[x].[Rec].[query]('./TimesPrinted').[value]('.', 'int')
								,CASE [x].[Rec].[query]('./VoidReason').[value]('.', 'varchar(50)') WHEN '' THEN NULL ELSE [x].[Rec].[query]('./VoidReason').[value]('.', 'varchar(50)') END
								,CASE [x].[Rec].[query]('./VoidNotes').[value]('.', 'varchar(MAX)') WHEN '' THEN NULL ELSE [x].[Rec].[query]('./VoidNotes').[value]('.', 'varchar(MAX)') END
								,NULL
								,NULL
								,NULL
								,1
								,NULL
								,NULL
								,NULL
								,NULL
								,NULL
								,NULL
								,0
								,NULL
								-- ,CASE [x].[Rec].[query]('./ConsignmnetId').[value]('.', 'varchar(50)') WHEN 'null' THEN NULL ELSE [x].[Rec].[query]('./ConsignmnetId').[value]('.', 'int') END
								,NULL
								-- ,CASE [x].[Rec].[query]('./InitialTaskImage').[value]('.', 'varchar(MAX)') WHEN '' THEN NULL ELSE [x].[Rec].[query]('./InitialTaskImage').[value]('.', 'varchar(MAX)') END
								,[x].[Rec].[query]('./InRoutePlan').[value]('.', 'int')
								,1--[IS_READY_TO_SEND]
								,0--[IS_SENDING]
								,NULL --[LAST_UPDATE_IS_SENDING]
								,@SIGNATURE
							FROM @xml.[nodes]('/Data/documents/document') as [x]([Rec])
							WHERE [x].[Rec].[query]('./DocumentId').[value]('.', 'int') = @DOCUMENT_ID
							--
							SET @ID = SCOPE_IDENTITY()

							-- ------------------------------------------------------------------------------------
							-- inserta el detalle
							-- ------------------------------------------------------------------------------------
							INSERT INTO [SONDA].[SONDA_POS_INVOICE_DETAIL]
									(
										[INVOICE_ID]
										,[INVOICE_SERIAL]
										,[SKU]
										,[LINE_SEQ]
										,[QTY]
										,[PRICE]
										,[DISCOUNT]
										,[TOTAL_LINE]
										,[POSTED_DATETIME]
										,[SERIE]
										,[SERIE_2]
										,[REQUERIES_SERIE]
										,[COMBO_REFERENCE]
										,[INVOICE_RESOLUTION]
										,[PARENT_SEQ]
										,[IS_ACTIVE_ROUTE]
										,[ID]
									)
							SELECT
								@DOC_NUM
								,[D].[INVOICE_SERIAL]
								,[D].[SKU]
								,[D].[LINE_SEQ]
								,[D].[QTY]
								,[D].[PRICE]
								,[D].[DISCOUNT]
								,[D].[TOTAL_LINE]
								,[D].[POSTED_DATETIME]
								,[D].[SERIE]
								,[D].[SERIE_2]
								,[D].[REQUERIES_SERIE]
								,[D].[COMBO_REFERENCE]
								,@DOC_RESOLUTION
								,[D].[PARENT_SEQ]
								,[D].[IS_ACTIVE_ROUTE]
								,@ID
							FROM @DETAIL [D]
					
							--
							COMMIT

							INSERT INTO @RESULTS
									(
										[DOC_ID]
										,[BO_ID]
										,[DOC_SERIE]
										,[DOC_NUM]
										,[DOC_TYPE]
										,[SUCCESS]
										,[ERROR]
										,[_ID]
									)
							VALUES
									(
										@DOCUMENT_ID  -- DOC_ID - int
										,@ID  -- BO_ID - int
										,@DOC_SERIE  -- DOC_SERIE - varchar(100)
										,@DOC_NUM  -- DOC_NUM - int
										,@DOC_TYPE  -- DOC_TYPE - int
										,1  -- SUCCESS - int
										,NULL  -- ERROR - varchar(100)
										,@_ID
									)
						END TRY
						BEGIN CATCH
							ROLLBACK
							--
							SET @INSERT_ERROR = ERROR_MESSAGE()
							--
							PRINT 'CATCH de insert: ' + @INSERT_ERROR + ' para documento: ' + CAST(@DOCUMENT_ID AS VARCHAR(10))
							--
							INSERT INTO @RESULTS
							(
								[DOC_ID]
								,[BO_ID]
								,[DOC_SERIE]
								,[DOC_NUM]
								,[DOC_TYPE]
								,[SUCCESS]
								,[ERROR]
								,[_ID]
							)
							VALUES
							(
								@DOCUMENT_ID  -- DOC_ID - int
								,NULL  -- BO_ID - int
								,@DOC_SERIE  -- DOC_SERIE - varchar(100)
								,@DOC_NUM  -- DOC_NUM - int
								,@DOC_TYPE  -- DOC_TYPE - int
								,0  -- SUCCESS - int
								,@INSERT_ERROR  -- ERROR - varchar(100)
								,@_ID
							)
						END CATCH
					END
				END
				ELSE IF(@DOC_TYPE = 1) -- ORDEN DE VENTA
				BEGIN
					-- ------------------------------------------------------------------------------------
					-- Valida si existe la orden de venta
					-- ------------------------------------------------------------------------------------
					INSERT INTO @RESULT_VALIDATION_SALES_ORDER
					EXEC [SONDA].[SONDA_SP_VALIDATED_IF_EXISTS_SALES_ORDER_2] 
						@DOC_SERIE = @DOC_SERIE,
						@DOC_NUM = @DOC_NUM, -- int
						@CODE_ROUTE = @CODE_ROUTE, -- varchar(50)
						@CODE_CUSTOMER = @CODE_CUSTOMER, -- varchar(50)
						@POSTED_DATETIME = @HEADER_POSTEDDATIME, -- datetime
						@DETAIL_QTY = 0, -- int
						@XML = @XML, -- xml
						@JSON = @JSON, -- varchar(max)
						@COMMITTED_INVENTORY = 0 -- int
					--
					SELECT
						@EXISTS = [R].[EXISTS]
						,@ID = [R].[ID]
					FROM @RESULT_VALIDATION_SALES_ORDER [R] 
					--
					IF(@EXISTS = 1)
					BEGIN
						PRINT '--> ya existe la orden de venta con el ID :' + CAST(@ID AS VARCHAR)
						--
						--
						INSERT INTO @RESULTS
								(
									[DOC_ID]
									,[BO_ID]
									,[DOC_SERIE]
									,[DOC_NUM]
									,[DOC_TYPE]
									,[SUCCESS]
									,[ERROR]
									,[_ID]
								)
						VALUES
								(
									@DOCUMENT_ID  -- DOC_ID - int
									,@ID  -- BO_ID - varchar(100)
									,@DOC_SERIE  -- DOC_SERIE - varchar(100)
									,@DOC_NUM  -- DOC_NUM - int
									,@DOC_TYPE -- DOC_TYPE - int
									,0
									,'Ya existe la orden de venta con el ID :' + CAST(@ID AS VARCHAR)
									,@_ID
								)
					END
					ELSE
					BEGIN
						BEGIN TRY
							BEGIN TRAN
					
							-- ------------------------------------------------------------------------------------
							-- Inserta el encabezado
							-- ------------------------------------------------------------------------------------
							INSERT INTO [SONDA].[SONDA_SALES_ORDER_HEADER]
									(
										[TERMS]
										,[POSTED_DATETIME]
										,[CLIENT_ID]
										,[POS_TERMINAL]
										,[GPS_URL]
										,[TOTAL_AMOUNT]
										,[STATUS]
										,[POSTED_BY]
										,[IMAGE_1]
										,[IMAGE_2]
										,[IMAGE_3]
										,[DEVICE_BATTERY_FACTOR]
										,[VOID_DATETIME]
										,[VOID_REASON]
										,[VOID_NOTES]
										,[VOIDED]
										,[CLOSED_ROUTE_DATETIME]
										,[IS_ACTIVE_ROUTE]
										,[GPS_EXPECTED]
										,[DELIVERY_DATE]
										,[SALES_ORDER_ID_HH]
										,[ATTEMPTED_WITH_ERROR]
										,[IS_POSTED_ERP]
										,[POSTED_ERP]
										,[POSTED_RESPONSE]
										,[IS_PARENT]
										,[REFERENCE_ID]
										,[WAREHOUSE]
										,[TIMES_PRINTED]
										,[DOC_SERIE]
										,[DOC_NUM]
										,[IS_VOID]
										-- ,[SALES_ORDER_TYPE]
										,[DISCOUNT]
										,[IS_DRAFT]
										,[ASSIGNED_BY]
										,[TASK_ID]
										,[COMMENT]
										,[ERP_REFERENCE]
										,[PAYMENT_TIMES_PRINTED]
										,[PAID_TO_DATE]
										,[TO_BILL]
										,[HAVE_PICKING]
										,[AUTHORIZED]
										,[AUTHORIZED_BY]
										,[AUTHORIZED_DATE]
										,[DISCOUNT_BY_GENERAL_AMOUNT]
										,[IS_READY_TO_SEND]
									)
							SELECT
								NULL
								,@HEADER_POSTEDDATIME
								,x.Rec.query('./ClientId').value('.', 'varchar(50)')
								,@CODE_ROUTE
								,x.Rec.query('./GpsUrl').value('.', 'varchar(50)')
								,x.Rec.query('./TotalAmount').value('.', 'money')
								,x.Rec.query('./Status').value('.', 'int')
								,x.Rec.query('./PostedBy').value('.', 'varchar(50)')
								,@SIGNATURE
								,ISNULL((SELECT TOP 1 [IMAGE] FROM @IMAGES WHERE [NUMBER] = 1),'')
								,ISNULL((SELECT TOP 1 [IMAGE] FROM @IMAGES WHERE [NUMBER] = 2),'')
								,x.Rec.query('./Battery').value('.', 'int')
								,CASE x.Rec.query('./VoidDatetime').value('.', 'varchar(50)') WHEN 'null' THEN NULL ELSE x.Rec.query('./VoidDatetime').value('.', 'DATETIME') END
								,CASE x.Rec.query('./VoidReason').value('.', 'varchar(50)') WHEN 'null' THEN NULL ELSE x.Rec.query('./VoidReason').value('.', 'VARCHAR(25)') END
								,CASE x.Rec.query('./VoidNotes').value('.', 'varchar(50)') WHEN 'null' THEN NULL ELSE x.Rec.query('./VoidNotes').value('.', 'VARCHAR(MAX)') END
								,CASE x.Rec.query('./Voided').value('.', 'varchar(50)') WHEN 'null' THEN NULL ELSE x.Rec.query('./Voided').value('.', 'INT') END
								,CASE x.Rec.query('./ClosedRouteDatetime').value('.', 'varchar(50)') WHEN 'null' THEN NULL ELSE x.Rec.query('./ClosedRouteDatetime').value('.', 'DATETIME') END
								,CASE x.Rec.query('./IsActiveRoute').value('.', 'varchar(50)') WHEN 'NO' THEN 0 ELSE 1 END
								,x.Rec.query('./GpsUrl').value('.', 'varchar(50)')
								,x.Rec.query('./DeliveryDate').value('.', 'DATETIME')
								,x.Rec.query('./SalesOrderId').value('.', 'int')
								,0
								,NULL
								,NULL
								,NULL
								,CASE [x].[Rec].[query]('./IsParent').[value]('.', 'varchar(50)') WHEN 'true' THEN 1 ELSE 0 END 
								,x.Rec.query('./ReferenceId').value('.', 'varchar(150)')						
								,@WAREHOUSE
								,x.Rec.query('./TimesPrinted').value('.', 'int')
								,x.Rec.query('./DocSerie').value('.', 'varchar(50)')
								,x.Rec.query('./DocNum').value('.', 'int')
								,CASE [x].[Rec].[query]('./IsVoid').[value]('.', 'varchar(50)') WHEN 'true' THEN 1 ELSE 0 END 
								-- ,x.Rec.query('./SalesOrderType').value('.', 'varchar(50)')
								,0
								,CASE x.Rec.query('./IsDraft').value('.', 'varchar(50)') WHEN 'NO' THEN 0 ELSE 1 END
								,'HH'
								,x.Rec.query('./TaskId').value('.', 'int')
								,x.Rec.query('./Comment').value('.', 'varchar(250)')
								,NULL
								,x.Rec.query('./PaymentTimesPrinted').value('.', 'int')
								,x.Rec.query('./PaidToDate').value('.', 'numeric(18,6)')
								,x.Rec.query('./ToBill').value('.', 'int')
								,0
								,CASE x.Rec.query('./Authorized').value('.', 'varchar(50)') WHEN 'NO' THEN 0 ELSE 1 END
								,NULL
								,NULL
								,x.Rec.query('./Discount').value('.', 'numeric(18,6)')
								,1
							FROM @xml.[nodes]('/Data/documents/document') as [x]([Rec])
							WHERE [x].[Rec].[query]('./DocumentId').[value]('.', 'int') = @DOCUMENT_ID
							--
							SET @ID = SCOPE_IDENTITY()

							-- ------------------------------------------------------------------------------------
							-- inserta el detalle
							-- ------------------------------------------------------------------------------------
							INSERT INTO [SONDA].[SONDA_SALES_ORDER_DETAIL]
									(
										[SALES_ORDER_ID]
										,[SKU]
										,[LINE_SEQ]
										,[QTY]
										,[PRICE]
										,[DISCOUNT]
										,[TOTAL_LINE]
										,[POSTED_DATETIME]
										,[SERIE]
										,[SERIE_2]
										,[REQUERIES_SERIE]
										,[COMBO_REFERENCE]
										,[PARENT_SEQ]
										,[IS_ACTIVE_ROUTE]
										,[CODE_PACK_UNIT]
										,[IS_BONUS]
										,[LONG]
									)
							SELECT
								@ID
								,[D].[SKU]
								,[D].[LINE_SEQ]
								,[D].[QTY]
								,[D].[PRICE]
								,[D].[DISCOUNT]
								,[D].[TOTAL_LINE]
								,[D].[POSTED_DATETIME]
								,[D].[SERIE]
								,[D].[SERIE_2]
								,[D].[REQUERIES_SERIE]
								,[D].[COMBO_REFERENCE]
								,[D].[PARENT_SEQ]
								,[D].[IS_ACTIVE_ROUTE]
								,[D].[CODE_PACK_UNIT]
								,[D].[IS_BONUS]
								,[D].[LONG]
							FROM @DETAIL [D]
							--
							COMMIT
							INSERT INTO @RESULTS
									(
										[DOC_ID]
										,[BO_ID]
										,[DOC_SERIE]
										,[DOC_NUM]
										,[DOC_TYPE]
										,[SUCCESS]
										,[ERROR]
										,[_ID]
									)
							VALUES
									(
										@DOCUMENT_ID  -- DOC_ID - int
										,@ID  -- BO_ID - int
										,@DOC_SERIE  -- DOC_SERIE - varchar(100)
										,@DOC_NUM  -- DOC_NUM - int
										,@DOC_TYPE  -- DOC_TYPE - int
										,1  -- SUCCESS - int
										,NULL  -- ERROR - varchar(100)
										,@_ID
									)
						END TRY
						BEGIN CATCH
							ROLLBACK
							--
							SET @INSERT_ERROR = ERROR_MESSAGE()
							--
							PRINT 'CATCH de insert: ' + @INSERT_ERROR + ' para documento: ' + CAST(@DOCUMENT_ID AS VARCHAR(10))
							--
							INSERT INTO @RESULTS
							(
								[DOC_ID]
								,[BO_ID]
								,[DOC_SERIE]
								,[DOC_NUM]
								,[DOC_TYPE]
								,[SUCCESS]
								,[ERROR]
								,[_ID]
							)
							VALUES
							(
								@DOCUMENT_ID  -- DOC_ID - int
								,NULL  -- BO_ID - int
								,@DOC_SERIE  -- DOC_SERIE - varchar(100)
								,@DOC_NUM  -- DOC_NUM - int
								,@DOC_TYPE  -- DOC_TYPE - int
								,0  -- SUCCESS - int
								,@INSERT_ERROR  -- ERROR - varchar(100)
								,@_ID
							)
						END CATCH
					END
				END
			END
			ELSE
			BEGIN
				INSERT INTO @RESULTS
				(
					[DOC_ID]
					,[BO_ID]
					,[DOC_SERIE]
					,[DOC_NUM]
					,[DOC_TYPE]
					,[SUCCESS]
					,[ERROR]
					,[_ID]
				)
				VALUES
				(
					@DOCUMENT_ID  -- DOC_ID - int
					,NULL  -- BO_ID - int
					,@DOC_SERIE  -- DOC_SERIE - varchar(100)
					,@DOC_NUM  -- DOC_NUM - int
					,@DOC_TYPE  -- DOC_TYPE - int
					,0  -- SUCCESS - int
					,'DocumentId '+CAST(@DOCUMENT_ID AS VARCHAR(50))+': No cuadra la cantidad de lineas que dice el encabezdo con las del detalle.'  -- ERROR - varchar(100)
					,@_ID
				)
			END
			-- ------------------------------------------------------------------------------------
			-- Elimina el registro del documento ya procesado
			-- ------------------------------------------------------------------------------------
			DELETE FROM [#DOCUMENTS] WHERE [DOCUMENT_ID] = @DOCUMENT_ID
			DELETE FROM [#_ID] WHERE [_ID] = @_ID
			DELETE FROM @DETAIL
			DELETE FROM @RESULT_VALIDATION_INVOICE
			DELETE FROM @RESULT_VALIDATION_SALES_ORDER
			DELETE FROM @IMAGES
		END;
		
		SELECT [DOC_ID]
				,[BO_ID]
				,[DOC_SERIE]
				,[DOC_NUM]
				,[DOC_TYPE]
				,[SUCCESS]
				,[ERROR] 
				,[_ID]
		FROM @RESULTS
	END TRY
	BEGIN CATCH
		DECLARE @ERROR VARCHAR(1000) = ERROR_MESSAGE()
		PRINT 'CATCH: ' + @ERROR
		RAISERROR (@ERROR,16,1)
	END CATCH
END
