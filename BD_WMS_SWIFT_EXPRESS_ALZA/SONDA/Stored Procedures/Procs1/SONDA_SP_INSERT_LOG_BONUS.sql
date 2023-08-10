-- =============================================
-- Autor:				diego.as
-- Fecha de Creacion: 	6/4/2017 @ A-TEAM Sprint Jibade 
-- Description:			SP que inserta el log de las bonificaciones

/*
-- Ejemplo de Ejecucion:
				EXEC [SONDA].[SONDA_SP_INSERT_LOG_BONUS]
				@CODE_ROUTE = ''
				, @SOURCE = ''
				, @XML = ''
				, @JSON = ''
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SONDA_SP_INSERT_LOG_BONUS](
	@CODE_ROUTE VARCHAR(250)
	, @SOURCE VARCHAR(250)
	, @XML XML
	, @JSON VARCHAR(MAX)
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	INSERT INTO [SONDA].[SONDA_LOG_BONUS]
			(
				[CODE_ROUTE]
				,[POSTED_DATETIME]
				,[SOURCE]
				,[XML]
				,[JSON]
			)
	VALUES
			(
				@CODE_ROUTE  -- CODE_ROUTE - varchar(250)
				,GETDATE()  -- POSTED_DATETIME - datetime
				,@SOURCE  -- SOURCE - varchar(250)
				,@XML  -- XML - xml
				,@JSON  -- JSON - varchar(max)
			)
	--
END
