
-- =============================================
-- Autor:					marvin.solares
-- Fecha: 					20190709 GForce@Dublin
-- Description:			    devuelve la informacion del catalogo de clientes

/*
-- Ejemplo de Ejecucion:
	
	EXEC [wms].[SWIFT_SP_GET_CUSTOMERS] @DATABASE='Me_Llega_DB',@OWNER = 'wms'
	EXEC [wms].[SWIFT_SP_GET_CUSTOMERS] @DATABASE='SAE70EMPRESA01',@OWNER = 'wms'
*/
-- =============================================

CREATE PROCEDURE [wms].[SWIFT_SP_GET_CUSTOMERS] (
		@DATABASE VARCHAR(35)
		,@OWNER VARCHAR(30)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--DECLARE	@QUERYERP VARCHAR(2000)= N'SELECT C.CardCode CardCode,C.CardName CardName FROM '
	--	+ @DATABASE + '.[dbo].ocrd C';
	----
	--DECLARE	@QUERY NVARCHAR(2000);
	----
	--SELECT
	--	@QUERY = N'
	--	SELECT
	--	[CardCode]
	--	,[CardName]
	--	,''' + @OWNER + ''' [OWNER] 
	--FROM
	--	OPENQUERY([ERP_SERVER],''' + @QUERYERP + ''');  ';
	
	--EXEC [sp_executesql] @QUERY;

		SELECT  
		 CODE_CUSTOMER [CardCode]
		,NAME_CUSTOMER [CardName]
		, 'ALZA' OWNER
		FROM SWIFT_INTERFACES.SONDA.SWIFT_ERP_CUSTOMERS
END;