﻿CREATE PROC [SONDA].[SWIFT_SP_GET_COUNT_HEADER_BY_ID]
@COUNT_ID VARCHAR(50)
AS
--DECLARE @COUNT_TYPE VARCHAR(50)

SELECT COUNT_TYPE, COUNT_NAME, A.COUNT_ASSIGNED_TO AS NAME_USER,COUNT_STATUS 
FROM [SONDA].SWIFT_CYCLE_COUNT_HEADER A, [SONDA].USERS B
WHERE  A.COUNT_ID = @COUNT_ID

SELECT A.[COUNT], A.LOCATION, A.COUNT_OPERATOR AS NAME_USER, A.COUNT_POSTED, A.COUNT_SKU, A.COUNT_SKU_DESCRIPTION, COUNT_HIT_OR_MISS, A.COUNT_BATCH_ID,
COUNT_SKU_COUNTED, COUNT_SKU_ONHAND, COUNT_STATUS
FROM [SONDA].SWIFT_CYCLE_COUNT_DETAIL AS A
WHERE COUNT_ID = @COUNT_ID
--SET @COUNT_TYPE = (SELECT COUNT_TYPE
--FROM [SONDA].SWIFT_CYCLE_COUNT_HEADER
--WHERE  COUNT_ID = @COUNT_ID)

--EXEC [SONDA].SWIFT_SP_GET_COUNT_HEADER_BY_ID '53'

--SELECT * FROM [SONDA].SWIFT_CYCLE_COUNT_DETAIL WHERE
