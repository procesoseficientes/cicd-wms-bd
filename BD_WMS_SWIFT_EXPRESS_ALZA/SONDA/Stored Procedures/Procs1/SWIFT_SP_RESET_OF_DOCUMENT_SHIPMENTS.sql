-- =============================================
-- Autor:             rudi.garcia
-- Fecha de Creacion: 24-Sep-2018 G-Force@Jaguar
-- Description:       SP que resetea los documentos de preventa y venta directa para que se pueden reintentar enviar a ERP

-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_RESET_OF_DOCUMENT_SHIPMENTS]
	(
		@XML XML
		,@LOGIN_ID VARCHAR(50)
	)
AS
	BEGIN
		SET NOCOUNT ON;

		BEGIN TRAN;
		BEGIN TRY
    
			DECLARE	@DOCUMENTS TABLE
				(
					[ID] INT
					,[DOC_TYPE] VARCHAR(11)
				);

			INSERT	INTO @DOCUMENTS
					(
						[ID]
						,[DOC_TYPE]
					)
			SELECT
				[x].[Rec].[query]('./ID').[value]('.' ,'int')
				,[x].[Rec].[query]('./DOC_TYPE').[value]('.' ,'varchar(11)')
			FROM
				@XML.[nodes]('NewDataSet/Documents') AS [x] ([Rec]);

			UPDATE
				[SOH]
			SET	
				[SOH].[ATTEMPTED_WITH_ERROR] = 0
				,[SOH].[POSTED_RESPONSE] = ''
				,[SOH].[IS_SENDING] = 0
				,[SOH].[LAST_UPDATE_IS_SENDING] = NULL
				,[SOH].[POSTED_ERP] = NULL
				,[SOH].[IS_POSTED_ERP] = 0
			FROM
				[SONDA].[SONDA_SALES_ORDER_HEADER] [SOH]
			INNER JOIN @DOCUMENTS [D]
			ON	([SOH].[SALES_ORDER_ID] = [D].[ID])
			WHERE
				[D].[DOC_TYPE] = 'SALES_ORDER';

			UPDATE
				[PIH]
			SET	
				[PIH].[ATTEMPTED_WITH_ERROR] = 0
				,[PIH].[POSTED_RESPONSE] = ''
				,[PIH].[IS_SENDING] = 0
				,[PIH].[LAST_UPDATE_IS_SENDING] = NULL
				,[PIH].[POSTED_ERP] = NULL
				,[PIH].[IS_POSTED_ERP] = 0
			FROM
				[SONDA].[SONDA_POS_INVOICE_HEADER] [PIH]
			INNER JOIN @DOCUMENTS [D]
			ON	([PIH].[ID] = [D].[ID])
			WHERE
				[D].[DOC_TYPE] = 'INVOICE';

			COMMIT;
			SELECT
				1 AS [Resultado]
				,'Proceso Exitoso' [Mensaje]
				,0 [Codigo]
				,CAST('0' AS VARCHAR(18)) [DbData];
		END TRY
		BEGIN CATCH
			ROLLBACK;
			DECLARE	@message VARCHAR(1000) = @@ERROR;
			SELECT
				-1 AS [Resultado]
				,ERROR_MESSAGE() [Mensaje]
				,@@ERROR [Codigo];

			RAISERROR (@message, 16, 1);
		END CATCH;
	END;
