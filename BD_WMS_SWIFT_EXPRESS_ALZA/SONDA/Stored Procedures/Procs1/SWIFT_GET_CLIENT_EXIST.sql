-- =============================================
-- Author:     		hector.gonzalez
-- Create date:		2016-04-21
-- Description:		Valida la existencia de un cliente segun su CODE_CUSTOMER y se obtiene la informacion de dicho cliente

/*
Ejemplo de Ejecucion:

            EXEC [SONDA].SWIFT_GET_CLIENT_EXIST @CODE_CUSTOMER = "100" 
*/
-- =============================================
CREATE PROCEDURE [SONDA].SWIFT_GET_CLIENT_EXIST
  @CODE_CUSTOMER VARCHAR(50)
  
AS
BEGIN

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
		,C.FREQUENCY
		,CAST(C.SUNDAY                      AS INT) SUNDAY
		,CAST(C.MONDAY                      AS INT) MONDAY
		,CAST(C.TUESDAY                     AS INT) TUESDAY
		,CAST(C.WEDNESDAY                   AS INT) WEDNESDAY
		,CAST(C.THURSDAY                    AS INT) THURSDAY
		,CAST(C.FRIDAY                      AS INT) FRIDAY
		,CAST(C.SATURDAY                    AS INT) SATURDAY
		,C.SCOUTING_ROUTE
		,C.EXTRA_DAYS
		,C.DISCOUNT
		,ISNULL(P.CODE_PRICE_LIST,@DEFAULT_CODE_PRICE_LIST) AS CODE_PRICE_LIST
	FROM [SONDA].SWIFT_VIEW_ALL_COSTUMER C
	LEFT JOIN [SONDA].SWIFT_PRICE_LIST_BY_CUSTOMER P ON (C.CODE_CUSTOMER = P.CODE_CUSTOMER)
	WHERE C.CODE_CUSTOMER = @CODE_CUSTOMER
		
END
