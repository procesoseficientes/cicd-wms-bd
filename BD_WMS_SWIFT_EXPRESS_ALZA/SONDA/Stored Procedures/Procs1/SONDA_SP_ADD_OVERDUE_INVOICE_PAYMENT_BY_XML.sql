-- ====================================================================================
-- Autor:				diego.as
-- Fecha de Creacion: 	5/10/2018 @ G-FORCE - TEAM Sprint Castor
-- Description:			SP que almacena la informacion de pagos de facturas vencidas

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_ADD_OVERDUE_INVOICE_PAYMENT_BY_XML]
				@XML = '
					
				'
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_ADD_OVERDUE_INVOICE_PAYMENT_BY_XML] (@XML XML)
AS
	BEGIN
		SET NOCOUNT ON;
	--
		DECLARE	@HEADER TABLE
			(
				[ID] INT IDENTITY(1 ,1)
							NOT NULL
				,[CODE_CUSTOMER] VARCHAR(250) NOT NULL
				,[DOC_SERIE] VARCHAR(250) NOT NULL
				,[DOC_NUM] INT NOT NULL
				,[CREATED_DATE] DATETIME NOT NULL
				,[POSTED_DATE] DATETIME NOT NULL
										DEFAULT GETDATE()
				,[CODE_ROUTE] VARCHAR(250) NOT NULL
				,[LOGIN_ID] VARCHAR(250) NOT NULL
				,[PAYMENT_AMOUNT] NUMERIC(18 ,6) NOT NULL
				,[COMMENT] VARCHAR(250)
				,PRIMARY KEY
					([CODE_CUSTOMER] ,[DOC_SERIE] ,[DOC_NUM] ,[CODE_ROUTE])
			);

		--
		DECLARE	@DETAIL TABLE
			(
				[ID] INT IDENTITY(1 ,1)
							NOT NULL
				,[INVOICE_ID] INT NOT NULL
				,[DOC_ENTRY] INT NOT NULL
				,[DOC_SERIE] VARCHAR(250) NOT NULL
				,[DOC_NUM] INT NOT NULL
				,[PAYED_AMOUNT] NUMERIC(18 ,6) NOT NULL
				,PRIMARY KEY ([INVOICE_ID] ,[DOC_ENTRY] ,[DOC_SERIE] ,[DOC_NUM])
			);
		
		--
		DECLARE	@PAYMENT_TYPE_DETAIL TABLE
			(
				[PAYMENT_TYPE_ID] INT IDENTITY(1 ,1)
				,[PAYMENT_HEADER_ID] INT
				,[PAYMENT_TYPE] VARCHAR(100)
				,[FRONT_IMAGE] VARCHAR(MAX)
				,[BACK_IMAGE] VARCHAR(MAX)
				,[DOCUMENT_NUMBER] VARCHAR(250)
				,[BANK_ACCOUNT] VARCHAR(100)
				,[BANK_NAME] VARCHAR(250)
				,[AMOUNT] NUMERIC(18 ,6)
				,[DOC_SERIE] VARCHAR(250) NOT NULL
				,[DOC_NUM] INT NOT NULL
				,PRIMARY KEY ([PAYMENT_TYPE_ID])
			);

		--
		DECLARE	@RESULT TABLE
			(
				[DOC_SERIE] VARCHAR(250)
				,[DOC_NUM] INT
				,[RESULT] INT
				,[PAYMENT_ID_BO] INT
			);

		--
		DECLARE
			@CURRENT_DOC_NUM INT
			,@CURRENT_DOC_SERIE VARCHAR(250)
			,@PAYMENT_ID_BO INT;

		BEGIN TRY
		    -- ------------------------------------------------------------------------------------
			-- Obtiene el encabezado
			-- ------------------------------------------------------------------------------------
			INSERT	INTO @HEADER
					(
						[CODE_CUSTOMER]
						,[DOC_SERIE]
						,[DOC_NUM]
						,[CREATED_DATE]
						,[CODE_ROUTE]
						,[LOGIN_ID]
						,[PAYMENT_AMOUNT]
						,[COMMENT]
					)
			SELECT
				[x].[Rec].[query]('./codeCustomer').[value]('.' ,'varchar(250)')
				,[x].[Rec].[query]('./docSerie').[value]('.' ,'varchar(250)')
				,[x].[Rec].[query]('./docNum').[value]('.' ,'int')
				,[x].[Rec].[query]('./createdDate').[value]('.' ,'datetime')
				,[x].[Rec].[query]('./codeRoute').[value]('.' ,'varchar(250)')
				,[x].[Rec].[query]('./loginId').[value]('.' ,'varchar(250)')
				,[x].[Rec].[query]('./paymentAmount').[value]('.' ,
																'numeric(18,6)')
				,[x].[Rec].[query]('./paidComment').[value]('.' ,'varchar(250)')
			FROM
				@XML.[nodes]('/Data/overdueInvoicePayment') AS [x] ([Rec]);

			-- ------------------------------------------------------------------------------------
			-- Obtiene el detalle
			-- ------------------------------------------------------------------------------------
			INSERT	INTO @DETAIL
					(
						[INVOICE_ID]
						,[DOC_ENTRY]
						,[DOC_SERIE]
						,[DOC_NUM]
						,[PAYED_AMOUNT] 
					)
			SELECT
				[x].[Rec].[query]('./invoiceId').[value]('.' ,'int')
				,[x].[Rec].[query]('./docEntry').[value]('.' ,'int')
				,[x].[Rec].[query]('./docSerie').[value]('.' ,'varchar(250)')
				,[x].[Rec].[query]('./docNum').[value]('.' ,'int')
				,[x].[Rec].[query]('./payedAmount').[value]('.' ,'numeric(18,6)')
			FROM
				@XML.[nodes]('/Data/overdueInvoicePayment/overdueInvoicePaymentDetail')
				AS [x] ([Rec]);

			-- ------------------------------------------------------------------------------------
			-- Obtiene el detalle de los tipos de pago realizados
			-- ------------------------------------------------------------------------------------
			INSERT	INTO @PAYMENT_TYPE_DETAIL
					(
						[PAYMENT_TYPE]
						,[FRONT_IMAGE]
						,[BACK_IMAGE]
						,[DOCUMENT_NUMBER]
						,[BANK_ACCOUNT]
						,[BANK_NAME]
						,[AMOUNT]
						,[DOC_SERIE]
						,[DOC_NUM]
					)
			SELECT
				[x].[Rec].[query]('./paymentType').[value]('.' ,'varchar(100)')
				,[x].[Rec].[query]('./frontImage').[value]('.' ,'varchar(max)')
				,[x].[Rec].[query]('./backImage').[value]('.' ,'varchar(max)')
				,[x].[Rec].[query]('./documentNumber').[value]('.' ,
																'varchar(250)')
				,[x].[Rec].[query]('./bankAccount').[value]('.' ,'varchar(100)')
				,[x].[Rec].[query]('./bankName').[value]('.' ,'varchar(250)')
				,[x].[Rec].[query]('./amount').[value]('.' ,'numeric(18,6)')
				,[x].[Rec].[query]('./docSerie').[value]('.' ,'varchar(250)')
				,[x].[Rec].[query]('./docNum').[value]('.' ,'int')
			FROM
				@XML.[nodes]('/Data/overdueInvoicePayment/overdueInvoicePaymentTypeDetail')
				AS [x] ([Rec]);


			-- ----------------------------------------------------------------------------
			-- Recorremos cada registro para procesarlo
			-- ----------------------------------------------------------------------------
			WHILE EXISTS ( SELECT TOP 1
								1
							FROM
								@HEADER )
			BEGIN
				-- ----------------------------------------------------------------------------
				-- Seleccionamos el registro a procesar
				-- ----------------------------------------------------------------------------
				SELECT TOP 1
					@CURRENT_DOC_SERIE = [H].[DOC_SERIE]
					,@CURRENT_DOC_NUM = [H].[DOC_NUM]
				FROM
					@HEADER AS [H]
				WHERE
					[H].[ID] > 0;

				BEGIN TRY
					
					-- ----------------------------------------------------------------------------
					-- Verificamos si ya existe el registro
					-- ----------------------------------------------------------------------------
					DECLARE	@POSTED_PAYMENT_ID INT = NULL;

					SELECT
						@POSTED_PAYMENT_ID = [ID]
					FROM
						[SONDA].[SONDA_OVERDUE_INVOICE_PAYMENT_HEADER]
					WHERE
						[DOC_SERIE] = @CURRENT_DOC_SERIE
						AND [DOC_NUM] = @CURRENT_DOC_NUM;

					IF (@POSTED_PAYMENT_ID IS NOT NULL)
					BEGIN
						INSERT	INTO @RESULT
								(
									[DOC_SERIE]
									,[DOC_NUM]
									,[RESULT]
									,[PAYMENT_ID_BO]
								)
						VALUES
								(
									@CURRENT_DOC_SERIE  -- DOC_SERIE - varchar(250)
									,@CURRENT_DOC_NUM  -- DOC_NUM - int
									,1  -- RESULT - int
									,@POSTED_PAYMENT_ID  -- PAYMENT_ID_BO - int
								);
					END;
					ELSE
					BEGIN
						-- ----------------------------------------------------------------------------
						-- Agregamos el encabezado
						-- ----------------------------------------------------------------------------
						INSERT	INTO [SONDA].[SONDA_OVERDUE_INVOICE_PAYMENT_HEADER]
								(
									[CODE_CUSTOMER]
									,[DOC_SERIE]
									,[DOC_NUM]
									,[CREATED_DATE]
									,[POSTED_DATE]
									,[CODE_ROUTE]
									,[LOGIN_ID]
									,[PAYMENT_AMOUNT]
									,[COMMENT]
								)
						SELECT
							[H].[CODE_CUSTOMER]
							,[H].[DOC_SERIE]
							,[H].[DOC_NUM]
							,[H].[CREATED_DATE]
							,GETDATE()
							,[H].[CODE_ROUTE]
							,[H].[LOGIN_ID]
							,[H].[PAYMENT_AMOUNT]
							,[H].[COMMENT]
						FROM
							@HEADER AS [H]
						WHERE
							[H].[DOC_SERIE] = @CURRENT_DOC_SERIE
							AND [H].[DOC_NUM] = @CURRENT_DOC_NUM;

						-- --------------------------------------------------------------------------------------
						-- Obtenemos el ID generado
						-- --------------------------------------------------------------------------------------
						SET @PAYMENT_ID_BO = SCOPE_IDENTITY();

						-- --------------------------------------------------------------------------------------
						-- Agregamos el detalle
						-- --------------------------------------------------------------------------------------
						INSERT	INTO [SONDA].[SONDA_OVERDUE_INVOICE_PAYMENT_DETAIL]
								(
									[PAYMENT_HEADER_ID]
									,[INVOICE_ID]
									,[DOC_ENTRY]
									,[DOC_SERIE]
									,[DOC_NUM]
									,[PAYED_AMOUNT]
								)
						SELECT
							@PAYMENT_ID_BO
							,[D].[INVOICE_ID]
							,[D].[DOC_ENTRY]
							,[D].[DOC_SERIE]
							,[D].[DOC_NUM]
							,[D].[PAYED_AMOUNT]
						FROM
							@DETAIL AS [D]
						WHERE
							[D].[DOC_SERIE] = @CURRENT_DOC_SERIE
							AND [D].[DOC_NUM] = @CURRENT_DOC_NUM;

						-- --------------------------------------------------------------------------------------
						-- Agregamos el detalle de los tipos de pago realizados en el documento
						-- --------------------------------------------------------------------------------------
						INSERT	INTO [SONDA].[SONDA_PAYMENT_TYPE_DETAIL_FOR_OVERDUE_INVOICE_PAYMENT]
								(
									[PAYMENT_HEADER_ID]
									,[PAYMENT_TYPE]
									,[FRONT_IMAGE]
									,[BACK_IMAGE]
									,[DOCUMENT_NUMBER]
									,[BANK_ACCOUNT]
									,[BANK_NAME]
									,[AMOUNT]
								)
						SELECT
							@PAYMENT_ID_BO
							,[PAYMENT_TYPE]
							,[FRONT_IMAGE]
							,[BACK_IMAGE]
							,[DOCUMENT_NUMBER]
							,[BANK_ACCOUNT]
							,[BANK_NAME]
							,[AMOUNT]
						FROM
							@PAYMENT_TYPE_DETAIL AS [PTD]
						WHERE
							[PTD].[DOC_SERIE] = @CURRENT_DOC_SERIE
							AND [PTD].[DOC_NUM] = @CURRENT_DOC_NUM;

						-- -------------------------------------------------------------------------------------------------------------
						-- Actualizamos el monto pendiente a pagar de las facturas procesadas en el pago actual
						-- -------------------------------------------------------------------------------------------------------------
						UPDATE
							[OI]
						SET	
							[OI].[PENDING_TO_PAID] = ([OI].[PENDING_TO_PAID]
														- [D].[PAYED_AMOUNT])
						FROM
							[SONDA].[SWIFT_OVERDUE_INVOICE_BY_CUSTOMER] AS [OI]
						INNER JOIN @DETAIL AS [D]
						ON	(
								[D].[INVOICE_ID] = [OI].[INVOICE_ID]
								AND [D].[DOC_ENTRY] = [OI].[DOC_ENTRY]
							)
						WHERE
							[D].[DOC_SERIE] = @CURRENT_DOC_SERIE
							AND [D].[DOC_NUM] = @CURRENT_DOC_NUM;
						
						-- -------------------------------------------------------------------------------------------------------------
						-- Agregamos el registro procesado como exitoso (RESULT = 1) a la tabla de resultado que sera enviada al movil
						-- -------------------------------------------------------------------------------------------------------------
						INSERT	INTO @RESULT
								(
									[DOC_SERIE]
									,[DOC_NUM]
									,[RESULT]
									,[PAYMENT_ID_BO]
								)
						VALUES
								(
									@CURRENT_DOC_SERIE  -- DOC_SERIE - varchar(250)
									,@CURRENT_DOC_NUM  -- DOC_NUM - int
									,1  -- RESULT - int
									,@PAYMENT_ID_BO  -- PAYMENT_ID_BO - int
								);
					END;

					
				END TRY
				BEGIN CATCH
					-- -------------------------------------------------------------------------------------------------------------
					-- Agregamos el registro procesado como fallido (RESULT = 0) a la tabla de resultado que sera enviada al movil
					-- -------------------------------------------------------------------------------------------------------------
					INSERT	INTO @RESULT
							(
								[DOC_SERIE]
								,[DOC_NUM]
								,[RESULT]
								,[PAYMENT_ID_BO]
							)
					VALUES
							(
								@CURRENT_DOC_SERIE  -- DOC_SERIE - varchar(250)
								,@CURRENT_DOC_NUM  -- DOC_NUM - int
								,0  -- RESULT - int
								,@PAYMENT_ID_BO  -- PAYMENT_ID_BO - int
							); 
				END CATCH;
				
				-- --------------------------------------------------------------------------------------
				-- Borramos el registro procesado
				-- --------------------------------------------------------------------------------------
				DELETE FROM
					@DETAIL
				WHERE
					[DOC_SERIE] = @CURRENT_DOC_SERIE
					AND [DOC_NUM] = @CURRENT_DOC_NUM;
				
				DELETE FROM
					@HEADER
				WHERE
					[DOC_SERIE] = @CURRENT_DOC_SERIE
					AND [DOC_NUM] = @CURRENT_DOC_NUM;
			END;

			-- --------------------------------------------------------------------------------------
			-- Devolvemos el resultado
			-- --------------------------------------------------------------------------------------
			SELECT
				[DOC_SERIE]
				,[DOC_NUM]
				,[RESULT]
				,[PAYMENT_ID_BO]
			FROM
				@RESULT;
		END TRY
		BEGIN CATCH
			DECLARE	@ERROR VARCHAR(MAX) = ERROR_MESSAGE();
			RAISERROR(@ERROR,16,1);
		END CATCH;
	END;
