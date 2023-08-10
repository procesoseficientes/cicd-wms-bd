-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	16-Jun-17 @ A-TEAM Sprint Jibade
-- Description:			SP que inserta el log del scouting

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_CUSTOMER_NEW_INSERT_LOG]
					@EXISTS_SCOUTING = 0
					,@DOC_SERIE = 'PRUEBA'
					,@DOC_NUM = 0
					,@CODE_ROUTE = 'PRUEBA'
					,@POSTED_DATETIME = '20170505 00:00:00.000'
					,@XML = N''
					,@JSON = ''
					,@SET_NEGATIVE_SEQUENCE = 0
					,@CODE_CUSTOMER = ''
				-- 
				SELECT * FROM [SONDA].[SONDA_CUSTOMER_NEW_LOG]
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_CUSTOMER_NEW_INSERT_LOG](
	@EXISTS_SCOUTING INT
	,@DOC_SERIE VARCHAR(50)
	,@DOC_NUM INT
	,@CODE_ROUTE VARCHAR(50)
	,@POSTED_DATETIME DATETIME
	,@XML XML
	,@JSON VARCHAR(MAX)
	,@SET_NEGATIVE_SEQUENCE INT
	,@CODE_CUSTOMER VARCHAR(50)
	,@IS_SUCCESSFUL INT = NULL
	,@MESSAGE VARCHAR(250) = NULL
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	BEGIN TRY
		DECLARE @ID INT
		--
		INSERT INTO [SONDA].[SONDA_CUSTOMER_NEW_LOG]
				(
					[LOG_DATETIME]
					,[EXISTS_SCOUTING]
					,[DOC_SERIE]
					,[DOC_NUM]
					,[CODE_ROUTE]
					,[POSTED_DATETIME]
					,[XML]
					,[JSON]
					,[SET_NEGATIVE_SEQUENCE]
					,[CODE_CUSTOMER]
					,[IS_SUCCESSFUL]
					,[MESSAGE]
				)
		VALUES
				(
					GETDATE()  -- LOG_DATETIME - datetime
					,@EXISTS_SCOUTING  -- EXISTS_SCOUTING - int
					,@DOC_SERIE  -- DOC_SERIE - varchar(50)
					,@DOC_NUM  -- DOC_NUM - int
					,@CODE_ROUTE  -- CODE_ROUTE - varchar(50)
					,@POSTED_DATETIME  -- POSTED_DATETIME - datetime
					,@XML  -- XML - xml
					,@JSON  -- JSON - varchar(max)
					,@SET_NEGATIVE_SEQUENCE  -- SET_NEGATIVE_SEQUENCE - int
					,@CODE_CUSTOMER  -- CODE_CUSTOMER - varchar(50)
					,@IS_SUCCESSFUL
					,@MESSAGE
				)
	END TRY
	BEGIN CATCH
		SELECT  -1 as Resultado
		,ERROR_MESSAGE() Mensaje 
		,@@ERROR Codigo 
	END CATCH
END
