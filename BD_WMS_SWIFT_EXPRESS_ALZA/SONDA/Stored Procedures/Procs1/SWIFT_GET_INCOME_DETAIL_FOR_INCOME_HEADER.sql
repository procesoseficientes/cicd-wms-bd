﻿CREATE PROCEDURE [SONDA].[SWIFT_GET_INCOME_DETAIL_FOR_INCOME_HEADER]
@INCOMEHEADER INT
AS
SELECT A.RECEPTION_DETAIL_TEMP,A.CODE_SKU,A.DESCRIPTION_SKU,A.EXPECTED
FROM [SONDA].SWIFT_TEMP_RECEPTION_DETAIL A
WHERE  A.RECEPTION_HEADER=@INCOMEHEADER
