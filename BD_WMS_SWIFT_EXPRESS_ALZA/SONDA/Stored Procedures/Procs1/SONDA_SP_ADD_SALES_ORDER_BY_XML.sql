-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-Mar-17 @ A-TEAM Sprint Ebonne 
-- Description:			SP que inserta los pedidos

-- Modificacion 7/27/2017 @ Sprint Bearbeitung
					-- rodrigo.gomez
					-- Se agrega la propiedad DISCOUNT_TYPE, se lee desde el XML y se inserta al detalle.

-- Modificacion 8/3/2017 @ Reborn-Team Sprint Bearbeitung
					-- diego.as
					-- se agrega la columna SERVER_POSTED_DATETIME que indica la fecha y hora en que se posteo el documento en el servidor

-- Modificacion 7/31/2017 @ Sprint Bearbeitung
					-- rodrigo.gomez
					-- Se agregan las dos culumnas DEVICE_NETWORK_TYPE e IS_POSTED_OFFLINE al XML y se inserta en el encabezado

-- Modificacion 8/24/2017 @ Reborn-Team Sprint Bearbeitung
					-- diego.as
					-- Se modifica tipo de datos en las columnas TOTAL_AMOUNT de la tabla SONDA_SALES_ORDER_HEADER
					-- asi tambien las columnas PRICE, DISCOUNT, TOTAL_LINE de la tabla SONDA_SALES_ORDER_DETAIL

-- Modificacion		11/21/2018 @ G-Force Team Sprint Mamut
-- Autor:			diego.as
-- Historia/Bug:	Product Backlog Item 25662: Precios Especiales en el movil
-- Descripcion:		11/21/2018 - Se agregan columnas
							--,[BASE_PRICE] NUMERIC(18 ,6)
							--,[CODE_FAMILY] VARCHAR(50)
							--,[UNIQUE_DISCOUNT_BY_SCALE_APPLIED] INT
							--,[DISPLAY_AMOUNT] NUMERIC(18 ,6)

/*			
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_ADD_SALES_ORDER_BY_XML]
					@XML = '<?xml version="1.0"?>
<Data>
  <salesOrder>
    <SalesOrderId>-3</SalesOrderId>
    <Terms>null</Terms>
    <PostedDatetime>2017/07/10 10:44:56</PostedDatetime>
    <ClientId>SO-2490686</ClientId>
    <PosTerminal>SOL0011@SONDA</PosTerminal>
    <GpsUrl>14.99522969,-90.80447165</GpsUrl>
    <TotalAmount>132.75</TotalAmount>
    <Status>0</Status>
    <PostedBy>sol0011@SONDA</PostedBy>
    <Image1 />
    <Image2 />
    <Image3>null</Image3>
    <DeviceBatteryFactor>87</DeviceBatteryFactor>
    <VoidDatetime>null</VoidDatetime>
    <VoidReason>null</VoidReason>
    <VoidNotes>null</VoidNotes>
    <Voided>null</Voided>
    <ClosedRouteDatetime>null</ClosedRouteDatetime>
    <IsActiveRoute>1</IsActiveRoute>
    <GpsExpected>14.9891943,-90.796127</GpsExpected>
    <SalesOrderIdBo>4605262</SalesOrderIdBo>
    <DeliveryDate>2017/7/11</DeliveryDate>
    <IsParent>1</IsParent>
    <ReferenceId>sol0011@SONDA2017/07/10 10:44:56-3</ReferenceId>
    <TimesPrinted>0</TimesPrinted>
    <DocSerie>SOL0011@SONDA</DocSerie>
    <DocNum>6034</DocNum>
    <IsVoid>0</IsVoid>
    <SalesOrderType>CREDIT</SalesOrderType>
    <Discount>0</Discount>
    <IsDraft>0</IsDraft>
    <TaskId>224275</TaskId>
    <Comment />
    <IsPosted>2</IsPosted>
    <Sinc>2</Sinc>
    <IsPostedVoid>2</IsPostedVoid>
    <IsUpdated>1</IsUpdated>
    <PaymentTimesPrinted>0</PaymentTimesPrinted>
    <PaidToDate>132.75</PaidToDate>
    <ToBill>0</ToBill>
    <Authorized>1</Authorized>
    <DetailQty>4</DetailQty>
	<DeviceNetworkType>3G</DeviceNetworkType>
	<IsPostedOffline>0</IsPostedOffline>
    <SaleDetails>
      <SalesOrderId>-3</SalesOrderId>
      <Sku>I00000319</Sku>
      <LineSeq>1</LineSeq>
      <Qty>2</Qty>
      <Price>27</Price>
      <Discount>0</Discount>
      <TotalLine>54</TotalLine>
      <PostedDatetime>2017/07/10 10:44:56</PostedDatetime>
      <Serie>0</Serie>
      <Serie2>0</Serie2>
      <RequeriesSerie>0</RequeriesSerie>
      <ComboReference>I00000319</ComboReference>
      <ParentSeq>1</ParentSeq>
      <IsActiveRoute>1</IsActiveRoute>
      <CodePackUnit>Manual</CodePackUnit>
      <IsBonus>0</IsBonus>
      <IsPostedVoid>2</IsPostedVoid>
      <Long>0</Long>
	  <discountType>NONE</discountType>
    </SaleDetails>
    <SaleDetails>
      <SalesOrderId>-3</SalesOrderId>
      <Sku>U00000392</Sku>
      <LineSeq>2</LineSeq>
      <Qty>15</Qty>
      <Price>2.75</Price>
      <Discount>0</Discount>
      <TotalLine>41.25</TotalLine>
      <PostedDatetime>2017/07/10 10:44:56</PostedDatetime>
      <Serie>0</Serie>
      <Serie2>0</Serie2>
      <RequeriesSerie>0</RequeriesSerie>
      <ComboReference>U00000392</ComboReference>
      <ParentSeq>1</ParentSeq>
      <IsActiveRoute>1</IsActiveRoute>
      <CodePackUnit>Manual</CodePackUnit>
      <IsBonus>0</IsBonus>
      <IsPostedVoid>2</IsPostedVoid>
      <Long>0</Long>
	  <discountType>NONE</discountType>
    </SaleDetails>
    <SaleDetails>
      <SalesOrderId>-3</SalesOrderId>
      <Sku>U00000383</Sku>
      <LineSeq>3</LineSeq>
      <Qty>15</Qty>
      <Price>2.5</Price>
      <Discount>0</Discount>
      <TotalLine>37.5</TotalLine>
      <PostedDatetime>2017/07/10 10:44:56</PostedDatetime>
      <Serie>0</Serie>
      <Serie2>0</Serie2>
      <RequeriesSerie>0</RequeriesSerie>
      <ComboReference>U00000383</ComboReference>
      <ParentSeq>1</ParentSeq>
      <IsActiveRoute>1</IsActiveRoute>
      <CodePackUnit>Manual</CodePackUnit>
      <IsBonus>0</IsBonus>
      <IsPostedVoid>2</IsPostedVoid>
      <Long>0</Long>
	  <discountType>NONE</discountType>
    </SaleDetails>
    <SaleDetails>
      <SalesOrderId>-3</SalesOrderId>
      <Sku>IP0000763</Sku>
      <LineSeq>4</LineSeq>
      <Qty>1</Qty>
      <Price>0</Price>
      <Discount>0</Discount>
      <TotalLine>0</TotalLine>
      <PostedDatetime>2017/07/10 10:44:56</PostedDatetime>
      <Serie>0</Serie>
      <Serie2>0</Serie2>
      <RequeriesSerie>0</RequeriesSerie>
      <ComboReference>IP0000763</ComboReference>
      <ParentSeq>1</ParentSeq>
      <IsActiveRoute>1</IsActiveRoute>
      <CodePackUnit>Manual</CodePackUnit>
      <IsBonus>1</IsBonus>
      <IsPostedVoid>2</IsPostedVoid>
      <Long>null</Long>
	  <discountType>NONE</discountType>
    </SaleDetails>
  </salesOrder>
  <dbuser>SONDA</dbuser>
  <dbuserpass>ServerSONDA</dbuserpass>
  <battery>63</battery>
  <routeid>SOL0011@SONDA</routeid>
  <warehouse>R008</warehouse>
  <uuid>a6941e7844e1768e</uuid>
</Data>'
					,@JSON = '{"salesOrder":{"SalesOrderId":-2,"Terms":"null","PostedDatetime":"2017/03/16 08:43:55","ClientId":"2373","PosTerminal":"6","GpsUrl":"14.6500982,-90.5397046","TotalAmount":305,"Status":"0","PostedBy":"Alberto@SONDA","Image1":"data:image/png;base64,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","Image2":"","Image3":null,"DeviceBatteryFactor":"26","VoidDatetime":null,"VoidReason":null,"VoidNotes":null,"Voided":null,"ClosedRouteDatetime":null,"IsActiveRoute":1,"GpsExpected":"14.3936039,-90.7068193","SalesOrderIdBo":0,"DeliveryDate":"2017/3/17","IsParent":1,"ReferenceId":"Alberto@SONDA2017/03/16 08:43:55-2","TimesPrinted":0,"DocSerie":"SO1","DocNum":25,"IsVoid":0,"SalesOrderType":"CREDIT","Discount":0,"IsDraft":0,"TaskId":57094,"Comment":"","IsPosted":1,"Sinc":0,"IsPostedVoid":2,"IsUpdated":1,"PaymentTimesPrinted":0,"PaidToDate":305,"ToBill":0,"Authorized":0,"DetailQty":3,"SaleDetails":[{"SalesOrderId":-2,"Sku":"100020","LineSeq":1,"Qty":11,"Price":5,"Discount":0,"TotalLine":55,"PostedDatetime":"2017/03/16 08:43:55","Serie":"0","Serie2":"0","RequeriesSerie":"0","ComboReference":"100020","ParentSeq":"1","IsActiveRoute":1,"CodePackUnit":"Manual","IsBonus":0,"IsPostedVoid":2,"Long":null},{"SalesOrderId":-2,"Sku":"100002","LineSeq":2,"Qty":12,"Price":10,"Discount":0,"TotalLine":120,"PostedDatetime":"2017/03/16 08:43:55","Serie":"0","Serie2":"0","RequeriesSerie":"0","ComboReference":"100002","ParentSeq":"1","IsActiveRoute":1,"CodePackUnit":"Manual","IsBonus":0,"IsPostedVoid":2,"Long":null},{"SalesOrderId":-2,"Sku":"100003","LineSeq":3,"Qty":13,"Price":10,"Discount":0,"TotalLine":130,"PostedDatetime":"2017/03/16 08:43:55","Serie":"0","Serie2":"0","RequeriesSerie":"0","ComboReference":"100003","ParentSeq":"1","IsActiveRoute":1,"CodePackUnit":"Manual","IsBonus":0,"IsPostedVoid":2,"Long":null}]},"dbuser":"USONDA","dbuserpass":"SONDAServer1237710","battery":23,"routeid":"6","warehouse":"BODEGA_CENTRAL","uuid":"ec26a682181b8186"}'
				--
				SELECT TOP 10 * FROM [SONDA].[SONDA_SALES_ORDER_HEADER] ORDER BY 1 DESC
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_ADD_SALES_ORDER_BY_XML]
	(
		@XML XML
		,@JSON VARCHAR(MAX)
	)
AS
	BEGIN
		SET NOCOUNT ON;
  --
		DECLARE	@DETAIL TABLE
			(
				[SKU] [VARCHAR](25) NOT NULL
				,[LINE_SEQ] [INT] NOT NULL
				,[QTY] [NUMERIC](18 ,2) NULL
				,[PRICE] [NUMERIC](18 ,6) NULL
				,[DISCOUNT] [NUMERIC](18 ,6) NULL
				,[TOTAL_LINE] [NUMERIC](18 ,6) NULL
				,[POSTED_DATETIME] [DATETIME] NULL
				,[SERIE] [VARCHAR](50) NULL
				,[SERIE_2] [VARCHAR](50) NULL
				,[REQUERIES_SERIE] [INT] NULL
				,[COMBO_REFERENCE] [VARCHAR](50) NULL
				,[PARENT_SEQ] [INT] NULL
				,[IS_ACTIVE_ROUTE] [INT] NULL
				,[CODE_PACK_UNIT] [VARCHAR](50) NULL
				,[IS_BONUS] [INT] NULL
				,[LONG] [NUMERIC](18 ,6) NULL
				,[DISCOUNT_TYPE] [VARCHAR](50)
				,[DISCOUNT_BY_FAMILY] NUMERIC(18 ,6) NOT NULL
														DEFAULT (0)
				,[DISCOUNT_BY_GENERAL_AMOUNT] NUMERIC(18 ,6) NOT NULL
																DEFAULT (0)
				,[DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE] NUMERIC(18 ,6) NOT NULL
																DEFAULT (0)
				,[TYPE_OF_DISCOUNT_BY_FAMILY] VARCHAR(100)
				,[TYPE_OF_DISCOUNT_BY_GENERAL_AMOUNT] VARCHAR(100)
				,[TYPE_OF_DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE] VARCHAR(100)
				,[BASE_PRICE] NUMERIC(18 ,6)
				,[CODE_FAMILY] VARCHAR(50)
				,[UNIQUE_DISCOUNT_BY_SCALE_APPLIED] INT
				,[DISPLAY_AMOUNT] NUMERIC(18 ,6)
			);
  --
		DECLARE	@RESULT_VALIDATION TABLE
			(
				[EXISTS] [INT]
				,[SALES_ORDER_ID] [INT]
				,[SERVER_POSTED_DATETIME] [DATETIME]
			);
  --
		DECLARE
			@ID INT
			,@HEADER_POSTEDDATIME DATETIME
			,@DETAIL_QTY INT
			,@HEADER_DETAIL_QTY INT
			,@DOC_SERIE VARCHAR(100)
			,@DOC_NUM INT
			,@CODE_ROUTE VARCHAR(50)
			,@CODE_CUSTOMER VARCHAR(50)
			,@EXISTS INT = 0
			,@SALES_ORDER_ID INT
			,@WAREHOUSE VARCHAR(50)
			,@DEVICE_ID VARCHAR(50)
			,@COMMITTED_INVENTORY INT
			,@INSERT_ERROR VARCHAR(1000)
			,@POSTED_BY VARCHAR(50)
			,@LOG_MESSAGE VARCHAR(100)
			,@SERVER_POSTED_DATETIME DATETIME;
  --
		BEGIN TRY
    -- ------------------------------------------------------------------------------------
    -- Obtiene los datos del encabezado
    -- ------------------------------------------------------------------------------------
			SELECT
				@HEADER_POSTEDDATIME = [x].[Rec].[query]('./PostedDatetime').[value]('.' ,
																'datetime')
				,@HEADER_DETAIL_QTY = [x].[Rec].[query]('./DetailQty').[value]('.' ,
																'int')
				,@DOC_SERIE = [x].[Rec].[query]('./DocSerie').[value]('.' ,
																'varchar(50)')
				,@DOC_NUM = [x].[Rec].[query]('./DocNum').[value]('.' ,'int')
				,@CODE_ROUTE = [x].[Rec].[query]('./PosTerminal').[value]('.' ,
																'varchar(50)')
				,@CODE_CUSTOMER = [x].[Rec].[query]('./ClientId').[value]('.' ,
																'varchar(50)')
				,@POSTED_BY = [x].[Rec].[query]('./PostedBy').[value]('.' ,
																'varchar(50)')
			FROM
				@XML.[nodes]('/Data/salesOrder') AS [x] ([Rec]);

    -- ------------------------------------------------------------------------------------
    -- Obtiene los datos generales de la ruta
    -- ------------------------------------------------------------------------------------
			SELECT
				@WAREHOUSE = [x].[Rec].[query]('./warehouse').[value]('.' ,
																'varchar(50)')
				,@DEVICE_ID = [x].[Rec].[query]('./uuid').[value]('.' ,
																'varchar(50)')
			FROM
				@XML.[nodes]('/Data') AS [x] ([Rec]);

    -- ------------------------------------------------------------------------------------
    -- Obtiene el detalle
    -- ------------------------------------------------------------------------------------
			INSERT	INTO @DETAIL
					(
						[SKU]
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
						,[DISCOUNT_TYPE]
						,[DISCOUNT_BY_FAMILY]
						,[DISCOUNT_BY_GENERAL_AMOUNT]
						,[DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE]
						,[TYPE_OF_DISCOUNT_BY_FAMILY]
						,[TYPE_OF_DISCOUNT_BY_GENERAL_AMOUNT]
						,[TYPE_OF_DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE]
						,[BASE_PRICE]
						,[CODE_FAMILY]
						,[UNIQUE_DISCOUNT_BY_SCALE_APPLIED]
						,[DISPLAY_AMOUNT] 
					)
			SELECT
				[x].[Rec].[query]('./Sku').[value]('.' ,'varchar(50)')
				,[x].[Rec].[query]('./LineSeq').[value]('.' ,'int')
				,[x].[Rec].[query]('./Qty').[value]('.' ,'numeric(18,6)')
				,[x].[Rec].[query]('./Price').[value]('.' ,'numeric(18,6)')
				,[x].[Rec].[query]('./Discount').[value]('.' ,'numeric(18,6)')
				,[x].[Rec].[query]('./TotalLine').[value]('.' ,'numeric(18,6)')
				,@HEADER_POSTEDDATIME
				,[x].[Rec].[query]('./Serie').[value]('.' ,'varchar(50)')
				,[x].[Rec].[query]('./Serie2').[value]('.' ,'varchar(50)')
				,[x].[Rec].[query]('./RequeriesSerie').[value]('.' ,'int')
				,[x].[Rec].[query]('./ParentSeq').[value]('.' ,'varchar(50)')
				,[x].[Rec].[query]('./RequeriesSerie').[value]('.' ,'int')
				,[x].[Rec].[query]('./IsActiveRoute').[value]('.' ,'int')
				,[x].[Rec].[query]('./CodePackUnit').[value]('.' ,'varchar(50)')
				,[x].[Rec].[query]('./IsBonus').[value]('.' ,'int')
				,CASE [x].[Rec].[query]('./Long').[value]('.' ,'varchar(50)')
					WHEN 'null' THEN NULL
					ELSE [x].[Rec].[query]('./Long').[value]('.' ,'varchar(50)')
					END
				,CASE [x].[Rec].[query]('./DiscountType').[value]('.' ,
																'varchar(50)')
					WHEN 'null' THEN NULL
					ELSE [x].[Rec].[query]('./DiscountType').[value]('.' ,
																'varchar(50)')
					END
				,CASE [x].[Rec].[query]('./DiscountByFamily').[value]('.' ,
																'varchar(50)')
					WHEN 'null' THEN 0
					ELSE [x].[Rec].[query]('./DiscountByFamily').[value]('.' ,
																'numeric(18,6)')
					END
				,CASE [x].[Rec].[query]('./DiscountByGeneralAmount').[value]('.' ,
																'varchar(50)')
					WHEN 'null' THEN 0
					ELSE [x].[Rec].[query]('./DiscountByGeneralAmount').[value]('.' ,
																'numeric(18,6)')
					END
				,CASE [x].[Rec].[query]('./DiscountByFamilyAndPaymentType').[value]('.' ,
																'varchar(50)')
					WHEN 'null' THEN 0
					ELSE [x].[Rec].[query]('./DiscountByFamilyAndPaymentType').[value]('.' ,
																'numeric(18,6)')
					END
				,CASE [x].[Rec].[query]('./TypeOfDiscountByFamily').[value]('.' ,
																'varchar(50)')
					WHEN 'null' THEN NULL
					ELSE [x].[Rec].[query]('./TypeOfDiscountByFamily').[value]('.' ,
																'varchar(50)')
					END
				,CASE [x].[Rec].[query]('./TypeOfDiscountByGeneralAmount').[value]('.' ,
																'varchar(50)')
					WHEN 'null' THEN NULL
					ELSE [x].[Rec].[query]('./TypeOfDiscountByGeneralAmount').[value]('.' ,
																'varchar(50)')
					END
				,CASE [x].[Rec].[query]('./TypeOfDiscountByFamilyAndPaymentType').[value]('.' ,
																'varchar(50)')
					WHEN 'null' THEN NULL
					ELSE [x].[Rec].[query]('./TypeOfDiscountByFamilyAndPaymentType').[value]('.' ,
																'varchar(50)')
					END
				,[x].[Rec].[query]('./BasePrice').[value]('.' ,'numeric(18,6)')
				,[x].[Rec].[query]('./CodeFamily').[value]('.' ,'varchar(50)')
				,[x].[Rec].[query]('./UniqueDiscountByScaleApplied').[value]('.' ,
																'int')
				,[x].[Rec].[query]('./TotalAmountDisplay').[value]('.' ,
																'numeric(18,6)')
			FROM
				@XML.[nodes]('/Data/salesOrder/SaleDetails') AS [x] ([Rec]);
    --
			SET @DETAIL_QTY = @@ROWCOUNT;

    -- ------------------------------------------------------------------------------------
    -- Valida cantidad de detalle con la del encabezado
    -- ------------------------------------------------------------------------------------
			IF (@DETAIL_QTY = @HEADER_DETAIL_QTY)
			BEGIN
      -- ------------------------------------------------------------------------------------
      -- Valida si existe la orden de venta
      -- ------------------------------------------------------------------------------------
				SET @COMMITTED_INVENTORY = 0;
	  --
				INSERT	INTO @RESULT_VALIDATION
						EXEC [SONDA].[SONDA_SP_VALIDATED_IF_EXISTS_SALES_ORDER_3] @DOC_SERIE = @DOC_SERIE ,
							@DOC_NUM = @DOC_NUM , -- int
							@CODE_ROUTE = @CODE_ROUTE , -- varchar(50)
							@CODE_CUSTOMER = @CODE_CUSTOMER , -- varchar(50)
							@POSTED_DATETIME = @HEADER_POSTEDDATIME , -- datetime
							@DETAIL_QTY = 0 , -- int
							@XML = @XML , -- xml
							@JSON = @JSON , -- varchar(max)
							@COMMITTED_INVENTORY = 0; -- int
      --
				SELECT
					@EXISTS = [R].[EXISTS]
					,@SALES_ORDER_ID = [R].[SALES_ORDER_ID]
					,@SERVER_POSTED_DATETIME = [R].[SERVER_POSTED_DATETIME]
				FROM
					@RESULT_VALIDATION [R];
      --
				IF (@EXISTS = 1)
				BEGIN
					PRINT '--> ya existe la orden de venta con el ID :'
						+ CAST(@SALES_ORDER_ID AS VARCHAR);

					BEGIN TRY
						IF NOT EXISTS ( SELECT
											1
										FROM
											[SONDA].[SONDA_SALES_ORDER_HEADER] [SH]
										WHERE
											[SH].[IS_READY_TO_SEND] = 1
											AND [SH].[DOC_SERIE] = @DOC_SERIE
											AND [SH].[DOC_NUM] = @DOC_NUM )
						BEGIN
							BEGIN TRAN;

							UPDATE
								[SONDA].[SONDA_SALES_ORDER_HEADER]
							SET	
								[IS_READY_TO_SEND] = 1
							WHERE
								[SALES_ORDER_ID] = @SALES_ORDER_ID;

							COMMIT;
		  --
							SET @LOG_MESSAGE = 'Listo para envio SAP Serie: '
								+ @DOC_SERIE + ' DocNum: '
								+ CAST(@DOC_NUM AS VARCHAR);
							EXEC [SONDA].[SONDA_SP_INSERT_SONDA_SERVER_ERROR_LOG] @CODE_ROUTE = @CODE_ROUTE ,
								@LOGIN = NULL ,
								@SOURCE_ERROR = 'SONDA_SP_ADD_SALES_ORDER_BY_XML' ,
								@DOC_RESOLUTION = NULL ,@DOC_SERIE = @DOC_SERIE ,
								@DOC_NUM = @DOC_NUM ,
								@MESSAGE_ERROR = @LOG_MESSAGE ,
								@SEVERITY_CODE = -6;

						END;
		--
						DELETE
							[SOD]
						FROM
							[SONDA].[SONDA_SALES_ORDER_DETAIL] [SOD]
						INNER JOIN [SONDA].[SONDA_SALES_ORDER_HEADER] [SOH]
						ON	[SOD].[SALES_ORDER_ID] = [SOH].[SALES_ORDER_ID]
						WHERE
							[SOH].[DOC_SERIE] = @DOC_SERIE
							AND [SOH].[DOC_NUM] = @DOC_NUM
							AND [SOH].[IS_READY_TO_SEND] = 0;
		--
						DELETE
							[SONDA].[SONDA_SALES_ORDER_HEADER]
						WHERE
							[DOC_SERIE] = @DOC_SERIE
							AND [DOC_NUM] = @DOC_NUM
							AND [IS_READY_TO_SEND] = 0;
					END TRY
					BEGIN CATCH
		--
						SET @LOG_MESSAGE = ERROR_MESSAGE();
						EXEC [SONDA].[SONDA_SP_INSERT_SONDA_SERVER_ERROR_LOG] @CODE_ROUTE = @CODE_ROUTE ,
							@LOGIN = NULL ,
							@SOURCE_ERROR = 'SONDA_SP_ADD_SALES_ORDER_BY_XML' ,
							@DOC_RESOLUTION = NULL ,@DOC_SERIE = @DOC_SERIE ,
							@DOC_NUM = @DOC_NUM ,@MESSAGE_ERROR = @LOG_MESSAGE ,
							@SEVERITY_CODE = 10;

						IF XACT_STATE() <> 0
						BEGIN
							ROLLBACK;
						END;

					END CATCH;
					IF (@COMMITTED_INVENTORY = 1)
					BEGIN
						EXEC [SONDA].[SONDA_SP_COMMIT_INVENTORY_BY_SALES_ORDER_ID] @SALE_ORDER_ID = @SALES_ORDER_ID;
					END;
        --
					SELECT
						@SALES_ORDER_ID [ID]
						,@SERVER_POSTED_DATETIME [SERVER_POSTED_DATETIME];
		--
				END;
				ELSE
				BEGIN
					BEGIN TRY
						BEGIN TRAN;
		-- -------------------------------------------------------------------------------------------
		-- Se obtiene la fecha y hora del servidor para almacenarlo en el campo SERVER_POSTED_DATETIME
		-- -------------------------------------------------------------------------------------------
						SET @SERVER_POSTED_DATETIME = GETDATE();

        -- ------------------------------------------------------------------------------------
        -- Inserta el encabezado
        -- ------------------------------------------------------------------------------------
						INSERT	INTO [SONDA].[SONDA_SALES_ORDER_HEADER]
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
									,[SALES_ORDER_TYPE]
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
									,[SERVER_POSTED_DATETIME]
									,[DEVICE_NETWORK_TYPE]
									,[IS_POSTED_OFFLINE]
									,[GOAL_HEADER_ID]
									
								)
						SELECT
							NULL
							,@HEADER_POSTEDDATIME
							,[X].[Rec].[query]('./ClientId').[value]('.' ,
																'varchar(50)')
							,@CODE_ROUTE
							,[X].[Rec].[query]('./GpsUrl').[value]('.' ,
																'varchar(50)')
							,[X].[Rec].[query]('./TotalAmount').[value]('.' ,
																'numeric(18,6)')
							,[X].[Rec].[query]('./Status').[value]('.' ,'int')
							,[X].[Rec].[query]('./PostedBy').[value]('.' ,
																'varchar(50)')
							,[X].[Rec].[query]('./Image1').[value]('.' ,
																'varchar(MAX)')
							,[X].[Rec].[query]('./Image2').[value]('.' ,
																'varchar(MAX)')
							,[X].[Rec].[query]('./Image3').[value]('.' ,
																'varchar(MAX)')
							,[X].[Rec].[query]('./DeviceBatteryFactor').[value]('.' ,
																'int')
							,CASE [X].[Rec].[query]('./VoidDatetime').[value]('.' ,
																'varchar(50)')
								WHEN 'null' THEN NULL
								ELSE [X].[Rec].[query]('./VoidDatetime').[value]('.' ,
																'DATETIME')
								END
							,CASE [X].[Rec].[query]('./VoidReason').[value]('.' ,
																'varchar(50)')
								WHEN 'null' THEN NULL
								ELSE [X].[Rec].[query]('./VoidReason').[value]('.' ,
																'VARCHAR(25)')
								END
							,CASE [X].[Rec].[query]('./VoidNotes').[value]('.' ,
																'varchar(50)')
								WHEN 'null' THEN NULL
								ELSE [X].[Rec].[query]('./VoidNotes').[value]('.' ,
																'VARCHAR(MAX)')
								END
							,CASE [X].[Rec].[query]('./Voided').[value]('.' ,
																'varchar(50)')
								WHEN 'null' THEN NULL
								ELSE [X].[Rec].[query]('./Voided').[value]('.' ,
																'INT')
								END
							,CASE [X].[Rec].[query]('./ClosedRouteDatetime').[value]('.' ,
																'varchar(50)')
								WHEN 'null' THEN NULL
								ELSE [X].[Rec].[query]('./ClosedRouteDatetime').[value]('.' ,
																'DATETIME')
								END
							,[X].[Rec].[query]('./IsActiveRoute').[value]('.' ,
																'int')
							,[X].[Rec].[query]('./GpsUrl').[value]('.' ,
																'varchar(50)')
							,[X].[Rec].[query]('./DeliveryDate').[value]('.' ,
																'DATETIME')
							,[X].[Rec].[query]('./SalesOrderId').[value]('.' ,
																'int')
							,0
							,NULL
							,NULL
							,NULL
							,[X].[Rec].[query]('./IsParent').[value]('.' ,'int')
							,[X].[Rec].[query]('./ReferenceId').[value]('.' ,
																'varchar(150)')
							,@WAREHOUSE
							,[X].[Rec].[query]('./TimesPrinted').[value]('.' ,
																'int')
							,[X].[Rec].[query]('./DocSerie').[value]('.' ,
																'varchar(50)')
							,[X].[Rec].[query]('./DocNum').[value]('.' ,'int')
							,[X].[Rec].[query]('./IsVoid').[value]('.' ,'int')
							,[X].[Rec].[query]('./SalesOrderType').[value]('.' ,
																'varchar(50)')
							,0
							,[X].[Rec].[query]('./IsDraft').[value]('.' ,'int')
							,'HH'
							,[X].[Rec].[query]('./TaskId').[value]('.' ,'int')
							,[X].[Rec].[query]('./Comment').[value]('.' ,
																'varchar(250)')
							,NULL
							,[X].[Rec].[query]('./PaymentTimesPrinted').[value]('.' ,
																'int')
							,[X].[Rec].[query]('./PaidToDate').[value]('.' ,
																'numeric(18,6)')
							,[X].[Rec].[query]('./ToBill').[value]('.' ,'int')
							,0
							,[X].[Rec].[query]('./Authorized').[value]('.' ,
																'int')
							,NULL
							,NULL
							,[X].[Rec].[query]('./Discount').[value]('.' ,
																'numeric(18,6)')
							,1
							,@SERVER_POSTED_DATETIME
							,[X].[Rec].[query]('./DeviceNetworkType').[value]('.' ,
																'varchar(15)')
							,CASE [X].[Rec].[query]('./IsPostedOffline').[value]('.' ,
																'varchar(50)')
								WHEN 'null' THEN NULL
								ELSE [X].[Rec].[query]('./IsPostedOffline').[value]('.' ,
																'int')
								END
							,CASE [X].[Rec].[query]('./GoalHeaderId').[value]('.' ,
																'varchar(50)')
								WHEN 'null' THEN NULL
								ELSE [X].[Rec].[query]('./GoalHeaderId').[value]('.' ,
																'int')
								END
						FROM
							@XML.[nodes]('/Data/salesOrder') AS [X] ([Rec]);
        --
						SET @ID = SCOPE_IDENTITY();


        -- ------------------------------------------------------------------------------------
        -- inserta el detalle
        -- ------------------------------------------------------------------------------------
						INSERT	INTO [SONDA].[SONDA_SALES_ORDER_DETAIL]
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
									,[DISCOUNT_TYPE]
									,[DISCOUNT_BY_FAMILY]
									,[DISCOUNT_BY_GENERAL_AMOUNT]
									,[DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE]
									,[TYPE_OF_DISCOUNT_BY_FAMILY]
									,[TYPE_OF_DISCOUNT_BY_GENERAL_AMOUNT]
									,[TYPE_OF_DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE]
									,[BASE_PRICE]
									,[CODE_FAMILY]
									,[UNIQUE_DISCOUNT_BY_SCALE_APPLIED]
									,[DISPLAY_AMOUNT] 
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
							,[D].[DISCOUNT_TYPE]
							,[D].[DISCOUNT_BY_FAMILY]
							,[D].[DISCOUNT_BY_GENERAL_AMOUNT]
							,[D].[DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE]
							,[D].[TYPE_OF_DISCOUNT_BY_FAMILY]
							,[D].[TYPE_OF_DISCOUNT_BY_GENERAL_AMOUNT]
							,[D].[TYPE_OF_DISCOUNT_BY_FAMILY_AND_PAYMENT_TYPE]
							,[D].[BASE_PRICE]
							,[D].[CODE_FAMILY]
							,[D].[UNIQUE_DISCOUNT_BY_SCALE_APPLIED]
							,[D].[DISPLAY_AMOUNT]
						FROM
							@DETAIL [D];

        -- ------------------------------------------------------------------------------------
        -- Retorna el resultado
        -- ------------------------------------------------------------------------------------
						SELECT
							@ID [ID]
							,@SERVER_POSTED_DATETIME [SERVER_POSTED_DATETIME];
        --
						COMMIT;
					END TRY
					BEGIN CATCH

						IF XACT_STATE() <> 0
						BEGIN
							ROLLBACK;
						END;

						SET @INSERT_ERROR = '1000 ' + ERROR_MESSAGE();
						PRINT 'CATCH de insert: ' + @INSERT_ERROR;
						RAISERROR (@INSERT_ERROR, 16, 1);
					END CATCH;
				END;
			END;
			ELSE
			BEGIN
				RAISERROR ('No cuadra la cantidad de lineas que dice el encabezado con las del detalle', 16, 1);
			END;
		END TRY
		BEGIN CATCH
			IF XACT_STATE() <> 0
			BEGIN
				ROLLBACK;
			END;

			SET @LOG_MESSAGE = ERROR_MESSAGE();
			EXEC [SONDA].[SONDA_SP_INSERT_SONDA_SERVER_ERROR_LOG] @CODE_ROUTE = @CODE_ROUTE ,
				@LOGIN = NULL ,@SOURCE_ERROR = 'SONDA_SP_ADD_SALES_ORDER_BY_XML' ,
				@DOC_RESOLUTION = NULL ,@DOC_SERIE = @DOC_SERIE ,
				@DOC_NUM = @DOC_NUM ,@MESSAGE_ERROR = @LOG_MESSAGE ,
				@SEVERITY_CODE = 10;

			DECLARE	@ERROR VARCHAR(1000) = ERROR_MESSAGE();
			PRINT 'CATCH: ' + @ERROR;
			RAISERROR (@ERROR, 16, 1);
		END CATCH;
	END;

