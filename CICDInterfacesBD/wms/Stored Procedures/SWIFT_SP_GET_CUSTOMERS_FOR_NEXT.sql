-- =============================================
-- Autor:					henry.rodriguez
-- Fecha: 					09-SEPTIEMBRE-2019 GForce@GUMARCAJ
-- Description:			    devuelve la informacion del catalogo de clientes

/*
-- Ejemplo de Ejecucion:
	
	EXEC [wms].[SWIFT_SP_GET_CUSTOMERS_FOR_NEXT] @DATABASE='Me_llega_db',@OWNER = 'FERCO'
*/
-- =============================================

CREATE PROCEDURE [wms].[SWIFT_SP_GET_CUSTOMERS_FOR_NEXT] (
		@DATABASE VARCHAR(35)
		,@OWNER VARCHAR(30)
	)
AS
BEGIN
	SET NOCOUNT ON;
	--DECLARE	@QUERYERP VARCHAR(2000)= N'SELECT C.CardCode CardCode,C.CardName CardName, C.Phone1 Phone1, C.Phone2 Phone2, 
	--	C.Cellular Cellular, C.U_LATITUDE LATITUDE, C.U_LONGITUDE LONGITUDE, C.U_IMG_FACADE IMG_FACADE, C.E_Mail E_Mail FROM '
	--	+ @DATABASE + '.[dbo].OCRD C';
	----
	--DECLARE	@QUERY NVARCHAR(2000);
	----
	--SELECT
	--	@QUERY = N'
	--	SELECT
	--	[CardCode]
	--	,[CardName]
	--	,[Phone1]
	--	,[Phone2]
	--	,[Cellular]
	--	,[LATITUDE]
	--	,[LONGITUDE]
	--	,[IMG_FACADE]
	--	,[E_Mail]
	--	,''' + @OWNER + ''' [OWNER] 
	--FROM
	--	OPENQUERY([ERP_SERVER],''' + @QUERYERP + ''');  ';
	
	--EXEC [sp_executesql] @QUERY;
	SELECT   CODE_CUSTOMER [CardCode]
		,NAME_CUSTOMER [CardName]
		,PHONE_CUSTOMER [Phone1]
		,NULL [Phone2]
		,NULL [Cellular]
		,LATITUDE [LATITUDE]
		,LONGITUDE  [LONGITUDE]
		,NULL [IMG_FACADE]
		,NULL [E_Mail]
		,'ALZA'[OWNER] FROM sonda.SWIFT_ERP_CUSTOMERS


END;


