-- =============================================
-- Autor:				alberto.ruiz
-- Fecha de Creacion: 	13-04-2016
-- Description:			Busca los clientes que sea similar el codigo de cliente o nombre

/*
-- EJEMPLO DE EJECUCION: 
		EXEC [SONDA].[SWIFT_SP_FIND_CUSTOMER]
			@FILTER = 'TIENDA'
		--
		EXEC [SONDA].[SWIFT_SP_FIND_CUSTOMER]
			@FILTER = '100'
		--
		EXEC [SONDA].[SWIFT_SP_FIND_CUSTOMER]
			@FILTER = ''

*/		
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_SP_FIND_CUSTOMER
		@FILTER VARCHAR(50)
AS
BEGIN
	SET NOCOUNT ON;
	--
	DECLARE @DEFAULT_CODE_PRICE_LIST INT
	
	-- ------------------------------------------------------------------------------------
	-- Obtiene la lista de precios por defecto
	-- ------------------------------------------------------------------------------------
	SELECT @DEFAULT_CODE_PRICE_LIST = CONVERT(INT,VALUE)
	FROM [SONDA].SWIFT_PARAMETER P
	WHERE P.GROUP_ID = 'ERP_HARDCODE_VALUES'
		AND P.PARAMETER_ID = 'PRICE_LIST'

	-- ------------------------------------------------------------------------------------
	-- Obtiene los datos de los clientes 
	-- ------------------------------------------------------------------------------------
	SELECT
		@FILTER = @FILTER + '%'
	--
	SELECT 
		CAST(C.CUSTOMER AS INT) CUSTOMER
		,C.CODE_CUSTOMER
		,C.NAME_CUSTOMER
		,C.PHONE_CUSTOMER
		,C.ADRESS_CUSTOMER
		,C.CLASSIFICATION_CUSTOMER
		,C.CONTACT_CUSTOMER
		,C.CODE_ROUTE
		,C.LAST_UPDATE
		,C.LAST_UPDATE_BY
		,C.SELLER_DEFAULT_CODE
		,C.CREDIT_LIMIT
		,C.FROM_ERP
		,C.TAX_ID_NUMBER
		,C.GPS
		,C.LATITUDE
		,C.LONGITUDE		
		,C.SCOUTING_ROUTE
		,C.EXTRA_DAYS
		,C.DISCOUNT
		,ISNULL(P.CODE_PRICE_LIST,@DEFAULT_CODE_PRICE_LIST) AS CODE_PRICE_LIST
	FROM [SONDA].SWIFT_VIEW_ALL_COSTUMER C
	LEFT JOIN [SONDA].SWIFT_PRICE_LIST_BY_CUSTOMER P ON (C.CODE_CUSTOMER = P.CODE_CUSTOMER)
	WHERE C.CODE_CUSTOMER LIKE (@FILTER + '%')
		OR C.NAME_CUSTOMER LIKE (@FILTER + '%')
END
