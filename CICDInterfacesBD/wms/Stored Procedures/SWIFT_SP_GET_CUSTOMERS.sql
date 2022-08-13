-- =============================================
-- Autor:					marvin.solares
-- Fecha: 					20190709 GForce@Dublin
-- Description:			    devuelve la informacion del catalogo de clientes

/*
-- Ejemplo de Ejecucion:
	
	EXEC [wms].[SWIFT_SP_GET_CUSTOMERS] @DATABASE='Me_llega_db',@OWNER = 'wms'
*/
-- =============================================

CREATE PROCEDURE [wms].[SWIFT_SP_GET_CUSTOMERS] (
		@DATABASE VARCHAR(35)
		,@OWNER VARCHAR(30)
	)
AS
BEGIN
	SET NOCOUNT ON;
	DECLARE	@QUERYERP VARCHAR(2000)= N'SELECT C.CardCode CardCode,C.CardName CardName FROM '
		+ @DATABASE + '.[dbo].OCRD C';
	--
	DECLARE	@QUERY NVARCHAR(2000);
	--
	SELECT
		@QUERY = N'
		SELECT
		[CardCode]
		,[CardName]
		,''' + @OWNER + ''' [OWNER] 
	FROM
		OPENQUERY([ERP_SERVER],''' + @QUERYERP + ''');  ';
	
	EXEC [sp_executesql] @QUERY;
END;