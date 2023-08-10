
-- =============================================
-- Autor:				eder.chamale
-- Fecha de Creacion: 	13-06-2017
-- Description:			Valida el número de la resolución

/*
-- Ejemplo de Ejecucion:

EXEC [SONDA].[SONDA_SP_UPDATE_DOCUMENT_SEQUENCES] 
	@XML = 
	'
<Data>
	<docSquences>
		<docSquence>
			<DOC_TYPE>SALES_ORDER</DOC_TYPE>
			<DOC_FROM>1</DOC_FROM>
			<DOC_TO>100000</DOC_TO>
			<SERIE>GUA0032@ARIUM</SERIE>
			<CURRENT_DOC>7947</CURRENT_DOC>
		</docSquence>
		<docType>777f0fcd-021e-4f7e-a3c0-8eef90942574SALES_ORDER</docType>
		<_id>95793f6e-cccb-4e6d-d4ba-55f3a3c0cdbf</_id>
		<_rev>1-91fe862ece05d69c959ff24ebaa515f3</_rev>
	</docSquences>
	<docSquences>
		<docSquence>
			<DOC_TYPE>BANK_DEPOSIT</DOC_TYPE>
			<DOC_FROM>1</DOC_FROM>
			<DOC_TO>100000</DOC_TO>
			<SERIE>33</SERIE>
			<CURRENT_DOC>1</CURRENT_DOC>
		</docSquence>
		<docType>777f0fcd-021e-4f7e-a3c0-8eef90942574SALES_ORDER</docType>
		<_id>95793f6e-cccb-4e6d-d4ba-55f3a3c0cdbf</_id>
		<_rev>1-91fe862ece05d69c959ff24ebaa515f3</_rev>
	</docSquences>
</Data>	
	'
--

*/
-- =============================================
-- DROP PROCEDURE [SONDA].[SONDA_SP_UPDATE_DOCUMENT_SEQUENCES]
CREATE PROCEDURE [SONDA].[SONDA_SP_UPDATE_DOCUMENT_SEQUENCES] (@XML XML)
AS
	BEGIN
		SET NOCOUNT ON;
		DECLARE
			@DOC_TYPE VARCHAR(50)
			,@SERIE VARCHAR(100)
			,@CURRENT_DOC INT
			,@RESULT INT;


		SELECT
			[x].[Rec].[query]('./DOC_TYPE').[value]('.' ,'varchar(50)') [DOC_TYPE]
			,[x].[Rec].[query]('./SERIE').[value]('.' ,'varchar(100)') [SERIE]
			,[x].[Rec].[query]('./CURRENT_DOC').[value]('.' ,'int') [CURRENT_DOC]
		INTO
			[#DOCUMENTS]
		FROM
			@XML.[nodes]('/Data/docSquences/docSquence') AS [x] ([Rec]);

		WHILE EXISTS ( SELECT TOP 1
							1
						FROM
							[#DOCUMENTS] )
		BEGIN
	
			BEGIN TRY
				SELECT TOP 1
					@DOC_TYPE = [DOC_TYPE]
					,@SERIE = [SERIE]
					,@CURRENT_DOC = [CURRENT_DOC]
				FROM
					[#DOCUMENTS];

				PRINT '->' + @DOC_TYPE;

				SET @RESULT = 0;

				UPDATE
					[SONDA].[SWIFT_DOCUMENT_SEQUENCE]
				SET	
					[CURRENT_DOC] = @CURRENT_DOC
				WHERE
					[DOC_TYPE] = @DOC_TYPE
					AND [SERIE] = @SERIE;
			END TRY
			BEGIN CATCH		
				DECLARE	@ERROR VARCHAR(1000) = ERROR_MESSAGE();
				PRINT 'CATCH: ' + @ERROR;
				RAISERROR (@ERROR,16,1);
			END CATCH;
			DELETE FROM
				[#DOCUMENTS]
			WHERE
				[SERIE] = @SERIE
				AND [DOC_TYPE] = @DOC_TYPE
				AND [CURRENT_DOC] = @CURRENT_DOC;
		END;
	END;
