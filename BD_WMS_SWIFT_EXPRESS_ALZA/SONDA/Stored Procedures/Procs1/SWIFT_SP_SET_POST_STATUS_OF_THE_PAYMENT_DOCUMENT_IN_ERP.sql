-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	7/22/2018 @ A-TEAM Sprint  
-- Description:			SP que actualiza 

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_SET_POST_STATUS_OF_THE_PAYMENT_DOCUMENT_IN_ERP]
					@PAYMENT_HEADER_ID = 20
					,@IS_POSTED_ERP = 1
					,@POSTING_RESPONSE = 'Proceso Exitoso'
					,@ERP_REFERENCE = '123456'
				-- 
				SELECT * FROM [SONDA].[SONDA_OVERDUE_INVOICE_PAYMENT_HEADER]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_SET_POST_STATUS_OF_THE_PAYMENT_DOCUMENT_IN_ERP]
	(
		@PAYMENT_HEADER_ID INT
		,@IS_POSTED_ERP INT
		,@POSTING_RESPONSE VARCHAR(250)
		,@ERP_REFERENCE VARCHAR(250) = NULL
	)
AS
	BEGIN
		BEGIN TRY

			IF (@IS_POSTED_ERP <> 1)
			BEGIN
				UPDATE
					[SONDA].[SONDA_OVERDUE_INVOICE_PAYMENT_HEADER]
				SET	
					[ATTEMPTED_WITH_ERROR] = [ATTEMPTED_WITH_ERROR] + 1
					,[POSTING_RESPONSE] = @POSTING_RESPONSE
					,[IS_POSTED_ERP] = @IS_POSTED_ERP
				WHERE
					[ID] = @PAYMENT_HEADER_ID;
			END 
			ELSE BEGIN
				
				UPDATE
					[SONDA].[SONDA_OVERDUE_INVOICE_PAYMENT_HEADER]
				SET	
					[IS_POSTED_ERP] = @IS_POSTED_ERP
					,[POSTING_RESPONSE] = @POSTING_RESPONSE
					,[POSTED_DATETIME_ERP] = GETDATE()
					,[ERP_REFERENCE] = @ERP_REFERENCE
				WHERE
					[ID] = @PAYMENT_HEADER_ID;
			END
		
		--
			SELECT
				1 AS [Resultado]
				,'Proceso Exitoso' [Mensaje]
				,0 [Codigo]
				,'' [DbData];
		END TRY
		BEGIN CATCH
			SELECT
				-1 AS [Resultado]
				,ERROR_MESSAGE() [Mensaje]
				,@@ERROR [Codigo]; 
		END CATCH;
	END;
