



CREATE VIEW [wms].[OP_WMS_VIEW_ACUERDOS] AS
	--SELECT 
	--	codcliente, 
	--	nomcliente, 
	--	codacuerdo, 
	--	descrip
	--FROM
	--	aritecdb.dbo.acuerdoscomerciales
	
	SELECT ac.CLIENT_ID AS codcliente
		, c.CLIENT_NAME AS nomcliente
		, ac.ACUERDO_COMERCIAL AS codacuerdo
		, t.ACUERDO_COMERCIAL_NOMBRE AS descrip
	FROM [wms].OP_WMS_ACUERDOS_X_CLIENTE ac
		INNER JOIN [wms].OP_WMS_VIEW_CLIENTS c ON ac.CLIENT_ID = c.CLIENT_CODE COLLATE DATABASE_DEFAULT
		INNER JOIN [wms].OP_WMS_TARIFICADOR_HEADER t ON ac.ACUERDO_COMERCIAL = t.ACUERDO_COMERCIAL_ID