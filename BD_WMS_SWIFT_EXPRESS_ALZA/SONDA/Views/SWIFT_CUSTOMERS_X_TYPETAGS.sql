﻿CREATE View [SONDA].SWIFT_CUSTOMERS_X_TYPETAGS
AS

SELECT 
	CUSTOMER
	,NAME_CUSTOMER
	,(Select count(T1.TAG_COLOR) From [SONDA].SWIFT_TAG_X_CUSTOMER_NEW T1 
		Inner JOIN [SONDA].SWIFT_TAGS T2 ON T1.TAG_COLOR = T2.TAG_COLOR 
		AND T1.CUSTOMER= T0.CODE_CUSTOMER AND UPPER(T2.TYPE)='CUSTOMER') AS TAGS_CUSTOMER
	,(Select count(T1.TAG_COLOR) From [SONDA].SWIFT_TAG_X_CUSTOMER_NEW T1 
		Inner JOIN [SONDA].SWIFT_TAGS T2 ON T1.TAG_COLOR = T2.TAG_COLOR 
		AND T1.CUSTOMER= T0.CODE_CUSTOMER AND UPPER(T2.TYPE)='PRODUCT') AS TAGS_PRODUCT
FROM [SONDA].SWIFT_CUSTOMERS_NEW T0
