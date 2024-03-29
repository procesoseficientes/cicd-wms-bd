﻿

CREATE VIEW [SONDA].[SWIFT_VIEW_SELLER_BY_SKU]
AS
SELECT DISTINCT
	B.CODE_RELATION,
	A.SELLER_CODE,
	A.SELLER_NAME,
	C.CODE_SKU,
	C.DESCRIPTION_SKU,
	B.FREQUENT
FROM 
	[SONDA].SWIFT_VIEW_SAP_SELLERS A
LEFT OUTER JOIN
	[SONDA].SWIFT_SELLER_BY_SKU B
		ON A.SELLER_CODE = B.CODE_SELLER
LEFT OUTER JOIN
	[SONDA].SWIFT_VIEW_ALL_SKU C
		ON B.CODE_SKU = C.CODE_SKU
