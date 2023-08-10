-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	31-Mar-17 @ A-TEAM Sprint Garai
-- Description:			SP para insertar log de validacion de facturas

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_INSERT_INVOICE_LOG_EXISTS]
					@EXISTS_INVOICE = 0
					,@DOC_RESOLUTION = 'PRUEBA'
					,@DOC_SERIE = 'PRUEBA'
					,@DOC_NUM = -1
					,@CODE_ROUTE = 'PRUEBA'
					,@CODE_CUSTOMER = 'PRUEBA'
					,@POSTED_DATETIME = '20170331 00:00:00.000'
					,@XML = NULL
					,@JSON = NULL
				-- 
				SELECT * FROM [SONDA].[SONDA_INVOICE_LOG_EXISTS]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_INSERT_INVOICE_LOG_EXISTS](
	@EXISTS_INVOICE INT
	,@DOC_RESOLUTION VARCHAR(100)
	,@DOC_SERIE VARCHAR(100)
	,@DOC_NUM INT
	,@CODE_ROUTE VARCHAR(50)
	,@CODE_CUSTOMER VARCHAR(50)
	,@POSTED_DATETIME DATETIME
	,@XML XML
	,@JSON VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		INSERT INTO [SONDA].[SONDA_INVOICE_LOG_EXISTS]
				(
					[LOG_DATETIME]
					,[EXISTS_INVOICE]
					,[DOC_RESOLUTION]
					,[DOC_SERIE]
					,[DOC_NUM]
					,[CODE_ROUTE]
					,[CODE_CUSTOMER]
					,[POSTED_DATETIME]
					,[XML]
					,[JSON]
				)
		VALUES
				(
					GETDATE()  -- LOG_DATETIME - datetime
					,@EXISTS_INVOICE  -- EXISTS_INVOICE - int
					,@DOC_RESOLUTION  -- DOC_RESOLUTION - varchar(100)
					,@DOC_SERIE  -- DOC_SERIE - varchar(100)
					,@DOC_NUM  -- DOC_NUM - int
					,@CODE_ROUTE  -- CODE_ROUTE - varchar(50)
					,@CODE_CUSTOMER  -- CODE_CUSTOMER - varchar(50)
					,@POSTED_DATETIME  -- POSTED_DATETIME - datetime
					,@XML  -- XML - xml
					,@JSON  -- JSON - varchar(max)
				)
	END TRY
	BEGIN CATCH
		DECLARE @MESSAGE VARCHAR(1000) = ERROR_MESSAGE()
		PRINT 'CATCH: ' + @MESSAGE
	END CATCH
END
