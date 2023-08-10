-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	31-Mar-17 @ A-TEAM Sprint Garai
-- Description:			SP que inserta el log del envio al erp de las facturas

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_INSERT_INVOICE_ERP_LOG]
					@ID = -1
					,@ATTEMPTED_WITH_ERROR = 0
					,@IS_POSTED_ERP = 0
					,@POSTED_RESPONSE = 'PRUEBA'
					,@ERP_REFERENCE = 'PRUEBA'
				-- 
				SELECT * FROM [SONDA].[SWIFT_SEND_INVOICE_ERP_LOG]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_INVOICE_ERP_LOG](
	@ID INT
	,@ATTEMPTED_WITH_ERROR INT
	,@IS_POSTED_ERP INT
	,@POSTED_RESPONSE VARCHAR(150)
	,@ERP_REFERENCE VARCHAR(256)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		INSERT INTO [SONDA].[SWIFT_SEND_INVOICE_ERP_LOG]
				(
					[ID]
					,[ATTEMPTED_WITH_ERROR]
					,[IS_POSTED_ERP]
					,[POSTED_ERP]
					,[POSTED_RESPONSE]
					,[ERP_REFERENCE]
				)
		VALUES
				(
					@ID  -- ID - int
					,@ATTEMPTED_WITH_ERROR  -- ATTEMPTED_WITH_ERROR - int
					,@IS_POSTED_ERP  -- IS_POSTED_ERP - int
					,GETDATE()  -- POSTED_ERP - datetime
					,@POSTED_RESPONSE  -- POSTED_RESPONSE - varchar(150)
					,@ERP_REFERENCE  -- ERP_REFERENCE - varchar(256)
				)
	END TRY
	BEGIN CATCH
		DECLARE @MESSAGE VARCHAR(1000) = ERROR_MESSAGE()
		PRINT 'CATCH: ' + @MESSAGE
	END CATCH
END
