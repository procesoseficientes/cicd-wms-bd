﻿CREATE PROC [SONDA].[SWIFT_SP_GET_BATCH_COUNT]
@BATCH VARCHAR(50)
AS
SELECT B.SKU, B.CODE_SKU, A.SKU_DESCRIPTION, A.SERIAL_NUMBER FROM [SONDA].SWIFT_INVENTORY A, [SONDA].SWIFT_VIEW_ALL_SKU B
WHERE A.BATCH_ID = @BATCH AND A.SKU = B.SKU 
--AND B.SKU NOT IN( (SELECT COUNT_SKU FROM [SONDA].SWIFT_CYCLE_COUNT_DETAIL WHERE COUNT_STATUS='PENDING'  AND COUNT_SKU IS NOT NULL) )
