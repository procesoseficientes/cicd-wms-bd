-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	5/10/2017 @ A-TEAM Sprint Issa
-- Description:			SP que inserta el log de transaccion del envio de Clientes o Cambios de Clientes hacia ERP

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_INSERT_CUSTOMER_ERP_LOG]
					@ID = -1
					,@ATTEMPTED_WITH_ERROR = 0
					,@IS_POSTED_ERP = 0
					,@POSTED_RESPONSE = 'PRUEBA'
					,@ERP_REFERENCE = 'PRUEBA'
					,@TYPE = 'SCOUTING'
				-- 
				SELECT * FROM [SONDA].[SWIFT_SEND_CUSTOMER_ERP_LOG]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_CUSTOMER_ERP_LOG](
	@ID INT
	,@ATTEMPTED_WITH_ERROR INT
	,@IS_POSTED_ERP INT
	,@POSTED_RESPONSE VARCHAR(150) = NULL
	,@ERP_REFERENCE VARCHAR(256) = NULL
	,@TYPE VARCHAR(50) = NULL
)
AS
BEGIN
	BEGIN TRY
		--
		INSERT INTO [SONDA].[SWIFT_SEND_CUSTOMER_ERP_LOG]
				(
					[ID]
					,[ATTEMPTED_WITH_ERROR]
					,[IS_POSTED_ERP]
					,[POSTED_ERP]
					,[POSTED_RESPONSE]
					,[ERP_REFERENCE]
					,[TYPE]
				)
		VALUES
				(
					@ID  -- ID - int
					,@ATTEMPTED_WITH_ERROR  -- ATTEMPTED_WITH_ERROR - int
					,@IS_POSTED_ERP  -- IS_POSTED_ERP - int
					,GETDATE()  -- POSTED_ERP - int
					,@POSTED_RESPONSE  -- POSTED_RESPONSE - varchar(250)
					,@ERP_REFERENCE  -- ERP_REFERENCE - varchar(250)
					,@TYPE
				)

		--
	END TRY
	BEGIN CATCH
		DECLARE @MESSAGE VARCHAR(1000) = ERROR_MESSAGE()
		PRINT 'CATCH: ' + @MESSAGE
	END CATCH
END
