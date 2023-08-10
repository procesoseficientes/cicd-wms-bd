-- =============================================
--  Autor:		joel.delcompare
-- Fecha de Creacion: 	2016-04-28 09:46:26
-- Description:		Marca como enviodo un cliente a SBO 

-- Modificacion:		    hector.gonzalez
-- Fecha de Creacion: 	2016-08-26
-- Description:		      Se agrego la ejecucion de procedimiento SWIFT_SP_MOVE_FREQUENCY_BY_ACCEPTED_SCOUTING

-- Modificacion 13-Oct-16 @ A-Team Sprint 3
					-- alberto.ruiz
					-- Se agrego parametro @CODE_CUSTOMER_BO

-- Modificacion 6/22/2017 @ A-Team Sprint Khalid
					-- rodrigo.gomez
					-- Se actualiza la

/*
-- Ejemplo de Ejecucion:
		USE SWIFT_EXPRESS
		GO

		DECLARE 
			@RC int
			,@CODE_CUSTOMER varchar(50)
			,@POSTED_RESPONSE varchar(150)
			,@CODE_CUSTOMER_BO VARCHAR(50)

		SELECT 
			@CODE_CUSTOMER = 'SO-374' 
			,@POSTED_RESPONSE = 'Proceso exitoso' 
			,@CODE_CUSTOMER_BO = 'SO-374'

		EXECUTE @RC = [SONDA].SWIFT_SP_STATUS_SEND_CUSTOMER_TO_SAP 
			@CODE_CUSTOMER
			,@POSTED_RESPONSE
			,@CODE_CUSTOMER_BO
GO
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_STATUS_SEND_CUSTOMER_TO_SAP] (
	@CODE_CUSTOMER VARCHAR(50)
	,@POSTED_RESPONSE VARCHAR(150)
	,@CODE_CUSTOMER_BO VARCHAR(50)
) AS
BEGIN
	DECLARE	@ID NUMERIC(18 ,0);
	DECLARE	@RC INT;
	DECLARE	@SP INT;
	DECLARE @FROM VARCHAR(50)

	SELECT @FROM = IS_FROM FROM [SONDA].[SWIFT_VIEW_ALL_CUSTOMER_NEW] WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER

	BEGIN TRAN [TransSend];
		BEGIN TRY
			EXECUTE @RC = [SONDA].[SWIFT_SP_MOVE_TAGS_BY_ACCEPTED_SCOUTING] @CODE_CUSTOMER;

			IF(@FROM = 'SONDA_CORE')
			BEGIN
				EXECUTE @SP = [SONDA].[SWIFT_SP_MOVE_FREQUENCY_BY_ACCEPTED_SCOUTING] @CODE_CUSTOMER;

				UPDATE [SONDA].[SWIFT_CUSTOMERS_NEW]
				SET	
					[IS_POSTED_ERP] = 1
					,[POSTED_ERP] = GETDATE()
					,[POSTED_RESPONSE] = @POSTED_RESPONSE
					,[CODE_CUSTOMER_BO] = @CODE_CUSTOMER_BO
				WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER;
			END
			ELSE
			BEGIN
				UPDATE [SONDA].[SONDA_CUSTOMER_NEW]
				SET	
					[IS_POSTED_ERP] = 1
					,[POSTED_ERP] = GETDATE()
					,[POSTED_RESPONSE] = @POSTED_RESPONSE
					--,[CODE_CUSTOMER_BO] = @CODE_CUSTOMER_BO
				WHERE [CODE_CUSTOMER] = @CODE_CUSTOMER;
			END

			IF @@ERROR = 0
			BEGIN
				SELECT
					1 AS [Resultado]
					,'Proceso Exitoso' [Mensaje]
					,0 [Codigo]
					,CONVERT(VARCHAR(50) ,@ID) [DbData];
				COMMIT TRAN [TransSend];
			END;
			ELSE
			BEGIN

				SELECT
					-1 AS [Resultado]
					,ERROR_MESSAGE() [Mensaje]
					,@@ERROR [Codigo];
				ROLLBACK TRAN [TransSend];
			END;

		END TRY
		BEGIN CATCH
			ROLLBACK TRAN [TransSend];
			SELECT
				-1 AS [Resultado]
				,ERROR_MESSAGE() [Mensaje]
				,@@ERROR [Codigo];
		END CATCH;
END
