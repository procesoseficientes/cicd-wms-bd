-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	22-Aug-17 @ Nexus Team Sprint CommandAndConquer
-- Description:			SP que obtiene el DocNum de un documento del ERP
/*
-- Ejemplo de Ejecucion:
				DECLARE @DOC_NUM INT =-1
				--
				EXEC [SONDA].[SWIFT_SP_GET_ERP_DOC_NUM_FOR_DOCUMENT_BY_DOC_ENTRY]
					@DATABASE ='[ME_LLEGA_DB]'
					,@TABLE = '[OPDN]'
					,@DOC_ENTRY = 44
					,@DOC_NUM = @DOC_NUM OUTPUT
				--
				SELECT @DOC_NUM
*/
-- =============================================
CREATE PROCEDURE [SONDA].[SWIFT_SP_GET_ERP_DOC_NUM_FOR_DOCUMENT_BY_DOC_ENTRY](
	@DATABASE VARCHAR(50)
	,@TABLE VARCHAR(50)
	,@DOC_ENTRY INT
	,@DOC_NUM INT =-1 OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @QUERY NVARCHAR(2000)
	--
	SELECT @QUERY = N'
		SELECT @DOC_NUM = [O].[DocNum]
		FROM (SELECT * FROM OPENQUERY([ERP_SERVER],''
			SELECT [O].[DocNum]
			FROM ' + @DATABASE + '.[dbo].' + @TABLE + ' [O]
			WHERE [O].[DocEntry] = ' + CAST(@DOC_ENTRY AS VARCHAR) + '
		'')) [O];'
	--
	PRINT @QUERY
	--
	EXEC sp_executesql @QUERY,N'@DOC_NUM INT =-1 OUTPUT',@DOC_NUM = @DOC_NUM OUTPUT;
END