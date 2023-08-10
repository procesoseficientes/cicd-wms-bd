-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	5/19/2017 @ A-TEAM Sprint  
-- Description:			Valida si el documento de factura u orden de venta estan posteados

/*
-- Ejemplo de Ejecucion:
		USE [SWIFT_EXPRESS]
		EXEC [SONDA].[SONDA_SP_VALIDATE_DOCUMENTS_IS_POSTED]] @XML = '
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
CREATE PROCEDURE [SONDA].[SONDA_SP_VALIDATE_DOCUMENTS_IS_POSTED](
	@XML XML
	,@JSON VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE	@DOCUMENT TABLE (
		[ID] INT
		,[DOC_RESOLUTION] VARCHAR(100)
		,[DOC_SERIE] VARCHAR(100)
		,[DOC_NUM] INT
		,[CODE_CUSTOMER] VARCHAR(50)
		,[POSTED_DATIME] DATETIME
		,[DETAIL_QTY] INT
		,[DOC_TYPE] INT
		,[DOC_ID] INT
	);
	--
	DECLARE @RESULT_VALIDATION_INVOICE TABLE (
		[EXISTS] [INT]
		,[ID] [INT]
		,[DOC_RESOLUTION] VARCHAR(100)
		,[DOC_SERIE] VARCHAR(100)
		,[DOC_NUM] INT
		,[DOC_ID] INT
		,[_ID] VARCHAR(150)
	)
	--
	DECLARE @RESULT_VALIDATION_SALES_ORDER TABLE (
		[EXISTS] INT
		,[ID] INT
		,[DOC_SERIE] VARCHAR(100)
		,[DOC_NUM] INT
		,[DOC_ID] INT
		,[_ID] VARCHAR(150)
	)
	--
	DECLARE 
		@CODE_ROUTE VARCHAR(50)
		,@ID INT
		,@POSTED_DATIME DATETIME
		,@DETAIL_QTY INT
		,@DOC_RESOLUTION VARCHAR(100)
		,@DOC_SERIE VARCHAR(100)
		,@DOC_NUM INT
		,@CODE_CUSTOMER VARCHAR(50)
		,@DOCUMENT_XML XML
		,@DOC_TYPE INT
		,@DOC_ID INT
		,@_ID VARCHAR(150);
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene los datos generales de la ruta
	-- ------------------------------------------------------------------------------------
	SELECT 
		@CODE_ROUTE = [x].[Rec].[query]('./routeid').[value]('.', 'varchar(50)')
	FROM @xml.[nodes]('/Data') as [x]([Rec])
	

	-- ------------------------------------------------------------------------------------
	-- Obtiene los documentos a validar
	-- ------------------------------------------------------------------------------------
	INSERT INTO @DOCUMENT
			(
				[ID]
				,[DOC_RESOLUTION]
				,[DOC_SERIE]
				,[DOC_NUM]
				,[CODE_CUSTOMER]
				,[POSTED_DATIME]
				,[DETAIL_QTY]
				,[DOC_TYPE]
				,[DOC_ID]
			)
	SELECT
		CASE [x].[Rec].[query]('./DocumentIdBo').[value]('.', 'varchar(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./DocumentIdBo').[value]('.', 'int') END
		,[x].[Rec].[query]('./DocResolution').[value]('.', 'varchar(50)')
		,[x].[Rec].[query]('./DocSerie').[value]('.', 'varchar(50)')
		,CASE [x].[Rec].[query]('./DocNum').[value]('.', 'varchar(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./DocNum').[value]('.', 'int') END
		,[x].[Rec].[query]('./ClientId').[value]('.', 'varchar(50)')
		,[x].[Rec].[query]('./PostedDatetime').[value]('.', 'datetime')
		,CASE [x].[Rec].[query]('./DetailQty').[value]('.', 'varchar(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./DetailQty').[value]('.', 'int') END
		,CASE [x].[Rec].[query]('./DocmentType').[value]('.', 'varchar(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./DocmentType').[value]('.', 'int') END
		,CASE [x].[Rec].[query]('./DocumentId').[value]('.', 'varchar(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./DocumentId').[value]('.', 'int') END
	FROM @XML.[nodes]('/Data/documents/document') as [x]([Rec])
	-- ------------------------------------------------------------------------------------
	-- Obtiene los _id de todos los documentos
	-- ------------------------------------------------------------------------------------
	SELECT
		[x].[Rec].query('./_id').value('.','varchar(150)') [_ID]
	INTO [#_ID]
	FROM @XML.nodes('/Data/documents') AS [x]([Rec])
	-- ------------------------------------------------------------------------------------
	-- Ciclo para validar documentos
	-- ------------------------------------------------------------------------------------
	WHILE EXISTS(SELECT TOP 1 1 FROM @DOCUMENT)
	BEGIN
		-- ------------------------------------------------------------------------------------
		-- Se toma documento a valdiar
		-- ------------------------------------------------------------------------------------
		SELECT TOP 1
			@ID = [ID]
			,@DOC_RESOLUTION = [DOC_RESOLUTION]
			,@DOC_SERIE = [DOC_SERIE]
			,@DOC_NUM = [DOC_NUM]
			,@CODE_CUSTOMER = [CODE_CUSTOMER]
			,@POSTED_DATIME = [POSTED_DATIME]
			,@DETAIL_QTY = [DETAIL_QTY]
			,@DOC_TYPE = [DOC_TYPE]
			,@DOC_ID = [DOC_ID]
		FROM @DOCUMENT
		--
		SELECT TOP 1
			@_ID = [_ID]
		FROM [#_ID]

		IF(@DOC_TYPE = 0)
		BEGIN
			-- ------------------------------------------------------------------------------------
			-- Valida si existe la factura
			-- ------------------------------------------------------------------------------------
			SELECT @DOCUMENT_XML = (
				SELECT 
					CASE [x].[Rec].[query]('./DocumentIdBo').[value]('.', 'VARCHAR(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./DocumentIdBo').[value]('.', 'int') END IdBo
					,[x].[Rec].[query]('./DocResolution').[value]('.', 'varchar(50)') AuthId
					,[x].[Rec].[query]('./DocSerie').[value]('.', 'varchar(50)') SatSerie
					,[x].[Rec].[query]('./DocNum').[value]('.', 'int') InvoiceId
					,[x].[Rec].[query]('./ClientId').[value]('.', 'varchar(50)') ClientId
					,[x].[Rec].[query]('./PostedDatetime').[value]('.', 'datetime') PostedDatetime
					,[x].[Rec].[query]('./DetailQty').[value]('.', 'int') DetailNum
				FROM @xml.[nodes]('/Data/documents/document') as [x]([Rec])
				WHERE CASE [x].[Rec].[query]('./DocumentIdBo').[value]('.', 'VARCHAR(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./DocumentIdBo').[value]('.', 'int') END = @ID
				FOR XML PATH ('Invoices'),ROOT('Data')
			)
			--
			INSERT INTO @RESULT_VALIDATION_INVOICE ([EXISTS], [ID], [DOC_RESOLUTION], [DOC_SERIE], [DOC_NUM])
			EXEC [SONDA].[SONDA_SP_VALIDATED_IF_EXISTS_INVOICE] 
				@CODE_ROUTE = @CODE_ROUTE
				,@CODE_CUSTOMER = @CODE_CUSTOMER
				,@DOC_RESOLUTION = @DOC_RESOLUTION
				,@DOC_SERIE = @DOC_SERIE
				,@DOC_NUM = @DOC_NUM
				,@POSTED_DATETIME = @POSTED_DATIME
				,@DETAIL_QTY = @DETAIL_QTY
				,@DECREASE_INVENTORY = 1
				,@XML = @DOCUMENT_XML
				,@JSON = @JSON
			UPDATE @RESULT_VALIDATION_INVOICE SET [DOC_ID] = @DOC_ID, [_ID] = @_ID WHERE [DOC_RESOLUTION] = @DOC_RESOLUTION AND [DOC_SERIE] = @DOC_SERIE AND [DOC_NUM] = @DOC_NUM
		END
		ELSE IF(@DOC_TYPE = 1)
		BEGIN
			-- ------------------------------------------------------------------------------------
			-- Valida si existe orden de venta
			-- ------------------------------------------------------------------------------------
			SELECT @DOCUMENT_XML = (
				SELECT 
					CASE [x].[Rec].[query]('./DocumentIdBo').[value]('.', 'VARCHAR(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./DocumentIdBo').[value]('.', 'int') END IdBo
					,[x].[Rec].[query]('./DocResolution').[value]('.', 'varchar(50)') DocResolution
					,[x].[Rec].[query]('./DocSerie').[value]('.', 'varchar(50)') DocSerie
					,[x].[Rec].[query]('./DocNum').[value]('.', 'int') DocNum
					,[x].[Rec].[query]('./ClientId').[value]('.', 'varchar(50)') ClientId
					,[x].[Rec].[query]('./PostedDatetime').[value]('.', 'datetime') PostedDatetime
					,[x].[Rec].[query]('./DetailQty').[value]('.', 'int') DetailQty
				FROM @xml.[nodes]('/Data/documents/document') as [x]([Rec])
				WHERE CASE [x].[Rec].[query]('./DocumentIdBo').[value]('.', 'VARCHAR(50)') WHEN '' THEN NULL WHEN 'NULL' THEN NULL ELSE [x].[Rec].[query]('./DocumentIdBo').[value]('.', 'int') END = @ID
				FOR XML PATH ('SalesOrder'),ROOT('Data')
			)
			--SELECT @ID, @DOC_ID, @DOC_SERIE, @DOC_NUM, @DETAIL_QTY, @DOCUMENT_XML, @JSON
			INSERT INTO @RESULT_VALIDATION_SALES_ORDER([EXISTS],[ID],[DOC_SERIE],[DOC_NUM])
			EXEC [SONDA].[SONDA_SP_VALIDATE_SALE_ORDER_IS_POSTED] 
				@SALES_ORDER_ID = @ID
				,@SALES_ORDER_ID_HH = @DOC_ID
				,@DOC_SERIE = @DOC_SERIE
				,@DOC_NUM = @DOC_NUM
				,@DETAIL_NUM = @DETAIL_QTY
				,@XML = @DOCUMENT_XML
				,@JSON = @JSON
			--
			UPDATE @RESULT_VALIDATION_SALES_ORDER SET [DOC_ID] = @DOC_ID, [_ID] = @_ID WHERE [DOC_SERIE] = @DOC_SERIE AND [DOC_NUM] = @DOC_NUM
		END	
		--
		DELETE FROM @DOCUMENT WHERE [ID] = @ID OR (
			ID IS NULL
			AND
			@ID IS NULL
		)
		--
		DELETE FROM [#_ID] WHERE [_ID] = @_ID
	END	
	-- ------------------------------------------------------------------------------------
	-- Envia resultado de validaciones
	-- ------------------------------------------------------------------------------------
	SELECT
		[EXISTS] [RESULT]
		,[ID] [ID]
		,[DOC_RESOLUTION] [DOC_RESOLUTION]
		,[DOC_SERIE] [DOC_SERIE]
		,[DOC_NUM] [DOC_NUM]
		,[DOC_ID] [DOC_ID]
		,[_ID] [_ID]
	FROM @RESULT_VALIDATION_INVOICE
	UNION ALL
	SELECT 
		[EXISTS] [RESULT]
		,[ID] [ID]
		,'' [DOC_RESOLUTION]
		,[DOC_SERIE] [DOC_SERIE]
		,[DOC_NUM] [DOC_NUM]
		,[DOC_ID] [DOC_ID]
		,[_ID] [_ID]
	FROM @RESULT_VALIDATION_SALES_ORDER
END
