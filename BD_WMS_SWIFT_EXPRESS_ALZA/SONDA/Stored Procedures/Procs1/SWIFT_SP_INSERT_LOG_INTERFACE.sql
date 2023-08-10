-- =============================================
-- Autor:				rodrigo.gomez
-- Fecha de Creacion: 	2/7/2017 @ A-TEAM Sprint Chatuluka
-- Description:			Insercion en la tabla SWIFT_LOG_INTERFACE

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SWIFT_SP_INSERT_LOG_INTERFACE]
				-- 
				SELECT * FROM [SONDA].[SWIFT_LOG_INTERFACE] 
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_INSERT_LOG_INTERFACE](
	@ERP_TARGET varchar(50) 
	,@OPERATION_TYPE varchar(50) 
	,@OBJECT_NAME varchar(250) 
	,@MESSAGE varchar(1000)
	,@DOC_ID int
	,@ERP_REFERENCE varchar(250)
	,@ERP_POSTING_ATTEMPTS int
)
AS
BEGIN
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SWIFT_LOG_INTERFACE]
				(
					[ERP_TARGET]
					,[OPERATION_TYPE]
					,[OBJECT_NAME]
					,[MESSAGE]
					,[LOG_DATETIME]
					,[DOC_ID]
					,[ERP_REFERENCE]
					,[ERP_POSTING_ATTEMPTS]
				)
		VALUES
				(
					@ERP_TARGET  -- ERP_TARGET - varchar(50)
					,@OPERATION_TYPE  -- OPERATION_TYPE - varchar(50)
					,@OBJECT_NAME  -- OBJECT_NAME - varchar(250)
					,@MESSAGE  -- MESSAGE - varchar(1000)
					,GETDATE()  -- LOG_DATETIME - datetime
					,@DOC_ID  -- SALES_ORDER_ID - int
					,@ERP_REFERENCE  -- ERP_REFERENCE - varchar(250)
					,@ERP_POSTING_ATTEMPTS  -- ERP_POSTING_ATTEMPTS - int
				)
		--
		SET @ID = SCOPE_IDENTITY()
		--
		SELECT  1 as Resultado , 'Proceso Exitoso' Mensaje ,  0 Codigo, CAST(@ID AS VARCHAR) DbData
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,CASE CAST(@@ERROR AS VARCHAR)
			WHEN '2627' THEN ''
			ELSE ERROR_MESSAGE() 
		END Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
